import React, { useState, ChangeEvent, FormEvent } from "react";
import axios from "axios";

const DogBreedForm: React.FC = () => {
  const [breed, setBreed] = useState<string>("");
  const [image, setImage] = useState<string | null>(null);
  const [error, setError] = useState<string>("");

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setBreed(e.target.value);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    setImage(null);
    try {
      const response = await axios.post("/dog_breeds/fetch_image", { breed });
      setImage(response.data.message);
    } catch (err: any) {
      if (err.response && err.response.data.error) {
        setError(err.response.data.error);
      } else {
        setError("An unexpected error occurred. Please try again.");
      }
    }
  };

  return (
    <>
      <form onSubmit={handleSubmit}>
        <div className="flex items-center gap-6">
          <label
            htmlFor="breed"
            className="text-2xl font-bold text-primary p-6 text-blue"
          >
            Breed
          </label>

          <input
            type="text"
            onChange={handleChange}
            value={breed}
            required
            className=" border-black border-2 p-2.5 focus:outline-none focus:shadow-[2px_2px_0px_rgba(0,0,0,1)] focus:bg-[#FFA6F6] active:shadow-[2px_2px_0px_rgba(0,0,0,1)] rounded-full"
            placeholder="Shih Tzu, Golden Retriever.."
          />
          <button
            type="submit"
            className="w-fit border-black border-2 p-2.5 bg-[#A6FAFF] hover:bg-[#79F7FF] hover:shadow-[2px_2px_0px_rgba(0,0,0,1)] active:bg-[#00E1EF] rounded-full"
          >
            Submit
          </button>
        </div>
      </form>
      {error && <p className="mt-4 text-red-500">{error}</p>}
      {image && (
        <div className="mt-4">
          <h3 className="text-2xl font-bold mb-2 text-primary">{breed}</h3>
          <img
            src={image}
            alt="Dog breed"
            className="w-full border-2 border-black rounded"
          />
        </div>
      )}
    </>
  );
};

export default DogBreedForm;
