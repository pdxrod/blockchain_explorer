defmodule BlockChainExplorer.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :block_id, :integer
      add :vsize, :integer
      add :outputs, :string
      add :inputs, :string
      add :version, :string
      add :txid, :string
      add :size, :string
      add :locktime, :integer
      add :hash, :string
    end
    create unique_index(:transactions, [:hash])
    create unique_index(:transactions, [:txid])
  end

end
