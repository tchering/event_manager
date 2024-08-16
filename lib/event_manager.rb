require "csv"
require "google/apis/civicinfo_v2"
require "pry-byebug"
require "erb"

file = "../event_attendees.csv"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
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

file_content = CSV.open(file, headers: true, header_converters: :symbol)
file_content.each do |row|
  id = row[0]
  zipcode = clean_zipcode(row[:zipcode])
  name = row[:first_name]
  legislators = legislator_by_zipcode(zipcode)
  template = File.read("../template.erb")
  erb_template = ERB.new(template)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

# legislator_by_zipcode(4444)
