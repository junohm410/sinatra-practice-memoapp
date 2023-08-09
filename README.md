##  概要
Sinatraを使って作成したメモアプリです。
タイトル付きのメモの作成・編集・削除が可能です。
メモの保存にはPostgreSQLのデータベースを使用しています。

## 事前準備（データベースとテーブルの用意）
このアプリはメモをローカルのデータベースに保存します。
よって、事前に下の手順で`memo`データベースと`memo`テーブルの用意をお願いします。

1. PostgreSQLに接続後、下のように`memo`データベースを作成。
```sql
CREATE DATABASE memo;
```

2. 作成した`memo`データベースに接続し、下のように`memo`テーブルを作成。
```sql
\c memo # memoデータベースに接続
```
```sql
CREATE TABLE memo (
  id CHAR(36) NOT NULL,
  title VARCHAR(100) NOT NULL,
  text VARCHAR(1000) NOT NULL,
  added_time TIMESTAMP NOT NULL,
  PRIMARY KEY (id));
```

## インストール
1. `git clone`を実行してローカルに複製。
```
$ git clone https://github.com/junohm410/sinatra-practice-memoapp.git
```

2. `bundle install`を実行。
```
$ bundle install
```

## 実行
1. `memo_app.rb`を実行。
```
$ bundle exec ruby memo_app.rb
```

2. ブラウザで`http://localhost:4567/memos`を開く。
