defmodule BlockChainExplorer.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :output_id, :integer
      add :input_id, :integer
      add :address, :string
    end
  end

end
