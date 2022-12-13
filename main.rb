require "telegram/bot"
require "json"
require "./lib/bot_functions"
require "./lib/user"
require "./lib/search"

token = "1582535548:AAFidqGW7P-6eQcNq0lLVSpHmi62Ne42t7A"
puts "started"
@user = @msg.new()
@book = @msg.new()

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::CallbackQuery
      data = JSON.parse(message.data)
      pp data
      case data["value"]
      when "pdf", "mobi", "epub", "txt"
        pp "printing"
        book = search_book(data["optional"])
        # pp data
        dir = book.create(data["value"])
        bot.api.send_document(chat_id: message.message.chat.id, caption: "\xF0\x9F\x93\x97 #{book.name}\n\xF0\x9F\x91\xA4 #{book.author}", thumb: book.cover, document: Faraday::UploadIO.new(dir, "document"))
      when "back"
        # pp data
        if @user == msg.new()
          @user = generate_user_message(@user, data["optional"])
        end

        bot.api.edit_message_media(disable_web_page_preview: true, chat_id: message.message.chat.id, message_id: message.message.message_id, reply_markup: @user.keyboard, media: { type: "photo", caption: @user.text, media: @user.image }.to_json)
        # bot.api.edit_message_caption(disable_web_page_preview: true, chat_id: message.message.chat.id, message_id: message.message.message_id, reply_markup: @user.keyboard)
      else
        # pp "open book"
        book = search_book(data["value"])
        kb = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [[
                                                              Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x95 PDF", callback_data: { :value => "pdf", :optional => data["value"] }.to_json),
                                                              Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x98 EPUB", callback_data: { :value => "epub", :optional => data["value"] }.to_json),
                                                            ], [
                                                              Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x99 MOBI", callback_data: { :value => "mobi", :optional => data["value"] }.to_json),
                                                              Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x93\x93 TXT", callback_data: { :value => "txt", :optional => data["value"] }.to_json),
                                                            ], [
                                                              Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xF0\x9F\x94\x99 Volver", callback_data: { :value => "back", :optional => data["optional"] }.to_json),
                                                            ]])
        @book = msg.new(book.print_full, kb, book.cover)
        # pp @book
        # pp message
        bot.api.edit_message_media(disable_web_page_preview: true, chat_id: message.message.chat.id, message_id: message.message.message_id, reply_markup: @book.keyboard, media: { type: "photo", caption: @book.text, media: @book.image }.to_json)
        # bot.api.edit_message_caption(disable_web_page_preview: true, chat_id: message.message.chat.id, message_id: message.message.message_id, reply_markup: @book.keyboard)
      end
    when Telegram::Bot::Types::Message
      case message.text[message.entities[0].offset..message.entities[0].length - 1]
      when "/start"
        bot.api.send_message(chat_id: message.chat.id, text: "Iniciando Bot")
      when "/user"
        @user = generate_user_message(@user, message.text[message.entities[0].length + 1...message.text.length])
        # bot.api.send_message(disable_web_page_preview: true, chat_id: message.chat.id, text: @user.text, reply_markup: @user.keyboard)
		if @user == nil
			bot.api.send_message(chat_id: message.chat.id, text: "Usuario no encontrado")
		else
			bot.api.send_photo(chat_id: message.chat.id, photo: @user.image, disable_web_page_preview: true, caption: @user.text, reply_markup: @user.keyboard)
		end
      when "/userurl"
        # https://www.wattpad.com/user/gabywritesbooks
        username = message.text[message.entities[0].length + 1...message.text.length].match("https://www.wattpad.com/user/?([^>]+)")[1]
        @user = generate_user_message(@user, username)
        pp @user.text.length()
		if @user == nil
			bot.api.send_message(chat_id: message.chat.id, text: "Usuario no encontrado")
		else
			bot.api.send_photo(chat_id: message.chat.id, photo: @user.image, disable_web_page_preview: true, caption: @user.text, reply_markup: @user.keyboard)
		end
      when "/book"
        @book = book_id(message.text[message.entities[0].length + 1...message.text.length])
		if @book == nil
			bot.api.send_message(chat_id: message.chat.id, text: "Libro no encontrado")
		else
			bot.api.send_photo(disable_web_page_preview: true, chat_id: message.chat.id, reply_markup: @book.keyboard, caption: @book.text, photo: @book.image)
		end
      when "/bookurl"
        # https://www.wattpad.com/story/136588104-contracorriente-%C2%A9-1-%E2%9C%93
		text = message.text[message.entities[0].length + 1...message.text.length].match("(com\/.*?\-)")[0][4..-2]
		pp text
        @book = book_id(text)
		pp @book == nil
		if @book == nil
			bot.api.send_message(chat_id: message.chat.id, text: "Libro no encontrado")
		else
			bot.api.send_photo(disable_web_page_preview: true, chat_id: message.chat.id, reply_markup: @book.keyboard, caption: @book.text, photo: @book.image)
		end
      when "/help"
        bot.api.send_message(disable_web_page_preview: true, chat_id: message.chat.id, text: "/user : Buscar usando el nombre de usario.\n Se refiere al @ de cada usuario o el mostrado en la url del perfil.\nhttps://www.wattpad.com/user/username\n\n/userurl : Buscar usando el URL al perfil.\n\n/book : Buscar con el id de la primer parte de la historia. \nhttps://www.wattpad.com/story/id-Hhstoria/parte\n\n/bookurl : Buscar usando el URL de la primer parte de la historia.\n\n")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Comando no reconocido")
      end
    end
  end
end
=begin
user - Buscar usando el nombre de usuario.
userurl - Buscar usando el url al perfil.
book - Buscar con el id de la primer parte de la historia.
bookurl - Buscar usando el URL de la primer parte de la historia.
help - Descripcion de comandos.
=end
