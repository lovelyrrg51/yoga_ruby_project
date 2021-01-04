$(document).ready(function() {

    if (navigator.geolocation) {
        if (Cookies.get('lat') && Cookies.get('lng')) {
        } else {
          Cookies.set('initial', "initial")
        }
        navigator.geolocation.getCurrentPosition(function(position) {
            if (typeof(Storage) !== "undefined") {
              Cookies.set('lat', position.coords.latitude);
              Cookies.set('lng', position.coords.longitude);
            }
        });
    }

});

// Show Loader
function showLoader(){
  $('.overlayload').addClass('overlay-active');
  $('body').addClass('noscroll');
}
//

// Hide Loader
function hideLoader(){
  $('.overlayload').removeClass('overlay-active');
  $('body').removeClass('noscroll');
  $('.refineCntrl').addClass('in');
  $('.tabledataCntrl').show(1200);
}
//

$(document).bind("ajaxSend", function(e, xhr, option){
  var params = new URLSearchParams(option.url)
  if(!params.has('noLoading') && !params.get('noLoading')){
    showLoader();
  }
}).bind("ajaxComplete", function(e, xhr, option){
  hideLoader();
// Set up modal if ajax return a modal 
  setupModal();
// Set up returned DOM
	setupReturnedDom();
}).on("turbolinks:request-start turbolinks:before-visit", function() {
  showLoader();
}).on('submit', 'form', function(){
  showLoader();
}).on('click', 'input[type="submit"]', function(){
  // showLoader();
}).on('click', 'button[type="submit"]', function(){
  // showLoader();
}).on("turbolinks:load", function() {
  hideLoader();
}).ready(function(){
  hideLoader();
});
 
$(document).on('turbolinks:load', function() {

    $('form').attr('autocomplete', 'off');
    // Hide loader if any error occur in form
    $("form").bind("invalid-form.validate", function() {
      hideLoader();
    });

    // Add validator for email
    $.validator.methods.email = function( value, element ) {
      return this.optional( element ) || /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test( value );
    }

    // Add validator for no special character allowed
    jQuery.validator.addMethod("noSpecialChar", function(value, element) {
   		return this.optional(element) || /^[A-Za-z0-9\s]+$/.test( value ); 
		}, "This field cannot contain any special character.");

		// Add validator for only letter allowed
		jQuery.validator.addMethod("letterOnly", function(value, element) {
			return this.optional(element) || /^[a-zA-Z]+$/i.test(value);
		}, "This field can contain only letters.");

		// Add validator for only letter allowed
		jQuery.validator.addMethod("letterAndSpaceOnly", function(value, element) {
			return this.optional(element) || /^[a-zA-Z\s]+$/i.test(value);
    }, "This field can contain only letters.");
    
    jQuery.validator.addMethod("exactlength", function(value, element, param) {
      return this.optional(element) || value.length == param;
    }, $.validator.format("Please enter exactly {0} characters."));

    // Skip validation for a field with class .ignor
    $.validator.setDefaults({ignore: ".ignore"});
    
    // If form has select2 select tag then add 'resetForm' class to reset button  
    $(document).on('click', 'button.resetForm', function(){
      $(this).closest("form")
      .trigger('reset')
      .find("select").trigger("change");
    })

    $("[data-role='tagsinput']").each(function() {
      if ($(this).siblings('.bootstrap-tagsinput').length == 0) {
        $(this).tagsinput({
          trimValue: true
        });
      }
    });

    $('.js-example-basic-single').select2();
    $('.js-example-basic-multiple').select2();

    $('span.icon_popup').tooltip();
    $('td.icon_popup').tooltip();

    $("[data-role='ezPlus']").each(function(){
      $(this).ezPlus({ scrollZoom : true });
    });

    initAutocompleteGoogleAddress();

    ($('body.height-full').length) ? $('html').addClass('height-full') : $('html').removeClass('height-full');

    modalHeight();

    $('.modal').on('shown.bs.modal', function () {
      modalHeight();
    });

    $(".asideCntrl .panel.active ").parents('.collapse').collapse();
    $(".asideCntrl .sub-panel.active ").parents('.collapse').collapse();
    $(window).resize(function() {
      if($(this).outerWidth(true) > 768){
        location.reload(true);
      }
    });
    $("div, document").on('cocoon:after-insert', function(e, insertedItem) {
      $(".simple-single").select2();
        $("[data-role='tagsinput']").each(function() {
          if ($(this).siblings('.bootstrap-tagsinput').length == 0) {
            $(this).tagsinput({
              trimValue: true
            });
          }
        });
    });
});

$(document).on('turbolinks:before-cache', function() {
  $("[data-role='tagsinput']").each(function() {
    $(this).tagsinput('destroy');
  });

  $('.js-example-basic-single').each(function() {
    $(this).select2("destroy");
  });

  $('.js-example-basic-multiple').each(function() {
    $(this).select2("destroy");
  });

  $(".mCustomScrollbar, .tableScrollbar, .Scrollbarhv, .select2-results, .multipleboxfield .select2-selection--multiple").mCustomScrollbar("destroy");

});




$(document).on('turbolinks:load', function () {

    window.query_params = (function(a) {
        if (a == "") return {};
        var b = {};
        for (var i = 0; i < a.length; ++i)
        {
            var p=a[i].split('=', 2);
            if (p.length == 1)
                b[p[0]] = "";
            else
                b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
        }
        return b;
    })(window.location.search.substr(1).split('&'));

});

$(document).on('focus', "[data-role='syDatepicker']", function(){

  if($(this).data("DateTimePicker")) {
    return;
  }

  var syDatepickerId = $(this).data('sydatepickerid'), syDatepickers = $("[data-sydatepickerid=" + syDatepickerId + "]")
  if (!syDatepickerId || syDatepickers.length == 0) {
    return;
  }

  datepickerObject = {
        format: 'MMM DD, YYYY',
        ignoreReadonly: true,
        widgetPositioning: {
          vertical: 'auto'
        },
        useCurrent: false,
        icons: {
          up: "fa fa-chevron-up",
          down: "fa fa-chevron-down",
          next: "fa fa-chevron-right",
          previous: "fa fa-chevron-left"
        }
      }
  syDatepickers.attr('readonly', true).each(function(i) {

    var minStartDate = $(this).data('minstartdate')
    var maxStartDate = $(this).data('maxstartdate')
    var defaultDate = $(this).data('defaultdate')

    var datepicker1Object = (typeof minStartDate != "undefined" && minStartDate.length && Date.parse(minStartDate)) ? $.extend({}, datepickerObject, { minDate: new Date(minStartDate) }) : datepickerObject;
    datepicker1Object = (typeof maxStartDate != "undefined" && maxStartDate.length && Date.parse(maxStartDate)) ? $.extend({}, datepicker1Object, { maxDate: new Date(maxStartDate) }) : datepicker1Object
    datepicker1Object = (typeof defaultDate != "undefined" && defaultDate.length && Date.parse(defaultDate)) ? $.extend({}, datepicker1Object, { defaultDate: new Date(defaultDate) }) : datepicker1Object

    if($(this).data("DateTimePicker")) {
      return;
    }
    (function(datepicker1, datepicker2){
      $(datepicker1).datetimepicker(datepicker1Object).on('dp.change', function(e){
        if (datepicker2 && e.date.isValid()) {
          if(e.date > $(datepicker2).data('DateTimePicker').viewDate()){
            $(datepicker2).data("DateTimePicker").clear();
          }
          $(datepicker2).data("DateTimePicker").minDate(e.date);
        }

      }).on('dp.show', function(e){
        var currentDatePickerIndex = syDatepickers.index(datepicker1), parentDatePicker = currentDatePickerIndex > 0 ? syDatepickers.get(currentDatePickerIndex-1) : null, mParentDate;

        if(parentDatePicker && !$(parentDatePicker).is($(datepicker1))){
          mParentDate = $(parentDatePicker).data('DateTimePicker') && $(parentDatePicker).data('DateTimePicker').viewDate();
          if(mParentDate && mParentDate.isValid()){
            $(datepicker1).data("DateTimePicker").minDate(mParentDate);
          }
        }

      });
    })(this, syDatepickers.get(i+1));

  });

});

// Reset bootstrap modal form if any upon close.
$(document).on('hidden.bs.modal', '[aria-labelledby="myModalLabel"]', function () {
  $(this).find('form').trigger('reset');
});

String.prototype.toTitleCase = function () {
    return this.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
};


String.prototype.humanize = function () {
  var frags = this.split('_');
  for (i=0; i<frags.length; i++) {
    frags[i] = frags[i].charAt(0).toUpperCase() + frags[i].slice(1);
  }
  return frags.join(' ');
}

// Table Collpase //
$(document).on('show.bs.collapse', '.tableCollapse', function(){
  var e = window.event, srcElementQ = $(e.srcElement);
  srcElementQ.parents('tr').toggleClass('tablerow-bg');
  $("a[data-target=" + "'#" + srcElementQ.closest('table').find('.tableCollapse.in').attr('id') + "'" + "]").closest('tr').toggleClass('tablerow-bg');
  srcElementQ.closest('table').find('.tableCollapse.in').removeClass('in');
});

$(document).on('hide.bs.collapse', '.tableCollapse', function(){
  var e = window.event;
  $(e.srcElement).closest('tr').toggleClass('tablerow-bg');
});


// add rule to check no space in input

jQuery.validator.addMethod("noSpace", function(value, element) {
     return value.indexOf(" ") < 0 && value != ""; 
}, "This field cannot contain any space.");

String.prototype.queryParams = function() {
  var queryParamsString = (this.toString().split('?')[1] || '').split('&');
  if (queryParamsString == "") return {};
  var b = {};
  for (var i = 0; i < queryParamsString.length; ++i)
  {
    var p=queryParamsString[i].split('=', 2);
    if (p.length == 1)
      b[p[0]] = "";
    else
      b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
  }
  return b;
}


/*script for autocomplete address*/

// This example requires the Places library. Include the libraries=places
// parameter when you first load the API. For example:
// <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places">

var input_field_components2 = {
		premise: 'first_line',
    street_number: 'first_line',
    route: 'first_line',
    sublocality_level_3: 'second_line',
    sublocality_level_2: 'second_line',
    sublocality_level_1: 'second_line',
    postal_code: 'postal_code'
};

var country_state_city = {
    country: 'country_id',
    administrative_area_level_1: 'state_id',
    locality: 'city_id'
}

function initAutocompleteGoogleAddress() {

    $('input[data-google-address-autocomplete="autocomplete"]').each(function(){
       var _autocomplete = new google.maps.places.Autocomplete(
        (this),
        {types: ['geocode']});
      geolocate(_autocomplete);
      _autocomplete.addListener('place_changed', fillInAddress.bind(this, _autocomplete));
      $(this).parents('form').on('keyup keypress', function(e) {
			  var keyCode = e.keyCode || e.which;
			  if (keyCode === 13) {
			    e.preventDefault();
			    return false;
			  }
			});
    });
}

function fillInAddress(autocomplete) {

    element = $(this);

    for (var k in input_field_components2) {

        var ele = element.parents('form').find("[name*='[address_attributes][" + input_field_components2[k] + "]']");
        ele.val('').attr('disabled', false);

    };

    for (var k in country_state_city) {

        var ele = element.parents('form').find("[name*='[address_attributes][" + country_state_city[k] + "]']");

        if (ele.data('select2')) {
          ele.select2('val', '');
        } else {
          ele.val('').attr('disabled', false);
        }

    };

    var place = autocomplete.getPlace(), api_state, api_city, api_country;
    for (var p in place.address_components) {

      p = place.address_components[p]
      var addressType = p.types[0];

      if (input_field_components2[addressType]) {
          var ele = element.parents('form').find("[name*='[address_attributes][" + input_field_components2[addressType] + "]']");
          if (p.long_name.length){
	          if (ele.val().length){
	          	ele.val(ele.val() + ", " + p.long_name);
	          } else {
	          	ele.val(p.long_name);
	          }
	        }
      }

      if(addressType == "country") api_country = p.long_name
      if(addressType == "administrative_area_level_1") api_state = p.long_name
      if(addressType == "locality") api_city = p.long_name

    }

    var select_country_ele = $('#country_' + element.parents('form').find("[name*='[address_attributes][country_id]']").attr('data-changable-id')),
        select_state_ele = $('#state_' + element.parents('form').find("[name*='[address_attributes][state_id]']").attr('data-changable-id')),
        select_city_ele = $('#city_' + element.parents('form').find("[name*='[address_attributes][city_id]']").attr('data-changable-id')),
        select_country_option = select_country_ele.find('option').filter(function () { return $(this).html() == api_country; });

    if(select_country_ele.length) select_country_ele.attr('data-autocomplete-country', api_country);
    if(select_state_ele.length) select_state_ele.attr('data-autocomplete-state', api_state);
    if(select_city_ele.length) select_city_ele.attr('data-autocomplete-city', api_city);

    if (select_country_option.length){
      select_country_ele.val(select_country_option.get(0).value).trigger('change');
    }

}

function geolocate(autocomplete) {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      var geolocation = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      };
      var circle = new google.maps.Circle({
        center: geolocation,
        radius: position.coords.accuracy
      });
      autocomplete.setBounds(circle.getBounds());
    });
  }
}

/*end script for autocomplete address*/
var fileExtensions = {
	'image': ['.jpg','.jpeg','.png'],
	'imageAndFile': ['.jpg','.jpeg','.png','.doc','.docx','.xls','.xlsx','.pdf','.csv'],
	'file': ['.doc','.docx','.xls','.xlsx','.pdf','.csv'],
	'doc': ['.doc','.docx'],
	'xls': ['.xls','.xlsx'],
	'pdf': ['.pdf'],
	'csv': ['.csv']
}
var fileIcons = { '.pdf': 'icon-pdf', '.doc': 'icon-word','.xls': 'icon-excel', '.csv': 'icon-excel', '.xlsx': 'icon-excel', '.docx': 'icon-word'
}

// Show preview for file
function readURL(input) {
	var dataExtension = $(event.target).data('extension')
	var allowedExtensions = fileExtensions[dataExtension];
  var isFileRequired = $(event.target).data('required') || false;
  if (input.files && input.files[0]) {
    var reader = new FileReader(), filePath = input.value, fileExtension = '.' + filePath.split('.').slice(-1).pop() ;
		if(allowedExtensions.indexOf(fileExtension) == -1) {
			toastr.error("Please upload only " + allowedExtensions.join(", ") + ' files.');
			return;
		}
    reader.onload = function(e) {
      var parentEl = $(input).closest(".box-upload"), uploadedimage = parentEl.find(".uploadedimage");
      parentEl.find('label.error').remove();
      if (uploadedimage.length === 0) {
        uploadedimage = $('<div>')
        .addClass("uploadedimage")
        .append($('<a>').attr({'href': 'javascript:void(0);'}))
        .appendTo(parentEl);
      } else {
        uploadedimage.find('a').attr('href', 'javascript:void(0);');
      }
      if(isFileRequired && uploadedimage){
        uploadedimage.append($('<a>').attr({'href': 'javascript:void(0);', "class": 'closeImg', 'onClick': "removeAttachedFile(this)"}).html('<i class="icon-close"></i>'));
      }
      showFilePreview(fileExtension, e, parentEl.find(".uploadedimage > a").first(), allowedExtensions);
      $(input).siblings("div").find("span").text(input.files[0].name);
    };
    reader.readAsDataURL(input.files[0]);
  }
}

function showFilePreview(fileExtension, file, targetEle, allowedExtensions){
	if(fileExtensions['image'].indexOf(fileExtension) == -1) {
		var fileIcon =  fileIcons[fileExtension]
		targetEle.html($('<i>').addClass('icon font-40 ' + fileIcon ));
	} else {
		targetEle.html($('<img>').attr("src", file.target.result));
	}
}

function scrollToElement(element) {
  if ($(element).length > 0) {
    var siblingHeight = 0;
    if (element.siblings().length > 0) {
      siblingHeight = element.siblings().height();
    }
    $('html, body').animate({
      scrollTop: element.offset().top - siblingHeight
    }, 1000); 
  }
}

$(document).on("keypress keyup blur", "input.only_integers", function (event) {
  $(this).val($(this).val().replace(/[^\d].+/, ""));
  if ((event.which < 48 || event.which > 57)) {
    event.preventDefault();
  }
});

// Tostr|Lobibox
function lobibox(type, message){
  $('.lobibox-notify-wrapper').remove();
  var window_width = $(window).width();
  var fullMessage = message;
  var lobiboxConfig = {
      icon: false,
      delay: 6000,
      sound: false,
      icon: true,
      title: true,
      closeOnClick: false,
      continueDelayOnInactiveTab: false,
      pauseDelayOnHover: true,
      msg: message
    }
  if (message.length > 85){
    lobiboxConfig['msg'] = "<p title='Click here to load more.'>" + message.slice(0, 85) + "... <b>more.</b></h1>" + "</p>"
    lobiboxConfig['onClick'] = function(){
      $('#modal-content-text').text(fullMessage);
        $('#error_popup_modal').modal('show');
      }
  }
  if (window_width < 992) {
    lobiboxConfig['size'] = 'mini';
  }
  Lobibox.notify(type, lobiboxConfig)
}
window.toastr = { 
  error: function(message){
    lobibox("error", message)
  },
  alert: function(message){
    lobibox("error", message)
  },
  success: function(message){
    lobibox("success", message)
  },
  info: function(message){
    lobibox("info", message)
  },
  warning: function(message){
    lobibox("warning", message)
  }
}

function modalHeight() {
  var windowheight = $(window).outerHeight();
  var windowwidth = $(window).outerWidth();
  // var modalHeader_Height = $('.modal-header').outerHeight();
  // var modalFooter_Height = $('.modal-footer').outerHeight();

  /*var TotalModal_Height = modalHeader_Height + modalFooter_Height + 61;*/
  if (windowwidth > 991) {
    var modalHeight = windowheight - 172;
    $('.Custommodal .modal-body').css('max-height', modalHeight);
  }
  else {
    var modalHeight = windowheight - 152;
    $('.Custommodal .modal-body').css('max-height', modalHeight);
  }
}

$(document).on("click", ".turbolinkReload", function () {
  Turbolinks.visit(location.protocol + '//' + location.host + location.pathname, { action: 'replace' });
});

function onScrollFetchNearestForum(){
	var offSet = $('#nearest-forum-container').offset().top;
 	var windowHeight = $(window).height();
 	var initial = true;
  $(window).scroll(function(){
    var scrollPosition = $(this).scrollTop();
    if ((scrollPosition + windowHeight) > offSet){
      navigator.geolocation.getCurrentPosition(function(position){
      	// Success
      	if (initial) {
      		initial = false;
          var lat = position.coords.latitude, lng = position.coords.longitude;
            $.ajax({
                url: "/v1/forums/nearest_sy_clubs",
                data: { lat: lat, lng: lng, noLoading: true },
                dataType: "script"
            });
          }
      }, function(){
      	// Error
        $('div.nearestForumError p').text("You have disabled your Location.");
      })
    }
  });
}

function setupReturnedDom(){
  $(".tableScrollbar").mCustomScrollbar({
    axis:"x"
  });
}

function removeAttachedFile(e){
  var ele = $(e)
  var parentEle = ele.parents('.uploadedimage')
  var target = parentEle.siblings().filter(function(){return this.id.match(/remove-attachment-/)})
  if (target.length){
    target.val("1");
  }
  parentEle.siblings('div.clickable').find('input').val('').end()
  .find('span').html('No file choosen');
  parentEle.remove();
}