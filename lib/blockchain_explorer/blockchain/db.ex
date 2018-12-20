defmodule BlockChainExplorer.Db do
  use Ecto.Schema
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Repo

  def insert( block ) do
    Repo.insert block
    block
  end

end
