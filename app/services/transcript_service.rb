require 'open3'
require 'fileutils'
require 'uri'

class TranscriptService
  def initialize(folder_path, video_url)
    @output_folder = folder_path
    @video_url = video_url
  end

  def create_audio_and_transcribe
    # Step 1: Download audio using yt-dlp
    audio_file = "#{@output_folder}/audio.mp3"
    download_command = "yt-dlp -x --audio-format mp3 -o #{audio_file} #{@video_url}"
    puts " Downloading audio..."
    system(download_command)

    transcription_command = "whisper #{audio_file} --model base --verbose True --output_dir #{@output_folder}"
    puts "Transcribing..."
    stdout, stderr, status = Open3.capture3(transcription_command)
    puts "Transcribing completed successfully"
  end
end



