$(document).ready(function() {

  function getLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(showPosition);
    }
    else {
      initializeTypeahead();
    }
  }
  function showPosition(position) {
    initializeTypeahead(position.coords.latitude, position.coords.longitude);
  }

  function goToCampaign(campaign) {
    window.location.href = '/campaigns/'+campaign.id;
  }

  function initializeTypeahead(latitude, longitude) {

    var campaigns = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      //prefetch: '../campaigns/prefetch_data.json',
      prefetch: '/campaigns/near.json',
      remote: '/campaigns/autocomplete.json?q=%QUERY',
      dupDetector: function(remoteMatch, localMatch) {
        return remoteMatch.value === localMatch.value;
      }
    });
     
    campaigns.initialize();
     
    $('#remote .typeahead').typeahead(null, {
      name: 'campaigns',
      displayKey: 'value',
      source: campaigns.ttAdapter()
    });

    $('.typeahead').on('typeahead:selected', function (e, datum) {
      goToCampaign(datum); // onclick
    }).on('typeahead:autocompleted', function (e, datum) {
        goToCampaign(datum); // ontab
    });

  } // end initializeTypeahead

  getLocation();

});