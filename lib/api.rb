module DailyTestRoom
  class API < ::Grape::API
    helpers Webhooks
    helpers Token
    version 'v1', using: :header, vendor: 'Elyx0'
    format :json

    resource :hipchat do
      desc 'Describes the add-on and what its capabilities are'
      get 'capabilities' do
        {
          name: 'HipChat Room Bot',
          description: 'Hotbot generates gif, answers back to you and got quizz features, the perfect fun companion',
          key: "hipchat-bot-addon-#{ENV['RACK_ENV']}",
          links: {
            homepage: ENV['BASE_URI'],
            self: "#{ENV['BASE_URI']}/hipchat/capabilities"
          },
          vendor: {
            url: ENV['BASE_URI'],
            name: 'Elyx0'
          },
          capabilities: {
            hipchatApiConsumer: {
              scopes: ENV['HIPCHAT_SCOPES'].split(' '),
              fromName: 'HotBot' #Your bot name when notifications are broadcasted
            },
            configurable: {
              url: "#{ENV['BASE_URI'].gsub('http','https')}/hipchat/configure"
              #Needs to be https + X-frame-options allow hipchat
            },
            installable: {
              allowGlobal: true,
              callbackUrl: "#{ENV['BASE_URI']}/hipchat/install"
            },
            webhook:
            [
              {
                url: "#{ENV['BASE_URI']}/hipchat/quote",
                pattern: "!quote",
                event: 'room_message',
                name: 'quote'
              },
              # {
              #   #Disregard this hook, used in internal
              #   url: "#{ENV['BASE_URI']}/hipchat/traffic",
              #   pattern: "^!traffic (.*)$",
              #   event: 'room_message',
              #   name: 'traffic'
              # },
              {
                url: "#{ENV['BASE_URI']}/hipchat/cleverbot",
                pattern: "(h|H)ot(b|B)ot|robot|bot",
                event: 'room_message',
                name: 'cleverbot'
              },
              {
                url: "#{ENV['BASE_URI']}/hipchat/answer",
                pattern: "^=(.*)$",
                event: 'room_message',
                name: 'answer to quizz'
              },
              {
                url: "#{ENV['BASE_URI']}/hipchat/gif",
                pattern: "^#(.*)$",
                event: 'room_message',
                name: 'gif'
              }
              # ,
              # {
              #   url: "#{ENV['BASE_URI']}/hipchat/greet",
              #   event: 'room_enter',
              #   name: 'room_enter'
              # }
            ] + hookList #Comment if you don't want auto-image meme
          }
        }
      end

      desc 'Receive installation notification'
      post 'install' do
          account = Account.find(params[:oauth_id]) || Account.new
          # Update account
          account._id = params[:oauthId]
          account.hipchat_oauth_id = params[:oauthId]
          account.hipchat_oauth_secret = params[:oauthSecret]
          account.hipchat_capabilities_url = params[:capabilitiesUrl]

          # Verify capabilities
          response = open(URI.parse(params[:capabilitiesUrl]))
          capabilities = JSON.parse(response.read)
          raise UnexpectedApplicationError if capabilities['name'] != 'HipChat'

          # Request an OAuth token
          token_url = capabilities['capabilities']['oauth2Provider']['tokenUrl']
          authorization_url = capabilities['capabilities']['oauth2Provider']['authorizationUrl']

          account.hipchat_token_url = token_url
          account.hipchat_authorization_url = authorization_url

          #Refresh or create account
          refreshToken(account)
          200
      end

      desc 'Receive uninstallation notification'
      params do
        requires :oauth_id, type: String,
          desc: 'OAuth ID value for the installation'
      end
      delete 'install/:oauth_id' do
        if account = Account.find(params[:oauth_id])
          account.destroy
        else
          # Uninstallation will continue anyway, we just can't
          # track it to an account.
          raise NoAccountError
        end
      end
    end

  end
end
