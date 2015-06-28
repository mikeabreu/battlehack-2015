require 'rubygems'
require 'sinatra'
require 'data_mapper'
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
    property :uname, Text, :required => true, :unique => true
    property :passhash, Text, :length => 60, :required => true
    property :salt, Text, :length => 30, :required => true
    property :location, Text
    property :date_joined, Text, :default => Time.nowdata
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

    get '/' do
        erb :index
    end

    post '/create-user' do
        @flags = Array.new
        if(params[:g_id])
            if(!Users.count(:g_id => params[:g_id]))
                user = User.create(:g_id => params[:g_id], :bt_id => params[:bt_id])
                user.save
            else
                @flags << 'Google ID already in use. Please try logging in'
            end                
        elsif(params[:f_id])
            if(!Users.count(:f_id => params[:f_id]))
                user = User.create(:f_id => params[:f_id], :bt_id => params[:bt_id])
                user.save
            else
                @flags << 'Facebook ID already in use. Please try logging in'
            end
        end
    end
    
end