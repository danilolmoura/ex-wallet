defmodule Integration.EtherScan.ApiTest do
  use ExUnit.Case, async: true

  import Mox

  alias Integration.EtherScan.Api
  alias Integration.EtherScan.Api.TransactionStatus
  alias Integration.EtherScan.Adapter.Mock

  @base_url "https://api.etherscan.io/api"

  setup :verify_on_exit!

  describe "get_tx_receipt/1" do
    setup do
      url_params = %{
        "action" => "eth_getTransactionReceipt",
        "module" => "proxy"
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

      Api.get_tx_receipt(tx_hash)
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

      Api.get_tx_receipt(tx_hash)
    end

    test "with valid http call and success transaction", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: success_call_success_transaction_output()}}
      end)

      assert Api.get_tx_receipt(tx_hash) ==
               {:ok, %TransactionStatus{hash: tx_hash, status: 1}}
    end

    test "with valid http call and failed transaction" do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: success_call_failed_transaction_output()}}
      end)

      tx_hash = "0xfa7f0dc937844c1a4f0cefa1b9cb147874bb2b199c60876a08f9f4b9c05f144d"

      assert Api.get_tx_receipt(tx_hash) ==
               {:ok, %TransactionStatus{hash: tx_hash, status: 0}}
    end

    test "with valid http call and pending transaction", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: success_call_pending_transaction_output()}}
      end)

      assert Api.get_tx_receipt(tx_hash) ==
               {:ok, %TransactionStatus{hash: tx_hash, status: 2}}
    end

    test "with valid http call and api limit reached", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: success_call_api_limit_reached_output()}}
      end)

      assert Api.get_tx_receipt(tx_hash) ==
               {:error, "Something went wrong, please try again in few seconds"}
    end

    test "with valid http call and invalid hash param", %{tx_hash: tx_hash} do
      expect(Mock, :call, fn
        %{
          method: :get
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: success_call_invalid_hash_output()}}
      end)

      assert Api.get_tx_receipt(tx_hash) ==
               {:error, "Invalid transaction hash"}
    end

    defp success_call_success_transaction_output do
      %{
        "id" => 1,
        "jsonrpc" => "2.0",
        "result" => %{
          "blockHash" => "0xbaee22af41ce5cb4d28a6a377da26f4fc4f9d893fdfaa6878fb732f42367a947",
          "blockNumber" => "0x4b9b05",
          "contractAddress" => nil,
          "cumulativeGasUsed" => "0x698420",
          "effectiveGasPrice" => "0x4a817c800",
          "from" => "0x0fe426d8f95510f4f0bac19be5e1252c4127ee00",
          "gasUsed" => "0x5208",
          "logs" => [],
          "logsBloom" =>
            "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "status" => "0x1",
          "to" => "0x4848535892c8008b912d99aaf88772745a11c809",
          "transactionHash" =>
            "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0",
          "transactionIndex" => "0xa0",
          "type" => "0x0"
        }
      }
    end

    defp success_call_failed_transaction_output do
      %{
        "id" => 1,
        "jsonrpc" => "2.0",
        "result" => %{
          "blockHash" => "0xfa7f0dc937844c1a4f0cefa1b9cb147874bb2b199c60876a08f9f4b9c05f144d",
          "blockNumber" => "0xe8db3b",
          "contractAddress" => nil,
          "cumulativeGasUsed" => "0xd58725",
          "effectiveGasPrice" => "0x2d4dd7d0f",
          "from" => "0xdd0de879a13227130bdd9b558fe22f15d0024ce1",
          "gasUsed" => "0xcc24",
          "logs" => [],
          "logsBloom" =>
            "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "status" => "0x0",
          "to" => "0x00000000006c3852cbef3e08e8df289169ede581",
          "transactionHash" =>
            "0xe4f9c6f157aa5f3427e9378af7eaa50fdf0f64297864d536e48f09814d6e9ea8",
          "transactionIndex" => "0x7c",
          "type" => "0x2"
        }
      }
    end

    defp success_call_pending_transaction_output do
      %{"id" => 1, "jsonrpc" => "2.0", "result" => nil}
    end

    defp success_call_invalid_hash_output do
      %{
        "error" => %{
          "code" => -32602,
          "message" =>
            "invalid argument 0: json: cannot unmarshal hex string of odd length into Go value of type common.Hash"
        },
        "id" => 1,
        "jsonrpc" => "2.0"
      }
    end

    defp success_call_api_limit_reached_output do
      %{
        "message" => "NOTOK",
        "result" => "Max rate limit reached, please use API Key for higher rate limit",
        "status" => "0"
      }
    end
  end
end
