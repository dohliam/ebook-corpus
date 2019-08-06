require 'fileutils'
require 'nokogiri'
require 'tempfile'
require 'zip'

require_relative 'common.rb'

def parse_epub(zipfilename, options)
  file_basename = zipfilename.gsub(/.*\//, "")

  sanitized_basename = file_basename.downcase.gsub(/\.epub/, "").gsub(/['",\.\-]/, "").gsub(/\s+/, "_")
  folder_name = sanitized_basename + "_extracted"

  @title = ""
  @author = ""
  @author_file_as = ""
  @description = ""
  @translator = ""
  @license = ""
  @language = ""
  @publisher = ""
  @isbn = ""

  @tmp = ""

  html = ""
  html_filenames = []


  Zip::File.open(zipfilename) do |zipfile|
    zipfile.each do |entry|
      basename = File.basename(entry.name)
      ext = File.extname(basename).downcase.gsub(/^\./, "")

      # extract all contents if option --all is set
      if options[:all]
        file_structure = File.dirname(entry.name) + "/"
        dir = folder_name + "/epub/" + file_structure.gsub(/^\.\//, "")
        FileUtils.mkdir_p dir
        entry.extract(dir + basename)
      end

      # read xml from content.opf
      if basename == "content.opf" || ext == "opf"
        xml = Nokogiri::XML(entry.get_input_stream.read)
        ns = xml.collect_namespaces
        @title = xml.at('//dc:title', ns).text
        @language = xml.at('//dc:language', ns).text
        @author = xml.at('//dc:creator', ns).text
	if xml.at('//dc:publisher', ns)
          @publisher = xml.at('//dc:publisher', ns).text
	end
        if xml.at('//dc:identifier[@opf:scheme="ISBN"]', ns)
          @isbn = xml.at('//dc:identifier[@opf:scheme="ISBN"]', ns).text
        end
        if xml.at('//dc:description', ns)
          @description = xml.at('//dc:description', ns).text
        end
      end

      # get cover image
      if basename.match(/^cover\.jpe*g$/i)
        if options[:cover]
          if options[:view]
	    tmp = Tempfile.new([ "cover", ".jpg" ])
	    tmp.binmode
	    tmp.write entry.get_input_stream.read
	    tmp.close
#             `xdg-open #{tmp.path}`
            `gwenview #{tmp.path}`
          else
            FileUtils.mkdir_p folder_name + "/img"
            entry.extract(folder_name + "/img/#{basename}")
          end
        end
      end

      # collect raw html
      if ext.match(/^(x*html|xml)$/)
        if options[:save] && options[:html]
          FileUtils.mkdir_p folder_name + "/html"
          entry.extract(folder_name + "/html/#{basename}")
        end
        html << entry.get_input_stream.read
      end

      # extract images
      if ext.match(/^jpg|jpeg|png|bmp|gif|svg$/i)
        if options[:images]
          if options[:view]
            @tmp = "/tmp/#{sanitized_basename}_img/"
            FileUtils.rm_rf(@tmp)
            FileUtils.mkdir_p(@tmp)
            entry.extract(@tmp + basename)
          else
            FileUtils.mkdir_p folder_name + "/img"
            entry.extract(folder_name + "/img/" + basename)
          end
        end
      end
    end
  end

  # open image folder in viewer
  if options[:images]
    if options[:view]
#       `xdg-open #{@tmp}`
      `gwenview #{@tmp}`
      FileUtils.rm_rf(@tmp)
      exit
    end
  end

  # print metadata
  if options[:metadata]
    if options[:save]
      FileUtils.mkdir_p folder_name
      filename = folder_name + "/metadata.txt"
      metadata = "Title: " + @title + "\nAuthor: " + @author + "\nLanguage: " + @language + "\nPublisher: " + @publisher + "\nISBN: " + @isbn + "\nDescription: " + @description + "\n"
      File.open(filename, "w") {|f| f << metadata }
    else
      puts "  Title: ".bold + @title
      puts "  Author: ".bold + @author
      puts "  Language: ".bold + @language
      puts "  Publisher: ".bold + @publisher
      puts "  ISBN: ".bold + @isbn
      puts "  Description: ".bold + @description
    end
  end

  # print individual metadata
  if options[:title]
    puts @title
  end
  if options[:author]
    puts @author
  end
  if options[:language]
    puts @language
  end
  if options[:publisher]
    puts @publisher
  end
  if options[:isbn]
    puts @isbn
  end
  if options[:description]
    puts @description
  end

  # output raw html
  if options[:html]
    if options[:pager]
      if `echo $PAGER`.chomp == ""
        IO.popen("pager", "w") { |f| f.puts html }
        exit
      else
        IO.popen("$PAGER", "w") { |f| f.puts html }
        exit
      end
    elsif !options[:save]
      puts html
    end
  end

  # output text only
  if options[:text]
    html_doc = Nokogiri::HTML(html)
    html_doc.xpath('//style').remove
    if options[:pager]
      if `echo $PAGER`.chomp == ""
        IO.popen("pager", "w") { |f| f.puts html_doc.text }
        exit
      else
        IO.popen("$PAGER", "w") { |f| f.puts html_doc.text }
        exit
      end
    elsif options[:save]
      filename = folder_name + "/txt/" + sanitized_basename + ".txt"
      if options[:flatten]
        filename = sanitized_basename + ".txt"
      elsif options[:output_dir]
        dir = options[:output_dir]
        filename = dir.gsub(/\/*$/, "/") + sanitized_basename + ".txt"
      else
        FileUtils.mkdir_p folder_name + "/txt"
      end
      File.open(filename, "w") {|f| f << html_doc.text }
    else
      puts html_doc.text
    end
  end
end
