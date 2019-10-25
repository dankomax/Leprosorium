#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def init_db
	@db = SQLite3::Database.new'leprosorium.db'
	@db.results_as_hash = true
end


before do 
	init_db
end


configure do
	init_db

	#creating table Posts
	@db.execute 'CREATE TABLE if not exists Posts (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					created_date DATA,
					content TEXT
				);'

	#creating table Comments
	@db.execute 'CREATE TABLE if not exists Comments (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					created_date DATA,
					content TEXT,
					post_id integer
				);'
end


get '/' do
	@results = @db.execute 'SELECT * 
						   FROM Posts 
						   ORDER by id DESC;'
	erb :index
end


get '/new' do
	erb :new
end


post '/new' do
	u_post = params[:user_post]

	if u_post.length <= 0
		@error = 'You can not submit an empty post'
		return erb :new
	end

	@db.execute 'insert into Posts (content, created_date)
				values (?, datetime());', [u_post]

	redirect to '/'

end


get '/details/:post_id' do
	#getting id from url
	post_id = params[:post_id]

	#getting list of posts
    results = @db.execute 'SELECT * 
						   FROM Posts 
						   WHERE id = ?;', [post_id]
	#saving one post in a variable
	@row = results[0]
	erb :details
end


post '/details/:post_id' do
	#getting id from url
	post_id = params[:post_id]

	#getting variable from form
	u_comment = params[:user_comment]

	@db.execute 'insert into Comments (content, created_date, post_id)
				values (?, datetime(), ?);', [u_comment, post_id]

	redirect to ('/details/' + post_id)
end