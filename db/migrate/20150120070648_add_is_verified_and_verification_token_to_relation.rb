class AddIsVerifiedAndVerificationTokenToRelation < ActiveRecord::Migration
  def change
    add_column :relations, :is_verified, :boolean
    add_column :relations, :verification_code, :string
  end
end
