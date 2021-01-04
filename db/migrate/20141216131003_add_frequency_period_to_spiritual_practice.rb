class AddFrequencyPeriodToSpiritualPractice < ActiveRecord::Migration
  def change
    add_column :spiritual_practices, :frequency_period, :string
  end
end
