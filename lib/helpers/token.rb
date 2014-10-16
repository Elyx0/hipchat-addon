module DailyTestRoom
    module Token
        require 'pry'
          def refreshToken account
                p "<<<<<<<<<<<<<<<<< REFRESHING TOKEN >>>>>>>>>>>>>>>"
                client = OAuth2::Client.new(
                        account.hipchat_oauth_id,
                        account.hipchat_oauth_secret,
                        site: account.hipchat_token_url,
                        scope: ENV['HIPCHAT_SCOPES'],
                        token_url: account.hipchat_token_url,
                        authorization_url: account.hipchat_authorization_url
                      )
                      begin
                        data = client.client_credentials.get_token({scope: ENV['HIPCHAT_SCOPES'] })
                      rescue OAuth2::Error => e
                        if e.code == 401
                          p e
                          p "Error 401"
                          raise TokenError
                        end
                      end
                      token = data.token
                      #binding.pry
                      expires_in = data.expires_in
                      expires_at = data.expires_at
                      #account.hipchat_expires_in = expires_in
                      account.hipchat_expires_at = expires_at
                      account.hipchat_oauth_token = token
                      account.save
          end
    end
end