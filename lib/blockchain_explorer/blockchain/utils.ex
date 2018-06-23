defmodule BlockChainExplorer.Utils do

  types = ~w[function nil integer binary bitstring list map float atom tuple pid port reference]
  for type <- types do
    def typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)
  end

  def recurse( fail, succeed, collection, condition ) do
    case collection do
      [] -> fail
      [head | tail] ->
        cond do
          condition.( head ) -> succeed
          true -> recurse( fail, succeed, tail, condition )
        end
    end
  end

  def notmt?( thing ) do
    thing != nil && thing != ""
  end

  def env( atom ) do
    Application.get_env( :blockchain_explorer, atom )
  end

end
