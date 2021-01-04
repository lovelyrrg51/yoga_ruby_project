class CreateDelayedJobProgresses < ActiveRecord::Migration
  def change
    create_table :delayed_job_progresses do |t|
      t.text :progress_stage, required: true, default: 'Queued'
      t.float :progress_current, required: true, default: 0.0
      t.float :progress_max, required: true, default: 0.0
      t.text :result
      t.text :last_error
      t.datetime :deleted_at
      t.integer :status, default: 0
      t.references :user, index: true
      t.references :delayed_job_progressable, :polymorphic => true

      t.timestamps
    end

    add_index :delayed_job_progresses, :deleted_at
  end
end
