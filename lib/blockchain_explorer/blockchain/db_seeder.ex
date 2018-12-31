defmodule BlockChainExplorer.DbSeeder do
  use GenServer
# Thanks https://stackoverflow.com/questions/51293467/calling-function-on-phoenix-app-start

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    BlockChainExplorer.Transaction.seed_db_and_get_a_useful_transaction()

    Process.sleep(30_000)

    {:ok, state, 60_000}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end
end
