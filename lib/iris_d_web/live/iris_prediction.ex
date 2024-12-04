defmodule IrisDWeb.IrisPredictionLive do
  use IrisDWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
      assign(socket,
        prediction_form: to_form(%{"sepal length" => "", "sepal width" => "", "petal length" => "", "petal width" => ""}),
        prediction_output: nil
      )
    }
  end

  def handle_event("predict", %{
    "sepal length" => sepal_length,
    "sepal width" => sepal_width,
    "petal length" => petal_length,
    "petal width" => petal_width
  }, socket) do
    features = [
      parse_number(sepal_length),
      parse_number(sepal_width),
      parse_number(petal_length),
      parse_number(petal_width)
    ]

    result = IrisD.Predictor.predict(features)
    case result do
      {:ok, prediction} ->
        {:noreply, assign(socket, prediction_output: "Iris #{format_prediction(prediction)}",
          flower_image: "/images/iris-#{format_prediction(prediction)}.png")
        }
      {:error, message} ->
        {:noreply, assign(socket, prediction_output: message)}
    end
  end

  defp parse_number(str) do
    case Float.parse(str) do
      {number, _} -> number
      :error -> raise ArgumentError, "Invalid number format"
    end
  end

  defp iris_classes do
    %{
      "0" => "setosa",
      "1" => "versicolor",
      "2" => "virginica"
    }
  end

  defp format_prediction(prediction) do
    Map.get(iris_classes(), prediction)
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 flex flex-col gap-8">
      <div class="flex items-center justify-center gap-2">
        <.icon name="hero-puzzle-piece-solid" class="w-8 h-8 mb-4 text-purple-700" />
        <h1 class="text-2xl font-bold mb-4">
          Iris Predictor
        </h1>
      </div>

      <.form for={@prediction_form} phx-submit="predict" class="flex flex-col space-y-4">
        <div class="flex gap-3 flex-col md:flex-row">
          <div class="form-group w-full md:w-1/2">
            <label class="block text-sm font-medium mb-1">Sepal Length</label>
            <.input type="number" field={@prediction_form["sepal length"]} min="0" max="10" step="0.1"
                    class="w-full p-2 border rounded" />
          </div>

          <div class="form-group w-full md:w-1/2">
            <label class="block text-sm font-medium mb-1">Sepal Width</label>
            <.input type="number" field={@prediction_form["sepal width"]} min="0" max="10" step="0.1"
                    class="w-full p-2 border rounded" />
          </div>
        </div>

        <div class="flex flex-col md:flex-row gap-3">
          <div class="form-group w-full md:w-1/2">
            <label class="block text-sm font-medium mb-1">Petal Length</label>
            <.input type="number" field={@prediction_form["petal length"]} min="0" max="10"step="0.1"
                    class="w-full p-2 border rounded" />
          </div>

          <div class="form-group w-full md:w-1/2">
            <label class="block text-sm font-medium mb-1">Petal Width</label>
            <.input type="number" field={@prediction_form["petal width"]} min="0" max="10" step="0.1"
                    class="w-full p-2 border rounded" />
          </div>
        </div>

        <button type="submit" class="w-full bg-purple-500 text-white p-2 rounded hover:bg-purple-600">
          Predict
        </button>
      </.form>

      <%= if @prediction_output do %>
        <div class="p-4 md:p-6 bg-gray-100 rounded flex flex-col items-center justify-center gap-3">
          <div class="flex gap-2">
            <.icon name="hero-check-circle-solid" class="w-6 h-6 md:w-8 md:h-8 text-green-500" />
            <h2 class="text-lg md:text-xl text-center font-semibold">Prediction Result</h2>
          </div>
          <div class="flex flex-col gap-3 items-center">
              <%= if @flower_image do %>
                <img src={@flower_image} alt="Iris flower" class="w-32 md:w-48 h-32 md:h-48 mx-auto rounded-full shadow-lg border-4 border-purple-700" />
              <% end %>
            <p class="md:text-xl font-semibold"><%= @prediction_output %></p>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
