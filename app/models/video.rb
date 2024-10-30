require 'httparty'
require 'cgi'

class Video < ApplicationRecord
  # 急上昇動画を取得して保存するメソッド
  def self.fetch_trending_videos(category_id)
    api_key = ENV['API_KEY']
    url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&regionCode=JP&videoCategoryId=#{category_id}&maxResults=50&key=#{api_key}"

    Rails.logger.info("Sending request to YouTube API: #{url}")
    response = HTTParty.get(url)
    Rails.logger.info("Response received from YouTube API: #{response}")

    if response.success? && response['items'].present?
      videos = response['items']
      videos.each do |video_data|
        video = Video.find_or_initialize_by(youtube_id: video_data['id'])
        video.update(
          title: video_data['snippet']['title'],
          channel_name: video_data['snippet']['channelTitle'],
          view_count: video_data['statistics']['viewCount'].to_i,
          category: video_data['snippet']['categoryId'],
          thumbnail_url: video_data['snippet']['thumbnails']['high']['url'],
          published_at: video_data['snippet']['publishedAt'] # 追加
        )
      end
    else
      Rails.logger.error("YouTube APIリクエストに失敗しました: #{response['error'] || response}")
    end
  end

  # VTuber関連動画を取得して保存するメソッド
  def self.fetch_vtuber_videos
    api_key = ENV['API_KEY']
    vtuber_keywords = ["ホロライブ", "にじさんじ", "ブイスポ"]
    Rails.logger.info("Using API Key: #{api_key}")

    vtuber_keywords.each do |keyword|
      # 1. Search APIで動画IDを取得
      search_url = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=#{CGI.escape(keyword)}&regionCode=JP&maxResults=50&key=#{api_key}"
      Rails.logger.info("Sending request to YouTube Search API for keyword '#{keyword}': #{search_url}")
      search_response = HTTParty.get(search_url)
      Rails.logger.info("Response received from YouTube Search API: #{search_response}")

      if search_response.success? && search_response['items'].present?
        video_ids = search_response['items'].map { |item| item['id']['videoId'] }.compact

        # 2. Videos APIで詳細情報を取得
        videos_url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=#{video_ids.join(',')}&key=#{api_key}"
        Rails.logger.info("Sending request to YouTube Videos API: #{videos_url}")
        videos_response = HTTParty.get(videos_url)
        Rails.logger.info("Response received from YouTube Videos API: #{videos_response}")

        if videos_response.success? && videos_response['items'].present?
          videos_response['items'].each do |video_data|
            video = Video.find_or_initialize_by(youtube_id: video_data['id'])
            video.update(
              title: video_data['snippet']['title'],
              channel_name: video_data['snippet']['channelTitle'],
              view_count: video_data['statistics']['viewCount'].to_i,
              category: "VTuber",
              thumbnail_url: video_data['snippet']['thumbnails']['high']['url'],
              published_at: video_data['snippet']['publishedAt'] # 追加
            )
          end
        else
          Rails.logger.error("YouTube Videos APIリクエストに失敗しました: #{videos_response['error'] || videos_response}")
        end
      else
        Rails.logger.error("YouTube Search APIリクエストに失敗しました（キーワード: #{keyword}）: #{search_response['error'] || search_response}")
      end
    end
  end

  # 全カテゴリとVTuber関連の急上昇動画を定期的に取得するメソッド
  def self.fetch_and_save_all_videos
    category_ids = [1, 10, 17, 20, 25, 23, 27, 28, 99]

    category_ids.each do |category_id|
      fetch_trending_videos(category_id)
    end

    fetch_vtuber_videos
  end

  # 追加: YouTubeの動画URLを生成するメソッド
  def youtube_url
    "https://www.youtube.com/watch?v=#{youtube_id}"
  end
end
