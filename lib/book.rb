require "HyPDF"
require "./lib/dyck"
require "epubber"
require "fileutils"
require "html2text"

class Book
  def print(user)
    list = Struct.new(:label, :value)
    val = { :value => @chapterList[0]["id"], :optional => user.username }
    option = list.new("\xF0\x9F\x93\x97 #{@name} \n\xF0\x9F\x93\x84#{@chapters}\t\xE2\xAD\x90#{@stars}", val.to_json)
    # pp option
  end

  def print_full
    comp = @completed ? "\xE2\x9C\x85" : "\xE2\x9D\x8E"
    mat = @mature ? "\xE2\x9C\x85" : "\xE2\x9D\x8E"
    tags = ""
    @tags.each do |tag|
      tags += "##{tag} "
    end
    pt1 = "\xF0\x9F\x93\x97 #{@name}\n\xF0\x9F\x91\xA4 #{@author}\t\xE2\xAD\x90 #{@stars}\t\xF0\x9F\x93\x84 #{@chapters}\nCompleted #{comp}\t Mature #{mat}"
    pt3 = "#{tags}\n\n#{@link}"
    msg = ""
    if pt1.length() + pt3.length() + @description.length() < 1024
      msg = pt1 + "\n\n#{@description}\n\n" + pt3
    else
      len = 1024 - (pt1.length() + pt3.length()) - 9
      msg = pt1 + "\n\n#{@description[0..len]} ...\n\n" + pt3
    end
    msg
  end

  def create(op)
    # @name = title
    case op
    when "pdf"
      text = ""
      @chapterList.each do |chapter|
        text += search_chapter(chapter)
      end
      create_PDF(text.force_encoding("UTF-8"))
    when "epub"
      create_epub()
    when "mobi"
      text = ""
      @chapterList.each do |chapter|
        text += search_chapter(chapter)
      end
      create_mobi(text.force_encoding("UTF-8"))
    when "txt"
      text = ""
      @chapterList.each do |chapter|
        text += search_chapter(chapter)
      end
      create_txt(text.force_encoding("UTF-8"))
    end
  end

  def create_PDF(text)
    @hypdf = HyPDF.htmltopdf(
      "<html><body><img src=#{@cover} style='width: 100%; height: auto;'> <br><br><br> #{text}</body></html>",
      landscape: false,
      format: "A4",
      user: "feeeed33-6dfb-4689-bf2b-1e8e1546ffb0",
      password: "qLwR143bqVO",
      header__template: "",
      footer_template: "<div style='font-size:12px; text-align: 'left''>Page <span class='pageNumber'></span> of <span class='totalPages'></span></div>",
      # ... other options ...
    )
    # or write to file
    dir = "./files/#{@name} - #{@author}.pdf"
    File.open(dir, "wb") do |f|
      f.write(@hypdf[:pdf])
    end
    dir
  end

  def create_mobi(text)
    mobi = Dyck::Mobi.new
    # Fill file metadata
    mobi.title = @name
    # mobi.publishing_date = Time.parse('October 18, 1851')
    mobi.author = @author
    mobi.subjects = @tags
    mobi.description = @description

    # Add MOBI6 data
    mobi.mobi6 = Dyck::MobiData.new
    mobi.mobi6.parts << "<html><body><img src=#{@cover}> <br><br><br> #{text}</body></html>"

    # Write to file
    dir = "./files/#{@name} - #{@author}.mobi"
    File.open(dir, "wb") do |f|
      mobi.write(f)
    end
    dir
  end

  def create_txt(html)
    puts "txt"
    dir = "./files/#{@name} - #{@author}.txt"
    text = Html2Text.convert(html.force_encoding("UTF-8"))
    File.open(dir, "w") do |file|
      file.write(text)
    end
    dir
  end

  def create_epub()
    dir = "./files/"
    tempfile = Down.download(@cover)
    # FileUtils.mv(tempfile.path, "./files/#{tempfile.original_filename}")
    cover_image = File.new tempfile.path
    path = Epubber.generate(working_dir: dir) do |b|
      b.title @name
      b.author @author
      b.url @link
      b.cover do |c|
        c.file cover_image
      end
      b.introduction do |i|
        i.content @description.force_encoding("UTF-8")
      end
      @chapterList.each do |chapter|
        b.chapter do |c|
          c.title chapter["title"].force_encoding("UTF-8")
          c.content search_chapter(chapter, false).force_encoding("UTF-8")
        end
      end
    end
    puts "Book generated in #{path}"
    path
  end

  def initialize(name = "", description = "", cover = "", link = "", chapters = 0, author = "", tags = [], chapterList = [], stars = 0, completed = false, mature = false, isPaywalled = false)
    @name = name
    @description = description
    @author = author
    @chapters = chapters
    @cover = cover
    @tags = tags
    @link = link
    @stars = stars
    @completed = completed
    @mature = mature
    @chapterList = chapterList
    @isPaywalled = isPaywalled
  end

  attr_accessor :name
  attr_accessor :description
  attr_accessor :author
  attr_accessor :chapters
  attr_accessor :cover
  attr_accessor :tags
  attr_accessor :link
  attr_accessor :stars
  attr_accessor :completed
  attr_accessor :mature
  attr_accessor :chapterList
  attr_accessor :isPaywalled

  def as_json(options = {})
    {
      name: @name,
      description: @description,
      author: @author,
      chapters: @chapters,
      cover: @cover,
      tags: @tags,
      link: @link,
      stars: @stars,
      completed: @completed,
      mature: @mature,
      chapterList: @chapterList,
      isPaywalled: @isPaywalled,
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
