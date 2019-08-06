require 'base64'
require 'fileutils'
require 'nokogiri'
require_relative 'common.rb'

def extract_text(xml)
  xml.xpath('//style').remove
  xml.xpath('//stylesheet').remove
  xml.xpath('//description').remove
  xml.xpath('//binary').remove
  xml
end

def parse_fb2(ebook, options)
  title = ""
  last_name = ""
  first_name = ""
  author = ""
  author_file_as = ""
  description = ""
  translator = ""
  trans_first_name = ""
  trans_last_name = ""
  license = ""
  language = ""
  publisher = ""
  isbn = ""
  date = ""

  fbook = File.read(ebook)

  xml = Nokogiri::HTML(fbook)

  title = xml.xpath('//book-title').text
  last_name = xml.xpath('//author//last-name').text
  first_name = xml.xpath('//author//first-name').text
  author = last_name + ", " + first_name
  author_file_as = ""
  description = xml.xpath('//annotation//p').text
  trans_first_name = xml.xpath('//translator//first-name').text
  trans_last_name = xml.xpath('//translator//last-name').text
  if trans_first_name != ""
    translator = trans_last_name + ", " + trans_first_name
  end
  license = ""
  language = xml.xpath('//lang').text
  publisher = xml.xpath('//publisher').text
  isbn = xml.xpath('//isbn').text
  date = xml.xpath('//title-info//date').text

  if options[:metadata]
    puts "  Title: ".bold + title
    puts "  Author: ".bold + author
    puts "  Translator: ".bold + translator
    puts "  Date: ".bold + date
    puts "  Language: ".bold + language
    puts "  Publisher: ".bold + publisher
    puts "  ISBN: ".bold + isbn
    puts "  Description: ".bold + description
  end

  if options[:text]
    book_text = extract_text(xml)
    puts book_text.text
  end

  if options[:cover]
    img = xml.xpath('//binary').text
    if img == ""
      abort("  No cover image found.")
    end
    decode = Base64.decode64(img)
    if options[:view]
      IO.popen('display', 'r+') do |pipe|
        pipe.puts(decode)
        pipe.close_write
      end
    else
      filename = xml.xpath('//binary').attr("id").text
      File.open(filename, "wb") {|f| f << decode }
    end
  else
    book_text = extract_text(xml)
    puts book_text.text
  end
end
