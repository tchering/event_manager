require "csv"
require "google/apis/civicinfo_v2"
require "pry-byebug"
require "pp"

file = "../event_attendees.csv"

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
# puts civic_info.methods
# p civic_info.method(:representative_info_by_address).parameters
civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def find_legislators(file, civic_info)
  file_content = CSV.open(file, headers: true, header_converters: :symbol)
  file_content.each do |row|
    # binding.pry
    city = row[:city]
    state = row[:state]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    begin
      legislators = civic_info.representative_info_by_address(
        address: zipcode,
        levels: "country",
        roles: ["legislatorUpperBody", "legislatorLowerBody"],
      )
      legislators = legislators.officials
      # pp legislators
    rescue
      puts "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
      legislators = []
    end
    legislators.each do |legislator|
      # puts "#{name} #{city} #{state} #{zipcode} #{legislator.name} #{legislator.party}"
    end
  end
end

find_legislators(file, civic_info)
