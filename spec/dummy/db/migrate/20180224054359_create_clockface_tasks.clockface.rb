# This migration comes from clockface (originally 20170528230549)
class CreateClockfaceTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :clockface_tasks do |t|
      t.timestamps
      t.string :name, null: false
      t.text :description
      t.string :command, null: false
    end
  end
end
