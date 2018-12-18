defmodule BlockChainExplorer.Repo.Migrations.AddHashIndexToBlocks do
  use Ecto.Migration

  def change do
    create unique_index(:blocks, [:hash])
  end

end
