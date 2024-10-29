require 'httparty'
require 'cgi'

class Video < ApplicationRecord
  # 急上昇動画を取得して保存するメソッド
  def self.fetch_trending_videos(category_id)
    api_key = ENV['API_KEY']
    url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&regionCode=JP&videoCategoryId=#{category_id}&key=#{api_key}"

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
          thumbnail_url: video_data['snippet']['thumbnails']['high']['url']
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

    vtuber_keywords.each do |keyword|
      url = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=#{CGI.escape(keyword)}&regionCode=JP&key=#{api_key}"

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
            category: "VTuber",
            thumbnail_url: video_data['snippet']['thumbnails']['high']['url']
          )
        end
      else
        Rails.logger.error("YouTube APIリクエストに失敗しました（キーワード: #{keyword}）: #{response['error'] || response}")
      end
    end
  end

  # 全カテゴリとVTuber関連の急上昇動画を定期的に取得するメソッド
  def self.fetch_and_save_all_videos
    category_ids = [1, 10, 17, 20, 25, 23, 27, 28]

    category_ids.each do |category_id|
      fetch_trending_videos(category_id)
    end

    fetch_vtuber_videos
  end
end
