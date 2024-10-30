class AddThumbnailUrlToVideos < ActiveRecord::Migration[7.2]
  def change
    add_column :videos, :thumbnail_url, :string
  end
end
