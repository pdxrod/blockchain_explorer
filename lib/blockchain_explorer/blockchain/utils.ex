defmodule BlockChainExplorer.Utils do
  alias BlockChainExplorer.Rpc

  defmodule AsynchronousTask do
    defstruct foo: nil, bar: nil

    def do_something do
      for n <- 1..3 do
        :timer.sleep 333
        IO.write "*"
      end
    end

    def do_something_else do
      for n <- 1..3 do
        :timer.sleep 333
        IO.write "-"
      end
    end

    defp foo do
      :timer.sleep 333
      "foo"
    end

    def really_do_something_else do
      Enum.map( ["foo", "bar", "baz"], fn(item) -> foo() end)
    end
  end

  @types ~w[function nil integer binary bitstring list map float atom tuple pid port reference]
  for type <- @types do
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

  def mode do # 'main', 'test' or 'regtest'
    result_tuple = Rpc.getmininginfo
    if elem( result_tuple, 0 ) == :ok do
      info = elem( result_tuple, 1 )
      info[ "chain" ]
    else
      error result_tuple
    end
  end

  def is_in_list?( list, item ) do
    case list do
      [] -> false
      [ head | tail ] -> if item == head, do: true, else: is_in_list?( tail, item )
    end
  end

  def is_in_tuple?( tuple, item ) do
    is_in_list? Tuple.to_list( tuple ), item
  end

  def tuple_test( num ) do
    if num <= 1 do
      {:one}
    else
      {:more_than_one}
    end
  end

  def join_with_spaces( list_of_strings ) do
    case list_of_strings do
      [] ->
        ""
      [ head | tail ] ->
        head <> if length(tail) < 1, do: "", else: " " <> join_with_spaces( tail )
    end
  end

  defp translate_message msg do
    result = case msg do
      "econnrefused" ->
        "Unable to connect to Bitcoin"
      "timeout" ->
        "Timed out connecting to Bitcoin"
      "Loading block index..." ->
        "Bitcoin is not up and running yet"
      "Block not found" ->
        "Block not found in this blockchain"
      "JSON integer out of range" ->
        "Invalid value for block"
      "0" ->
        "Security issue"
      _ -> msg
    end
    result
  end

# Various functions produce a range of not-ok results - this reduces them to one simple form - %{error: "message"}
  defp find_message( arg ) do
    message = case typeof( arg ) do
                "tuple" ->
                  "#{ find_message( elem( arg, tuple_size( arg ) - 1 )) }"
                "map" ->
                  "#{ find_message( List.last( Map.values( arg )) ) }"
                "list" ->
                  "#{ find_message( List.last( arg ) ) }"
                _ ->
                  "#{ arg }"
              end
    translate_message message
  end

  def error( tuple ) do
    err = case typeof( tuple ) do
      "tuple" ->
        if elem( tuple, 0 ) == :ok, do: raise "Utils.error should not be used with tuples beginning with :ok"
        atom = elem( tuple, 0 )
        tail = Tuple.delete_at tuple, 0
        result = Map.new [ {:error, find_message( tail )} ]

        if atom != :error, do: %{error: "#{ atom } " <> result[:error]}, else: result
      _ -> %{error: find_message( tuple )}
    end
    err
  end

  def message do
    blockchain = mode()
    msg =
      case blockchain do
        "regtest" -> "The explorer is running in 'regtest' mode. This saves disk space, but there is limited data."
        "main" -> "The explorer is running as a full 'mainnet' node, communicating with the real blockchain."
        "test" -> "The explorer is running in 'testnet' mode, which is like a full node, but without real money."
        _ -> "#{blockchain[:error]}"
      end
    if String.starts_with? msg, "The explorer" do
      "<span>#{ msg }</span>"
    else
      "<span class='error'>#{ msg }</span>"
    end
  end

  def index( mainstring, searchstring ) do
    tuple = (:binary.match mainstring, searchstring)
    if tuple === :nomatch do
       nil
    else
       elem(tuple, 0)
    end
  end
end
