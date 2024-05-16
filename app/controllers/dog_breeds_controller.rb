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

    fetcher = DogBreedImageFetcher.new(breed)
    response = fetcher.fetch_image
    render json: response, status: response[:error].present? ? :not_found : :ok
  end
end
