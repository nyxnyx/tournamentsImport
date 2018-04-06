require 'mechanize'
require 'pp'
require 'firebase'

FIREBASE_URL='https://cioff-f755f.firebaseio.com/'
FIREBASE_SDK_JSON='./cioff-f755f-firebase-adminsdk-6f7ey-c2c286e6b0.json'
TOURNAMENTS="tournaments"

records=[]
record = nil

a = Mechanize.new
page = a.get("http://www.taniecpolski.cioff.pl/index.php/turnieje-w-2017r")

#city
page.search('table.uk-table').search('tbody').search('tr').map do |row|

  #city and atDate
  if row.at('h3')

    record = { city: row.at("h3").text.strip, date: row.at("td:last")&.text.strip }
    records << record

  elsif row.at('h2')

    record[:name] = row.at("h2").text.strip

  elsif row.at("td")&.text == "Adres"

    record[:address] = row.search('td')[1].text.gsub(/, (Ten adres pocztowy.*)(\n*.*\t*)*/, "").strip

  elsif row.at("td")&.text == "Skład sędziowski"
    
    record[:judges] = row.search('td')[1].text.strip

  end
  
end

#pp records

private_json_string = File.open(FIREBASE_SDK_JSON).read
firebase = Firebase::Client.new(FIREBASE_URL, private_json_string)
year = Time.now.strftime("%Y").to_s

path = TOURNAMENTS+"/"+year
path    
firebase.delete(path)
firebase.set(path, records)
pp firebase.get(path).body

