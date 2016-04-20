require 'sinatra'
require "sinatra/content_for"
require "sinatra/flash"
require 'json'
require 'pp'
require 'bcrypt'

use Rack::Session::Pool, :expire_after => 2592000

#set :bind, '104.236.224.216'
set :bind, '0.0.0.0'
set :port, 3030

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

get '/user/cart' do
  erb :cart
end

get '/user/cart.json' do
  if not session[:userHash]
    status 401
    redirect to('/user/login')
  else
    session[:userHash]['cart'].to_json
  end
end

post '/user/purchase' do

end

delete '/user/cart' do
  
end

post '/user/login_attempt' do
  if File.exists?("user/" + params[:username] + ".json") then
    userHash = JSON.parse(File.read("user/" + params[:username] + ".json"))
    if(BCrypt::Password.new(userHash['passHash']) == params[:pass])
      userHash.delete("pass")
      session[:userHash] = userHash
      redirect to('/')
    else
      status 401
      flash[:error] = "Username or password was invalid!"
      redirect to('/user/login')
    end
  else
    status 401
    flash[:error] = "Username or password was invalid!"
    redirect to('/user/login')
  end
end

post '/user/new' do
  passHash = BCrypt::Password.create(params[:pass])
  userHash = {:username => params[:username], :passHash => passHash}
  userJSON = File.new('user/' + params[:username] + '.json', "w+")
  userJSON.write(userHash.to_json)
  userJSON.close
  status 201
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
    status 404
    erb :product_not_found 
  end
end

get '/user/test' do
  session[:userHash]
end

post '/cart/add' do
  if not session[:userHash]
    status 401
    "{\"response\": \"login_requested\"}"
  else
    itemID = params['itemID']
    if not File.file?('prod/' + itemID + '.json')
      status 404
      "{\"response:\": \"invalid_product\"}"
    end
    prodFile = File.read('prod/' + itemID + '.json')
    prod = JSON.parse(prodFile)
    if not session[:userHash]['cart']
      session[:userHash]['cart'] = Hash.new
    end
    if not session[:userHash]['cart'][itemID]
      session[:userHash]['cart'][itemID] = Hash.new
      session[:userHash]['cart'][itemID]['qty'] = 1
    else
      session[:userHash]['cart'][itemID]['qty'] += 1
    end
    userFile = File.open('user/' + session[:userHash]['username'] + '.json', 'w')
    userFile.truncate(0)
    userFile.write(session[:userHash].to_json)
    userFile.close()
    "{\"response\": \"Added " + prod['name'] + " to cart!\"}"
  end
end
