# This migration comes from clockface (originally 20170528234810)
class CreateClockfaceClockworkScheduledJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :clockface_clockwork_scheduled_jobs do |t|
      t.timestamps

      t.references(
        :clockface_task,
        foreign_key: true,
        # Override index name because default is > 63 character postgres maximum
        index: { name: "index_clockwork_scheduled_jobs_on_task_id" }
      )
      t.boolean :enabled, default: false
      t.string :tenant
      t.datetime :last_triggered_at
      t.integer :period_value, null: false
      t.string :period_units, null: false
      t.integer :day_of_week
      t.integer :hour
      t.integer :minute
      t.string :time_zone
      t.string :if_condition
    end
  end
end
