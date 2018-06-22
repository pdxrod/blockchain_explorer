# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :blockchain_explorer, bitcoin_url: "http://USERNAME:PASSWORD@127.0.0.1:18332"
config :blockchain_explorer, base_16_address_regex: ~r/^([A-Fa-f0-9]{64})$/
config :blockchain_explorer, base_58_partial_regex: ~r/^([1-9a-km-zA-HJ-NP-Z])$/
config :blockchain_explorer, base_58_address_regex: ~r/^([1-9a-km-zA-HJ-NP-Z]{35})/

# Configures the endpoint
config :blockchain_explorer, BlockChainExplorerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iAk3XzhkACUWGx6517EPLuswkibOEagnemvzsz5czCR5h6sf52urW9w4NP+H2CV5",
  render_errors: [view: BlockChainExplorerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BlockChainExplorer.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
