defmodule Payx.Schemas.Merchant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchants" do
    field :merchant_id, :string
    field :api_key, :string
    field :name, :string
    field :email, :string
    field :onboarding_status, :string
    field :kyc_status, :string
    field :daily_transaction_limit, :decimal
    field :per_transaction_limit, :decimal
    field :is_active, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(merchant, attrs) do
    merchant
    |> cast(attrs, [:merchant_id, :api_key, :name, :email, :onboarding_status, :kyc_status, :daily_transaction_limit, :per_transaction_limit, :is_active])
    |> validate_required([:merchant_id, :api_key, :name, :email, :onboarding_status, :kyc_status, :daily_transaction_limit, :per_transaction_limit, :is_active])
  end
end
