class ChromeLog < ApplicationRecord
	serialize :data, ActiveSupportJsonProxy
	def data
	    ActiveSupport::JSON.decode(self[:data])	
	end
end
