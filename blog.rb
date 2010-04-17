require 'dm-core'
require 'dm-timestamps'
require 'lib/authorization'

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

DataMapper.auto_upgrade!

before do
	@twitter_content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas at massa quis felis hendrerit ultricies eget nec est. In nulla sapien"
end

helpers do
	include Sinatra::Authorization
end

get '/' do	
	articles = Article.all(:limit => 1, :order=> :updated_at.desc)
	@article = articles.pop
	erb :article unless @article.nil?
end


get '/article/add' do
	require_admin
	@article = Article.new()
	
	@article.title = "New Article"	
	@article.content = "<p>Body goes here</p>"
	
	@article.save
	erb :article
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
	erb :list
end

get '/article/:id/delete' do
	require_admin
	article = Article.get(params[:id])
	article.destroy unless article.nil?
	redirect '../list'
end

get '/article/:id' do
	@article = Article.get(params[:id])
	if @article
		erb :article
	end
end
