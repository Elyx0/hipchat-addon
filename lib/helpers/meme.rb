module DailyTestRoom
    require 'pry'
    class Meme
        def initialize(id,text0,text1 = '')
            @id = id
            @text0 = URI::encode(text0)
            @text1 = URI::encode(text1)
        end

        def get
            #Open Uri
            url = "https://api.imgflip.com/caption_image?template_id=#{@id}&username=elyx0&password=hotbot123&text0=#{@text0}&text1=#{@text1}"
            uri = URI.parse(url)
            response = Net::HTTP.get_response(uri)
            JSON.parse(response.body)["data"]["url"]
        end
    end
end