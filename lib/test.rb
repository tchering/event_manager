require "csv"
require "google/apis/civicinfo_v2"

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

# puts civic_info.methods

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

file = "../event_attendees.csv"
puts "EventManager initialized."

contents = CSV.open(
  file,
  headers: true,
  header_converters: :symbol,
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ["legislatorUpperBody", "legislatorLowerBody"]
    )
  puts legislators.class
  puts legislators.methods.sort
  # puts "#{name} #{zipcode} #{legislators}"
  puts Google::Apis::CivicinfoV2::RepresentativeInfoResponse.instance_methods(false).sort
end
