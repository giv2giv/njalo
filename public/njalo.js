(function(window, document) {"use strict";  /* Wrap code in an IIFE */

var jQuery, $; // Localize jQuery variables

var HOST = 'http://10.0.0.1:3000/'; // also set host in widget_example.html
var STRIPE_KEY = 'pk_test_d678rStKUyF2lNTZ3MfuOoHy';

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

//    $(function() {

      /* The main logic of our widget is here */
      /* We should have fully loaded jquery, jquery-ui and all plugins */

      var script = $('#njalo-script'),

      campaign_preferences = {
        campaign_id: script.data('campaign-id'),
        minamt: script.data('minimum-amount'),
        maxamt: script.data('maximum-amount'),
        minpct: script.data('minimum-passthru-percentage'),
        maxpct: script.data('maximum-passthru-percentage'),
        inc: script.data('incremenent'),
        initial_amount: script.data('initial-amount'),
        initial_passthru: script.data('initial-passthru'),
        assume_fees: script.data('donor-assumes-fees')
      },
      div = $('#njalo-button'),
      frm = $('#njalo-form'),
      dialog = $('#njalo-dialog'),
      amountSlider = $('#njalo-amount-slider'),
      passthruSlider = $('#njalo-passthru-slider'),
      amount = $('#njalo-amount'),
      passthru = $('#njalo-passthru-percent'),
      donationDetails = $('#njalo-donation-details'),
      assumeFeesLabel = $('#njalo-assume-fees-label'),
      assumeFees = $('#njalo-assume-fees'),
      campaignPrefs = $.extend({
        campaign_id: null,
        minamt: 5.00,
        maxamt: 10000,
        minpct: 0,
        maxpct: 100,
        inc: 1.00,
        initial_amount: 25,
        initial_passthru: 50,
        assume_fees: true
      }, campaign_preferences);      

      div.css(
        {
          'border':'3px solid black',
          'height':50,
          'width':125
        }
      );

      assumeFees.prop("checked", campaignPrefs.assume_fees==true);

      if (campaignPrefs.campaign_id == null) {
        var div_html = "script tag missing data-campaign-id=YOURCAMPAIGNID";
        div.html(div_html);
        return;
      }

      // tabify bank account / credit card tabs
      $( "#njalo-tabs" ).tabs({
        activate: function() {
          donationDetails.empty().append(returnFormattedDonationDetails(amount, passthru, assumeFees));
          assumeFeesLabel.html(returnFormattedAmountDetails(amount));
        },
        create: function() {
          donationDetails.empty().append(returnFormattedDonationDetails(amount, passthru, assumeFees));
        }
      });

      var json_url = HOST + "campaigns/"+campaignPrefs.campaign_id+"/widget_data.json";

      $.getJSON(json_url, function(campaign) {
        var dialog = $( "#njalo-dialog" ).dialog({
          autoOpen: false,
          title: "Donate to " + campaign.name + " through giv2giv.org",
          height: 600,
          width: 500,
          modal: true,
          buttons: {
            Submit: function(){

              // increase amount if donor assuming fees
              campaignPrefs.assume_fees==true ? amount.val(parseStrToNum(amount.val())+calculateFee(amount)) : "";

              if ($('#njalo-tabs').tabs('option','active')==0) { // if tab 0 selected
                
                frm
                  .attr('action', HOST + '/charities/' + campaign.id + '/dwolla')
                  .submit();
              }
              else {
                // Disable the submit button to prevent repeated clicks
                frm.find('button').prop('disabled', true);

                Stripe.card.createToken(frm, function(status, response) {
                  if (response.error) {
                    // Show the errors on the form
                    frm.find('.payment-errors').text(response.error.message);
                    frm.find('button').prop('disabled', false);
                  } else {
                    // response contains id and card, which contains additional card details
                    var token = response.id;
                    // Insert the token into the form so it gets submitted to the server
                    amount.val(parseStrToNum(amount.val()));
                    frm
                      .append($('<input type="hidden" name="njalo-stripeToken" />').val(token))
                      .attr('action', HOST + '/charities/' + campaign.id + '/stripe')
                      .submit();
                  }

                });
              }
              // Prevent the form from submitting with the default action
              return false;
            },
            Cancel: function() {
              dialog.dialog( "close" );
            }
          },
          close: function() {
            amount.removeClass( "ui-state-error");
          }
        });

        // Show widget when button clicked
        div.button().on( "click", function() {
          dialog.dialog( "open" );
        });

        // Form submitted
        frm.on( "submit", function( event ) {
          if (whichProcessor()=='stripe') {
            event.preventDefault();
            $.ajax({
              data: frm.serialize(),
              url: HOST + '/campaigns/' + campaign.id + '/' + whichProcessor(),
              cache: false
            })
            .done(function ( response ) {
              console.log(response);
              // show 'Thank you!' maybe with print
            });
          }
        });

        // Init the amount slider
        amountSlider.slider({
          animate: true,
          value: campaignPrefs.initial_amount,
          min: campaignPrefs.minamt,
          max: campaignPrefs.maxamt,
          step: campaignPrefs.inc,
          slide: function(event, ui) {
            amount
              .val("$" + ui.value) // Update donation amount
              .trigger('update'); // Parse, format, update
          }
        });

        // Init the passthru slider
        passthruSlider.slider({
          animate: true,
          value: campaignPrefs.initial_passthru,
          min: campaignPrefs.minpct,
          max: campaignPrefs.maxpct,
          step: campaignPrefs.inc,
          slide: function(event, ui) {
            passthru
              .val(ui.value+"%") // Update donation passthru
              .trigger('update'); // Parse, format, update
          }
        });

        // set Stripe key

        $.getScript("https://js.stripe.com/v2/", function() {
            Stripe.setPublishableKey(STRIPE_KEY);
        });


        // Attach listeners to the amount input fields to update the slider when amount is changed
        amount
          .on('keyup blur update', function(e) {
            // Parse input field
            var rawVal = parseStrToNum(amount.val());

            // Update slider amount, but only
            // if the update didn't originate 
            // from the manual slider change
            if(e.type !== 'update') {
              amountSlider.slider("value", rawVal);
            }

            // No need to format the amount
            // on every keystroke
            if(e.type !== 'keyup') {
              // Parse and format amount
              var rawVal = parseStrToNum(amount.val()) || campaignPrefs.minamt,
                val = rawVal.formatMoney(2, '.', ',');
        
              // Update input field
              amount.val('$' + val);
            }

            // Update details
            donationDetails.html(returnFormattedDonationDetails(amount, passthru, assumeFees));
            assumeFeesLabel.html(returnFormattedAmountDetails(amount));
          })
          .on('click', function() {
            // Select all text in input field
            // when clicking inside it
            amount
              .focus()
              .select();
          });

          // Attach listeners to the amount input fields to update the slider when amount is changed
        passthru
          .on('keyup blur update', function(e) {
            // Parse input field
            var rawVal = parseStrToNum(passthru.val());

            // Update slider amount, but only
            // if the update didn't originate 
            // from the manual slider change
            if(e.type !== 'update') {
              passthruSlider.slider("value", rawVal);
            }

            // No need to format the amount
            // on every keystroke
            if(e.type !== 'keyup') {
              // Parse and format amount
              var rawVal = parseStrToNum(passthru.val()) || campaignPrefs.minpct,
                val = rawVal;//.formatPercent(2, '.', ',');
        
              // Update input field
              passthru.val(val+'%');
            }

            // Update details
            donationDetails.html(returnFormattedDonationDetails(amount, passthru, assumeFees));

          })
          .on('click', function() {
            // Select all text in input field
            // when clicking inside it
            passthru
              .focus()
              .select();
          });

        // Manually update the field amount
        // to match the slider's initial amount
        // and trigger a blur event to update
        // the tooltips
        amount
          .val("$" + amountSlider.slider("value"))
          .trigger('update');

        passthru
          .val(passthruSlider.slider("value")+'%')
          .trigger('update');

        // Fee assumption toggle button
        assumeFees.change(function() {
          var el = $(this);
          campaignPrefs.assumeFees = el.is(':checked');
          donationDetails.empty().append(returnFormattedDonationDetails(amount, passthru, assumeFees));
          assumeFeesLabel.html(returnFormattedAmountDetails(amount));
          amount.trigger('update'); // Update tooltips
          passthru.trigger('update'); // Update tooltips
        });

        // Validation
        $('.validate_form').each(function() {
           $(this).validate();
        });

        // Forms
        $('input')
          .on('focus', function() {
            $(this)
              .addClass('active')
              .parents('.input_wrapper')
                .addClass('active');
          })
          .on('blur', function() {
            $(this)
              .removeClass('active')
              .parents('.input_wrapper')
                .removeClass('active');
          });
        // Cool tooltips
        //$(document).tooltip( {
        //  content:function(){
        //    return this.getAttribute("title");
        //  }
        //});
        $( "#njalo-accordion" ).accordion({
          active: false,
          collapsible: true
        });

      /*
        // Bind form enter key
        $("form").not('#frm-feedback').find("input").last().keydown(function(e) {
          if(e.keyCode == 13) {
            $(this).parents('form').submit();
          }
        });




        // Generate and update tooltips
        var rawVal = parseStrToNum(amount.val()) || gatewayOpts.min
        var stripeMoneyLeft = gatewayOpts.assumeFees ? rawVal : (rawVal - ((rawVal * 0.029) + 0.30)),
          dwollaMoneyLeft = gatewayOpts.assumeFees ? rawVal : (rawVal - (rawVal > 10 ? 0.25 : 0));

        stripePayBtn
          .data('tooltip', 'The nonprofit will receive <strong>$' + stripeMoneyLeft.formatMoney(2, '.', ',') + '</strong> (after fees) using this method');
          .tooltip('refresh');
        dwollaPayBtn
          .data('tooltip', 'The nonprofit will receive <strong>$' + dwollaMoneyLeft.formatMoney(2, '.', ',') + '</strong> (after fees) using this method');
          .tooltip('refresh');
      */

      }); // getJSON end
  //});
} // end main()


/**
 * Returns an HTML string with the donations details
*/
var returnFormattedDonationDetails = function (amount, passthru, assumeFees) {
  var val, transactionAmount, amount_passthru, percent_passthru, amount_invested, net_amount=0, fee=0;

  if (assumeFees.is(':checked')) {
    transactionAmount = parseStrToNum(amount.val()) + calculateFee(amount);
  }
  else {
    transactionAmount = parseStrToNum(amount.val());
    fee = calculateFee(amount);
  }
  net_amount = transactionAmount - fee;

  percent_passthru = parseStrToNum(passthru.val()) / 100; // convert int to percent e.g. 50 to .5
  amount_passthru = net_amount * percent_passthru;
  amount_invested = net_amount - amount_passthru;

  val = "<h1>Summary:</h1>You will donate: $" + transactionAmount.formatMoney(2, '.', ',');
  val += "<br />$" + amount_passthru.formatMoney(2, '.', ',') + " will be sent to the charities for immediate impact.";
  val += "<br />$" + amount_invested.formatMoney(2, '.', ',') + " will be invested, becoming a legacy that grants to your charities forever!";
  return val;
}

var returnFormattedAmountDetails = function (amount) {
  var fee = calculateFee(amount);
  return "Assume transaction fee of " + fee.formatMoney(2, '.', ',') +"?";

}

var whichProcessor = function() {
  if ($('#njalo-tabs').tabs('option','active')==0)
    return "dwolla";
  else if ($('#njalo-tabs').tabs('option','active')==1)
    return "stripe";
}

/**
 * Returns fee (2-digit float) amount
*/
var calculateFee = function (amount) {
  var fee;
  var thisAmount = parseStrToNum(amount.val());
  switch (whichProcessor()) {
    case "stripe":
      fee = 0.3 + (.029 * thisAmount);
    break;
    case "dwolla":
      fee = 0.0
      if (thisAmount > 10.0) {
        fee = 0.25;
      }
    break;
    default:
      fee = 0.0;
  }
  return fee;
}


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


/* Load jQuery */
loadScript("//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js", function() {
  /* Restore $ and window.jQuery to their previous values and store the
     new jQuery in our local jQuery variables. */
  $ = jQuery = window.jQuery.noConflict(true);

  $('#njalo-button').load(HOST+'/button-contents.html');

  loadScript("jquery-ui.min.js", function() { // load locally-modified JS
    initjQueryUIPlugin(jQuery);
    loadScript("jquery.validate.min.js", function() {
      initjQueryValidatePlugin(jQuery);
      main(); // call our main function
    });
  });

});


}(window, document)); /* end IIFE */