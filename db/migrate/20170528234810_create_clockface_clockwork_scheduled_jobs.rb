class CreateClockfaceClockworkScheduledJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :clockface_clockwork_scheduled_jobs do |t|
      t.timestamps

      t.references(
        :clockface_clockwork_event,
        foreign_key: true,
        # Override index name because default is > 63 character postgres maximum
        index: { name: "index_clockwork_scheduled_jobs_on_clockwork_event_id" }
      )
      t.boolean :enabled, default: false
      t.datetime :last_ran_at
      t.integer :period_value, null: false
      t.string :period_units, null: false
      t.integer :day_of_week
      t.integer :hour
      t.integer :minute
      t.string :timezone
      t.string :if_condition
    end
  end
end
