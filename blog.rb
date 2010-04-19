require 'haml'
require 'dm-core'
require 'dm-timestamps'
require 'dm-aggregates'
require 'lib/authorization'
require 'lib/twitter'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/articles.db")

class Article
	include DataMapper::Resource

	property :id,		Serial
	property :title,	String
	property :content,	String
	property :created_at,	DateTime
	property :updated_at,	DateTime
	has n,	:tag_references
end

class TagReference
	include DataMapper::Resource

	property :id,		Serial
	belongs_to :article
	belongs_to :tag
end

class Tag
	include DataMapper::Resource

	property :id,		Serial
	property :tag,		String

	has n,	:tag_references
end

class Author
	include DataMapper::Resource

	property :id,		Serial
	property :username,	String
	# TODO: Change this to a "Password" Type
	property :password,	String
	property :FullName,	String
	has n, 	:articles
end

class Twit
	include DataMapper::Resource

	property :id,		Serial
	property :text,		String		
	property :created_at,	DateTime
	property :type,		String

	def set_type
		return self.type = 'link' if self.text =~ /#l\b/
		return self.type = 'quote' if self.text =~ /#q\b/
	end

end

DataMapper.auto_upgrade!

helpers do
	include Sinatra::Authorization
	include Sinatra::Twitter

end

before do
	load_twits

	@twit = Twit.first(:order => :id.desc, :type => 'quote')
	@twitter_content = @twit.text unless @twit.nil?
end

get '/' do	
	articles = Article.all(:limit => 1, :order=> :updated_at.desc)
	@article = articles.pop
	haml :article unless @article.nil?
end


get '/article/add' do
	require_admin
	@article = Article.new()
	
	@article.title = "New Article"	
	@article.content = "<p>Body goes here</p>"
	
	@article.save
	haml :article
end

post '/article/save' do
	require_admin
	@article = Article.get(params[:article][:id])
	@article.update(params[:article])
	@article.save
	redirect 'list'
end

get '/article/list' do
	require_admin
	@articles = Article.all(:order =>[:created_at.desc])	
	haml :list
end

get '/article/:id/delete' do
	require_admin
	article = Article.get(params[:id])
	article.destroy unless article.nil?
	redirect '../list'
end

get '/article/:id' do
	@article = Article.get(params[:id])
	haml :article unless @article.nil?
end
