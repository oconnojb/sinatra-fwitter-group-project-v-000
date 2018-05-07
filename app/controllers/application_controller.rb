require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    redirect '/tweets' if logged_in?
    erb :'users/create_user'
  end

  post "/signup" do
      @user = User.new(:username => params[:username], :email => params[:email], :password => params[:password])

      if @user.save && params[:username].size > 0 && params[:email].size > 0
        session[:user_id] = @user.id
        redirect "/tweets"
      else
        redirect "/signup?failed=yes"
      end
  end

  get '/login' do
    redirect '/tweets' if logged_in?
    erb :'users/login'
  end

  post '/login' do

    if @user = User.find_by(:username => params[:username])

      if !!@user && !!@user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect "/tweets"
      else
        redirect '/login?failed=yes'
      end
    else
      redirect '/login?failed=yes'
    end

  end

  get '/tweets' do
    logged_in? ? (erb :'tweets/tweets') : (redirect '/login?failed=yes')
  end

  post '/tweets' do
    if !params[:content].empty?
      @user = current_user
      @tweet = @user.tweets.build(content: params[:content])
      @tweet.save
      redirect "/tweets/#{@tweet.id}"
    else
      redirect "/tweets/new?content_empty=yes"
    end
  end

  get '/tweets/new' do
    logged_in? ? (erb :'tweets/create_tweet') : (redirect '/login?failed=yes')
  end

  get '/tweets/:id' do
    @tweet = Tweet.find(params[:id]) if logged_in?
    logged_in? ? (erb :'tweets/show_tweet') : (redirect '/login?failed=yes')
  end

  get '/tweets/:id/edit' do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      @tweet.user == current_user ? (erb :'tweets/edit_tweet') : (redirect "/users/#{current_user.slug?cant_edit=yes}")
    else
      redirect '/login?failed=yes'
    end
  end

  post '/tweets/:id/edit' do
    if !params[:content].empty?
      @tweet = Tweet.find(params[:id])
      @tweet.content = params[:content]
      @tweet.save
      redirect "/tweets/#{@tweet.id}"
    else
      redirect "/tweets/#{params[:id]/edit}?content_empty=yes"
    end
  end

  get '/tweets/:id/delete' do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      if @tweet.user == current_user
        @tweet.delete
        erb :'delete'
      end
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end

  helpers do
		def logged_in?
			!!session[:user_id]
		end

		def current_user
			User.find(session[:user_id])
		end
	end

end
