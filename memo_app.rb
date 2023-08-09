# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'securerandom'
require 'pg'

enable :method_override

helpers do
  def h(text)
    CGI.escape_html(text)
  end
end

def symbolize_keys(hash)
  hash.transform_keys(&:to_sym)
end

def search_memo_by_id(id)
  conn = PG.connect(dbname: 'memo')
  search_result = conn.exec_params('SELECT * FROM memo WHERE id = $1', [id])
  raise Sinatra::NotFound if search_result.ntuples.zero?

  conn.finish
  symbolize_keys(search_result.first)
end

get '/' do
  redirect to('/memos')
end

get '/memos' do
  @title = 'メモ一覧'

  conn = PG.connect(dbname: 'memo')
  @memos =
    conn.exec('SELECT * FROM memo ORDER BY added_time ASC') do |result|
      result.map { |row| symbolize_keys(row) }
    end
  conn.finish
  erb :memos
end

post '/memos' do
  id = SecureRandom.uuid
  conn = PG.connect(dbname: 'memo')
  conn.exec_params('INSERT INTO memo VALUES ($1, $2, $3, current_timestamp)', [id, params[:title], params[:content]])
  conn.finish
  redirect to('/memos')
end

get '/memos/new' do
  @title = 'メモ作成'
  erb :new
end

get '/memos/:id' do |id|
  @title = 'メモ詳細'
  @id = id
  @memo = search_memo_by_id(id)
  erb :memo
end

patch '/memos/:id' do |id|
  conn = PG.connect(dbname: 'memo')
  conn.exec_params('UPDATE memo SET title = $1, text = $2 WHERE id = $3', [params[:title], params[:content], id])
  conn.finish
  redirect to('/memos')
end

delete '/memos/:id' do |id|
  conn = PG.connect(dbname: 'memo')
  conn.exec_params('DELETE FROM memo WHERE id = $1', [id])
  conn.finish
  redirect to('/memos')
end

get '/memos/:id/edit' do |id|
  @title = 'メモ編集'
  @id = id
  @memo = search_memo_by_id(id)
  erb :edit
end

not_found do
  'ファイルが存在しません'
end
