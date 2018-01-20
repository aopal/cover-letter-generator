require 'watir'
require 'json'
require 'date'
require 'io/console'

def load_from_shortlist(parent)
  parent.link(text: "Hire Waterloo Co-op").click
  parent.link(text: "Shortlist").click
  ids = parent.div(id:"postingsTableDiv").tbody.trs.map(&:id).map{|a| a.scan(/[0-9]+/).first }
  parent.link(text: "Hire Waterloo Co-op").click

  return ids
end

# load content
base_text = File.read("base.html")
json = File.read("mappings.json")
mappings = JSON.parse(json)
date = Date.today.strftime("%B %e, %Y")

# log in to waterlooworks
parent = Watir::Browser.new :chrome
parent.goto "waterlooworks.uwaterloo.ca"
parent.link(text: "Students/Alumni/Staff").click

job_ids = (ARGV.empty?)? load_from_shortlist(parent) : ARGV

job_ids.each do |job_id|
  ### scrape data from waterlooworks
  # navigate to posting
  parent.link(text: "Hire Waterloo Co-op").click
  parent.input(id: "postingId").send_keys(job_id)
  parent.form(id: "searchByPostingNumberForm").link.click

  # extract info/initialize stuff
  position = parent.tr(text: /job title: /i).text.split(": ").last
  company = parent.tr(text: /organization: /i).text.split(": ").last
  letter = base_text.dup
  body = ""

  search_text = parent.tr(text: /job summary/i).text
  search_text += "\n" + parent.tr(text: /job responsibilities/i).text
  search_text += "\n" + parent.tr(text: /required skills/i).text
  search_text.downcase!

  # a bit of processing
  position.gsub!(/ engineering/i, " Engineer")
  company.gsub!(/( corporation| corp| incorporated| inc| limited| ltd| canada)/i, "")
  company.gsub!(".","")

  #### generate cover letter
  # search mappings
  mappings.each do |i|
    exp = Regexp.new(i[1]["matcher"])

    if(exp.match(search_text))
      body += i[1]["text"] + "\n\n"
    end
  end

  # perform substitutions
  letter.gsub!("DATE", date)
  letter.gsub!("COMPANY", company)
  letter.gsub!("POSITION", position)
  letter.gsub!("BODY", body)

   # there's some weirdness with encodings cause I'm doing this on windows
  letter.force_encoding(::Encoding::UTF_8)

  # generate html
  file_name = "#{job_id} #{position} - #{company}.html".gsub(/[\/\\\<\>\:\"\|\?\*]/,"") # trim out any illegal characters
  File.write("./generated/#{file_name}", letter)
end
