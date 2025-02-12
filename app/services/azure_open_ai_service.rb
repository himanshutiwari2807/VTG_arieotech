require 'net/http'
require 'uri'
require 'json'

class AzureOpenAiService
    def initialize
      @uri = URI(ENV["OPEN_AI_URI"])
      @api_key = ENV["API_KEY"]
    end


  def request_ai(prompt)
    headers = {
      "Content-Type" => "application/json",
      "api-key" => @api_key
    }

    body = {
      model: "gpt-4o",
      messages: [
        { role: "system", content: "You are an advanced AI assistant." },
        { role: "user", content: prompt }
      ]
    }

    response = Net::HTTP.post(@uri, body.to_json, headers)
    response_body = JSON.parse(response.body)

    response_body.dig("choices", 0, "message", "content")
  end

  def save_to_file(filename, content)
    return unless content
    File.write(filename, content)
    puts "Saved: #{filename}"
  end
end
