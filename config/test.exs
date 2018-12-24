use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :blockchain_explorer, BlockChainExplorerWeb.Endpoint,
  http: [port: 4001],
  server: false

config :blockchain_explorer, BlockChainExplorer.Db,
  adapter: Ecto.Adapters.MySQL,
  database: "blockchain_explorer_test",
  username: "root",
  password: "",
  hostname: "localhost"

# Print only warnings and errors during test
config :logger, level: :warn
