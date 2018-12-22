defmodule BlockChainExplorer.Repo.Migrations.CreateInputs do
  use Ecto.Migration

  def change do
    create table(:inputs) do
      add :transaction_id, :integer
      add :sequence, :bigint
      add :scriptsig, :string
      add :coinbase, :string
      add :asm, :string
      add :hex, :string
    end
    create unique_index(:inputs, [:transaction_id])
  end

end
