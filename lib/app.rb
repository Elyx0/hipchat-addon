require 'open-uri'
require 'grape'
require 'sinatra'
require 'stripe'
require 'rack-flash'
require 'jwt'
require 'mongo_mapper'
require 'money'
require 'oauth2'
require 'haml'
require 'pry'
require 'nokogiri'
require 'cleverbot-api'
require 'htmlentities'

#MonkeyPatch ZLIB for cleverbot-api to work...
class Net::HTTPResponse
  class Inflater

    def finish
      begin
        @inflate.finish
      rescue Zlib::DataError
        @inflate = Zlib::Inflate.new(-Zlib::MAX_WBITS)
        retry
      end
    end

    def inflate_adapter(dest)
      block = proc do |compressed_chunk|
        begin
          @inflate.inflate(compressed_chunk) do |chunk|
            dest << chunk
          end
        rescue Zlib::DataError
          @inflate = Zlib::Inflate.new(-Zlib::MAX_WBITS)
          retry
        end
      end

      Net::ReadAdapter.new(block)
    end
  end
end

configure do
    ENV['HIPCHAT_SCOPES'] = "send_notification"
    if ENV['RACK_ENV'] != 'production'

        #Development settings : ngrok tunnel url + mongodb db
        ENV['BASE_URI'] = 'http://255a6f30.ngrok.com'
        ENV['MONGOHQ_URL'] = 'mongodb://127.0.0.1:27017/test' #Local Mongo Database
    end
    MongoMapper.setup({
        ENV['RACK_ENV'] => { 'uri' => ENV['MONGOHQ_URL']}
    }, ENV['RACK_ENV'])
end

#GLOBAL VARIABLE DECLARATION FOR !quote game and AI bot declaration
$waitingAnswer = false
$answer = false
$bot = {}


module DailyTestRoom
  class Web < Sinatra::Base
    enable :sessions
    enable :logging

    use ::Rack::Flash

    set :session_secret, ENV['SESSION_SECRET']


  end
end

require './lib/models/account'
require './lib/helpers/token'
require './lib/helpers/traffic'
require './lib/helpers/meme'
require './lib/helpers/giphy'
require './lib/helpers/webhooks'
require './lib/helpers/hipchat'
require './lib/helpers/quote'
require './lib/exceptions'
require './lib/api'
require './lib/web'