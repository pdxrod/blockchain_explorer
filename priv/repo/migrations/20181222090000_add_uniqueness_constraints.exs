defmodule BlockChainExplorer.Repo.Migrations.AddUniquenessConstraints do
  use Ecto.Migration

  def change do
    create unique_index(:outputs, [:transaction_id, :asm])
    create unique_index(:inputs, [:transaction_id, :asm])
    create unique_index(:addresses, [:output_id, :address])
  end

end
