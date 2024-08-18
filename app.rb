require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require "sqlite3"

# Создание базы и представление в виде хеша
def get_db
  db = SQLite3::Database.new "_base.db"
  db.results_as_hash = true
  return db
end

# Проверка имени в базе
def is_barber_exists? base, name
  base.execute('SELECT * FROM barbers WHERE barbername=?', [name]).length > 0
end

# Наполение базы с проверкой на уже существующие имя
def seed_db base, names
  names.each do |name|
    if !is_barber_exists? base, name
      base.execute 'INSERT INTO barbers (barbername) VALUES (?)', [name]
    end
  end
end


configure do
  db = get_db
  # Создание базы пользователей и записи в нее данные
  db.execute 'CREATE TABLE IF NOT EXISTS "users" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "username" TEXT,
    "phone"	TEXT,
    "datestamp"	TEXT,
    "barber"	TEXT,
    "color"	TEXT
  )'
  # создание базы барберов
  db.execute 'CREATE TABLE IF NOT EXISTS "barbers" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "barbername" TEXT UNIQUE
  )'

  # добавление данных в базу барберов
  barbers = ["Gus Fring", "Mike Ehrmantraut", "Jesse Pinkman", "Wolter White"]

  # добавление данных в базу барберов
  seed_db db, barbers
end

before do
  db = get_db
  @barbers = db.execute("select * from barbers") 
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
