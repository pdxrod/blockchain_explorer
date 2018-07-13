
$( "#blocks_show_submit_button" ).on( "click", function() {
  document.getElementById( "please_wait_message" ).style.visibility = "visible";
});
$( "#blocks_show_submit_button" ).addEventListener( "click", disable_blocks_submit_button(), false );
function disable_blocks_submit_button() {
};
