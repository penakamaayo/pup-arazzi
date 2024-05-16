class DogBreedImageFetcher
  require 'net/http'
  require 'uri'
  require 'json'

  attr_reader :breed

  def initialize(breed)
    @breed = breed.downcase.gsub(/\s+/, "")
  end

  def fetch_image
    url = URI("https://dog.ceo/api/breed/#{@breed}/images/random")
    response = Net::HTTP.get_response(url)
    parse_response(response)
  rescue StandardError
    { error: 'An unexpected error occurred. Please try again later.' }
  end

  def self.fetch_breeds
    url = URI("https://dog.ceo/api/breeds/list/all")
    response = Net::HTTP.get_response(url)
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)['message'].keys
    else
      []
    end
  rescue StandardError
    []
  end

  private

  def parse_response(response)
    data = JSON.parse(response.body)

    if response.is_a?(Net::HTTPSuccess) && data['status'] == 'success'
      { image: data['message'], breed: breed.capitalize }
    elsif data['status'] == 'error'
      { error: data['message'] }
    else
      { error: 'An error occurred while fetching the breed image. Please try again later.' }
    end
  end
end
