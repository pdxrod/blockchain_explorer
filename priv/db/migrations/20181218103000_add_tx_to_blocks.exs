defmodule BlockChainExplorer.Db.Migrations.AddTxToBlocks do
  use Ecto.Migration

  def change do
    alter table(:blocks) do
      add :tx, :string
    end
  end

end
