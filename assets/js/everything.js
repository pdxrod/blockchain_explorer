var form_number = $( "form#number" );
if( form_number ) { // You're on the /blocks page
    form_number.submit( function() {
      $( this ).find( ":input[type=submit]" ).prop( "disabled", true );
  } );
// Thanks https://stackoverflow.com/questions/5691054/disable-submit-button-on-form-submit
  $( "#blocks_show_submit_button" ).on( "click", function() {
    // document.getElementById( "blocks_please_wait_message" ).style.visibility = "visible";
  } );
}

var LOOP = 12;
var TIME = 10000;

var transactions_please_wait_message = document.getElementById( "transactions_please_wait_message" );
if( transactions_please_wait_message ) { // You're on the /transactions page
  $( document ).ready( function() {
    transaction_finder_loop( LOOP );
  } );
}

function transactions_div_extractor( page ) {
  var starting = page.indexOf( "<div id=\"transactions_block\">" );
  var ending = page.length - 1;
  var div = page.substring( starting, ending );
  ending = div.indexOf( "</div>" ) + 6;
  div = div.substring( 0, ending );
  return div;
}

function transaction_finder_loop( n ) {
   setTimeout( function () {
     transactions_please_wait_message.style.visibility = "visible";
     var address = document.getElementById( "address" );
     var transactions_address = address.innerHTML.trim();

     $.ajax( {
         url : "/find/" + transactions_address,
         success : function( result ) {
           var div = transactions_div_extractor( result );
           document.getElementById( "transactions" ).innerHTML = div;
         }
     } );

     n -- ;
     if( n > 0 ) {
       var msg = transactions_please_wait_message.innerHTML.trim();
       msg += "...";
       transactions_please_wait_message.innerHTML = msg;
       transaction_finder_loop( n );
     } else {
       transactions_please_wait_message.style.visibility = "hidden";
     }

   }, TIME );
}
