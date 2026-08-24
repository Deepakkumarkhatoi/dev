defmodule Payx.Repo do
  use Ecto.Repo,
    otp_app: :payx,
    adapter: Ecto.Adapters.SQLite3
end
