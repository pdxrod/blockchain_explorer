
$( "form#number" ).submit( function() {
    $( this ).find( ":input[type=submit]" ).prop( "disabled", true );
});
// Thanks https://stackoverflow.com/questions/5691054/disable-submit-button-on-form-submit
$( "#blocks_show_submit_button" ).on( "click", function() {
  document.getElementById( "please_wait_message" ).style.visibility = "visible";
});
