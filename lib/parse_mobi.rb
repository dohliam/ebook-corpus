require 'base64'
require 'fileutils'
require 'nokogiri'
require_relative 'common.rb'

def parse_mobi(ebook, options)
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

  mobi = ebook
  mobi_file = File.basename(mobi)
  file_basename = File.basename(mobi_file, ".mobi")
  sanitized_basename = file_basename.downcase.gsub(/['",\.\-\)\(]/, "").gsub(/\s+/, "_")
  folder_name = sanitized_basename + "_mobi/"

  mobiunpack_dir = "/tmp/mobiunpack/"
  tmp_dir = mobiunpack_dir + sanitized_basename + "/"
  new_mobi = mobiunpack_dir + sanitized_basename + ".mobi"
  FileUtils.mkdir_p tmp_dir
  FileUtils.cp mobi, new_mobi

  script_dir = File.dirname(__FILE__)
  `python vendor/mobiunpack_32.py #{new_mobi} #{tmp_dir}`

  html = tmp_dir + sanitized_basename + ".html"
  ncx = tmp_dir + sanitized_basename + ".ncx"
  opf = tmp_dir + sanitized_basename + ".opf"
  img_dir = tmp_dir + "images/"

  images = Dir.glob(img_dir + "*")

  # extract all contents if option --all is set
  if options[:all]
    dir = folder_name + "mobi/"
    FileUtils.mkdir_p dir
    FileUtils.cp_r(tmp_dir, dir)
  end

  # extract images
  if options[:images]
    if !options[:view]
      FileUtils.cp_r(img_dir, folder_name)
    end
  end

  # open image folder in viewer
  if options[:images]
    if options[:view]
      `gwenview #{img_dir}`
  #     `xdg-open #{tmp}`
    end
  end

  # read xml from content.opf
    xml = Nokogiri::XML(File.read(opf))
    ns = xml.collect_namespaces
    if xml.at('//dc:title', ns)
      title = xml.at('//dc:title', ns).text
    elsif xml.at('//dc:Title', ns)
      title = xml.at('//dc:Title', ns).text
    end
    if xml.at('//dc:language', ns)
      language = xml.at('//dc:language', ns).text
    elsif xml.at('//dc:Language', ns)
      language = xml.at('//dc:Language', ns).text
    end
    if xml.at('//dc:creator', ns)
      author = xml.at('//dc:creator', ns).text
    elsif xml.at('//dc:Creator', ns)
      author = xml.at('//dc:Creator', ns).text
    end
    if xml.at('//dc:publisher', ns)
      publisher = xml.at('//dc:publisher', ns).text
    elsif xml.at('//dc:Publisher', ns)
      publisher = xml.at('//dc:Publisher', ns).text
    end
    if xml.at('//dc:identifier[opf:scheme="ISBN"]', ns)
      isbn = xml.at('//dc:identifier[opf:scheme="ISBN"]', ns).text
    end
    if xml.at('//dc:description', ns)
      description = xml.at('//dc:description', ns).text
    elsif xml.at('//dc:Description', ns)
      description = xml.at('//dc:Description', ns).text
    end

  # print metadata
  if options[:metadata]
    if options[:save]
      FileUtils.mkdir_p folder_name
      filename = folder_name + "/metadata.txt"
      metadata = "Title: " + title + "\nAuthor: " + author + "\nLanguage: " + language + "\nPublisher: " + publisher + "\nISBN: " + isbn + "\nDescription: " + description + "\n"
      File.open(filename, "w") {|f| f << metadata }
    else
      puts "  Title: ".bold + title
      puts "  Author: ".bold + author
      puts "  Language: ".bold + language
      puts "  Publisher: ".bold + publisher
      puts "  ISBN: ".bold + isbn
      puts "  Description: ".bold + description
    end
    exit
  end

  # print individual metadata
  if options[:title]
    puts title
    exit
  end
  if options[:author]
    puts author
    exit
  end
  if options[:language]
    puts language
    exit
  end
  if options[:publisher]
    puts publisher
    exit
  end
  if options[:isbn]
    puts isbn
    exit
  end
  if options[:description]
    puts description
    exit
  end

  # output raw html
  if options[:html]
    if !options[:save]
      puts html
    end
  end

  # output text only
  if options[:text]
    html_doc = Nokogiri::HTML(File.read(html))
    if options[:save]
      filename = folder_name + "/txt/" + sanitized_basename + ".txt"
      if options[:flatten]
        filename = sanitized_basename + ".txt"
      elsif options[:output_dir]
        dir = options[:output_dir]
        filename = dir.gsub(/\/*$/, "/") + sanitized_basename + ".txt"
      else
        FileUtils.mkdir_p folder_name + "/txt"
      end
      txt = `w3m -cols 10000 #{html}`
      File.open(filename, "w") {|f| f << txt }
    else
      puts `w3m #{html}`
    end
  else
    html_doc = Nokogiri::HTML(File.read(html))
    puts `w3m #{html}`
  end

  FileUtils.rm_rf(mobiunpack_dir)

end
