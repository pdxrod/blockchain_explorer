defmodule BlockChainExplorer.Repo.Migrations.CreateInputs do
  use Ecto.Migration

  def change do
    create table(:inputs) do
      add :transaction_id, :integer
      add :sequence, :integer
      add :scriptsig, :string
      add :coinbase, :string
      add :asm, :string
      add :hex, :string
      timestamps()
    end
    create unique_index(:inputs, [:transaction_id])
  end

end
