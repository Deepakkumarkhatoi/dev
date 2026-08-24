defmodule Payx.Schemas.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :transaction_id, :string
    field :idempotency_key, :string 
    field :amount, :decimal
    field :currency, :string
    field :status, :string
    field :reference_id, :string
    field :customer_email, :string
    field :customer_phone, :string
    field :merchant_id, :id
    field :payment_method_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
def changeset(transaction, attrs) do
  transaction
  |> cast(attrs, [
    :transaction_id,
    :amount,
    :currency,
    :status,
    :reference_id,
    :customer_email,
    :customer_phone,
    :merchant_id,
    :payment_method_id,
    :idempotency_key
  ])
  |> validate_required([
    :transaction_id,
    :amount,
    :currency,
    :status,
    :reference_id,
    :customer_email
  ])
  |> validate_number(:amount, greater_than: 0)
  |> validate_length(:currency, is: 3)
end
end
