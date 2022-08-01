defmodule Integration.EtherScan.ApiTest do
  use ExUnit.Case, async: true

  import Mox

  alias Integration.EtherScan.Api
  alias Integration.EtherScan.Api.TransactionStatus
  alias Integration.EtherScan.Adapter.Mock

  @base_url "https://api.etherscan.io/api"

  setup :verify_on_exit!

  describe "get_tx_receipt_status/1" do
    setup do
      url_params = %{
        "action" => "gettxreceiptstatus",
        "module" => "transaction"
      }

      %{
        tx_hash: "0xee363c2dd3ee454c7af54000f85188bc443ce155e37066cc9d8275fa802125ef",
        params: url_params
      }
    end

    test "with valid query", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          query: query
        },
        _opts ->
          assert query == [apikey: Application.get_env(:integration, :etherscan)[:api_key]]

          {:ok, %Tesla.Env{status: 200, body: success_call_success_transaction_output()}}
      end)

      Api.get_tx_receipt_status(tx_hash)
    end

    test "with valid url", %{tx_hash: tx_hash, params: params} do
      expect(Mock, :call, fn
        %{
          url: url
        },
        _opts ->
          assert url == Api.build_url(@base_url, Map.put(params, "txhash", tx_hash))

          {:ok, %Tesla.Env{status: 200, body: success_call_success_transaction_output()}}
      end)

      Api.get_tx_receipt_status(tx_hash)
    end

    test "with valid http call and success transaction", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: success_call_success_transaction_output()}}
      end)

      assert Api.get_tx_receipt_status(tx_hash) ==
               {:ok, %TransactionStatus{hash: tx_hash, status: true}}
    end

    test "with valid http call and failed transaction", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: success_call_failed_transaction_output()}}
      end)

      assert Api.get_tx_receipt_status(tx_hash) ==
               {:ok, %TransactionStatus{hash: tx_hash, status: false}}
    end

    test "with failed http call", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: failed_call_output()}}
      end)

      assert Api.get_tx_receipt_status(tx_hash) ==
               {:error, "Max rate limit reached, please use API Key for higher rate limit"}
    end
  end

  defp success_call_success_transaction_output do
    %{
      "message" => "OK-Missing/Invalid API Key, rate limit of 1/5sec applied",
      "result" => %{"status" => "1"},
      "status" => "1"
    }
  end

  defp success_call_failed_transaction_output do
    %{
      "message" => "OK-Missing/Invalid API Key, rate limit of 1/5sec applied",
      "result" => %{"status" => "0"},
      "status" => "1"
    }
  end

  defp failed_call_output do
    %{
      "message" => "NOTOK",
      "result" => "Max rate limit reached, please use API Key for higher rate limit",
      "status" => "0"
    }
  end
end
