class VideosController < ApplicationController
  def index
    # params[:category_id]がnilまたは空の場合には、デフォルト値0を設定
    category_id = params[:category_id].to_i
    
    if category_id.zero?
      # 全カテゴリの動画を表示
      @videos = Video.all
    elsif category_id == 99
      # VTuber関連動画を取得して表示
      Video.fetch_vtuber_videos
      @videos = Video.where(category: "VTuber")
    else
      # 指定されたカテゴリIDで急上昇動画を取得して表示
      Video.fetch_trending_videos(category_id)
      @videos = Video.where(category: category_id)
    end
  end
end
