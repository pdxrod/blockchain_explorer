defmodule BlockChainExplorer.Db.Migrations.ChangeTxToText do
  use Ecto.Migration

  def change do
    alter table(:blocks) do
      modify :tx, :text
    end
  end

end
