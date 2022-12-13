class User
  def print
    # list = ""
    # @books.each do |book|
    #   list += print_book(book)
    # end
    text = "\xF0\x9F\x91\xA4 #{@name}\t \xF0\x9F\x93\x9A #{@bookNumber}\n#{@link} \n" #" \nAvatar: #{@avatar} \n"
    len = 1020 - text.length()
    text += "#{@detail[0..len]}..."
  end

  def to_utf
    @detail = String.new(@detail, encoding: "UTF-8")
    @name = String.new(@name, encoding: "UTF-8")
    @username = String.new(@username, encoding: "UTF-8")
    @detail = String.new(@detail, encoding: "UTF-8")
  end

  def initialize(name = "", avatar = "", username = "", link = "", books = [], detail = "", bookNumber = 0, website = "")
    @name = name
    @username = username
    @detail = detail
    @avatar = avatar
    @link = link
    @books = books
    @bookNumber = bookNumber
    @website = website
  end

  attr_accessor :name
  attr_accessor :username
  attr_accessor :link
  attr_accessor :books
  attr_accessor :detail
  attr_accessor :bookNumber
  attr_accessor :avatar
  attr_accessor :website

  def as_json(options = {})
    {
      name: @name,
      username: @username,
      detail: @detail,
      avatar: @avatar,
      link: @link,
      books: @books,
      bookNumber: @bookNumber,
      website: @website,
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end
end
