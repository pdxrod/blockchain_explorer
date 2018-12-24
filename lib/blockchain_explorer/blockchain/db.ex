defmodule BlockChainExplorer.Db do
  use Ecto.Repo, otp_app: :blockchain_explorer

  def get_db_result_from_tuple( tuple ) do
    if elem( tuple, 0 ) == :ok, do: elem( tuple, 1 ), else: %{}
  end
end
