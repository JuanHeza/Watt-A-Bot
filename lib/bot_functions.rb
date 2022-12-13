# require "./lib/user"
require "down"
require "json"

@msg = Struct.new(:text, :keyboard, :image)

def book_menu(books, user)
  buttons = []
  # pp  user
  books.each do |book|
    button = book.print(user)
    # pp user.username
    buttons << Telegram::Bot::Types::InlineKeyboardButton.new(text: button.label, callback_data: button.value)
  end
  Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
end

def book_id(int)
  # pp "open book"
  book = search_book(int)
  pp book != nil
  if book != nil
	  kb = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [[
															Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x95 PDF", callback_data: { :value => "pdf", :optional => int }.to_json),
															Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x98 EPUB", callback_data: { :value => "epub", :optional => int }.to_json),
														  ], [
															Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x99 MOBI", callback_data: { :value => "mobi", :optional => int }.to_json),
															Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x93 TXT", callback_data: { :value => "txt", :optional => int }.to_json),
														  ]])
	  @book = @msg.new(book.print_full, kb, book.cover)
	  # pp @book
	  # pp message
	  @book
	 end
end

def generate_user_message(res, name)
  puts "searchhing User: #{name}"
  user = User.new()
  user.username = name
  user = search_user(user)
  user.to_utf

  res.text = user.print
  res.keyboard = book_menu(user.books, user)
  res.image = user.avatar

  res
end
