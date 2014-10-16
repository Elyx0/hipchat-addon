module DailyTestRoom
    require 'pry'
    class Quote
        def get
            #Open Uri
            url = "http://thesurrealist.co.uk/movie.php?word=*"
            page = Nokogiri::HTML(open(url))
            answer = page.css('#toggle')[0].text.match(/'(.*)'/)[1]
            title = page.css('#toggle')[0].text.split("\n")[0]
            quote = page.css('h1').text
            quote["*"] = answer #Filling answer
            regex = title.match(/(.*)\s\((.*)\)/)
            answer = regex[1]
            date = regex[2]
            $answer = answer.downcase
            "<b>#{quote}</b> - '#{date}'    (To answer: <b>=</b>myAnswer)"
        end
    end
end