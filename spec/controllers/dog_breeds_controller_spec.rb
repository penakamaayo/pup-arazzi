require 'rails_helper'

RSpec.describe DogBreedsController, type: :controller do
  describe "GET #index" do
    context "when format is HTML" do
      it "should render the index html template" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context "when format is JSON" do
      before do
        allow(DogBreedImageFetcher).to receive(:fetch_breeds).and_return(["pug", "bulldog"])
      end

      it "should return a list of breeds" do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(["pug", "bulldog"])
      end
    end
  end

  describe "POST #fetch_image" do
    context "when breed parameter is missing" do
      it "should return a bad request error" do
        post :fetch_image
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq({ "error" => "Breed parameter is required."})
      end
    end

    context "when breed parameter is provided" do
      let(:breed) { "bulldog" }
      let(:fetcher) { instance_double(DogBreedImageFetcher) }

      before do
        allow(DogBreedImageFetcher).to receive(:new).with(breed).and_return(fetcher)
      end

      context "when the fetch is successful" do
        let(:response_body) { { "message" => "image_url", "status" => "success" } }

        before do
          allow(fetcher).to receive(:fetch_image).and_return({ "message" => "image_url", "breed" => breed.capitalize })
        end

        it "should returns the result (image URL and breed name)" do
          post :fetch_image, params: { breed: breed }
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({ "message" => "image_url", "breed" => breed.capitalize })
        end
      end

      context "when the fetch returns an error" do
        before do
          allow(fetcher).to receive(:fetch_image).and_return({ :error => "Breed not found" })
        end

        it "should return a not found error" do
          post :fetch_image, params: { breed: breed }
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)).to eq({ "error" => "Breed not found" })
        end
      end

      context "when an unexpected error occurs" do
        before do
          allow(fetcher).to receive(:fetch_image).and_raise(StandardError.new("Unexpected error"))
        end

        it "should return an internal server error" do
          post :fetch_image, params: { breed: breed }
          expect(response).to have_http_status(:internal_server_error)
          expect(JSON.parse(response.body)).to eq({ "error" => "An unexpected error occurred. Please try again later." })
        end
      end
    end
  end
end
