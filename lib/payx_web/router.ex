defmodule PayxWeb.Router do
  use PayxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", PayxWeb do
    pipe_through :api

    # Create transaction
    post "/transactions", TransactionController, :create

    # Get transaction by transaction_id
    get "/transactions/:transaction_id", TransactionController, :show
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:payx, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PayxWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end