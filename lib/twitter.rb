require 'net/http'
require 'xmlsimple'

module Sinatra
	module Twitter

		def load_twits
			id = Twit.max(:id) || id = 1
			res = Net::HTTP::get_response( URI.parse( "http://api.twitter.com/1/statuses/user_timeline/kasthor.xml?since_id=#{id}" ) )

			xml = XmlSimple.xml_in( res.body ) if res.code == "200"

			xml['status'].each do |m|
				t = Twit.new(m.select{|k,v| k == 'id' or k == 'text' or k == 'created_at'})
				t.set_type
				t.save
			end unless xml.nil? or not xml['status']
		end
	end
end
