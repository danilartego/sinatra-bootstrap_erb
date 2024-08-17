require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require "sqlite3"

configure do
  @db = SQLite3::Database.new "_base.db"
  @db.execute 'CREATE TABLE IF NOT EXISTS "users" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "usename" TEXT,
    "phone"	TEXT,
    "datestamp"	TEXT,
    "barber"	TEXT,
    "color"	TEXT
  );'
end

get "/" do
  erb "Вы на сайте где можно записаться на стрижку"
end

get "/about" do
  erb :about
end

get "/visit" do
  erb :visit
end

get "/login" do
  erb :login
end

post "/visit" do
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  @color = params[:color]

  hh = {
    username: "Введите имя",
    phone: "Введите телефон",
    datetime: "Введите дату и время",
  }

  # Обработка ошибок
  @error = hh.select { |key, _| params[key] == "" }.values.join(", ")

  return erb :visit if @error != ""

  File.open("./public/users.txt", "a") do |file|
    file.write "#{@username} - #{@phone} - #{@datetime} - #{@barber} - #{@color}\n"
  end

  erb "#{@username} - #{@phone} - #{@datetime} - #{@barber} - #{@color}"
end

post "/" do
  @login = params[:login]
  @pass = params[:pass]

  if @login == ENV["LOGIN"] && @pass == ENV["PASS"]
    @error = "Вы вошли в свою учетную запись"
    erb :visit
  elsif @login == "admin" && @pass == "admin"
    @access_denied = "Хорошая попытка!, но неправильный пароль или логин"
    erb :login
  else
    @access_denied = "Введен неправильный логин или пароль"
    erb :login
  end
end
