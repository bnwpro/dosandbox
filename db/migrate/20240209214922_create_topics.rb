class CreateTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :topics do |t|
      t.string :title
      t.text :preview
      t.text :notes
      t.string :url

      t.timestamps
    end
  end
end
