require 'rails_helper'

RSpec.describe SadhakAssetAccessAssociation, type: :model do
  it { should belong_to(:collection) }
end