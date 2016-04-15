require 'sinatra'
require "sinatra/content_for"
require "sinatra/flash"
require 'json'
require 'pp'
require 'bcrypt'

use Rack::Session::Pool, :expire_after => 2592000

set :bind, '104.236.224.216'
set :port, 80

get '/' do
  erb :index
end

get '/browse' do
  files =  Dir['prod/*.json']
  erb :browse, :locals => {:files => files}
end

get '/user/register' do
  erb :user_register
end

get '/user/login' do
  erb :user_login
end

post '/user/login_attempt' do
  if File.exists?("user/" + params[:username] + ".json") then
    "Hello!"
  else
    "Goodbye!"
  end
  #redirect to('/')
end

post '/user/new' do
  passHash = BCrypt::Password.create(params[:pass])
  userHash = {:username => params[:username], :passHash => passHash}
  userJSON = File.new('user/' + params[:username] + '.json', "w+")
  userJSON.write(userHash.to_json)
  userJSON.close
  flash[:success] = "Success! Try logging in."
  redirect to('/')
end

get '/product/:id' do
  md5 = Digest::MD5.new
  md5 << params['id']
  if File.file?('prod/' + md5.hexdigest + '.json')
    prodFile = File.read('prod/' + md5.hexdigest + '.json')
    prodHash = JSON.parse(prodFile)
    erb :product, :locals => {:prod => prodHash}
  else
    erb :product_not_found 
  end
end
