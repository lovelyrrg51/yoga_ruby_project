// Shivir Event
$(document).on('click', '#event_pre_approval_required', function() {
  $("#pre_approval_event_requirement").toggleClass("overlay-active");
  $('#event_logistic_email, #event_approver_email')
  .val('')
  .valid();
  if (!$(this).is(":checked")){
   $('#event_auto_approve').prop( "checked", false );
  }
});

$(document).on('click', '#event_auto_approve', function() {
	if ($(this).is(":checked") && !$('#event_pre_approval_required').is(":checked")){
		$('#event_pre_approval_required').click();
	}
});

$(document).on('click', '#date_to_be_decided', function() {
  $("#event_date_requirement").toggleClass("overlay-active");
  $("[data-role='syDatepicker']").find("input").valid()
});

$(document).on('click', '#event_end_date_ignored', function() {
  $("#end_date_ignored_alert").toggleClass("hidden");
});

$(document).on('click', '#min_age_criteria_checkbox', function() {
  $("div#min_age_criteria").toggleClass("overlay-active");
  $('input#event_min_age_criteria').val(0);
});

var event_form_validation_obj =  function () {
  return {
    debug: false,
    errorPlacement: function(error, element) {
      if (element.attr("name") == "event[contact_details]")
          error.appendTo(".merge-error.event_contact_details_error");
      else if (element.attr("name") == "event[contact_email]")
          error.appendTo(".merge-error.event_contact_email_error");
      else if (element.attr("name") == "event[registrations_recipients]")
          error.appendTo(".merge-error.event_registrations_recipients_error");
      else if (element.attr("name") == "event[logistic_email]")
          error.appendTo(".merge-error.event_logistic_email_error");
      else if (element.attr("name") == "event[approver_email]")
          error.appendTo(".merge-error.event_approver_email_error");
      else
          error.insertAfter(element);
    },
    rules: {
      "event[event_name]": "required",
      "event[cannonical_event_id]": "required",
      "event[event_type_id]": "required",
      "event[graced_by]": "required",
      "event[payment_category]": "required",
      "event[contact_details]": {
        required: true
      },
      "event[attachments_attributes][0][name]": {
        extension: "jpg,jpeg,png,doc,docx,xls,xlsx,pdf,csv",
        filesize: 5,
      },
      "event[event_start_date]": {
        required: "#date_to_be_decided:unchecked"
      },
      "event[event_end_date]": {
        required: "#date_to_be_decided:unchecked"
      },
      "event[handy_attachments_attributes][0][name]": {
        extension: "jpg,jpeg,png,doc,docx,xls,xlsx,pdf,csv",
        filesize: 5,
      },
      "event[approver_email]": { 
        required: "#event_pre_approval_required:checked"
      },      
      "event[logistic_email]": { 
        required: "#event_pre_approval_required:checked"
      },
      "event[registrations_recipients]": "required",
      "event[venue_type_id]": "required",
      "event[address_attributes][country_id]": "required",
      "event[address_attributes][state_id]": "required",
      "event[address_attributes][city_id]": "required",
      "event[address_attributes][other_state]": {
        required: function(){ return $('select[name="event[address_attributes][state_id]"]').val() == OTHER_STATE_ID
        }
      },
      "event[address_attributes][other_city]": {
        required: function(){ return $('select[name="event[address_attributes][city_id]"]').val() == OTHER_CITY_ID
        }
      },
      "event[address_attributes][first_line]": "required",
      "event[address_attributes][postal_code]": "required",
      "event[event_location]": "required"
    },
    messages: {
      "event[contact_details]": {
        required: "This field is required"
      }
    },
    submitHandler: function(form) {
      form.submit();
    }
  }
}

$.validator.addMethod('filesize', function(value, element, param) {
  return this.optional(element) || (element.files[0].size / 1024 / 1024 <= param);
}, 'File size must be less than {0}');

function isMembersAddedToList(){
  return $('div.eventaddmember').find('tbody').find('tr').filter(function() {
    return this.id.match(/SY\d+/);
  }).length > 0;
}

// Function to change amount upon category change.
$(document).on('change', '.registrationflowCntrl .eventaddmember .tableCntrl table tr select', function(){
  var selectedOption = $(this).val(), category = _.find($(this).data('seating-categories'), function(category){
      return category.id === selectedOption; 
  });
  if(selectedOption.length)
  {
    $(this).closest('tr').find('td span.primarybold').html(category.price);  
  }
  else
  {
    $(this).closest('tr').find('td span.primarybold').html('-');   
  }
  
});

// Function to remove member from list.
$(document).on('click', '.registrationflowCntrl .eventaddmember .tableCntrl table tr td a', function() {
  var form = $(this).closest('form');
  $(this).closest('tr').remove();
  if (isMembersAddedToList()){
    $('.registrationflowCntrl .eventaddmember').removeClass('hidden');
  } else {
    $('.registrationflowCntrl .eventaddmember').addClass('hidden');
  }

  if($(form).find('table.table').find('tbody').find('tr').length == 0)
  {
    $('div.eventmemberCntrl').removeClass('hidden');
  }

});

$(document).on('turbolinks:load', function() {
  
  $("form#event_register_syid_search_form").validate();
  $("form#photo_approval_admin_role_dependency_form").validate();
  $("form#clone_event_form").validate();

  $('.addmember-btn').click(function() {
    $(this).parent('.eventaction').find('button.event_register_cancel').removeClass('hidden');
    $(this).parents('.eventmemberCntrl').find('.eventreg-one').removeClass('hidden');
    $(this).parents('.eventmemberCntrl').find('.eventreg-two').addClass('hidden');
    if (isMembersAddedToList()){
      $(this).parents('.eventaddmember').removeClass('hidden');
    }
    $(this).parents('.eventmemberCntrl').find('div.registeredshivyog').removeClass('hidden');
    $(this).parents('.eventmemberCntrl').find('div.forgotsyid.event-registration').addClass('hidden');
  });

  $('.addmorememb-btn').click(function() {
    $(this).parent('.eventaction').find('a').removeClass('hidden');
    $(this).parents('.eventaddmember').siblings('.eventmemberCntrl').find('.eventreg-one').removeClass('hidden');
    $(this).parents('.eventaddmember').siblings('.eventmemberCntrl').find('.eventreg-two').addClass('hidden');
    $(this).parents('.eventaddmember').siblings('.eventmemberCntrl').removeClass('hidden');
    if (isMembersAddedToList()){
      $(this).parents('.eventaddmember').removeClass('hidden');
    }
  });

  $('.event_register_cancel').on('click', function(){
    Turbolinks.visit(window.location.toString(), { action: 'replace' })
  });

  $("select[name='sadhak_profile[country_id]']").removeAttr('required');
  $("select[name='sadhak_profile[state_id]']").removeAttr('required');
  $("select[name='sadhak_profile[city_id]']").removeAttr('required');
  $("select[name='sadhak_profile[other_city]']").removeAttr('required');
  $("select[name='sadhak_profile[other_state]']").removeAttr('required');

  $('.docteraddsyid-btn').click(function() {
    $(this).parents('.registrationflowCntrl').find('.doctorregisterCntrl').removeClass('hidden');
    $(this).parents('.eventmemberCntrl').addClass('hidden');
  });

  $('.doctorsave-btn').click(function() {
      $(this).parents('.registrationflowCntrl').find('.eventaddmember').removeClass('hidden');
      $(this).parents('.doctorregisterCntrl').addClass('hidden');
  });

  $('#event_register-forgot-syid-form').validate();

  $('#event_register_event_order_create_form').validate({
    onkeyup: false,
    rules: {
      "event_order[guest_email]": { required: function () { return $("[name='event_order[guest_email]']").val() == ""; }, email: true },
    }
  });
  
  $('#event_register_event_order_create_form').submit(function(){

    var error = false, syids = "";

    if($('input#event_register_ack_checkbox').length && !$('input#event_register_ack_checkbox').prop('checked'))
    {
      $('input#event_register_ack_checkbox').parents('div.CustomCheckbox.event_register_ack_div').siblings('span.event_register_ack_checkbox_error_span').text('This field is required.');
      error = true;
    }

    if($("input[name='event_order[accepted_terms_and_conditions][]']").length){
      if($("input[name='event_order[accepted_terms_and_conditions][]']:checked").length != ASHRAM_RESIDENTIAL_SHIVIR_T_AND_C.length){
        toastr.error("Please select all the terms and conditions.");
        error = true;
      }
    }

    $('div.registrationflowCntrl select.event-register-seating-category-select-tag').each(function(){

      if(!$(this).val().length)
      {
        syids = syids + " " + $(this).data('syid');
        error = true;
      }
    
    });

    if(syids.length)
    {
      toastr.error("Please select the Seating Category for" + syids + ".");
    }

    if(error) return false;

  });

  $('input#event_register_ack_checkbox').click(function(){
    if($('input#event_register_ack_checkbox').prop('checked'))
    {
      $('input#event_register_ack_checkbox').parents('div.CustomCheckbox.event_register_ack_div').siblings('span.event_register_ack_checkbox_error_span').text('');
    }
  });

  $('.forgotsyid-btn').click(function() {
        $(this).parents('.registeredshivyog').addClass('hidden');
        $(this).parents('.registeredshivyog').next().removeClass('hidden');
  });

  $("select#event_register_syid_search_event_select_options").on("change", function(e) {
        var selectedOption = e.target.value,
            searchByValue = $("input#event_register_syid_search_value");
        if (selectedOption === 'date_of_birth')
        {
          datepickerObject = {
            format: 'MMM DD, YYYY',
            ignoreReadonly: true,
            widgetPositioning: {
              vertical: 'bottom'
            },
            useCurrent: false,
            icons: {
              up: "fa fa-chevron-up",
              down: "fa fa-chevron-down",
              next: "fa fa-chevron-right",
              previous: "fa fa-chevron-left"
            }
          }
          
          var minStartDate = searchByValue.data('minstartdate'), maxStartDate = searchByValue.data('maxstartdate'), datepicker1Object = (typeof minStartDate != "undefined" && minStartDate.length && Date.parse(minStartDate)) ? $.extend({}, datepickerObject, { minDate: new Date(minStartDate) }) : datepickerObject;
          datepicker1Object = (typeof maxStartDate != "undefined" && maxStartDate.length && Date.parse(maxStartDate)) ? $.extend({}, datepicker1Object, { maxDate: new Date(maxStartDate) }) : datepicker1Object

          searchByValue.datetimepicker(datepicker1Object)

        }
        else
        {
          if(searchByValue.data("DateTimePicker")) searchByValue.datetimepicker("destroy");
        }


        searchByValue.attr('placeholder', selectedOption.replace(/_/g, " ").charAt(0).toUpperCase() + this.value.replace(/_/g, " ").slice(1));
        searchByValue.attr('name', 'sadhak_profiles[' + selectedOption + ']');
        searchByValue.val('');

    });

  $('#new_event_order').validate({
      debug: false,
      rules: {
          "event_order[guest_email]": "required",
          "underage-checkbox": "required",
          "terms-condition-checkbox": "required"
      },
      messages: {
          "event_order[guest_email]": "Please enter a email.",
          "underage-checkbox": 'Please tick the checkbox.',
          "terms-condition-checkbox": "Please accept terms and conditions."
      },
      submitHandler: function(form) {
          form.submit();
      }
  });

  $('#registration_invoices_form').validate();
  $('#event_resend_transaction_receipt_form').validate();

});

$(document).on('click', '.payment_gateway_radio_button', function(){
  _.find($('.payment_gateway_display_div'), function(display_div){
    $(display_div).css('display', 'none');
  });
  $("div#" + $(this).attr('data-id') + "").css('display', 'block');
});

$(document).on('click', '.onlinePaymentTab', function(){
  selectedRadio = $('div#onlinepayment').find("input[type='radio']:checked");
  if(selectedRadio.length) $("div#" + $(selectedRadio).attr('data-id') + "").css('display', 'block');
});

$(document).on('click', '.offlinePaymentTab', function(){
  selectedRadio = $('div#offlinepayment').find("input[type='radio']:checked");
  if(selectedRadio.length) $("div#" + $(selectedRadio).attr('data-id') + "").css('display', 'block');
});