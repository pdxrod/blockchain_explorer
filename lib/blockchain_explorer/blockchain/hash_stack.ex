defmodule BlockChainExplorer.HashStack do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__ )
  end

  defp block?( %{} ), do: true
  defp block?( _ ), do: false

  def push( block ) do
    if ! block?( block ), do: raise "HashStack only accepts blocks"
    Agent.update(__MODULE__, &List.insert_at( &1, 0, block ))
  end

  def pop() do
    result = Agent.get(__MODULE__, &List.pop_at( &1, 0 ))
    block = elem( result, 0 )
    Agent.update(__MODULE__, &List.delete_at( &1, 0 ))
    block
  end

  defp do_nothing() do
  end

  def pop_til_empty() do
    block = pop()
    cond do
      block == nil -> do_nothing()
      true -> pop_til_empty()
    end
  end

  def peek() do
    result = Agent.get(__MODULE__, &List.pop_at( &1, 0 ))
    elem( result, 0 )
  end
end
