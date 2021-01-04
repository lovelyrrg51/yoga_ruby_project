// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on("turbolinks:load", function() {

  $('#merge-syid-form').validate({
    errorPlacement: function(error, element) {
       (element.attr("name") == "admin[secondary_sadhak]") ? error.appendTo( $(".merge_syid_secondary_sadhak_tag_input_error")) : error.insertAfter(element);
     }
  });

});
