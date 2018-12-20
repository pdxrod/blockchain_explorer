use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# BlockChainExplorerWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :blockchain_explorer, BlockChainExplorerWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :blockchain_explorer, BlockChainExplorer.Repo,
  adapter: Ecto.Adapters.MySQL,
  database: "blockchain_explorer_prod",
  username: "",
  password: "",
  hostname: "localhost"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :blockchain_explorer, BlockChainExplorerWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :blockchain_explorer, BlockChainExplorerWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :blockchain_explorer, BlockChainExplorerWeb.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
### Removed for gigalixir: https://gigalixir.readthedocs.io/en/latest/main.html#modifying-existing-app
# import_config "prod.secret.exs"
config :blockchain_explorer, BlockChainExplorerWeb.Endpoint,
  load_from_system_env: true,
  # http: [port: {:system, "PORT"}], # Uncomment this line if you are running Phoenix 1.2
  server: true, # Without this line, your app will not start the web server!
  secret_key_base: "${SECRET_KEY_BASE}",
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"
