defmodule Integration.EtherScan.ApiTest do
  use ExUnit.Case, async: true

  import Mox

  alias Integration.EtherScan.Api
  alias Integration.Etherscan.Api.TransactionStatus
  alias Integration.EtherScan.Adapter.Mock

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

    test "with valid tx_hash", %{tx_hash: tx_hash, params: params} do
      expect(Mock, :call, fn
        %{
          method: :get,
          url: url,
          query: query
        },
        _opts ->
          assert query == [apikey: Application.get_env(:integration, :etherscan)[:api_key]]
          assert url == Api.build_url(:gettxreceiptstatus, Map.put(params, "txhash", tx_hash))

          {:ok, %Tesla.Env{status: 200, body: create_output()}}
      end)

      assert Api.get_tx_receipt_status(tx_hash) ==
               {:ok, %TransactionStatus{hash: tx_hash, status: true}}
    end

    test "with some failure tx_hash", %{tx_hash: tx_hash, params: params} do
      expect(Mock, :call, fn
        %{
          method: :get,
          url: url,
          query: query
        },
        _opts ->
          assert query == [apikey: Application.get_env(:integration, :etherscan)[:api_key]]
          assert url == Api.build_url(:gettxreceiptstatus, Map.put(params, "txhash", tx_hash))

          {:ok, %Tesla.Env{status: 200, body: create_failure_output()}}
      end)

      assert Api.get_tx_receipt_status(tx_hash) ==
               {:error, "Max rate limit reached, please use API Key for higher rate limit"}
    end
  end

  defp create_output do
    %{
      "message" => "OK-Missing/Invalid API Key, rate limit of 1/5sec applied",
      "result" => %{"status" => "1"},
      "status" => "1"
    }
  end

  defp create_failure_output do
    %{
      "message" => "NOTOK",
      "result" => "Max rate limit reached, please use API Key for higher rate limit",
      "status" => "0"
    }
  end
end
