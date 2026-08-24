defmodule Payx.Repo.Migrations.CreatePaymentMethods do
  use Ecto.Migration

  def change do
    create table(:payment_methods) do
      add :method_id, :string
      add :name, :string
      add :min_amount, :decimal
      add :max_amount, :decimal
      add :processing_fee_percent, :decimal
      add :is_active, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
