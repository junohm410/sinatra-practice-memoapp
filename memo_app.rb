# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'json'
require 'securerandom'

enable :method_override

helpers do
  def h(text)
    CGI.escape_html(text)
  end
end

def create_memos_file
  File.open('memo_data/memos.json', 'w') do |file|
    file.puts '[]'
  end
end

def read_memos_file
  File.open('memo_data/memos.json') do |file|
    JSON.parse(file.read, symbolize_names: true)
  end
end

def create_new_memo(title, text)
  {
    id: SecureRandom.uuid,
    title:,
    text:
  }
end

def update_memo_file(memos)
  File.open('memo_data/memos.json', 'w') do |file|
    JSON.dump(memos, file)
  end
end

get '/' do
  redirect to('/memos')
end

get '/memos' do
  @title = 'メモ一覧'
  create_memos_file unless File.exist?('memo_data/memos.json')
  @memos = read_memos_file
  erb :memos
end

post '/memos' do
  memos = read_memos_file
  new_memo = create_new_memo(params[:title], params[:content])
  memos << new_memo
  update_memo_file(memos)
  redirect to('/memos')
end

get '/memos/new' do
  @title = 'メモ作成'
  erb :new
end

get '/memos/:id' do |id|
  @title = 'メモ詳細'
  @id = id
  target_memo = read_memos_file.find { |memo| memo[:id] == id }
  raise Sinatra::NotFound if target_memo.nil?

  @memo = target_memo
  erb :memo
end

patch '/memos/:id' do |id|
  memos = read_memos_file
  target_memo = memos.find { |memo| memo[:id] == id }
  target_memo[:title] = params[:title]
  target_memo[:text] = params[:content]
  update_memo_file(memos)
  redirect to('/memos')
end

delete '/memos/:id' do |id|
  memos = read_memos_file
  memos = memos.reject { |memo| memo[:id] == id }
  update_memo_file(memos)
  redirect to('/memos')
end

get '/memos/:id/edit' do |id|
  @title = 'メモ編集'
  @id = id
  @memo = read_memos_file.find { |memo| memo[:id] == id }
  erb :edit
end

not_found do
  'ファイルが存在しません'
end
