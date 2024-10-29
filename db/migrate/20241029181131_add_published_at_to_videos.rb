class AddPublishedAtToVideos < ActiveRecord::Migration[7.2]
  def change
    add_column :videos, :published_at, :datetime
  end
end
