require "./nancy"

get "/" do
  "Hey there!"
end

Rack::Handler::WEBrick.run Nancy::Application, Port: 9292
