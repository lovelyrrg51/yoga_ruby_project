class Chrome::Api::V1::DigitalAssetPolicy < Chrome::Api::V1::ApplicationPolicy
	attr_reader :user, :digital_asset


	def initialize(user, digital_asset)
		@user = user
		@digital_asset = digital_asset
	end

end