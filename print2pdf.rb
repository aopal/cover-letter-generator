require 'uri'

files = Dir.glob("generated/*.html")
cwd = `cd`.gsub("\n", "\\")

files.each do |file|
    `chrome --enable-logging --headless --disable-gpu --print-to-pdf="#{cwd}#{file.gsub("/", "\\").gsub(".html",".pdf")}" "file:///D:/Git/cover-letter-generator/#{URI.encode(file)}"`
end