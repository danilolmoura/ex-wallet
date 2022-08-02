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
    case EtherScan.Api.get_tx_receipt(String.trim(tx_hash)) do
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

  defp status_color(0), do: "badge error-status"
  defp status_color(1), do: "badge success-status"
  defp status_color(2), do: "badge pending-status"

  defp hide_element(true), do: "hide-element"
  defp hide_element(false), do: ""
end
