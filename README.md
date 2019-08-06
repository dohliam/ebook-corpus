# Ebook Corpus - A parser and extractor for electronic books

Ebook Corpus is a set of tools for parsing and extracting the text of ebooks in various formats, designed for the purpose of creating large multilingual ebook-based text corpora.

Many people have amassed enormous collections of ebooks, often containing millions of lines of text when taken as a whole, so it is always surprising to find that there aren't more tools and libraries available to work with ebooks as a corpus source. It seems that almost all the existing tools are focused on consuming (reading) ebooks, while the remaining few provide the functionality to create ebooks to be thus consumed.

As wonderful as ebooks are, they are often packaged in formats that are incredibly underspecified, or worse, that don't follow the specifications that do exist. A remarkable number of parsing libraries choke on very simple books even in presumably well-supported formats like EPUB3.

There are many ways for an ebook to defy the expectations of the parser -- perhaps it has been written in Unicode and the parser only handles US-ASCII, or the parser expects Unicode and it's written in KOI-8. Maybe the ebook contains an OPF file called `content.opf` in the root directory, or maybe it's in a separate `CONTENT` subfolder -- or called something completely different, like `mytoc.opf` or `目录.opf`.

The Ebook Corpus tools won't solve all of these problems, but they nevertheless provide a number of options to make it easier to work with large, multilingual collections of ebooks as a raw text source.

## Usage

Invoking the program on the command-line is straightforward:

    ./ebook.rb [options] [filename]

Where `[filename]` is the path to the ebook file that you want to work with. If the file has a standard extension (`*.epub`, `*.mobi`, `*.fb2`) it should be detected automatically.

### Options

* `-a` or `--all`: _Extract all contents of epub_
* `-c` or `--cover`: _Extract cover image_
* `-f` or `--flatten-dir`: _Save all files to the current folder rather than an individual directory_
* `-h` or `--html`: _Extract raw html_
* `-i` or `--images`: _Extract images to a separate folder_
* `-m` or `--metadata`: _Print metadata_
  * `-T` or `--title`: _Print title metadata only_
  * `-A` or `--author`: _Print author metadata only_
  * `-I` or `--isbn`: _Print ISBN metadata only_
  * `-L` or `--language`: _Print language metadata only_
  * `-P` or `--publisher`: _Print publisher metadata only_
  * `-D` or `--description`: _Print description metadata only_
* `-o` or `--output-dir DIR`: _Save output to specified director_
* `-s` or `--save`: _Save (text or html) to file instead of printing_
* `-t` or `--text`: _Extract plain text_
* `-T` or `--tests`: _Run test suite_
* `-p` or `--pager`: _View text in pager_
* `-v` or `--view`: _Open images in viewer_

## Supported formats

Format | File extension
------ | --------------
EPUB | `.epub`
[FictionBook](https://en.wikipedia.org/wiki/FictionBook) | `.fb2`
[Mobipocket](http://wiki.mobileread.com/wiki/MOBI) | `.mobi`, `.prc`, `azw`

Support for Mobipocket files is provided via a wrapper for the python script [mobiunpack.py](http://www.mobileread.com/forums/showthread.php?t=61986) by [@kevinhendricks](https://github.com/kevinhendricks) (released as [GPL3](https://github.com/kevinhendricks/KindleUnpack/blob/master/COPYING.txt)). If you know of a drop-in replacement library in Ruby for parsing MOBI files (or are interested in writing one), please let me know!

Note that only ebooks without DRM will work with this script.

## Contributing

PRs, suggestions, examples of ebooks that don't parse properly, and other contributions are always welcome! Providing support for additional formats or opening issues for bugs are examples of ways to help.

MOBI support has only been tested against files with the `.mobi` extension. It should in theory also work for other extensions. If you have access to ebooks with a `.prc` or `.azw` file extension and can confirm this, that would be appreciated!

## To do

Code is pretty ad hoc at the moment and in general need of a cleanup. Different formats are handled separately but should probably be merged.

Other things:

* Default to outputting raw text
* Add more specific metadata support for mobi and fb2
* Guess alternately-named `content.opf` files
* Figure out cross-platform way of opening images in default viewer (current kludge is hard-coded to open image folder in Gwenview since `xdg-open` doesn't play nicely with cleaning up temporary files after viewing)

## License

MIT.
