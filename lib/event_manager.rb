require "csv"
require "google/apis/civicinfo_v2"
require "pry-byebug"
require "erb"
require "date"

file = "../event_attendees.csv"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_number(phone_number)
  phone_number = phone_number.to_s.gsub(/\D/, "")
  if phone_number.length < 10 || phone_number.length > 11
    "0000000000"
  elsif phone_number.length == 10
    return phone_number
  elsif phone_number.length == 11 && phone_number[0] == "1"
    phone_number.slice(1..-1)
  elsif phone_number.length == 11 && phone_number[0] != "1"
    "0000000000"
  else
    "0000000000"
  end
end

def legislator_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read("../secret.key")
  # p civic_info.method(:representative_info_by_address).parameters
  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ["legislatorUpperBody", "legislatorLowerBody"],
    )
    legislators = legislators.officials

    legislator_names = legislators.map do |legislator|
      legislator.name
    end
    legislator_names.join(",") #using map method returns array of names there we are using join method to convert the array in string of names.
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("../output") unless Dir.exist?("../output")
  file_name = "../output/thanks_#{id}.html"
  File.open(file_name, "w") do |file|
    file.write(form_letter)
  end
end

registration_hours = Hash.new(0)
registration_days = Hash.new(0)

file_content = CSV.open(file, headers: true, header_converters: :symbol)
file_content.each do |row|
  phone_number = clean_number(row[:homephone])
  id = row[0] #we need this to generate file_name in thank you letter.
  zipcode = clean_zipcode(row[:zipcode])
  name = row[:first_name]

  legislators = legislator_by_zipcode(zipcode)
  template = File.read("../template.erb")
  erb_template = ERB.new(template)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
  #!extracting hours from the date in csv file
  registration_date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")
  registration_hour = registration_date.hour
  registration_hours[registration_hour] += 1

  #!extracting days from the date in csv file
  registration_day = registration_date.day
  registration_days[registration_day] += 1
end
#Determining peak registration hours
max_hour, max_count = registration_hours.max_by { |hour, count| count }
puts "Peak registration hour:"
puts "Hour #{max_hour}: #{max_count} registration "

#Determining the day most people registered.
day, count = registration_days.max_by { |day, count| count }
puts "Peak registration day"
puts "#{day}: #{count} people"
