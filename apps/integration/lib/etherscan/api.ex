defmodule Integration.EtherScan.Api do
  @moduledoc """
  Provides integration with `EtherScan API`

  https://docs.etherscan.io/
  """

  use Integration, :default_api

  require Logger

  alias Integration.EtherScan.Api.TransactionStatus

  @base_url "https://api.etherscan.io/api"
  @params_get_tx_receipt_status %{
    "action" => "gettxreceiptstatus",
    "module" => "transaction"
  }

  defp api_key, do: Application.get_env(:integration, :etherscan)[:api_key]

  @doc """
  Get transaction receipt status

  ## Parameters

    - txhash: String representing a transaction hash

  ## Examples

  iex> Integration.EtherScan.Api.get_tx_receipt_status("0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0")
  {:ok,
  %Integration.EtherScan.Api.TransactionStatus{
    hash: "1111",
    status: true
  }}
  """
  @spec get_tx_receipt_status(String.t()) :: {:ok, %TransactionStatus{}} | {:error, String.t()}
  def get_tx_receipt_status(txhash) do
    params = @params_get_tx_receipt_status |> Map.put("txhash", txhash)

    client()
    |> get(build_url(@base_url, params))
    |> handle_response()
    |> build_transaction_status(txhash)
  end

  defp client() do
    api_middleware = [
      {Tesla.Middleware.Query, [apikey: api_key()]},
      {Tesla.Middleware.JSON,
       [engine: Jason, encode_content_type: "application/json; charset=UTF-8"]}
    ]

    Tesla.client(api_middleware)
  end

  defp handle_response({:ok, result}), do: response_status(result)
  defp handle_response({:error, error}), do: {:error, error}

  defp response_status(%Tesla.Env{status: 200, body: %{"status" => "0", "result" => result}}) do
    Logger.warning("EtherScan.Api: #{result}")
    {:error, "Something went wrong, please try again in few seconds"}
  end

  defp response_status(%Tesla.Env{status: 200, body: %{"status" => "1", "result" => result}}) do
    {:ok, result}
  end

  defp response_status(%Tesla.Env{status: 400}) do
    {:ok, :bad_request}
  end

  defp build_transaction_status({:error, reason}, _), do: {:error, reason}

  defp build_transaction_status({:ok, response}, tx_hash) do
    Map.new()
    |> put_transaction_status(response)
    |> put_hash(tx_hash)
    |> build_struct(TransactionStatus)
  end

  defp put_transaction_status(map, %{"status" => "1"}), do: Map.put(map, "status", true)
  defp put_transaction_status(map, %{"status" => "0"}), do: Map.put(map, "status", false)

  defp put_hash(map, hash), do: Map.put(map, "hash", hash)
end
