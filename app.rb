require "rubygems"
require "sinatra"
require "sinatra/reloader"

get "/" do
  erb 'Привет, тут можно записатья в Barbershop'
end

get "/about" do
  erb :about
end

get "/visit" do
  erb :visit
end
