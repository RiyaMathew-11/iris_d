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
        {:noreply, assign(socket, prediction_output: format_prediction(prediction))}
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
      "0" => "Iris setosa",
      "1" => "Iris versicolor",
      "2" => "Iris virginica"
    }
  end

  defp format_prediction(prediction) do
    Map.get(iris_classes(), prediction)
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto p-6">
      <div class="flex items-center justify-center gap-2">
        <.icon name="hero-puzzle-piece-solid" class="w-8 h-8 mb-4 text-purple-700" />
        <h1 class="text-2xl font-bold mb-4">
          Iris Predictor
        </h1>
      </div>

      <.form for={@prediction_form} phx-submit="predict" class="space-y-4">
        <div class="form-group ">
          <label class="block text-sm font-medium mb-1">Sepal Length</label>
          <.input type="number" field={@prediction_form["sepal length"]} step="0.1"
                  class="w-full p-2 border rounded" />
        </div>

        <div class="form-group">
          <label class="block text-sm font-medium mb-1">Sepal Width</label>
          <.input type="number" field={@prediction_form["sepal width"]} step="0.1"
                  class="w-full p-2 border rounded" />
        </div>

        <div class="form-group">
          <label class="block text-sm font-medium mb-1">Petal Length</label>
          <.input type="number" field={@prediction_form["petal length"]} step="0.1"
                  class="w-full p-2 border rounded" />
        </div>

        <div class="form-group">
          <label class="block text-sm font-medium mb-1">Petal Width</label>
          <.input type="number" field={@prediction_form["petal width"]} step="0.1"
                  class="w-full p-2 border rounded" />
        </div>

        <button type="submit" class="w-full bg-purple-500 text-white p-2 rounded hover:bg-purple-600">
          Predict
        </button>
      </.form>

      <%= if @prediction_output do %>
        <div class="mt-6 p-4 bg-gray-100 rounded">
          <h2 class="text-xl font-semibold">Prediction Result:</h2>
          <p class="text-lg mt-2"><%= @prediction_output %></p>
        </div>
      <% end %>
    </div>
    """
  end
end
