defmodule Payx.Schemas.MerchantPaymentMethod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merchant_payment_methods" do
    field :custom_fee_percent, :decimal
    field :is_enabled, :boolean, default: false
    field :priority, :integer
    field :merchant_id, :id
    field :payment_method_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(merchant_payment_method, attrs) do
    merchant_payment_method
    |> cast(attrs, [
  :merchant_id,
  :payment_method_id,
  :custom_fee_percent,
  :is_enabled,
  :priority
])
    |> validate_required([
  :merchant_id,
  :payment_method_id,
  :custom_fee_percent,
  :is_enabled,
  :priority
])
  end
end
