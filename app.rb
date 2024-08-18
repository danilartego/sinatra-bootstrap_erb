require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require "sqlite3"

def get_db
  db = SQLite3::Database.new "_base.db"
  db.results_as_hash = true
  return db
end


configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS "users" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "username" TEXT,
    "phone"	TEXT,
    "datestamp"	TEXT,
    "barber"	TEXT,
    "color"	TEXT
  )'
  db.execute 'CREATE TABLE IF NOT EXISTS "barbers" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "barbername" TEXT UNIQUE
  )'

  barbers = ["Jessie Pinkman", "Walter White", "Gus Fring", "Mike Ehrmantraut"]

  barbers.each do |barber|
    db.execute 'INSERT OR IGNORE INTO barbers (barbername) VALUES (?)', [barber]
  end
end

get "/" do
  erb "Вы на сайте где можно записаться на стрижку"
end

get "/about" do
  erb :about
end

get "/visit" do
  # @barbers = []
  # db = get_db
  # db.execute("select * from barbers") do |row|
  #   @barbers << row['barbername']
  # end
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

  # Запись данных в текстовый файл
  # File.open("./public/users.txt", "a") do |file|
  #   file.write "#{@username} - #{@phone} - #{@datetime} - #{@barber} - #{@color}\n"
  # end

  # Запись данных в БД
  db = get_db
  db.execute "INSERT INTO users (username, phone, datestamp, barber, color)
  VALUES (?, ?, ?, ?, ?)", [@username, @phone, @datetime, @barber, @color]

  erb "Спасибо, Вы записаны:
  <br> #{@username} | #{@phone} 
  <br>На время: #{@datetime} 
  <br>К Барберу: #{@barber} 
  <br>Цвет: #{@color}"
end

get "/showusers" do

  db = get_db
  @db_users = db.execute("select * from users order by id desc")

  erb :showusers
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
