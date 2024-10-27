class VideosController < ApplicationController
  def index
    # params[:category_id]がnilまたは空の場合には、デフォルト値0を設定
    category_id = params[:category_id].to_i
    Video.fetch_trending_videos(category_id)
    @videos = Video.where(category: category_id)

    if category_id.zero?
      @videos = Video.all
    else
      @videos = Video.where(category: category_id)
    end
  end
end
