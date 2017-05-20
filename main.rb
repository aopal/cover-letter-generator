require 'combine_pdf'
require 'watir'
require 'json'
require 'date'

# initialize stuff
wkhtml = "wkhtmltopdf.exe"
priv_key = "C:\\keys\\priv"
enc_file = "enc"
rsa = "..\\RSA-Electron\\main.js"

content = `node #{rsa} -d #{priv_key} #{enc_file}`
user = content.split("\n").first
pass = content.split("\n").last.split("\x00").first

# navigate to page
parent = Watir::Browser.new :chrome
parent.goto "waterlooworks.uwaterloo.ca"
parent.link(text: "Students/Staff").click
parent.input(id: "username").send_keys(user)
parent.input(id: "password").send_keys(pass)
parent.input(name: "submit").click
parent.link(text: "Hire Waterloo Co-op").click
parent.input(id: "postingId").send_keys(ARGV[0])
parent.form(id: "searchByPostingNumberForm").link.click

# extract info
position = parent.tr(text: /job title/i).text.split(": ").last
company = parent.tr(text: /organization/i).text.split(": ").last

search_text = parent.tr(text: /job summary/i).text
search_text += "\n\n" + parent.tr(text: /job responsibilities/i).text
search_text += "\n\n" + parent.tr(text: /required skills/i).text
search_text.downcase!

# a bit of processing
position.gsub!(/ engineering/i, "")
company.gsub!(/( corp| inc)/i, "")

# more initialization
base_text = ""
body = ""
json = ""
File.open("base.html").each{ |line| base_text += line}.close
date = Date.today.strftime("%B %e, %Y")

# load mappings and search
File.open("mappings.json").each{ |line| json += line}.close
mappings = JSON.parse(json)
mappings.each do |i|
  exp = Regexp.new(i[1]["matcher"])
  
  if(exp.match(search_text))
    body += i[1]["text"] + "\n\n"
  end
end

body.force_encoding(::Encoding::UTF_8)
base_text.force_encoding(::Encoding::UTF_8)

# perform substitutions
base_text.gsub!("DATE", date)
base_text.gsub!("COMPANY", company)
base_text.gsub!("POSITION", position)
base_text.gsub!("BODY", body)

# generate html/pdf
File.open("temp.html", "w") { |file| file.write(base_text)}

# manually saving through chrome gives the nicest looking pdf :/
`chrome.exe temp.html`
puts "Please enter name of saved pdf: "
cover_letter = STDIN.gets.chomp

# combine with resume/reference letter
pdf = CombinePDF.new
pdf << CombinePDF.load(cover_letter)
pdf << CombinePDF.load("resume-reference.pdf")
pdf.save("#{position} #{company}.pdf".gsub(/[\/\\\<\>\:\"\|\?\*]/,"")) # trim out any illegal characters