module DailyTestRoom
    class Hipchat
        include Token

        def initialize(account_id,room)
            @room = room
            @account = Account.find(account_id)
            check_validity
        end

        def check_validity
            expires_at = @account.hipchat_expires_at
            if (expires_at.to_i - Time.now.to_i) < 30
                refreshToken(@account)
            end
        end
        def send_msg(msg,params={})
            message = HTMLEntities.new.decode msg
            endpoint = "https://api.hipchat.com/v2/room/#{@room}/notification?auth_token=#{ @account.hipchat_oauth_token }"
            jdata = JSON.generate({"message" => message,"message_format" => "text"})
            RestClient.post endpoint, jdata, {:content_type => :json}
        end
    end
end