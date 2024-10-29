class AddYoutubeIdToVideos < ActiveRecord::Migration[7.2]
  def change
    add_column :videos, :youtube_id, :string
  end
end
