module DailyTestRoom
  class Account
    include ::MongoMapper::Document

    # The oauth client to interface with Hipchat
    key :hipchat_oauth_id, String
    key :hipchat_oauth_secret, String
    key :hipchat_oauth_issued_at, String
    key :hipchat_oauth_token, String
    key :hipchat_expires_at, String

    #Needed to refresh token
    key :hipchat_token_url, String
    key :hipchat_authorization_url, String

    # The currently logged in user's ID
    key :hipchat_user_id, String

    # A map of extra context information, such as the user's preferred timezone
    key :hipchat_config_context, Object

    key :hipchat_capabilities_url, String

    timestamps!
  end
end
