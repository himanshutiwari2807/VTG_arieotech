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

    if File.exist?(output_file)
      output_file
    else
      prompt = "Translate the following text into #{target_lang}:\n\n#{text}"
      translated_text = @service.request_ai(prompt)

      @service.save_to_file(output_file, translated_text)
      output_file
    end
  end
end

