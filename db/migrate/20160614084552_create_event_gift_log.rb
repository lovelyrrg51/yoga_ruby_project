class CreateEventGiftLog < ActiveRecord::Migration
  def change
    create_table :event_gift_logs do |t|
      t.references :event, index: true
      t.integer :status
      t.text :message
    end
  end
end
