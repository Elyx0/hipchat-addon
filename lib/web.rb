module DailyTestRoom
  class Web < ::Sinatra::Base
    helpers Token
    helpers Webhooks
    register Token
    register Webhooks
    require 'pry'
    get '/' do
      haml :index
    end

    post '/hipchat/traffic' do #
      data = JSON.parse(request.body.read)
      message = data['item']['message']['message']
      message.gsub!(/\s+/,' ')
      params = message.split(' ')
      p params

      method = params[1]
      url = 'http://rw:rw@traffic-01.corp.dailymotion.com/api'
      data = {'method' => method}
      #Set lamp
      if method == "set_lamp"
        if params[2]
          data['lamps'] = params[2]
        end
        if params[3]
          data['state'] = params[3]
        end
        if params[4]
          data['lifetime'] = params[4]
        end
      end
      ## Play sound
      if method == "play_sound"
        if params[2]
          data['sound'] = params[2]
        end
      end

      ## Say speech
      if method == "say_text"
        text = params[3,params.size].join(' ')
        if params[2]
          data['language'] = params[2]
        end
        if text
          data['text'] = text
        end
      end
      response  = RestClient.post url, data.to_json, :content_type => :json, :accept => :json
      if response
      p response
      #r = JSON.parse(response)
      end
    end

    get '/traffic/:method/?:p1?/?:p2?/?:p3' do #
      method = params[:method]
      url = 'http://rw:rw@traffic-01.corp.dailymotion.com/api'
      data = {'method' => method}
      if method == "set_lamp"
        if params[:p1]
          data['lamps'] = params[:p1]
        end
        if params[:p2]
          data['state'] = params[:p2]
        end
        if params[:p3]
          data['lifetime'] = params[:p3]
        end
      end
      if method == "set_lamp"
        if params[:p1]
          data['lamps'] = params[:p1]
        end
        if params[:p2]
          data['state'] = params[:p2]
        end
        if params[:p3]
          data['lifetime'] = params[:p3]
        end
      end
      response  = RestClient.post url, data.to_json, :content_type => :json, :accept => :json
      if response
      p response
      #r = JSON.parse(response)
      end
    end

    get '/support' do
      haml :support
    end

    get '/meme' do
      hookArrays.to_json
    end
    post '/hipchat/meme/:id' do
      data = JSON.parse(request.body.read)
      message = data['item']['message']['message']
      room = data['item']['room']['id']
      account_id = data['oauth_client_id']
      memeHook = hookArrays.select{|x| x[:id] == params[:id].to_i}
      regex = message.match(memeHook.first[:regex])

      memeUrl = Meme.new(params[:id],regex[1],regex[2]).get
      Hipchat.new(account_id,room).send_msg(memeUrl)
    end

    post '/hipchat/cleverbot' do
        data = JSON.parse(request.body.read)
        message = data['item']['message']['message']
        message.gsub!(/\s+/,' ')
        if message[0] == ' '
          message = message[1,message.size]
        end
        if message[message.size-1] == ' '
          message = message[0,message.size-1]
        end
        room = data['item']['room']['id']
        account_id = data['oauth_client_id']
        message.gsub!(/hotbot/i,'') #Removing bot name from string to pass to api
        mention = data['item']['message']['from']['mention_name']
        if !$bot[mention]
          $bot[mention] = CleverBot.new
        end
        resp = $bot[mention].think message
        p "#{message} <<< message"
        p "#{resp} <<< response"
        retries = 0
        while resp == nil and retries < 4 do
          p 'Relaunching bot because empty response'
          $bot[mention] = CleverBot.new
          resp = $bot[mention].think message
          p "#{resp} <<< response"
          retries+=1
        end
        reply = "@#{ data['item']['message']['from']['mention_name'] } : #{resp}"
        Hipchat.new(account_id,room).send_msg(reply)
    end


  post '/hipchat/gif' do
      data = JSON.parse(request.body.read)
      message = data['item']['message']['message']
      room = data['item']['room']['id']
      account_id = data['oauth_client_id']
      message[0] = '' #Removing the '#'
      gif = Giphy.new(message).get
      Hipchat.new(account_id,room).send_msg("<img src='#{gif}'/> (#<b>#{message}</b>)",'html')
  end

    post '/hipchat/quote' do
        data = JSON.parse(request.body.read)
        message = data['item']['message']['message']
        room = data['item']['room']['id']
        account_id = data['oauth_client_id']
        if $waitingAnswer
        else
            Hipchat.new(account_id,room).send_msg(Quote.new.get,'html')
            $waitingAnswer = true
            timeout1 = Thread.new(Time.now + 20) do |end_time|
              while Time.now < end_time
                Thread.pass
              end
              if ($waitingAnswer == true)
                Hipchat.new(account_id,room).send_msg("Hint: #{$answer[0,$answer.size/2]}...")
              end
            end

            timeout2 = Thread.new(Time.now + 30) do |end_time|
              while Time.now < end_time
                Thread.pass
              end
              if ($waitingAnswer == true)
                Hipchat.new(account_id,room).send_msg("Too late ! Answer was: #{$answer}")
              end
              $waitingAnswer = false
              $answer = false
            end
            timeout1.join
            timeout2.join
        end
    end


    post '/hipchat/greet' do
      if request and request.body
        data = JSON.parse(request.body.read)
        message = data['item']['sender']['mention_name']
        room = data['item']['room']['id']
        account_id = data['oauth_client_id']
        #Build your custom greet for users here
      end
    end

    post '/hipchat/answer' do
        data = JSON.parse(request.body.read)
        #binding.pry
        message = data['item']['message']['message']
        room = data['item']['room']['id']
        account_id = data['oauth_client_id']

        if message[1,message.length].downcase == $answer
            $waitingAnswer = false
            reply = "Correct @#{ data['item']['message']['from']['mention_name'] } ! = #{$answer}"
            Hipchat.new(account_id,room).send_msg(reply)
            $waitingAnswer = false
            $answer = false
        end
    end

    get '/hipchat/accounts' do
        Account.all.to_json
    end

    get '/hipchat/configure' do
      headers({ 'X-Frame-Options' => 'ALLOW-FROM hipchat.com' })
      token = ::JWT.decode params['signed_request'], nil, nil
      if account = Account.find(token[0]['iss']) #Oauth_id
        account.hipchat_config_context = token[0]['context'] #Contains first Room ID information.
        #roomId = account.hipchat_config_context["roomId"]
        account.save
      else
        raise NoAccountError
      end
      erb :configure
    end

    get '/thanks' do
      haml :thanks
    end

    error NoAccountError do
      flash[:error] = 'We couldn\'t find your account, please contact support.'
      redirect to('/support')
    end



  end
end