defmodule BlockChainExplorer.DivExtractorTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils

  @page """
  <!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Blockchain Explorer</title>

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" integrity="sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB" crossorigin="anonymous">
    <link rel="stylesheet" href="/css/app.css">
    <script src="http://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js" integrity="sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T" crossorigin="anonymous"></script>
   </head>

   <body>
      <div class="outer">
        <span id="error"></span>

        <div class="container">
          <span class="links"; style="display: inline-block !important;"><a href="/blocks">home</a></span>&nbsp;&nbsp;&nbsp;
          <span class="links"; style="display: inline-block !important;"><a href="/index">blocks</a></span>
          <br />
          <br />
<div id='transactions_block'>
  TRANSACTIONS_HERE
</div>
        </div>

        <script src="/js/app.js"></script>

      </div>
   <iframe src="/phoenix/live_reload/frame" style="display: none;"></iframe>
</body>
</html>
"""

@div "<div id='transactions_block'>
  TRANSACTIONS_HERE
</div>"

  describe "div extractor" do

    test "div extractor for transactions page" do
      assert Utils.div_extractor( @page ) == @div
    end

  end
end
