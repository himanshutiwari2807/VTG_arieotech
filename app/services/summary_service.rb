require_relative 'azure_open_ai_service'

class SummaryService
  def initialize(input_file)
    @input_file = input_file
    @service = AzureOpenAiService.new
  end

  def generate_summary
    return puts "File not found: #{@input_file}" unless File.exist?(@input_file)

    output_file = File.join(File.dirname(@input_file), "summary.html")
    if File.exist?(output_file)
      output_file
    else
      text = File.read(@input_file).strip

      prompt = "Summarize the following text into key points with beautiful html file:\n\n#{text}"

      summary_text = @service.request_ai(prompt)

      @service.save_to_file(output_file, summary_text)
      output_file
    end
  end
end