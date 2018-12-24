defmodule BlockChainExplorer.Db.Migrations.AddAddressesToOutputs do
  use Ecto.Migration

  def change do
    alter table(:outputs) do
      add :addresses, :string
    end
  end

end
