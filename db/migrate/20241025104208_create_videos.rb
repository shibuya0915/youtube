class CreateVideos < ActiveRecord::Migration[7.2]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :channel_name
      t.integer :view_count
      t.string :category

      t.timestamps
    end
  end
end
