require "csv"
require "google/apis/civicinfo_v2"
require "pry-byebug"

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
    legislator_names.join(",")
    rescue
       'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

file_content = CSV.open(file, headers: true, header_converters: :symbol)
file_content.each do |row|
  zipcode = clean_zipcode(row[:zipcode])
  name = row[:first_name]
  legislators = legislator_by_zipcode(zipcode)
  puts "#{name} #{zipcode} #{legislators}"
end

# legislator_by_zipcode(4444)
