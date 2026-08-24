defmodule Payx.Transactions do
  import Ecto.Query

  alias Payx.Repo

  alias Payx.Schemas.{
    Transaction,
    Merchant,
    PaymentMethod,
    MerchantPaymentMethod
  }

  # ============================================================
  # CREATE TRANSACTION
  # ============================================================

  def create_transaction(attrs, api_key) do
    with {:ok, merchant} <- authenticate(api_key),
         {:ok, payment_method} <- get_payment_method(attrs["payment_method"]),
         :ok <- check_merchant_method(merchant.id, payment_method.id),
         :ok <- check_limits(merchant, payment_method, attrs["amount"]),
         {:ok, transaction} <-
           insert_transaction(attrs, merchant, payment_method) do
      {:ok, transaction}
    end
  end

  # ============================================================
  # AUTHENTICATE MERCHANT
  # ============================================================

  defp authenticate(api_key) do
    case Repo.get_by(Merchant, api_key: api_key) do
      nil ->
        {:error, "ENTITY_MERCHANT_NOT_FOUND"}

      merchant ->
        cond do
          !merchant.is_active ->
            {:error, "ENTITY_MERCHANT_INACTIVE"}

          merchant.kyc_status not in ["approved", "verified"] ->
            {:error, "ENTITY_KYC_NOT_APPROVED"}

          true ->
            {:ok, merchant}
        end
    end
  end

  # ============================================================
  # GET PAYMENT METHOD
  # ============================================================

  defp get_payment_method(method_id) do
    case method_id do
      nil ->
        {:error, "RULE_PAYMENT_METHOD_INVALID"}

      "" ->
        {:error, "RULE_PAYMENT_METHOD_INVALID"}

      method_id ->
        case Repo.get_by(
               PaymentMethod,
               method_id: method_id,
               is_active: true
             ) do
          nil ->
            {:error, "RULE_PAYMENT_METHOD_INVALID"}

          method ->
            {:ok, method}
        end
    end
  end

  # ============================================================
  # CHECK MERCHANT PAYMENT METHOD
  # ============================================================

  defp check_merchant_method(merchant_id, payment_method_id) do
    query =
      from m in MerchantPaymentMethod,
        where:
          m.merchant_id == ^merchant_id and
            m.payment_method_id == ^payment_method_id and
            m.is_enabled == true

    if Repo.exists?(query) do
      :ok
    else
      {:error, "RULE_PAYMENT_METHOD_NOT_ENABLED"}
    end
  end

  # ============================================================
  # CHECK AMOUNT LIMITS
  # ============================================================

  defp check_limits(merchant, payment_method, amount) do
    case Decimal.parse(to_string(amount)) do
      {amount, _} ->
        cond do
          Decimal.lt?(amount, payment_method.min_amount) ->
            {:error, "RULE_AMOUNT_BELOW_MINIMUM"}

          Decimal.gt?(amount, payment_method.max_amount) ->
            {:error, "RULE_AMOUNT_ABOVE_MAXIMUM"}

          Decimal.gt?(amount, merchant.per_transaction_limit) ->
            {:error, "RULE_MERCHANT_LIMIT_EXCEEDED"}

          true ->
            :ok
        end

      :error ->
        {:error, "SCHEMA_INVALID_AMOUNT"}
    end
  end

  # ============================================================
  # INSERT TRANSACTION
  # ============================================================

  defp insert_transaction(attrs, merchant, payment_method) do
    attrs =
      attrs
      |> Map.put("transaction_id", "txn_" <> Ecto.UUID.generate())
      |> Map.put("status", "processing")
      |> Map.put("merchant_id", merchant.id)
      |> Map.put("payment_method_id", payment_method.id)

    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  # ============================================================
  # GET TRANSACTION
  # ============================================================

  def get_transaction(transaction_id) do
    case Repo.get_by(Transaction, transaction_id: transaction_id) do
      nil ->
        {:error, :not_found}

      transaction ->
        {:ok, transaction}
    end
  end
end