require 'json'
require 'csv'
require 'fileutils'
class JsonConverterService
  def initialize(tsv_file_path)
    @file_path = tsv_file_path
  end

  # Function to parse TSV file
  def parse_tsv
    subtitles = []

    CSV.foreach(@file_path, col_sep: "\t", headers: true) do |row|
      subtitles << {
        "startTime" => ms_to_seconds(row["start"].to_i),
        "endTime" => ms_to_seconds(row["end"].to_i),
        "text" => row["text"]
      }
    end

    subtitles
  end

  # Function to convert milliseconds to seconds
  def ms_to_seconds(ms)
    (ms.to_f / 1000).round(2)
  end
end

