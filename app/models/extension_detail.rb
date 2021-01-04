class ExtensionDetail < ApplicationRecord

    # Association
    belongs_to :sadhak_profile

    # Serialize
    serialize :downloaded_assets, Array

end
