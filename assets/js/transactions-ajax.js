$( "#transactions_submit_button" ).on( "click", function() {
  findTransactionsInBackground();
});

function findTransactionsInBackground() {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if( this.readyState == 4 && this.status == 200 ) {
      document.getElementById( "more_transactions" ).innerHTML = this.responseText;
    }
  };
  var address = document.getElementById( "transactions_address" ).value
  xhttp.open( "GET", "/transaction/find/" + address, true );
  xhttp.send();
}
