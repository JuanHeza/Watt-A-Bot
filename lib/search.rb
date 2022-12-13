require "net/http"
require "json"
require "./lib/book"

def search_user(input)
  v3 = "https://www.wattpad.com/api/v3/users/#{input.username}?fields=username%2Cavatar%2Cname%2Cdescription%2Cwebsite%2CnumStoriesPublished%2Cdeeplink"
  uri = URI(v3)
  res = Net::HTTP.get(uri)
  data = JSON.parse(res)
  input.avatar = data["avatar"]
  input.name = data["name"]
  input.detail = data["description"]
  input.bookNumber = data["numStoriesPublished"].to_i
  input.link = data["deeplink"]
  input.website = data["website"]

  search_user_books(input)
end

# def serch_by_user_url
# end

def search_user_books(input)
  v4 = "https://www.wattpad.com/v4/users/#{input.username}/stories/published?limit=20"
  uri = URI(v4)
  res = Net::HTTP.get(uri)
  data = JSON.parse(res)
  stories = data["stories"]
  stories.each do |story|
    book = Book.new()
    book.name = story["title"]
    book.description = story["description"]
    book.author = input.username
    book.chapters = story["numParts"].to_i
    book.cover = story["cover"]
    book.tags = story["tags"]
    book.link = story["url"]
    book.stars = story["voteCount"].to_i
    book.completed = story["completed"] == "true"
    book.mature = story["mature"]
    book.chapterList = story["parts"]
    book.isPaywalled = story["isPaywalled"]

    input.books << book
  end
  input
end

def search_book(id)
  v4 = "https://www.wattpad.com/v4/parts/#{id}?fields=id%2Ctitle%2Curl%2CvoteCount%2Cprivate%2Cdeleted%2Cgroup(id%2CnumParts%2Ccover%2Cuser(username%2Cname%2Cavatar%2CauthorMessage%2Curl)%2Ccategories%2Cmature%2Cdeleted%2Clanguage%2Cdescription%2Ctags%2Ccompleted%2CisPaywalled%2Cparts(title%2Curl%2Cid%2Cdeleted%2C)%2C)"
  uri = URI(v4)
  res = Net::HTTP.get(uri)
  story = JSON.parse(res)
  book = Book.new()
  if story.dig("title") != nil
	  book.name = story["title"]
	  book.description = story["group"]["description"]
	  book.author = story["group"]["user"]["name"]
	  book.chapters = story["group"]["numParts"].to_i
	  book.cover = story["group"]["cover"]
	  book.tags = story["group"]["tags"]
	  book.link = story["url"]
	  book.stars = story["voteCount"].to_i
	  book.completed = story["group"]["completed"] == "true"
	  book.mature = story["group"]["mature"]
	  book.chapterList = story["group"]["parts"]
	  book.isPaywalled = story["isPaywalled"]
	  pp book
	  book
  end
end

def serch_by_book_url
end

def search_chapter(chapter, setTitle = true)
  title = ""
  if setTitle
    title = "<h1 style='text-align: center'>#{chapter["title"]}</h1>"
  end
  v2 = "https://www.wattpad.com/apiv2/storytext?id=#{chapter["id"]}"
  uri = URI(v2)
  body = Net::HTTP.get(uri)
  "#{title.force_encoding("UTF-8")}<br><br>#{body.force_encoding("UTF-8")}<br><br><br><br><br>"
end
