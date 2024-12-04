defmodule IrisD.Predictor do
  def predict(input_data) do
    python_path = Path.join([:code.priv_dir(:iris_d), "python/predictor.py"])

    case System.cmd("python", [python_path, Jason.encode!(input_data)]) do
      {output, 0} ->
        {:ok, Jason.decode!(output)}

      {error, _} ->
        {:error, "Prediction failed, error: #{inspect(error)}"}
    end
  end
end
