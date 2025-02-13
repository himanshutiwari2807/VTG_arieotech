class VideosController < ApplicationController

  def create
    video_url = video_params[:url]

    if video_url.present?
      video_id = get_video_id(video_url)
      # Check if the video URL exists, create it if not
      video = Video.find_or_create_by(url: video_id)

      if video.persisted?
        # Run the Python script if the URL is saved successfully
        folder_path = root_video_folder_path(video_id)

        if Dir.exist?(folder_path)
          json_file_path = File.join(folder_path, 'audio.json')
        else
          transcript_service = TranscriptService.new(folder_path, video_url)
          transcript_service.create_audio_and_transcribe

          tsv_file_path = File.join(folder_path, 'audio.tsv')
          if File.exist?(tsv_file_path)
            json_converter_service = JsonConverterService.new(tsv_file_path)
            output = json_converter_service.parse_tsv

            json_file_path = tsv_file_path.sub(/\.tsv$/, '.json')

            File.write(json_file_path, JSON.pretty_generate(output))
            puts "JSON file saved at: #{json_file_path}"

          else
            render json: { error: 'Error processing Video URL' }, status: :unprocessable_entity
          end
        end
        send_file json_file_path, type: 'application/json', disposition: 'attachment'
      else
        render json: { error: 'Video URL already exists.' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Video URL is required.' }, status: :unprocessable_entity
    end
  end

  def show
    video_url = video_params[:url]
    if video_url
      video_id =
      video = Video.find_by(url: video_id)
      if video
        video_id = video.url.split('=')[-1]
        folder_path = root_video_folder_path(video_id)

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
    else
      render json: { error: 'URL not found.' }, status: :not_found
    end
  end

  def generate_translation
    video_url = params[:url]
    language = params[:language]
    if video_url.present? && language.present?
      video_id = get_video_id(video_url)
      folder_path = root_video_folder_path(video_id)
      json_file_path = File.join(folder_path, 'audio.json')
      if File.exist?(json_file_path)
        translator_service = TranslationService.new(json_file_path, language)
        translated_file = translator_service.translate
        send_file translated_file, type: 'application/json', disposition: 'attachment'
      else
        render json: { error: 'JSON file not available yet.' }, status: :not_found
      end
    else
      render json: { error: 'Video URL and Language is required.' }, status: :unprocessable_entity
    end
  end

  def generate_summary
    video_url = params[:url]

    if video_url.present?
      video_id = get_video_id(video_url)
      folder_path = root_video_folder_path(video_id)
      txt_file_path = File.join(folder_path, 'audio.txt')
      if File.exist?(txt_file_path)
        summary_service = SummaryService.new(txt_file_path)
        summarized_file = summary_service.generate_summary
        send_file summarized_file, type: 'text/html', disposition: 'attachment'
      else
        render json: { error: 'TXT file not available yet.' }, status: :not_found
      end
    else
      render json: { error: 'Video URL and Language is required.' }, status: :unprocessable_entity
    end
  end

  def generate_mcq
    video_url = params[:url]
    if video_url.present?
      video_id = get_video_id(video_url)
      folder_path = root_video_folder_path(video_id)
      json_file_path = File.join(folder_path, 'audio.json')

      if File.exist?(json_file_path)
        mcq_generator = McqService.new(json_file_path)

        summarized_file = mcq_generator.generate_mcq
        send_file summarized_file, type: 'application/json', disposition: 'attachment'
      else
        render json: { error: 'JSON file not available yet.' }, status: :not_found
      end
    else
      render json: { error: 'Video URL and Language is required.' }, status: :unprocessable_entity
    end
  end

  private

  def video_params
    params.require(:video).permit(:url)
  end

  def get_video_id(video_url)
    URI(video_url).query.split("&").find { |param| param.start_with?("v=") }&.split("=")&.last
  end

  def root_video_folder_path(video_id)
    Rails.root.join('public', 'video', video_id)
  end
end