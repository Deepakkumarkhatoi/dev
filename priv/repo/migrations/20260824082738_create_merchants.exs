defmodule Payx.Repo.Migrations.CreateMerchants do
  use Ecto.Migration

  def change do
    create table(:merchants) do
      add :merchant_id, :string
      add :api_key, :string
      add :name, :string
      add :email, :string
      add :onboarding_status, :string
      add :kyc_status, :string
      add :daily_transaction_limit, :decimal
      add :per_transaction_limit, :decimal
      add :is_active, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
