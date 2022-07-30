defmodule Integration.EtherScan.Api do
  use Tesla

  Tesla.Middleware.PathParams

  alias Integration.Etherscan.Api.TransactionStatus

  @base_url "https://api.etherscan.io/api"
  @params_get_tx_receipt_status %{
    "action" => "gettxreceiptstatus",
    "module" => "transaction"
  }

  @spec get_tx_receipt_status(String.t()) :: {:ok, %TransactionStatus{}} | {:error, String.t()}
  def get_tx_receipt_status(txhash) do
    params = @params_get_tx_receipt_status |> Map.put("txhash", txhash)

    client()
    |> get(build_url(:gettxreceiptstatus, params))
    |> handle_response()
    |> build_transaction_status(txhash)
  end

  defp client() do
    api_middleware = [
      {Tesla.Middleware.Query, [apikey: Application.get_env(:integration, :etherscan)[:api_key]]},
      {Tesla.Middleware.JSON,
       [engine: Jason, encode_content_type: "application/json; charset=UTF-8"]}
    ]

    Tesla.client(api_middleware)
  end

  @spec build_url(atom, map) :: String.t()
  def build_url(:gettxreceiptstatus, params) do
    Tesla.build_url(@base_url, params)
  end

  defp handle_response({:ok, result}), do: response_status(result)
  defp handle_response({:error, error}), do: {:error, error}

  defp response_status(%Tesla.Env{status: 200, body: %{"status" => "0", "result" => result}}) do
    {:error, result}
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

  defp build_struct(params, schema) do
    struct(schema)
    |> schema.changeset(params)
    |> schema.build()
  end
end
