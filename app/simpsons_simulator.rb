require 'sinatra'
require 'json'

def parse_gift(raw)
  parsed = JSON.parse(raw)
  parsed['gift']
end

get '/' do
  "Welcome to the Simpson household"
end

get '/homer' do
  "I hope you brought donuts"
end

post '/homer' do
  gift = parse_gift(request.body.read)
  if gift == 'donut'
    [200, 'Woohoo']
  else
    [400, "D'oh"]
  end
end

###################################
# FIXME: Implement Lisa endpoints #
###################################

get '/lisa' do
  "The baritone sax is the best sax"
end

post '/lisa' do
  gift = parse_gift(request.body.read)
  case gift
  when 'book'
    [200, "I love it"]
  when 'saxaphone'
    [200, "I REALLY love it"]
  when 'video_game'
    [400, "I hate it"]
  when 'skateboard'
    [400, "I REALLY hate it"]
  else
    [400, "Not Aware of this"]
  end
end
