import React from "react";
import axios from "axios";

interface Result {
  image: string | null;
  breed: string;
  error: string;
}

const DogBreedForm: React.FC = () => {
  const [breed, setBreed] = React.useState<string>("");
  const [result, setResult] = React.useState<Result>({
    image: null,
    breed: "",
    error: ""
  });
  const [loading, setLoading] = React.useState<boolean>(false);
  const [suggestions, setSuggestions] = React.useState<string[]>([]);
  const [breeds, setBreeds] = React.useState<string[]>([]);
  const [showSuggestions, setShowSuggestions] = React.useState<boolean>(false);

  React.useEffect(() => {
    const fetchBreeds = () => {
      axios
        .get("/dog_breeds.json")
        .then((response) => {
          setBreeds(response.data);
        })
        .catch((err) => {
          console.error("Error fetching breed list", err);
        });
    };

    fetchBreeds();
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setBreed(value);
    setSuggestions(getSuggestions(value));
    setShowSuggestions(true);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setResult({ image: null, breed: "", error: "" });
    setLoading(true);
    setShowSuggestions(false);

    axios
      .post("/dog_breeds/fetch_image", { breed })
      .then((response) => {
        setResult({
          image: response.data.image,
          breed: response.data.breed,
          error: ""
        });
      })
      .catch((err) => {
        if (err.response && err.response.data.error) {
          setResult({
            image: null,
            breed: "",
            error: `Oops! ${err.response.data.error}. Maybe try a different breed?`
          });
        } else {
          setResult({
            image: null,
            breed: "",
            error:
              "Who let the dogs out? We encountered an unexpected error. Please try again."
          });
        }
      })
      .finally(() => {
        setLoading(false);
      });
  };

  const getSuggestions = (value: string) => {
    const inputValue = value.trim().toLowerCase();
    const inputLength = inputValue.length;

    return inputLength === 0
      ? []
      : breeds.filter(
          (breed) => breed.toLowerCase().slice(0, inputLength) === inputValue
        );
  };

  const handleSuggestionClick = (suggestion: string) => {
    setBreed(suggestion);
    setSuggestions([]);
    setShowSuggestions(false);
  };

  return (
    <div className="flex flex-col lg:flex-row gap-10 justify-center items-center p-6">
      <form onSubmit={handleSubmit} className="w-full lg:w-1/2 relative">
        <div className="flex flex-col lg:flex-row items-center gap-4">
          <label
            htmlFor="breed"
            className="text-2xl text-primary w-full lg:w-[60px]"
          >
            Breed
          </label>

          <input
            name="breed"
            value={breed}
            onChange={handleChange}
            className="w-full h-16 border-black border-2 p-2.5 focus:outline-none focus:shadow-[0_0_5px_3px_#caff04] active:shadow-[2px_2px_0px_rgba(0,0,0,1)]"
            placeholder="Shih Tzu, Golden Retriever, Japanese Spitz.."
            required
          />

          <button
            type="submit"
            className="w-full lg:w-auto h-16 border-black border-2 px-4 bg-[#caff04] hover:bg-[#79F7FF] hover:shadow-[2px_2px_0px_rgba(0,0,0,1)] active:bg-[#00E1EF]"
            disabled={loading}
          >
            {loading ? "Loading..." : "Submit"}
          </button>
        </div>
        {showSuggestions && suggestions.length > 0 && (
          <ul className="absolute bg-white border-black border-2 w-full mt-2 max-h-60 overflow-auto z-10">
            {suggestions.map((suggestion, index) => (
              <li
                key={index}
                className="cursor-pointer p-2 hover:bg-[#caff04] hover:text-black"
                onClick={() => handleSuggestionClick(suggestion)}
              >
                {suggestion}
              </li>
            ))}
          </ul>
        )}
      </form>
      <div className="w-full lg:w-1/2 text-center">
        {loading && (
          <div className="mt-4">
            <p>Loading...</p>
          </div>
        )}
        {result.error && <p className="mt-4 text-red-500">{result.error}</p>}
        {result.image ? (
          <div className="mt-4 max-h-screen">
            <h3 className="text-4xl mb-2 text-primary">{result.breed}</h3>
            <img
              src={result.image}
              alt="Dog breed"
              className="w-full border-2 border-black md:h-[500px] object-cover"
            />
          </div>
        ) : (
          !loading &&
          !result.error && (
            <p className="mt-4 text-gray-500">No image to display</p>
          )
        )}
      </div>
    </div>
  );
};

export default DogBreedForm;
