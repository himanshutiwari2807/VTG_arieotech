require_relative 'azure_open_ai_service'
require 'json'

class McqService
  def initialize(input_file)
    @input_file = input_file
    @service = AzureOpenAiService.new
  end

  def generate_mcq
    return puts "File not found: #{@input_file}" unless File.exist?(@input_file)

    output_file = File.join(File.dirname(@input_file), "mcq_questions.json")

    if File.exist?(output_file)
      output_file
    else
      text = File.read(@input_file).strip
      prompt = <<~PROMPT
        Generate a list of multiple-choice questions (MCQs) in **valid JSON format**.
        Each question should have:
        - "question": The MCQ question
        - "options": An array of four possible answers
        - "answer": The correct answer

        Example output (must be pure JSON, no extra text):
        [
          {
            "question": "What is Ruby?",
            "options": ["A gemstone", "A programming language", "A car brand", "A city"],
            "answer": "A programming language"
          }
        ]

        Use the following text to generate questions:
        #{text}
      PROMPT

      response = @service.request_ai(prompt)
      cleaned_response = extract_json(response)

      unless cleaned_response
        puts "AI response is not a valid JSON format."
        return
      end

      @service.save_to_file(output_file, JSON.pretty_generate(cleaned_response))
      output_file
    end
  end

  private

  def extract_json(response)
    json_match = response.match(/\[\s*\{.*\}\s*\]/m) # Extracts content between [ ... ]
    return unless json_match

    json_str = json_match[0]
    begin
      json = JSON.parse(json_str)
      return json if json.is_a?(Array) && json.all? { |q| q.is_a?(Hash) && q.key?("question") && q.key?("options") && q.key?("answer") }

      puts "Extracted JSON is not in expected MCQ format."
      nil
    rescue JSON::ParserError
      puts "Error parsing extracted JSON."
      nil
    end
  end
end

