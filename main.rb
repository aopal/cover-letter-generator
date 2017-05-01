require 'pdfkit'
require 'combine_pdf'
require 'watir'

PDFKit.configure do |config|
  config.wkhtmltopdf = "wkhtmltopdf.exe"
  config.default_options = {
    :page_size => 'Letter',
    :print_media_type => true
  }
end

parent = Watir::Browser.new :phantomjs

kit = PDFKit.new(File.new('base.html'))

file = kit.to_file('base2.pdf')

fileName = ARGV[0]
text = ""
file = File.new(fileName, "r")

while(line = file.gets)
  puts line.length()
  text += line + "\n"
end