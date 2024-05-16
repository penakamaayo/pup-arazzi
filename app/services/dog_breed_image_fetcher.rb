require 'net/http'
require 'uri'

class DogBreedImageFetcher
  API_BASE_URL = 'https://dog.ceo/api'.freeze
  
  attr_reader :breed

  def initialize(breed)
    @breed = breed.downcase.gsub(/\s+/, '')
  end

  def fetch_image
    response = Net::HTTP.get_response(URI("#{API_BASE_URL}/breed/#{@breed}/images/random"))
    parse_response(response)
  rescue StandardError
    { error: 'An unexpected error occurred. Please try again later.' }
  end

  def self.fetch_breeds
    response = Net::HTTP.get_response(URI("#{API_BASE_URL}/breeds/list/all"))
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
