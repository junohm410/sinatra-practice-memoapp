# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'json'
require 'securerandom'
require 'pg'

enable :method_override

helpers do
  def h(text)
    CGI.escape_html(text)
  end
end

# def create_memos_file
#   File.open('memo_data/memos.json', 'w') do |file|
#     file.puts '[]'
#   end
# end

# def read_memos_file
#   File.open('memo_data/memos.json') do |file|
#     JSON.parse(file.read, symbolize_names: true)
#   end
# end

# def create_new_memo(title, text)
#   {
#     id: SecureRandom.uuid,
#     title:,
#     text:
#   }
# end

# def update_memo_file(memos)
#   File.open('memo_data/memos.json', 'w') do |file|
#     JSON.dump(memos, file)
#   end
# end

def hash_symbolize_keys(hash)
  hash.transform_keys(&:to_sym)
end

get '/' do
  redirect to('/memos')
end

# get '/memos' do
#   @title = 'メモ一覧'
#   create_memos_file unless File.exist?('memo_data/memos.json')
#   @memos = read_memos_file
#   erb :memos
# end

#DB版
get '/memos' do
  @title = 'メモ一覧'

  memos = ''
  conn = PG.connect( dbname: 'memo' )
  conn.exec( "SELECT * FROM memo ORDER BY added_time ASC" ) do |result|
    memos = result.map { |row| row }
  end
  @memos = memos.map { |memo| hash_symbolize_keys(memo) }
  conn.finish
  erb :memos
end

# post '/memos' do
#   memos = read_memos_file
#   new_memo = create_new_memo(params[:title], params[:content])
#   memos << new_memo
#   update_memo_file(memos)
#   redirect to('/memos')
# end

#DB版
post '/memos' do
  id = SecureRandom.uuid
  conn = PG.connect( dbname: 'memo' )
  conn.exec_params( "INSERT INTO memo VALUES ($1, $2, $3, current_timestamp)", [id, params[:title], params[:content]] )
  conn.finish
  redirect to('/memos')
end

get '/memos/new' do
  @title = 'メモ作成'
  erb :new
end

# get '/memos/:id' do |id|
#   @title = 'メモ詳細'
#   @id = id
#   target_memo = read_memos_file.find { |memo| memo[:id] == id }
#   raise Sinatra::NotFound if target_memo.nil?

#   @memo = target_memo
#   erb :memo
# end

# DB版
get '/memos/:id' do |id|
  @title = 'メモ詳細'
  @id = id

  target_memo = ''
  conn = PG.connect( dbname: 'memo' )
  conn.exec_params( "SELECT * FROM memo WHERE id = $1", [id] ) do |result|
    target_memo = result.map { |row| row }
  end
  raise Sinatra::NotFound if target_memo.empty?
  
  target_memo = hash_symbolize_keys(target_memo[0])
  @memo = target_memo
  conn.finish
  erb :memo
end

# patch '/memos/:id' do |id|
#   memos = read_memos_file
#   target_memo = memos.find { |memo| memo[:id] == id }
#   target_memo[:title] = params[:title]
#   target_memo[:text] = params[:content]
#   update_memo_file(memos)
#   redirect to('/memos')
# end

#DB版
patch '/memos/:id' do |id|
  conn = PG.connect( dbname: 'memo' )
  conn.exec_params( "UPDATE memo SET title = $1, text = $2 WHERE id = $3", [params[:title], params[:content], id] )
  conn.finish
  redirect to('/memos')
end

# delete '/memos/:id' do |id|
#   memos = read_memos_file
#   memos.delete_if { |memo| memo[:id] == id }
#   update_memo_file(memos)
#   redirect to('/memos')
# end

#DB版
delete '/memos/:id' do |id|
  conn = PG.connect( dbname: 'memo' )
  conn.exec_params( "DELETE FROM memo WHERE id = $1", [id] )
  conn.finish
  redirect to('/memos')
end

# get '/memos/:id/edit' do |id|
#   @title = 'メモ編集'
#   @id = id
#   @memo = read_memos_file.find { |memo| memo[:id] == id }
#   erb :edit
# end

#DB版
get '/memos/:id/edit' do |id|
  @title = 'メモ編集'
  @id = id

  target_memo = ''
  conn = PG.connect( dbname: 'memo' )
  conn.exec_params( "SELECT * FROM memo WHERE id = $1", [id] ) do |result|
    target_memo = result.map { |row| row }
  end
  raise Sinatra::NotFound if target_memo.empty?
  
  target_memo = hash_symbolize_keys(target_memo[0])
  @memo = target_memo
  conn.finish
  erb :edit
end

not_found do
  'ファイルが存在しません'
end
