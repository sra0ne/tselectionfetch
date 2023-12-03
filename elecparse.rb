require 'net/http'
require 'json'

# API endpoint please note that this endpoint is not documented and i just pinged it and it actually worked
Api_url = URI('https://results.eci.gov.in/AcResultGenDecNew2023/election-json-S29-live.json')
$party_sums = Hash.new(0)
$party_mapping = {
  'INC' => 'Indian National Congress - INC',
  'BRS' => 'Bharat Rashtra Samithi - BRS',
  'BJP' => 'Bharatiya Janata Party - BJP',
  'AIMIM' => 'All India Majlis-E-Ittehadul Muslimeen - AIMIM',
  'CPI' => 'Communist Party of India - CPI'
}
$constituency_names = { 1 => 'Sirpur', 2 => 'Chennur', 3 => 'Bellampalli', 4 => 'Mancherial', 5 => 'Asifabad',
                        7 => 'Adilabad', 8 => 'Boath', 9 => 'Nirmal', 10 => 'Mudhole', 6 => 'Khanapur', 11 => 'Armur', 12 => 'Bodhan', 13 => 'Jukkal', 14 => 'Banswada', 15 => 'Yellaredy', 16 => 'Kamareddy', 17 => 'Nizamabad Urban', 18 => 'Nizamabad Rural', 19 => 'Balkonda', 20 => 'Koratala', 21 => 'Jagtial', 22 => 'Dharmapuri', 23 => 'Ramagundam', 24 => 'Manthani', 25 => 'Peddapalle', 26 => 'Karimnagar', 27 => 'Choppadandi', 28 => 'Vemulawada', 29 => 'Sircilla', 30 => 'Manakondur', 31 => 'Huzurabad', 32 => 'Husnabad', 33 => 'Siddipet', 34 => 'Medak', 35 => 'Narayankhed', 36 => 'Andole', 37 => 'Narsapur', 38 => 'Zahirabad', 39 => 'Sangareddy', 40 => 'Patancheru', 41 => 'Dubbak', 42 => 'Gajwel', 43 => 'Medchal', 44 => 'Malkajgiri', 45 => 'Quthbullapur', 46 => 'Kukatpally', 47 => 'Uppal', 48 => 'Ibrahimpatnam', 49 => 'Lal Bahadur Nagar', 50 => 'Maheshwaram', 51 => 'Rajendranagar', 52 => 'Serilingampally', 53 => 'Chevella', 54 => 'Pargi', 55 => 'Vikarabad', 56 => 'Tandur', 57 => 'Musheerabad', 58 => 'Malakpet', 59 => 'Amberpet', 60 => 'Khairatabad', 61 => 'Jubilee Hills', 62 => 'Sanatnagar', 63 => 'Nampally', 64 => 'Karwan', 65 => 'Goshamahal', 66 => 'Charminar', 67 => 'Chandrayangutta', 68 => 'Yakutpura', 69 => 'Bahadurpura', 70 => 'Secunderabad', 71 => 'Secunderabad Cantonment', 72 => 'Kodangal', 73 => 'Narayanpet', 74 => 'Mahbubnagar', 75 => 'Jadcherla', 76 => 'Devarkadra', 77 => 'Makthal', 78 => 'Wanaparthy', 79 => 'Gadwal', 80 => 'Alampur', 81 => 'Nagarkurnool', 82 => 'Achampet', 83 => 'Kalwakurthy', 84 => 'Shadnagar', 85 => 'Kollapur', 86 => 'Devarakonda', 87 => 'Nagarjuna Sagar', 88 => 'Miryalaguda', 89 => 'Huzurnagar', 90 => 'Kodada', 91 => 'Suryapet', 92 => 'Nalgonda', 93 => 'Munugode', 94 => 'Bhongir', 95 => 'Nakrekal', 96 => 'Thungathurthi', 97 => 'Alair', 98 => 'Jangaon', 99 => 'Ghanpur Station', 100 => 'Palakurthi', 101 => 'Dornakal', 102 => 'Mahabubabad', 103 => 'Narsapur', 104 => 'Parkal', 105 => 'Warangal West', 106 => 'Warangal East', 107 => 'Waradhanapet', 108 => 'Bhupalpalle', 109 => 'Mulug', 110 => 'Pinapaka', 111 => 'Yellandu', 112 => 'Khammam', 113 => 'Palair', 114 => 'Madhira', 115 => 'Wyra', 116 => 'Sathupalli', 117 => 'Kothagudem', 118 => 'Aswaraopeta', 119 => 'Bhadrachalam' }
def getresponse
  $party_sums = Hash.new(0)
  $s29_chart_data = []
  response = Net::HTTP.get(Api_url)
  puts '>Calling API'
  parsed_data = JSON.parse(response)
  puts ">Fetched response data for Telangana, last checked #{Time.now.strftime('%d-%m-%Y %I:%M:%S %p')}"
  $s29_chart_data = parsed_data['S29']['chartData']
  $s29_chart_data.each do |chart_array|
    cleaned_chart_array = chart_array.reject do |item|
                            item.is_a?(String) && item.empty? || item == 'S29'
                          end.map do |item|
      if item.is_a?(String)
        item.gsub(/#.*$/, '').gsub(
          'BHRS', 'BRS'
        )
      else
        item
      end
    end
    $party_sums[cleaned_chart_array[0]] += 1
  end
  sorted_party_sums = $party_sums.sort_by { |_party, sum| sum }.reverse.to_h
  sorted_party_sums.values.sum
  puts '---Total Party Wise Results---'.ljust(30)
  sorted_party_sums.each do |party, sum|
    replaced_party_name = $party_mapping[party] || party
    puts "#{replaced_party_name.ljust(40)} \t #{sum}"
  end
  puts 'Total'.ljust(49) + $party_sums.values.sum.to_s
end

def constiwise
  puts '---Constituency Wise Results---'.ljust(30)
  $s29_chart_data.each do |c_array|
    $carray = c_array.reject { |item| item.is_a?(String) && item.empty? || item == 'S29' }.map do |item|
      if item.is_a?(Integer)
        "#{item} - #{$constituency_names[item]}"
      elsif item.is_a?(String)
        item.gsub(/#.*$/, '').gsub('BHRS', 'BRS')
      else
        item
      end
    end
    puts "#{$carray[0].ljust(8)} #{$carray[1].ljust(8)} #{$carray[2...].join("\t")}"
  end
end

def selection
  puts 'For more options press '
  puts '1.Constituency Wise Breakup'
  puts '2.Refresh'
  puts '3.Exit'
  $choice = gets.chomp.to_i
  if $choice == 1
    constiwise
    selection
  elsif $choice == 2
    getresponse
    selection
  else
    exit
  end
end

getresponse
selection
