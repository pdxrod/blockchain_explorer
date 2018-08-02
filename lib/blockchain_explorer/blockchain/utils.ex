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

  def mt?( thing ) do
    thing == nil || thing == "" || thing == '' || thing == %{} || thing == [] || thing == {}
  end

  def notmt?( thing ) do
    ! mt?( thing )
  end

  def div_extractor( page ) do
    starting = :binary.match( page, "<div id='transactions_block'>" ) |> elem( 0 )
    ending = String.length( page ) - 1
    div = String.slice page, starting, ending
    ending = :binary.match( div, "</div>" ) |> elem( 0 )
    ending = ending + 6
    String.slice div, 0, ending
  end

  def env( atom ) do
    Application.get_env( :blockchain_explorer, atom )
  end

end
