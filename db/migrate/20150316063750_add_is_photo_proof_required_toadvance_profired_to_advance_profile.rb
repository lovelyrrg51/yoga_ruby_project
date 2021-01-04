class AddIsPhotoProofRequiredToadvanceProfiredToAdvanceProfile < ActiveRecord::Migration
  def change
    add_column :events, :is_photo_proof_required, :boolean,
    :default => false
  end
end
