console.log( "everything.js" );

var form_number = $( "form#number" );
if( form_number ) {
  $( "form#number" ).submit( function() {
      $( this ).find( ":input[type=submit]" ).prop( "disabled", true );
  });
// Thanks https://stackoverflow.com/questions/5691054/disable-submit-button-on-form-submit
  $( "#blocks_show_submit_button" ).on( "click", function() {
    document.getElementById( "blocks_please_wait_message" ).style.visibility = "visible";
  });
}

function findTransactionsInBackground() {
  var xhttp = new XMLHttpRequest();
  console.log( "findTransactionsInBackground() " );
  xhttp.onreadystatechange = function() {
    if( this.readyState == 4 && this.status == 200 ) {
      console.log( "findTransactionsInBackground " + this.responseText );
      document.getElementById( "more_transactions" ).innerHTML = this.responseText;
    }
  };
  var address = document.getElementById( "transactions_address" ).value;
  console.log( "findTransactionsInBackground " + address );

  xhttp.open( "GET", "/find/" + address, true );
  xhttp.send();
}

var transactions_please_wait_message = document.getElementById( "transactions_please_wait_message" );
if( transactions_please_wait_message ) {
  $( document ).ready( function() {
    document.getElementById( "transactions_please_wait_message" ).style.visibility = "visible";
    console.log( "Calling findTransactionsInBackground() " );
    findTransactionsInBackground();
  });
}
