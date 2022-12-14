import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ex_wallet, ExWallet.Repo,
  url: String.replace(System.get_env("DATABASE_URL"), "?", "test"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_wallet_web, ExWalletWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QbDaD/tNIoNr9D757vc0Z3va0JRSPQYMEHXW6SQ3E3HbgGbGsXTWxHdF5fSIWFPf",
  server: false

# EtherScan  configs
config :tesla, Integration.EtherScan.Api, adapter: Integration.EtherScan.Adapter.Mock

config :integration, :etherscan, api_key: "TEST_API_KEY"

# Print only warnings and errors during test
config :logger, level: :error

# In test we don't send emails.
config :ex_wallet, ExWallet.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
