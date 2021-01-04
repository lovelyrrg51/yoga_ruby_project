module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    
    geocoded_by :ip   # can also be an IP address
		after_validation :geocode # auto-fetch coordinates

		has_one :actor, class_name: "User", foreign_key: 'id', primary_key: :whodunnit

  end
end
