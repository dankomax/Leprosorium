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
	@db.execute 'CREATE TABLE if not exists Posts (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					created_date DATA,
					content TEXT
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

	erb "Your post is: #{u_post}"
end