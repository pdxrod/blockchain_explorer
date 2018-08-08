defmodule BlockChainExplorer.SimultaneityTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils.AsynchronousTask

  describe "simultaneity test" do
    task_a = Task.async( fn() -> AsynchronousTask.do_something() end)
    task_b = Task.async( fn() -> AsynchronousTask.do_something_else() end)
    task_c = Task.async( fn() -> AsynchronousTask.really_do_something_else() end)
    Task.await task_a
    Task.await task_b
    result = Task.await task_c
    IO.inspect result
  end

end
