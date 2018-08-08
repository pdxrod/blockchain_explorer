defmodule BlockChainExplorer.SimultaneityTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils.AsynchronousTask

  describe "simultaneity test" do
    a = %AsynchronousTask{}
    b = %AsynchronousTask{}
    IO.puts ""
    task_a = Task.async( fn() -> AsynchronousTask.do_something() end)
    task_b = Task.async( fn() -> AsynchronousTask.do_something_else() end)
    Task.await(task_a);
    Task.await(task_b);
  end

end
