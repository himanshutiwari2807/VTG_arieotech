require 'json'
require_relative 'azure_open_ai_service'

class TranslationService
  LANGUAGE_MAP = {
    "English" => "en",
    "French" => "fr",
    "Spanish" => "es",
    "German" => "de",
    "Italian" => "it",
    "Chinese" => "zh",
    "Japanese" => "ja",
    "Korean" => "ko",
    "Russian" => "ru"
  }

  def initialize(input_file, language)
    @input_file = input_file
    @language = language
    @service = AzureOpenAiService.new
  end

  def translate
    return puts "File not found: #{@input_file}" unless File.exist?(@input_file)

    text = File.read(@input_file).strip
    target_lang = LANGUAGE_MAP[@language]

    unless target_lang
      puts "Language not supported. Available: #{LANGUAGE_MAP.keys.join(', ')}"
      return
    end

    output_file = File.join(File.dirname(@input_file), "#{target_lang}.json")

    return output_file if File.exist?(output_file)

    prompt = <<~PROMPT
      Translate the following text into #{target_lang}. Provide the output as a valid JSON array without any introduction:

      #{text}
    PROMPT

    translated_text = @service.request_ai(prompt)
    cleaned_json = extract_json(translated_text)

    if cleaned_json
      @service.save_to_file(output_file, cleaned_json)
      output_file
    else
      puts "Invalid JSON response received from AI"
      nil
    end
  end

  private

  def extract_json(response)
    match = response.match(/\[.*\]/m) # Extracts content within JSON array brackets
    return unless match

    json_string = match[0]

    begin
      parsed = JSON.parse(json_string)
      JSON.pretty_generate(parsed) # Ensures valid, formatted JSON
    rescue JSON::ParserError
      nil
    end
  end
end
