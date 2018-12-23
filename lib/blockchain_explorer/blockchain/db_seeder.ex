defmodule BlockChainExplorer.DbSeeder do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    BlockChainExplorer.Transaction.seed_db_and_get_a_useful_transaction()

    Process.sleep(10_000)

    # Process will send :timeout to self after 1 second
    {:ok, state, 1_000}
  end

  @impl true
  def handle_info(:timeout, state) do
    # Stop this process, because it's temporary it will not be restarted
    IO.inspect "Terminating DoSomething"
    {:stop, :normal, state}
  end
end
