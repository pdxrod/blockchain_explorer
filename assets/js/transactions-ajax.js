$( "#transactions_submit_button" ).on( "click", function() {
  findTransactionsInBackground();
});

function findTransactionsInBackground() {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
     document.getElementById( "more_transactions" ).innerHTML ="foobar" // this.responseText;
    }
  };
  xhttp.open("GET", "/transactions/find", true);
  xhttp.send();
}
