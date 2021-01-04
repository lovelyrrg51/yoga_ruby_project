function switchToCashDDTallyReport(target){

  var target = $(target);

  if (target.is(":checked")) {
    $('#event_email_tally_report_excel_form').attr('action', target.data('event-registration-cash-dd-tally-report-url'));
  } else {
    $('#event_email_tally_report_excel_form').attr('action', target.data('event-registration-tally-report-url'));
  }

}

function eventRegistrationReportFieldsSelectAll(target) {

  $(".event_registration_report_master_field").prop('checked', $(target).prop('checked'));

}

$(document).on('click', '.event_registration_report_master_field', function(){
  var allCheckbox = true
  $('.event_registration_report_master_field').each(function(){
    if(!$(this).prop('checked')){
      allCheckbox = false;
      return;
    }
  });
  (allCheckbox) ? $('#report_master_selectAll').prop('checked', true) : $('#report_master_selectAll').prop('checked', false);
});

$(document).on('show.bs.modal', '#registrationDetailModal', function(e) {
  var registrationDetail = $(e.relatedTarget).data('registration-detail'), modalBody = $(this).find('div.modal-body');
  modalBody.html('');
  $.each(registrationDetail, function(k, v){
    modalBody.append('<div class="groupBlock row"><label class="col-sm-6 col-xs-6">' + k + ':</label><label class="col-sm-6 col-xs-6"><b>' + v + '</b></label></div>')
  });
});

$(document).ready(function(){

  var count = 0

  $("#select_all_report_master_field_check").click(function () {
      $(".single_report_master_field_check").prop('checked', $(this).prop('checked'));
  });


  $(".single_report_master_field_check").click(function(){

    var all_checked = 1

      $(".single_report_master_field_check").each(function(){

        if( !$(this).prop("checked") )
          all_checked = 0;

      });

      if(all_checked == 1)
      {
        $("#select_all_report_master_field_check").prop("checked", true);
      }
      else
      {
        $("#select_all_report_master_field_check").prop("checked", false);
      }

  });

  $('#registration_status_excel_report_email').on('itemAdded', function(event) {

    var count_excel_report_emails = $('#count_excel_report_emails').val();

    count_excel_report_emails = (parseInt(count_excel_report_emails) + 1).toString() ;

    $("#count_excel_report_emails").val(count_excel_report_emails);

  });


  $('#registration_status_excel_report_email').on('itemRemoved', function(event) {

    var count_excel_report_emails = $('#count_excel_report_emails').val();

    count_excel_report_emails = (parseInt(count_excel_report_emails) - 1).toString() ;

    $("#count_excel_report_emails").val(count_excel_report_emails);

  });


  $('#registration_status_excel_report_email').on('beforeItemAdd', function(event) {

    $("#registration_status_excel_report_email_error").text("");

  });



  $("#registration_status_email_excel_form").submit(function(){

    ret = true;


    if( $(this).find("#count_excel_report_emails").val() == 0 )
    {

      $("#registration_status_excel_report_email_error").text("Field required.");

      ret = false;
    }

    else if( $(".bootstrap-tagsinput").has(".tag") && $(".bootstrap-tagsinput").find(".tag").length > 0 )
    {

      bootstrap_tag_count =  $(".bootstrap-tagsinput").find(".tag").length;

      ret = check_for_valid_tagsinput_emails(bootstrap_tag_count, ret);
      
    }

    return ret;

  });

  $("#event_email_tally_report_excel_form").validate();
  $("#event_email_excel_report_form").validate();

});





