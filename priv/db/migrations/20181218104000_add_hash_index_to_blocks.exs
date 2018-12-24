defmodule BlockChainExplorer.Db.Migrations.AddHashIndexToBlocks do
  use Ecto.Migration

  def change do
    create index(:blocks, [:hash])
  end

end
