// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on('focus',".sy_club_validity_window_datepicker", function(){

  if( $(this).hasClass("hasDatepicker"))
    return
  
  $("#sy_club_validity_window_club_reg_start_date").datepicker({
      changeMonth: true,
      changeYear: true,
      dateFormat: "yy-mm-dd",
      showOtherMonths: true,
      yearRange: "-100:+100",
      onClose: function (dateText, inst) {
        try {
          $.datepicker.parseDate( "yy-mm-dd", dateText );
        } catch (err){
          dateText = "";
          $("#sy_club_validity_window_club_reg_start_date").datepicker( "setDate", dateText );
        }
        $("#sy_club_validity_window_club_reg_end_date").datepicker( "option", "minDate", dateText );
        $("#sy_club_validity_window_club_reg_end_date").datepicker( "setDate", "" );
      }
    });
  
  $("#sy_club_validity_window_club_reg_end_date").datepicker({
        changeMonth: true,
        changeYear: true,
        dateFormat: "yy-mm-dd",
        showOtherMonths: true,
        yearRange: "0:+100",
        minDate: new Date(),
        onClose: function (dateText, inst) {
          try {
            $.datepicker.parseDate( "yy-mm-dd", dateText );
          } catch (err){
            dateText = "";
            $("#sy_club_validity_window_club_reg_end_date").datepicker( "setDate", dateText );
          }
        }
   });

  $("#sy_club_validity_window_membership_start_date").datepicker({
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd",
    showOtherMonths: true,
    yearRange: "-100:+100",
    onClose: function (dateText, inst) {
      try {
        $.datepicker.parseDate( "yy-mm-dd", dateText );
      } catch (err){
        dateText = "";
        $("#sy_club_validity_window_membership_start_date").datepicker( "setDate", dateText );
      }
      $("#sy_club_validity_window_membership_end_date").datepicker( "option", "minDate", dateText );
      $("#sy_club_validity_window_membership_end_date").datepicker( "setDate", "" );
    }
  });

  $("#sy_club_validity_window_membership_end_date").datepicker({
      changeMonth: true,
      changeYear: true,
      dateFormat: "yy-mm-dd",
      showOtherMonths: true,
      yearRange: "0:+100",
      minDate: new Date(),
      onClose: function (dateText, inst) {
        try {
          $.datepicker.parseDate( "yy-mm-dd", dateText );
        } catch (err){
          dateText = "";
          $("#sy_club_validity_window_membership_end_date").datepicker( "setDate", dateText );
        }
      }
  });



});