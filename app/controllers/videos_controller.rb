class VideosController < ApplicationController

  def create
    url = params[:url]

    # Check if the video URL exists, create it if not
    video = Video.find_or_create_by(url: url)

    if video.persisted?
      # Run the Python script if the URL is saved successfully
      video_id = url.split('=')[-1]  # Assuming the URL is a YouTube URL like https://www.youtube.com/watch?v=mKDeMvFjiQ4
      folder_path = Rails.root.join('public', 'video', video_id)

      unless Dir.exist?(folder_path)
        # Run the Python script to generate the files
        system("python3 #{Rails.root}/scripts/generate_subtitles.py #{url} #{folder_path}")
      end

      render json: { message: 'Video URL saved and processing started.' }, status: :created
    else
      render json: { error: 'Video URL already exists.' }, status: :unprocessable_entity
    end
  end

  def show
    video = Video.find_by(id: params[:id])
    if video
      video_id = video.url.split('=')[-1]
      folder_path = Rails.root.join('public', 'video', video_id)

      # Check if translated file exists
      translated_file = File.join(folder_path, 'translated.json')
      if File.exist?(translated_file)
        send_file translated_file, type: 'application/json', disposition: 'attachment'
      else
        render json: { error: 'Translated file not available yet.' }, status: :not_found
      end
    else
      render json: { error: 'Video not found.' }, status: :not_found
    end
  end
end
