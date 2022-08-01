defmodule ExWalletWeb.PageController do
  use ExWalletWeb, :controller

  def always_redirect(conn, _params) do
    redirect(conn, to: "/")
  end
end
