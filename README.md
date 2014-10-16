# HipChat Bot Addon

HipChat room addon using api v2 webhooks in Ruby / Sinatra + Grape

![Screenshot](/../screenshots/example.png?raw=true "Example")

## Getting Started

You need to be the room owner of the hipchat room.

### Setup

#### Local Setup

Install [MongoDB](http://docs.mongodb.org/manual/tutorial/install-mongodb-on-os-x/)

Run mongod

```
mongod --config /usr/local/etc/mongod.conf
```

Install [ngrok](https://ngrok.com/)

Install Bundle
```
bundle install
```

Then run ngrok on your server port (default: 9292)

```
ngrok 9292
```
Hint your can point your browser to point your browser to [http://localhost:4040](http://localhost:4040) to have a better understanding of what are the HEADERS / params passed.



Edit the configuration in app.rb:

```ruby
configure do
    ENV['HIPCHAT_SCOPES'] = "send_notification admin_room"
    if ENV['RACK_ENV'] != 'production'

        #Development settings : ngrok tunnel url + mongodb db
        ENV['BASE_URI'] = 'YOUR NGROK TUNNEL URL'
        ENV['MONGOHQ_URL'] = 'mongodb://127.0.0.1:27017/test' #Local Mongo Database
    end
    MongoMapper.setup({
        ENV['RACK_ENV'] => { 'uri' => ENV['MONGOHQ_URL']}
    }, ENV['RACK_ENV'])
end
```

Run your server
```
rackup -E "development"
```

Access to the root url (/) of your application and click the Install link.

Chat with HotBot !

#### Heroku Setup

Assuming you have the [Heroku Toolbelt](https://toolbelt.heroku.com/) installed

```
heroku apps:create <add-on-name>
heroku config:set RACK_ENV=production
heroku config:set BASE_URI=http://<add-on-name>.herokuapp.com
heroku addons:add mongohq
git add .
git commit -m "Heroku init"
git remote add heroku git@heroku.com:<add-on-name>.git
git push heroku master
```

Access to the root url (/) of your application and click the Install link.

#### Never sleeping Heroku app

Your heroku free app will idle after 1hour, which can kinda be bad
Use [Kaffeine](kaffeine.herokuapp.com) to register your website and prevent idling



#### Documentation

Debugging: [Pry Gem](https://github.com/pry/pry)

Simply add
```
binding.pry
```
Anywhere and access your console to inspect what's going on


Testing your calls with curl [HipChat Auth Api](https://www.hipchat.com/docs/apiv2/auth):

Generate your user token on the website [https://www.hipchat.com/account/api](https://www.hipchat.com/account/api):

Get your room API Id [https://hipchat.com/rooms](https://hipchat.com/rooms) then click on the room name

```
curl -X POST https://api.hipchat.com/v2/room/<YOUR-ROOM-ID>/notification?auth_token=<YOUR-TOKEN> -d '{"message": "TEST"}' -H "Content-Type: application/json
```

[HipChat WebHooks](https://www.hipchat.com/docs/apiv2/webhooks)
[HipChat Atlassian NodeJS implementation](https://bitbucket.org/hipchat/atlassian-connect-express-hipchat)


#### Features

Currently supports:
* ```!quote``` to display a movie quote game
Answers should be made with ```=<yourAnswer>```

* Answers to its name with CleverBot api ```Hi HotBot !```

* #word outputs gif about tagged as word ```#cat```

Feel free to contact me if anything is going wrong.
