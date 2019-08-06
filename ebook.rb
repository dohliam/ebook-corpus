#!/usr/bin/env ruby

require 'optparse'

require_relative 'lib/parse_epub.rb'
require_relative 'lib/parse_fb2.rb'
require_relative 'lib/parse_mobi.rb'
require_relative 'lib/tests.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ebook.rb [options] [EPUB]"

  opts.on("-a", "--all", "Extract all contents of epub") { options[:all] = true }
  opts.on("-c", "--cover", "Extract cover image") { options[:cover] = true }
  opts.on("-e", "--tests", "Run test suite") { options[:tests] = true }
  opts.on("-f", "--flatten-dir", "Save all files to the current folder rather than an individual directory") { options[:flatten] = true }
  opts.on("-h", "--html", "Extract raw html") { options[:html] = true }
  opts.on("-i", "--images", "Extract images to a separate folder") { options[:images] = true }
  opts.on("-m", "--metadata", "Print metadata") { options[:metadata] = true }
    opts.on("-T", "--title", "Print title metadata only") { options[:title] = true }
    opts.on("-A", "--author", "Print author metadata only") { options[:author] = true }
    opts.on("-I", "--isbn", "Print ISBN metadata only") { options[:isbn] = true }
    opts.on("-L", "--language", "Print language metadata only") { options[:language] = true }
    opts.on("-P", "--publisher", "Print publisher metadata only") { options[:publisher] = true }
    opts.on("-D", "--description", "Print description metadata only") { options[:description] = true }
  opts.on("-o", "--output-dir DIR", "Save output to specified director")  { |v| options[:output_dir] = v }
  opts.on("-s", "--save", "Save (text or html) to file instead of printing") { options[:save] = true }
  opts.on("-t", "--text", "Extract plain text") { options[:text] = true }
  opts.on("-p", "--pager", "View text in pager") { options[:pager] = true }
  opts.on("-v", "--view", "Open images in viewer") { options[:view] = true }

end.parse!

ebook = ARGV[0]

if !ebook
  abort("  Please supply a filename.")
end

if options[:tests]
  test_suite(ebook)
  exit
end

ext = File.extname(ebook)
if ext == ".epub"
  parse_epub(ebook, options)
elsif ext == ".fb2"
  parse_fb2(ebook, options)
elsif ext == ".mobi" || ext == ".prc" || ext == ".azw"
  parse_mobi(ebook, options)
else
  abort("  File is not a recognized ebook format (.epub/.mobi/.fb2).")
end
