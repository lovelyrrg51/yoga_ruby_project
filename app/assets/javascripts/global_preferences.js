// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on('turbolinks:load', function() {

  $("#global_preference_form").validate({
    errorPlacement: function(error, element) {
       (element.hasClass("tagsinput")) ? error.appendTo( $(".global_preference_tag_input_error")) : error.insertAfter(element);
     }
  });

});