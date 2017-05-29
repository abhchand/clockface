class CreateClockfaceClockworkEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :clockface_clockwork_events do |t|
      t.timestamps
      t.string :name, null: false
      t.text :description
      t.string :command, null: false
    end
  end
end
