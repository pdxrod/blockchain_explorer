defmodule BlockChainExplorer.Block do
  alias BlockChainExplorer.Blockchain

  defmodule Foo do
    defstruct type: nil
  end

  defstruct hash: "", foo: :bar

  def get_x( str ) do
    str
  end

end
