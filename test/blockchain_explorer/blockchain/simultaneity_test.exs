defmodule BlockChainExplorer.SimultaneityTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils.AsynchronousTask

  describe "simultaneity test" do
# These two should write *-*-*- to the screen
    task_a = Task.async( fn() -> AsynchronousTask.do_something() end)
    task_b = Task.async( fn() -> AsynchronousTask.do_something_else() end)
    task_c = Task.async( fn() -> AsynchronousTask.really_do_something_else() end)
  # This slowly produces a 3-item list
    result = Task.await task_c
    Task.await task_a
    Task.await task_b
    assert ["foo", "foo", "foo"] == result
  end

end
