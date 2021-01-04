// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on("turbolinks:load", function() {

  $("#add_rc_user_form").validate();

    $("#registration_center_new_edit_form").validate();

    $("#registration_center_new_edit_form").submit(function(){

      if( $(this).find("#registration_center_user_ids_").length == 0 ) {

        $('<input>').attr({
          type: 'hidden',
          name: 'registration_center[user_ids][]',
          value: ''
        }).appendTo('#registration_center_new_edit_form');

      }

    });

})
