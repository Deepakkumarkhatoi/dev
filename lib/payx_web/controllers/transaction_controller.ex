defmodule PayxWeb.TransactionController do
  use PayxWeb, :controller

  alias Payx.Transactions

  def create(conn, params) do
    idempotency_key =
      get_req_header(conn, "idempotency-key")
      |> List.first()

    params = Map.put(params, "idempotency_key", idempotency_key)

    api_key =
      get_req_header(conn, "x-api-key")
      |> List.first()

    case Transactions.create_transaction(params, api_key) do
      {:ok, transaction} ->
        conn
        |> put_status(:created)
        |> json(%{
          success: true,
          data: %{
            transaction_id: transaction.transaction_id,
            status: transaction.status,
            amount: transaction.amount,
            currency: transaction.currency
          }
        })

      {:error, reason} when is_binary(reason) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          error: %{
            code: reason,
            message: reason
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          success: false,
          error: %{
            code: "SCHEMA_VALIDATION_ERROR",
            message: "Invalid transaction data",
            details:
              Ecto.Changeset.traverse_errors(
                changeset,
                fn {msg, _} -> msg end
              )
          }
        })
    end
  end

  # GET /api/v1/transactions/:transaction_id
  def show(conn, %{"transaction_id" => transaction_id}) do
    case Transactions.get_transaction(transaction_id) do
      {:ok, transaction} ->
        json(conn, %{
          success: true,
          data: %{
            transaction_id: transaction.transaction_id,
            status: transaction.status,
            amount: transaction.amount,
            currency: transaction.currency
          }
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          success: false,
          error: %{
            code: "TRANSACTION_NOT_FOUND",
            message: "Transaction not found"
          }
        })
    end
  end
end