require 'rails_helper'
require 'net/http'

RSpec.describe DogBreedImageFetcher do
  describe '#fetch_image' do
    let(:breed) { 'pug' }
    let(:fetcher) { DogBreedImageFetcher.new(breed) }

    context 'when the API call is successful' do
      let(:response_body) { { "message" => "https://images.dog.ceo/breeds/chihuahua/1.jpg", "status" => "success" }.to_json }
      let(:response) { instance_double(Net::HTTPSuccess, body: response_body, is_a?: true) }

      before do
        allow(Net::HTTP).to receive(:get_response).and_return(response)
      end

      it 'returns the image URL' do
        result = fetcher.fetch_image
        expect(result).to eq({ image: "https://images.dog.ceo/breeds/chihuahua/1.jpg", breed: "Pug" })
      end
    end

    context 'when the API call returns an error' do
      let(:response_body) { { "message" => "Breed not found (master breed does not exist)", "status" => "error" }.to_json }
      let(:response) { instance_double(Net::HTTPClientError, body: response_body, is_a?: false) }

      before do
        allow(Net::HTTP).to receive(:get_response).and_return(response)
      end

      it 'returns an error message' do
        result = fetcher.fetch_image
        expect(result).to eq({ error: "Breed not found (master breed does not exist)" })
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("Unexpected error"))
      end

      it 'returns a generic error message' do
        result = fetcher.fetch_image
        expect(result).to eq({ error: 'An unexpected error occurred. Please try again later.' })
      end
    end
  end

  describe '.fetch_breeds' do
    context 'when the API call is successful' do
      let(:response_body) { { "message" => { "pug" => [], "poodle" => [] }, "status" => "success" }.to_json }
      let(:response) { instance_double(Net::HTTPSuccess, body: response_body, is_a?: true) }

      before do
        allow(Net::HTTP).to receive(:get_response).and_return(response)
      end

      it 'returns a list of breeds' do
        result = DogBreedImageFetcher.fetch_breeds
        expect(result).to eq(["pug", "poodle"])
      end
    end

    context 'when the API call returns an error' do
      let(:response) { instance_double(Net::HTTPClientError, is_a?: false) }

      before do
        allow(Net::HTTP).to receive(:get_response).and_return(response)
      end

      it 'returns an empty array' do
        result = DogBreedImageFetcher.fetch_breeds
        expect(result).to eq([])
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("Unexpected error"))
      end

      it 'returns an empty array' do
        result = DogBreedImageFetcher.fetch_breeds
        expect(result).to eq([])
      end
    end
  end
end
