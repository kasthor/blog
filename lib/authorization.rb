module Sinatra
	module Authorization

		def require_admin
			return if authorized?
			headers 'WWW-Authenticate' => %(Basic realm="Authenticate")
			throw(:halt, [401, "Not Authorized"])
		end

		def authorized?
			@auth ||= Rack::Auth::Basic::Request.new(request.env)
			@auth.provided? and @auth.basic? and @auth.credentials == ['kasthor', 'ilkaz']
		end

	end
end
