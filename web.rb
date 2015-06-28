require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'bcrypt'
#require 'omniauth'
#require 'braintree'
#require 'sendgrid'
#require 'twilio'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/payday.db")

class User
    include DataMapper::Resource
    has n, :payments
    property :uid, Serial, :key=> true
    property :g_id, Text, :unique => true
    property :f_id, Text, :unique => true
    property :bt_id, Text, :unique => true
    property :admin, Boolean, :required => true, :default => false
    property :date_joined, DateTime, :default => Time.now
end

class Payment
    include DataMapper::Resource
    belongs_to :user, :key => true
    belongs_to :charity, :key => true
    property :time, DateTime, :default => Time.now
    property :amount, Float
end

class Charity
    include DataMapper::Resource
    has n, :payments
    has n, :images
    property :cid, Serial, :key=> true
    property :name, Text
    property :uname, Text, :required => true, :unique => true
    property :passhash, Text, :length => 60, :required => true
    property :salt, Text, :length => 30, :required => true
    property :location, Text
    property :date_joined, Text, :default => Time.now
    property :description, Text
end

class Image
    include DataMapper::Resource
    belongs_to :charity, :key => true
    property :onum, Integer, :key => true
    property :url, Serial, :required => true
end

DataMapper.finalize.auto_upgrade!


class Payday < Sinatra::Base
    enable :sessions
    #    use Rack::Session::Cookie
    #    use OmniAuth::Strategies::Google

    get '/' do
        erb :index
    end

    get '/create-user' do
        erb :createuser 
    end    

    post '/create-user' do
        @flags = Array.new
        if(params[:g_id]!='')
            if(User.count(:g_id => params[:g_id])==0)
                user = User.create(:g_id => params[:g_id], :bt_id => params[:bt_id])
                user.save
            else
                @flags << 'Google ID already in use. Please try logging in'
            end                
        elsif(params[:f_id]!='')
            if(User.count(:f_id => params[:f_id])==0)
                user = User.create(:f_id => params[:f_id], :bt_id => params[:bt_id])
                user.save
            else
                @flags << 'Facebook ID already in use. Please try logging in'
            end
        end
    end
    
    post '/create' do
        @flags = Array.new
        j = params[:pass]==params[:pass2]
        k = Charity.count(:uname => params[:username])==0
        if(!j)
            @flags << 'Passwords do not match'
        end
        if(!k)
            @flags << 'Username Taken'
        end
        if(j&&k)
            salt = BCrypt::Engine.generate_salt
            hash = BCrypt::Engine.hash_secret params[:pass], salt
            charity = Charity.new(:uname => params[:username], :name => params[:name], :passhash => hash, :salt => salt)
            charity.save
        end
        redirect '/charities'
    end
    
    get '/create' do
        erb :createcharity
    end
    
    post '/auth' do
        @flags = Array.new
        if(Charity.count(:uname => params[:username])==0 && Charity.count)
            @flags << 'Username not registered'
        else
            charity = Charity.get(:uname => params[:username])
            @flags << params[:password]
            @flags << charity[:salt]
#            hash = BCrypt::Engine.hash_secret params[:password], charity[:salt]
#            if(hash==charity[:passhash])
#                @flags << "You are signed in as "+charity[:name]
#            else
#                @flags << "Invalid Username/Password Combination"
#            end
        end
        erb :index
    end
    
    get '/charities' do
        @charities = Charity.all()
        erb :charities
    end
    
    get '/login' do
        @google_login = '<meta name="google-signin-scope" content="profile email">
<meta name="google-signin-client_id" content="832042376397-g9gldd1bhps132no05i80favrvjk59vu.apps.googleusercontent.com">
<script src="https://apis.google.com/js/platform.js" async defer></script>';
        erb :login
    end

    get '/users' do
        @users = User.all()
        erb :users
    end
end