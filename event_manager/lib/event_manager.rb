require "csv"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each_with_index do |row, num|
  if num == 3
	name = row[:first_name]
	zipcode = clean_zipcode(row[:zipcode])
	puts "#{name} #{zipcode}"
  end
end

x = 1

if 
  begin
    Float(x)
    x = Float(x)
    catch ArgumentError
  end
else
  puts "hello"
end