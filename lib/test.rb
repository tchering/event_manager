require 'date'

date_string = "2023-10-05 14:35:00"

strp_date = DateTime.strptime(date_string, '%Y-%m-%d %H:%M:%S')
formatted_date = strp_date.strftime('%Y-%m-%d %H:%M')
puts formatted_date
