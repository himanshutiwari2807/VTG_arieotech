class CreateFileUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :file_uploads do |t|
      t.timestamps
    end
  end
end
