# require "rubygems"
# require "mechanize"
# require "./lib/book"
# require "./lib/user"

# def search(input)
#   list = Struct.new(:books, :users)
#   data = list.new([], [])
#   agent = Mechanize.new
#   search = "https://www.wattpad.com/search/" + input

#   puts search

#   page = agent.get(search)
#   bookSearch = page.search(".//ul[@class = 'list-group']")
#   userSearch = page.search(".//div[@id = 'results-people-region']").search(".//ul[@class = 'list-group']")
#   bookList = bookSearch.children
#   userList = userSearch.children
#   bookList.each do |book|
#     section = book.search(".//a[@class = 'on-result']")
#     link = section.attr("href")
#     if link != nil
#       one.link = link.value
#       one.cover = section.search(".//div[@class = 'cover cover-xs pull-left']").children[1].attr("src")
#       box = section.search(".//div[@class = 'content']")
#       one.name = box.search(".//h5[@class = 'story-title-heading']").children[0].text
#       one.description = box.search(".//p").children[0].text
#       one = Book.new()
#       data.books << one
#     end
#   end
#   userList.each do |user|
#     section = user.search(".//a[@class = 'on-result person-result']")
#     link = section.attr("href")
#     if link != nil
#       one.link = link.value
#       one.avatar = section.search(".//div[@class = 'avatar avatar-md pull-left']").children[1].attr("src")
#       box = section.search(".//div[@class = 'content']")
#       one.username = box.search(".//small[@class = 'username']").text
#       one.name = box.search(".//div[@class = 'name-and-badges']").children[1].text
#       one = User.new()
#       data.users << one
#     end
#     # section = book.search(".//[@ = '']")
#   end
#   puts "Users #{data.users.length()}"
#   puts "Books #{data.books.length()}"
#   # PENDIENTE ACTIVAR EL BOTON "SHOW MORE" EN EL AREA DE LIBROS
#   data
# end

# def search_user(user)
#   agent = Mechanize.new
#   search = "https://www.wattpad.com/user/" + user.username.match(/@([^>]+)\Z/)[1]
#   user.link = search
#   page = agent.get(search)
#   userBox = page.search(".//div[@class = 'profile-layout']")
#   if user.avatar == ""
#     user.avatar = userBox.search(".//div[@class = 'component-wrapper']").children[0].attr("src")
#   end
#   if user.name == ""
#     user.name = userBox.search(".//div[@class = 'badges']").children[1].text.delete "\n              "
#   end
#   if user.detail = ""
#     box = userBox.search(".//div[@class = 'description']").children[1].children
#     box.each do |e|
#       user.detail += "#{e.text}\n"
#     end
#   end
#   user.bookNumber = userBox.search(".//div[@data-id = 'profile-works']").children[1].text.to_i
#   # pp user
#   # search

#   section = userBox.search(".//section[@id = 'profile-works']")
#   button = page.forms # your criteria
#   # section.search(".//button[@class = 'btn btn-grey on-showmore']")
#   pp button # button.submit(button)
#   list = section.search(".//div[@id = 'works-item-view']").children

#   pp list.length()
#   list.each do |item|
#     book = Book.new()
#     # name = item.search(".//")
#   end
#   # if user.books.length() != user.bookNumber
#   # end
#   user.to_utf
#   user
# end

# def search_book(book)
# end
