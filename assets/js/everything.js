console.log( "everything.js" );

var form_number = $( "form#number" );
if( form_number ) { // You're on the /blocks page
    form_number.submit( function() {
      $( this ).find( ":input[type=submit]" ).prop( "disabled", true );
  } );
// Thanks https://stackoverflow.com/questions/5691054/disable-submit-button-on-form-submit
  $( "#blocks_show_submit_button" ).on( "click", function() {
    document.getElementById( "blocks_please_wait_message" ).style.visibility = "visible";
  } );
}

var transactions_please_wait_message = document.getElementById( "transactions_please_wait_message" );
if( transactions_please_wait_message ) { // You're on the /transactions page
  $( document ).ready( function() {
    transaction_finder_loop( 30 );
  } );
}

function div_extractor( page ) {
  var starting = page.indexOf( "<div id='transactions_block'>" );
  console.log( "div_extractor - starting is "+starting );
  var ending = page.length - 1;
  var div = page.substring( starting, ending );
  ending = div.indexOf( "</div>" ) + 6;
  div = div.substring( 0, ending );
  console.log( "div_extractor '" + div + "'" );
  return div;
}

function transaction_finder_loop ( n ) {
   setTimeout(function () {
     var address = document.getElementById( "address" );
     console.log( "address " + address );
     var transactions_address = address.innerHTML.trim();
     console.log( "ajax " + transactions_address );

     transactions_please_wait_message.style.visibility = "visible";
     console.log( "Calling ajax " );
     var address = document.getElementById( "address" );
     console.log( "address " + address );
     var transactions_address = address.innerHTML.trim();
     console.log( "ajax " + transactions_address );
     $.ajax( {
         url : "/find/" + transactions_address,
         success : function( result ) {
        //   var div = div_extractor( result.trim() );
        //   document.getElementById( "transactions" ).innerHTML = div;
           document.getElementById( "transactions" ).innerHTML = result;
         }
     } );

     n -- ;
     if( n > 0 ) {
       transaction_finder_loop( n );
     }

   }, 6000 );
}
