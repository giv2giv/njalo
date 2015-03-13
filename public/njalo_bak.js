(function(window, document) {"use strict";  /* Wrap code in an IIFE */

var jQuery, $; // Localize jQuery variables

var HOST = 'http://localhost:3000/'; // also set host in widget_example.html

function loadScript(url, callback) {
  /* Load script from url and calls callback once it's loaded */
  var scriptTag = document.createElement('script');
  scriptTag.setAttribute("type", "text/javascript");
  scriptTag.setAttribute("src", url);
  if (typeof callback !== "undefined") {
    if (scriptTag.readyState) {
      /* For old versions of IE */
      scriptTag.onreadystatechange = function () { 
        if (this.readyState === 'complete' || this.readyState === 'loaded') {
          callback();
        }
      };
    } else {
      scriptTag.onload = callback;
    }
  }
  (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(scriptTag);
}


function main() {
  $(document).ready(function(){

    /* The main logic of our widget is here */
    /* We should have fully loaded jquery, jquery-ui and all plugins */

    /******* Load CSS *******/
    var css_link = $("<link>", { // always use var
        rel: "stylesheet", 
        type: "text/css", 
        href: "//ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/themes/south-street/jquery-ui.css" 
    });
    css_link.appendTo('head');

    var script = $('#njalo-script'); // always use var
    var div = $('#njalo-donation');

    // better to div.load('widget_contents.html') and put everything in there?

    div.css(
      {
        'border':'3px solid black',
        'height':50,
        'width':125
      }// or inside style.css?
    ); 

    /******* Load charity data *******/
    var charity_id = script.data('charity-id');

    if (charity_id == null) {
      var div_html = "script tag missing data-charity-id=YOURCHARITYID";
      div.html(div_html);
      return;
    }

    var json_url = HOST + "charities/"+charity_id+"/widget_data.json";
    $.getJSON(json_url, function(charity) {

        div_html = '<form method="GET" action="#" id="frm-donate">' +
        '<div id="dialog-form" class="section">' +
            '<h1>Donate to ' + charity.name +
            '</h1>' +
            '<p class="small">Use the slider below to choose a donation amount, or enter your own.</p>' +
            '<div class="donation slider">' +
              '<div id="slider"></div>' +
            '</div>' +

            '<div class="buttons">' +
              '<div class="raised">' +
                '<p>Amount Raised:<span>some other var</span></p>' +
              '</div>' +
              '<div class="amount">' +
                '<p>Your Donation<br /><input type="text" id="amount" name="amount" value="$5.00" /></p>' +
              '</div>' +

              '<a href="javascript:void(0);" class="button dwolla medium" id="pay-dwolla">Donate with Dwolla</a>' +
              '<a href="javascript:void(0);" class="button stripe medium" id="pay-stripe">Donate with Credit Card</a>' +
              '<div class="fee_assumption">' +
                '<div>' +
                  '<input type="checkbox" name="assumeFees" id="assumeFees" value="1" />' +
                  '<label for="assumeFees">Assume transaction fees?</label>' +
                '</div>' +

                '<p id="understanding-fees" data-tooltip="The payment fee depends on the donation method. You can either assume the cost or allow the nonprofit to pay the fee. By default the nonprofit will assume the cost.||Here is fee table to give you a good sense of the process:||Dwolla:|$10 and under = free to send/receive money|$10.01 and over = flat fee of 25&cent;||Credit Card:|2.9% + 30&cent; for any transaction.||Some participating organizations have sponsors that help cover the costs of processing fees.">(<span>Understanding transactions fees</span>)</p>' +
              '</div>' +
            '</div>' +

        '</div>' +
      '</form>';
      div.html(div_html).load(setupButton(charity));
 //     alert(div.html.length);
   //   var myInterval = setInterval(function(){ if (div.length){ clearInterval(myInterval); setupButton(charity); } },10);//run it every 10ms

      //}); // end window.load DOM ready
    }); /* end getJSON */
  }); // end document.ready
} // end main

/* Load jQuery */
loadScript("//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js", function() {
  /* Restore $ and window.jQuery to their previous values and store the
     new jQuery in our local jQuery variables. */
  $ = jQuery = window.jQuery.noConflict(true);

  loadScript("jquery-ui.min.js", function() {
    initjQueryUIPlugin(jQuery);
    loadScript("jquery.validate.min.js", function() {
      initjQueryValidatePlugin(jQuery);
      main();
    });
  });
});

function setupButton(charity) {

      // set up the div's html after it's fully loaded in the DOM
      //$(window).load(function(){


        // dialog not found -- why?? div's .html not processed by DOM?

/*
        dialog = $( "#dialog-form" ).dialog({
          autoOpen: false,
          height: 300,
          width: 350,
          modal: true,
          buttons: {
            "Create an account": (function(){}),
            Cancel: function() {
              dialog.dialog( "close" );
            }
          },
          close: function() {
            form[ 0 ].reset();
            allFields.removeClass( "ui-state-error" );
          }
        });

        div.button().on( "click", function() {
          dialog.dialog( "open" );
        });
*/
        var gateway = {
          min: 0.01,
          inc: 5.00,
          str: 5.00,
          assumeFees: false
        }
        var frm = $('#frm-donate'),
        slider = $('#slider'),
        amount = $('#amount'),
        dwollaPayBtn = $('#pay-dwolla'),
        stripePayBtn = $('#pay-stripe'),
        gatewayOpts = $.extend({
          min: 0.01,
          inc: 5.00,
          str: 5.00,
          assumeFees: false
        }, gateway);

        // Update the payment form according
        // to whichever gateway the user
        // chooses to pay with
        stripePayBtn.click(function() {
          frm
            .attr('action', '/donate/' + charity.id + '/stripe')
            .submit();
        });
        dwollaPayBtn.click(function() {
          frm
            .attr('action', 'http://localhost:3000/charities/' + charity.id + '/dwolla')
            .submit();
        });

        // Init the amount slider
        slider.slider({
          animate: true,
          value: gatewayOpts.str,
          min: 0,
          max: 500,
          step: gatewayOpts.inc,
          slide: function(event, ui) {
            amount
              .val("$" + ui.value) // Update donation amount
              .trigger('update'); // Parse, format, update
          }
        });

        // Attach listeners to the input field
        amount
          .on('keyup blur update', function(e) {
            // Parse input field
            var rawVal = parseStrToNum(amount.val());

            // Update slider amount, but only
            // if the update didn't originate 
            // from the manual slider change
            if(e.type !== 'update') {
              slider.slider("value", rawVal);
            }

            // Toggle payment buttons
            // according to the donation amount
            if(typeof rawVal !== 'undefined') {
              stripePayBtn.toggle(!(rawVal < 0.50));
              dwollaPayBtn.toggle(!(rawVal > 5000));
            }
            
      /*
            // Generate and update tooltips
            var stripeMoneyLeft = gatewayOpts.assumeFees ? rawVal : (rawVal - ((rawVal * 0.029) + 0.30)),
              dwollaMoneyLeft = gatewayOpts.assumeFees ? rawVal : (rawVal - (rawVal > 10 ? 0.25 : 0));

            stripePayBtn
              .data('tooltip', 'The nonprofit will receive <strong>$' + stripeMoneyLeft.formatMoney(2, '.', ',') + '</strong> (after fees) using this method')
              .tooltip('refresh');
            dwollaPayBtn
              .data('tooltip', 'The nonprofit will receive <strong>$' + dwollaMoneyLeft.formatMoney(2, '.', ',') + '</strong> (after fees) using this method')
              .tooltip('refresh');
      */

            // No need to format the amount
            // on every keystroke
            if(e.type !== 'keyup') {
              // Parse and format amount
              var rawVal = parseStrToNum(amount.val()) || gatewayOpts.min,
                val = rawVal.formatMoney(2, '.', ',');
        
              // Update input field
              amount.val('$' + val);
            }
          })
          .on('click', function() {
            // Select all text in input field
            // when clicking inside it
            amount
              .focus()
              .select();
          });

        // Manually update the field amount
        // to match the slider's initial amount
        // and trigger a blur event to update
        // the tooltips
        amount
          .val("$" + slider.slider("value"))
          .trigger('update');

        // Fee assumption toggle button
        $('#assumeFees').change(function() {
          var el = $(this);
          
          gatewayOpts.assumeFees = el.is(':checked');
          amount.trigger('update'); // Update tooltips
        });
} // end SETUP Button

/**
 * Parses a string into a number
 *
 * parseStrToNum('$0.01aab');
 * @desc removes all non-alpha numeric characters from the string
 *
 * @name parseStrToNum
 * @param {string} string to parse
 * @return {number} parsed number
*/
var parseStrToNum = function(str) {
  var val = +str.replace(/[^0-9\.]+/g, '');

  return val;
}

/**
 * Formats a number into currency standards
 *
 * .formatNumber(2, '.', ',');
 * @desc adds dots and commas to format a number into currency
 *       standards
 *
 * @name parseStrToNum
 * @param {string} string to parse
 * @return {number} parsed number
*/
Number.prototype.formatMoney = function(c, d, t){
  var n = this, c = isNaN(c = Math.abs(c)) ? 2 : c, d = d == undefined ? "," : d, t = t == undefined ? "." : t, s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;

  return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
}


}(window, document)); /* end IIFE */

