module Sinatra
	module Authorization

	def auth
		@auth ||= Rack::Auth::Basic::Request.new(request.env)
	end

	def unauthorized!(realm="Kasthor's Blog")
		headers 'WWW-Authenticate' => %(Basic realm="#{realm}")
		throw :halt, [401, 'Authorization required']
	end

	def bad_request!
		throw :halt, [400, 'Bad Request']
	end

	def authorized?
		auth.provided? and auth.username
	end

	def authorize ( username, password )
		if ( username == "kasthor" && password="ilkaz" ) then
			true
		else 
			false
		end
	end
	
	def require_admin
		return if authorized?
		unauthorized! unless auth.provided?
		bad_request! unless auth.basic?
		unauthorized! unless authorize(*auth.credentials)
		request.env['REMOTE_USER'] = auth.username
	end

	def admin?
		authorized?
	end
	
	end
end
