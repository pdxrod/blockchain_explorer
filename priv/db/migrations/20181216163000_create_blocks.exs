defmodule BlockChainExplorer.Db.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add :block, :text
      add :hash, :string
      add :height, :integer
      add :previousblockhash, :string
      add :nextblockhash, :string
      add :weight, :integer
      add :versionhex, :string
      add :version, :integer
      add :time, :integer
      add :strippedsize, :integer
      add :size, :integer
      add :nonce, :integer
      add :merkleroot, :string
      add :mediantime, :integer
      add :difficulty, :float
      add :confirmations, :integer
      add :chainwork, :string
      add :bits, :string
      timestamps()
    end
    create unique_index(:blocks, [:height])
  end

end
