MIX_ENV=prod mix phx.digest
MIX_ENV=prod PORT=4000 elixir --detached -S mix phx.server

