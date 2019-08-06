#!/usr/bin/env ruby

require_relative 'parse_epub.rb'
require_relative 'parse_fb2.rb'
require_relative 'parse_mobi.rb'

def test_module(options, dir, error_log, broken_files, format)
  source_files = Dir.glob(dir.gsub(/\/$/, "") + "/**/*#{format}")
  @total_files = source_files.length

  errors = []

  source_files.sort.each do |f|
    begin
      if format == ".epub"
        parse_epub(f, options)
      elsif format == ".fb2"
        parse_fb2(f, options)
      elsif format == ".mobi"
        parse_mobi(f, options)
      end
    rescue Exception => msg
      error_hash = {}
      error_hash["file"] = f
      broken_files << f.gsub(/#{dir}\/*/, "./")
      error_hash["opts"] = options
      error_hash["msg"] = msg
      errors << error_hash
      puts "  **ERROR** (" + f + ")"
    end
  end

  if errors.length > 0
    File.open(error_log, "a") {|f| f << errors.join("\n"); f << "\n\n" }
  end
end

def test_unit(dir, format)
  if !File.directory?(dir)
    abort("  Please supply a source directory for tests")
  end

  t = Time.new.strftime("%Y%m%d%H%M%S")
  error_log = "test_output/error_log-" + t + "_" + format.gsub(/\./, "") + ".txt"
  File.open(error_log, "a") {|f| f << "Searching for #{format} files in: " + dir + "\n\n" }

  broken_files = []

  options = {}
  options[:title] = true
  test_module(options, dir, error_log, broken_files, format)

  options = {}
  options[:author] = true
  test_module(options, dir, error_log, broken_files, format)

  options = {}
  options[:isbn] = true
  test_module(options, dir, error_log, broken_files, format)

  options = {}
  options[:language] = true
  test_module(options, dir, error_log, broken_files, format)

  options = {}
  options[:publisher] = true
  test_module(options, dir, error_log, broken_files, format)

  options = {}
  options[:description] = true
  test_module(options, dir, error_log, broken_files, format)

  status = "\n\nTotal # of files found: " + @total_files.to_s + "\n"
  if broken_files.length > 0
    status << "\nFiles with issues:\n\n"
    File.open(error_log, "a") {|f| f << status + broken_files.uniq.sort.join("\n") + "\n" }
  else
    status << "\nNo issues found in any files.\n"
    File.open(error_log, "a") {|f| f << status }
  end

end

def test_suite(dir)
  test_unit(dir, ".epub")
  test_unit(dir, ".fb2")
  test_unit(dir, ".mobi")
end
