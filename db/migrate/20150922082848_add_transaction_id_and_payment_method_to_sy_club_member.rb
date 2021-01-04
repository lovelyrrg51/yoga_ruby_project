class AddTransactionIdAndPaymentMethodToSyClubMember < ActiveRecord::Migration
  def change
    add_column :sy_club_members, :transaction_id, :string
    add_column :sy_club_members, :payment_method, :string
  end
end
