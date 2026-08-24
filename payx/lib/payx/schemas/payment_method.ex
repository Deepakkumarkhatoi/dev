defmodule Payx.Schemas.PaymentMethod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payment_methods" do
    field :method_id, :string
    field :name, :string
    field :min_amount, :decimal
    field :max_amount, :decimal
    field :processing_fee_percent, :decimal
    field :is_active, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment_method, attrs) do
    payment_method
    |> cast(attrs, [:method_id, :name, :min_amount, :max_amount, :processing_fee_percent, :is_active])
    |> validate_required([:method_id, :name, :min_amount, :max_amount, :processing_fee_percent, :is_active])
  end
end
