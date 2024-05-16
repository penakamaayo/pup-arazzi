import * as React from "react";
import * as ReactDOM from "react-dom";
import DogBreedForm from "./DogBreedForm";

function App() {
  return <DogBreedForm />;
};

document.addEventListener("DOMContentLoaded", () => {
  const rootEl = document.getElementById("root");
  ReactDOM.render(<App />, rootEl);
});
