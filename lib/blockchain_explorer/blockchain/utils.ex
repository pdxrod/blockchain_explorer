defmodule BlockChainExplorer.Utils do

  types = ~w[function nil integer binary bitstring list map float atom tuple pid port reference]
  for type <- types do
    def typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)
  end

  def recurse( fail, succeed, collection, fun ) do
    case collection do
      [] -> fail
      [head | tail] ->
        cond do
          fun( head ) -> succeed
          true -> recurse( fail, succeed, condition, tail, fun )
        end
    end
  end

end
