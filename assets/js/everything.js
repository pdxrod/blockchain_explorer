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

var transactions_please_wait_message = document.getElementById( "transactions_please_wait_message" );
if( transactions_please_wait_message ) {
  $( document ).ready( function() {
    transactions_please_wait_message.style.visibility = "visible";
    console.log( "Calling ajax " );
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if( this.readyState == 4 && this.status == 200 ) {
        console.log( "ajax " + this.responseText );
        document.getElementById( "more_transactions" ).innerHTML = this.responseText;
      }
    };

    var address = document.getElementById( "address" );
    console.log( "address " + address );
    var transactions_address = address.innerHTML.trim();
    console.log( "ajax " + transactions_address );

    xhttp.open( "GET", "/find/" + transactions_address, true );
    xhttp.send();
  });
}
