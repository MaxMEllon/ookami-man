require 'sinatra'
require 'sinatra-websocket'
if development?
  require 'sinatra/reloader'
  require 'pry'
end

require 'json'
require 'slim'
require 'sass'

set :root, File.dirname(__FILE__)
set :public, File.dirname(__FILE__) << '/public'
# set :server, 'thin'
set :sockets, []

config = {}
users =  {}
@@vote_num = {}
@@vote_counts = {}

ROLES = [
  # :villager,    # 村人
  :wolf,        # 狼
  # :madman,      # 狂人
  # :teller,      # 占い師
  # :knight,      # 騎士
  # :psychic_mage # 霊能術師
].freeze

# @return String: role_name
def deside_role
  while true
    role = ROLES.sample
    @counts ||= {}
    next if role == 'wolf' && @counts[role] > 2    # 狼は３人
    next if role == 'madman' && @counts[role] > 1  # 狂人は１人
    next if role == 'teller' && @counts[role] > 1
    next if role == 'psychic_mage' && @counts[role] > 1
    next if role == 'knight' && @counts[role] > 1
    next if role == 'villager' && @counts.map < 6
    @counts[role] ||= 0
    @counts[role] += 1
    return role
  end
end

def try_kill()

end

def add_vote(user_name, target_user)
  @@vote_num[user_name] ||= ''
  @@vote_num[user_name] = target_user
  nil
end

def max_vote
  map = {}
  @@vote_num.values.each do |value|
    map[value] ||= 0
    map[value] += 1
  end
  max = map.find { |key, value| value == map.values.max }
  max[0]
end

def reset_vote
  vote_num = nil
end

get '/' do
  slim :index
end

get '/noon' do
  unless params[:users].nil?
    config[:users] = params[:users] if params[:users]
    config[:nighttime] = params[:nighttime] if params[:nighttime]
    config[:noontime] = params[:noontime] if params[:noontime]
    users = {}
    config[:users].each_with_index do |user, index|
      users[index] = {role: deside_role, name: user, live: true}
    end
    config[:users] = users
  end

  p @config = config
  slim :noon
end

get '/night' do
  p @config = config
  slim :night
end

get '/users/:user_name' do
  user_name = params[:user_name]
  template = ''
  begin
    config[:users].each do |key, value|
      @info = 'あなたは死にました' unless value[:live]
      template = value[:role] if value[:name] == user_name
    end
  rescue => e
    puts '404'
  end
  @my = user_name
  @users = config[:users]
  slim template
end

get '/websocket' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen { settings.sockets << ws }
      ws.onmessage do |data|
        json = JSON.parse(data)
        p data
        p json
        case json['action']
        when 'change_to_night'
          # 票の集計処理
          max = max_vote
          vote_result = {dead: max, action: 'vote_result'}.to_json
          settings.sockets.each do |socket|
            socket.send(vote_result)
          end
          p vote_result
          reset_vote
          # 狩人反映
          # プレイヤー一覧の送信
        when 'change_to_noon'
          # 占い結果の送信
          # 霊能の結果を送信
          # 狼の噛み結果の送信
          # ゲーム情報の送信
        when 'vote'
          # 投票の加算
          # add_vote json
          add_vote json['user_name'], json['target_user']
        when 'try_kill'
          # 噛み先の指定
        when 'try_defense'
          # 守り先の指定
        when 'select_telling'
          # 占いの実行
        else
          #
        end
      end
      ws.onclose { settings.sockets.delete(ws) }
    end
  end
end

