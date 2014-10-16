require './lib/app'

run Rack::Cascade.new [DailyTestRoom::API,DailyTestRoom::Web]
