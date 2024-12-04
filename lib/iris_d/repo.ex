defmodule IrisD.Repo do
  use Ecto.Repo,
    otp_app: :iris_d,
    adapter: Ecto.Adapters.Postgres
end
