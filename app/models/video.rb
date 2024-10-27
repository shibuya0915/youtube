require 'httparty'

class Video < ApplicationRecord
  def self.fetch_trending_videos(category_id)
    api_key = "AIzaSyCjsaCaFCBvxrghmyzzm73FdN9MQFzxPlw"
    url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&regionCode=JP&videoCategoryId=#{category_id}&key=#{api_key}"

    Rails.logger.info("Sending request to YouTube API: #{url}") # リクエストURLをログに出力

    response = HTTParty.get(url)

    # レスポンスの内容を確認するためのログ
    Rails.logger.info("Response received from YouTube API: #{response}")

    def thumbnail_url
      # データベースにサムネイルURLが保存されている場合
      # このカラム名をデータベースの実際のカラム名に変更してください
      videos['thumbnails']['high']['url']
    end

    # レスポンスの成功状態を確認し、itemsが存在するかチェック
    if response.success? && response['items'].present?
      videos = response['items']
      videos.each do |video_data|
        Video.create(
          title: video_data['snippet']['title'],
          channel_name: video_data['snippet']['channelTitle'],
          view_count: video_data['statistics']['viewCount'].to_i,
          category: video_data['snippet']['categoryId']
        )
      end
    else
      # エラーメッセージをログに出力
      Rails.logger.error("YouTube APIリクエストに失敗しました: #{response['error'] || response}")
    end
  end

  def self.fetch_vtuber_videos
    api_key = "AIzaSyCjsaCaFCBvxrghmyzzm73FdN9MQFzxPlw"
    vtuber_keywords = ["ホロライブ", "にじさんじ", "ブイスポ"]

    vtuber_keywords.each do |keyword|
      url = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=#{URI.encode(keyword)}&regionCode=JP&key=#{api_key}"

      Rails.logger.info("Sending request to YouTube API for keyword '#{keyword}': #{url}")
      response = HTTParty.get(url)
      Rails.logger.info("Response received from YouTube API: #{response}")

      if response.success? && response['items'].present?
        videos = response['items']
        videos.each do |video_data|
          video = Video.find_or_initialize_by(youtube_id: video_data['id']['videoId'])
          video.update(
            title: video_data['snippet']['title'],
            channel_name: video_data['snippet']['channelTitle'],
            view_count: video_data['statistics'] ? video_data['statistics']['viewCount'].to_i : 0,
            category: "VTuber", # カテゴリを特定できないので「VTuber」に固定
            thumbnail_url: video_data['snippet']['thumbnails']['high']['url']
          )
        end
      else
        Rails.logger.error("YouTube APIリクエストに失敗しました（キーワード: #{keyword}）: #{response['error'] || response}")
      end
    end
  end
end
