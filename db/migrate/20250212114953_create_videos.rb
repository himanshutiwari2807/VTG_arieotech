class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos do |t|
      t.string :url

      t.timestamps
    end
    add_index :videos, :url, unique: true
  end
end
