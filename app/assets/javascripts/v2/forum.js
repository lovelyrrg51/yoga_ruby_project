$(document).on('turbolinks:load', function () {
  if ($("body").data("class") === "forums" && $("body").data("action") === "index") {
    $(window).scroll(function () {
      var scroll = $(window).scrollTop();
      if (scroll >= 300) {
        $(".bh-sl-map").addClass("map-fix");
      }
      else {
        $(".bh-sl-map").removeClass("map-fix");
      }
    });

    $(window).scroll(function () {
      var scroll = $(window).scrollTop();
      if (scroll >= 300) {
        // $(".map-section").addClass("all-forums-fix");
      }
      else {
        // $(".map-section").removeClass("all-forums-fix");
      }
    });

    $(window).scroll(function () {
      var scroll = $(window).scrollTop();
      if (scroll >= 100) {
        $(".forum-form").addClass("forum-form-fix");
      }
      else {
        $(".forum-form").removeClass("forum-form-fix");
      }
    });

    var QueryStringToJSON = function(qstr) {
        var pairs = qstr.split('&');

        var result = {};
        pairs.forEach(function(pair) {
            pair = pair.split('=');
            result[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1] || '');
        });

        return JSON.parse(JSON.stringify(result));
    }
    var submitForm = function(){
      //$('#paginate-infinite-scrolling').empty();
      //$('.all-forums').empty();
      //$('.forum-form').submit();

      params = QueryStringToJSON($('.forum-form').serialize()); // {"utf8": "✓", "q[name_cont]" : "Mountain"},
      $('#bh-sl-map-container')
        .storeLocator('ajaxData', params);

      $('#bh-sl-map-container')
        .storeLocator('mapping',
              {
                'lat': '52.1650645',
                'lng': '-106.65650210000001',
                'origin': null,
                'page': 0
              }
      );
    }
    $('.search').click(function(){
      submitForm();
    })

    $('#forum-search-input').keypress(function (e) {
      if (e.which == 13) {
        submitForm();
        return false;
      }
    });

    params = QueryStringToJSON($('.forum-form').serialize()); // {"utf8": "✓", "q[name_cont]" : "Mountain"},
    temp = $('#bh-sl-map-container').storeLocator({
      autoGeocode: false, //does not work on insecure origins. Only works on https.
      originMarker: false,
      originMarkerImg: $('#bh-sl-map-container').data('closeIcon'),
      originMarkerDim: {'height': 34, 'width': 34},
      storeLimit: -1,
      pagination: false,
      'mapSettings': {
        zoom                  : 6,
        mapTypeId             : google.maps.MapTypeId.ROADMAP,
        disableDoubleClickZoom: false,
        scrollwheel           : true,
        navigationControl     : true,
        draggable             : true
      },
      sortBy: {
        method: 'number',
        order: 'asc', // This is the default value but here for example.
        prop: 'distance' // This is the default alpha sorting value but here for example.
      },
      taxonomyFilters : {
      /*'features' : 'category-filters-container2',
      'city' : 'city-filter',
      'postal': 'postal-filter',
      'state': 'state-filter',
      'category': 'category-filter',
      'product': 'category-filter',*/
      },
      infoBubble: {
        backgroundClassName: 'bh-sl-window',
        backgroundColor: '#fff',
        borderColor: '#ccc',
        borderRadius: 8,
        borderWidth: 1,
        closeSrc: $('#bh-sl-map-container').data('closeIcon'),
        disableAutoPan: false,
        shadowStyle: 1,
        padding: 10,
        minHeight: 'auto',
        maxHeight: 300,
        minWidth: 400,
        maxWidth: 450
      },
      dataRaw: null,
      ajaxData: params,
      dataType: 'json',
      dataLocation: '/forum/',
      slideMap: false,
      lengthUnit: 'km',
      inlineDirections: false,
      defaultLoc: true,
      defaultLat: '28.644800',
      defaultLng : '77.216721',
      markerImg: $('#bh-sl-map-container').data('forumIcon'),
      markerDim: {'height': 34, 'width': 34},
      pagination: true,
      callbackFilters: function() {
        var firstForum = $('.forum-place')[0]
        if (firstForum) {
          $(firstForum).trigger('click')
        }
      }
    });
  }
});
