require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'bcrypt'
require 'braintree'
#require 'sendgrid'
#require 'twilio'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/payday.db")

class User
    include DataMapper::Resource
    has n, :payments
    property :uid, Serial, :key=> true
    property :g_id, Text, :unique => true
    property :f_id, Text, :unique => true
    property :bt_id, Text, :unique => true, :default => "abcd"
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

DataMapper.finalize.auto_migrate!


class Payday < Sinatra::Base
    enable :sessions
    Braintree::Configuration.environment = :sandbox
    Braintree::Configuration.merchant_id = 'yt7jzdw785q2wqb8'
    Braintree::Configuration.public_key = 'qvmdsqc7bfk7mwgd'
    Braintree::Configuration.private_key = '1c3036a079b2542cfce490b3a917c706'

    get '/' do
        erb :index
    end

    get '/client_token' do
        Braintree::ClientToken.generate(
            :customer_id => User.all(:uname => session[:user])[0][:uid]
            )
    end

    get '/create-user' do
        erb :createuser 
    end

    get '/addbt' do
        @flags = Array.new
        #@flags << User.all(:g_id => session[:uname])[0][:bt_id]
        if(User.all(:g_id => session[:uname])[0][:bt_id]=="abcd")
            result = Braintree::Customer.create(
                :first_name => 'Anonymous',
                :last_name => 'Donor') 
            if result.success?
                user = User.all(:g_id => session[:uname])[0]
                user.update(:bt_id => result.customer.id)
                redirect '/users'
            else
                p result.errors
            end
        else
            #            @flags << "Username: " + session[:uname]
        end
        erb :addbt
    end

    post '/checkout' do
        nonce = params[:payment_method_nonce]
        result = Braintree::Transaction.sale(
            :amount => "100.00",
            :payment_method_nonce => nonce
            )
        if result.success?
            redirect '/sorta'
        else
            result.errors.each do |error|
                @flags << error.code
                @flags << error.message
            end
        end
    end

    post '/create-user' do
        @flags = Array.new
        if(params[:g_id]!='')
            if(User.count(:g_id => params[:g_id])==0)
                user = User.create(:g_id => params[:g_id])
                user.save
                session[:uname]=params[:g_id]
                redirect '/addbt'
            else
                session[:uname]=params[:g_id]
                @flags << 'Google ID already in use. Please try logging in'
            end                
        elsif(params[:f_id]!='')
            if(User.count(:f_id => params[:f_id])==0)
                user = User.create(:f_id => params[:f_id])
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
            charity = Charity.all(:uname => params[:username])
            char = charity[0]
            hash = BCrypt::Engine.hash_secret params[:password], char[:salt]
            if(hash==char[:passhash])
                @flags << "You are signed in as "+char[:name]
            else
                @flags << "Invalid Username/Password Combination"
            end
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