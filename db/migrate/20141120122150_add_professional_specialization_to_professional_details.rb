class AddProfessionalSpecializationToProfessionalDetails < ActiveRecord::Migration
  def change
    add_column :professional_details, :professional_specialization, :string
  end
end
