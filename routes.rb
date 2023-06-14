require 'sinatra'
require_relative 'pages.rb'
require_relative 'database.rb'
require 'securerandom'

$sessions = {}

configure do
  set :port, 80
  enable :sessions
end

helpers do
  def showpage(page)
    template, locals = Pages.show(page, params)
    erb template, {:locals => locals}, layout: :layout
  end

  def loggedin?
    id = session[:id] 
    $sessions[id] != nil
  end
end

get '/' do
  redirect '/chat' if loggedin?
  showpage('main')
end

get '/err/:code' do
  showpage('err')
end

get '/chat' do
  redirect '/' unless loggedin?

  params['online'] = $sessions.values

  showpage('chatroom')
end

get '/log' do
  halt 403 unless loggedin?

  File.write('chat.log', '') unless File.exist?('chat.log')
  msgs = File.readlines('chat.log')

  erb :log, :locals => {msgs: msgs}, :layout => nil
end

get '/logoff' do
  id = session[:id]
  $sessions.delete id

  redirect '/'
end

post '/send' do
  msg = params['msg']
  id = session[:id]
  user = $sessions[id]
  time = Time.now.strftime("%H:%M:%S")
  message = "#{user} #{time} #{msg}"

  redirect '/err/4' unless msg.match(/[^<>\/]{3,100}/)
  
  File.open('chat.log', 'a') do |fp|
    fp.puts message
    fp.close
  end

  redirect '/chat'
end

post '/login' do
  user = params['user']
  pass = params['pass']

  redirect '/err/3' unless userexists? user
  redirect '/chat' if loggedin?

  success = login(user, pass)

  if success
    sid = SecureRandom.hex(20)
    session[:id] = sid
    $sessions[sid] = user
    redirect '/chat'
  else
    redirect '/err/1'
  end
end
  

post '/signup' do
  user = params['user']
  pass = params['pass']

  redirect '/err/1' if user.empty? || pass.empty? || !user.match?(/^\w{6,20}$/)

  if userexists? user
    redirect 'err/2'
  else
    createuser(user, pass)
    redirect '/?newusr=1'
  end
end
