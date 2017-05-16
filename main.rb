require 'pdfkit'
require 'combine_pdf'
require 'watir'

wkhtml = "wkhtmltopdf.exe"
priv_key = "C:\\keys\\priv"
enc_file = "enc"
rsa = "..\\RSA-Electron\\main.js"

content = `node #{rsa} -d #{priv_key} #{enc_file}`
user = content.split("\n").first
pass = content.split("\n").last.split("\x00").first

PDFKit.configure do |config|
  config.wkhtmltopdf = wkhtml
  config.default_options = {
    :page_size => 'Letter',
    :print_media_type => true
  }
end

parent = Watir::Browser.new :chrome
parent.goto "waterlooworks.uwaterloo.ca"
parent.link(text: "Students/Staff").click
parent.input(id: "username").send_keys(user)
parent.input(id: "password").send_keys(pass)
parent.input(name: "submit").click
parent.link(text: "Hire Waterloo Co-op").click
parent.input(id: "postingId").send_keys(ARGV[0])
parent.form(id: "searchByPostingNumberForm").link.click

position = parent.tr(text: /job title/i).text
company = parent.tr(text: /organization/i).text

searchText = parent.tr(text: /job summary/i).text
searchText += "\n\n" + parent.tr(text: /job responsibilities/i).text
searchText += "\n\n" + parent.tr(text: /required skills/i).text
searchText.downcase!

puts position, company

sleep 5

puts searchText

sleep(60)

# kit = PDFKit.new(File.new('base.html'))

# file = kit.to_file('base2.pdf')

# fileName = ARGV[0]
# text = ""
# file = File.new(fileName, "r")
# 
# while(line = file.gets)
#   puts line.length()
#   text += line + "\n"
# end