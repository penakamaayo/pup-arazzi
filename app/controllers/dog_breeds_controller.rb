class DogBreedsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json { render json: DogBreedImageFetcher.fetch_breeds }
    end
  end

  def fetch_image
    breed = params[:breed]
    return render json: { error: 'Breed parameter is required.' }, status: :bad_request if breed.blank?

    begin
      fetcher = DogBreedImageFetcher.new(breed)
      response = fetcher.fetch_image

      if response[:error].present?
        render json: response, status: :not_found
      else
        render json: response, status: :ok
      end
    rescue StandardError => e
      render json: { error: 'An unexpected error occurred. Please try again later.' }, status: :internal_server_error
    end
  end
end
