module DailyTestRoom
    require 'pry'
    class Giphy
        def initialize(keyword)
            @keyword = URI::encode(keyword)
        end

        def get
            #Open Uri
            url = "http://api.giphy.com/v1/gifs/search?q=#{@keyword}&api_key=dc6zaTOxFJmzC"
            uri = URI.parse(url)
            response = Net::HTTP.get_response(uri)
            a = JSON.parse(response.body)["data"]
            a[rand(a.size)]["images"]["original"]["url"]
        end
    end
end