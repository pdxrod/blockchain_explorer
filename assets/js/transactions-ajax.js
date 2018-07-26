$( "#transactions_submit_button" ).on( "click", function() {
  console.log( "calling findTransactionsInBackground() " );

  findTransactionsInBackground();
});

function findTransactionsInBackground() {
  var xhttp = new XMLHttpRequest();
  console.log( "findTransactionsInBackground() " );
  xhttp.onreadystatechange = function() {
    if( this.readyState == 4 && this.status == 200 ) {
      console.log( "findTransactionsInBackground "+this.responseText );
      document.getElementById( "more_transactions" ).innerHTML = this.responseText;
    }
  };
  var address = document.getElementById( "transactions_address" ).value;
  console.log( "findTransactionsInBackground "+address );

  xhttp.open( "GET", "/transactions_ajax/" + address, true );
  xhttp.send();
}
