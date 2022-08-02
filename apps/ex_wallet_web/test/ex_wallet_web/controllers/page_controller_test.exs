defmodule ExWalletWeb.PageControllerTest do
  use ExWalletWeb.ConnCase

  test "Redirect any url to: /", %{conn: conn} do
    conn = get(conn, "/ddd")

    assert html_response(conn, 302) =~
             "<html><body>You are being <a href=\"/\">redirected</a>.</body></html>"
  end
end
