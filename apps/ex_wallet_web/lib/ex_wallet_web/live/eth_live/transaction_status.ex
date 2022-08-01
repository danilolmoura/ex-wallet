defmodule ExWalletWeb.EthLive.TransactionStatus do
  use ExWalletWeb, :live_view

  alias Integration.EtherScan

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(transactions: [])

    {:ok, socket}
  end

  def handle_event("tx_search", %{"tx_hash" => tx_hash}, socket) do
    case EtherScan.Api.get_tx_receipt_status(tx_hash) do
      {:ok, transaction} ->
        socket =
          socket
          |> assign(transactions: [transaction])

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> assign(transactions: [])
          |> put_flash(:error, reason)

        {:noreply, socket}
    end
  end

  defp status_color(true), do: "badge success-status"
  defp status_color(false), do: "badge error-status"

  defp hide_element(true), do: "hide-element"
  defp hide_element(false), do: ""
end
