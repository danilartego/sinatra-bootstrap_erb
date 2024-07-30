require "rubygems"
require "sinatra"
require "sinatra/reloader"

get "/" do
  erb :index
end

get "/about" do
  erb :about
end

# get "/visit" do
#   erb :visit
# end

post "/visit" do
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]

  File.open("./public/users.txt", "a") do |file|
    file.write "#{@username} - #{@phone} - #{@datetime} - #{@barber}"
    file.write "\n"
  end
  erb :visit
end

post "/" do
  @login = params[:login]
  @pass = params[:pass]

  if @login == "admin" && @pass == "secret"
    @error = "Вы вошли в свою учетную запись"
    erb :visit
  elsif @login == "admin" && @pass == "admin"
    @access_denied = "Хорошая попытка!, но неправильный пароль или логин"
    erb :index
  else
    @access_denied = "Введен неправильный логин или пароль"
    erb :index
  end
end
