defmodule BlockChainExplorer.Repo.Migrations.CreateOutputs do
  use Ecto.Migration

  def change do
    create table(:outputs) do
      add :transaction_id, :integer
      add :input_id, :integer
      add :value, :float
      add :n, :integer
      add :asm, :string
      add :hex, :string
    end
    create unique_index(:outputs, [:transaction_id])
  end

end
