defmodule ExWallet.Repo do
  use Ecto.Repo,
    otp_app: :ex_wallet,
    adapter: Ecto.Adapters.Postgres
end
