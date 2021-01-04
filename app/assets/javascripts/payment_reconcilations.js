$(document).on('turbolinks:load', function () {
  $("form#payment_reconcilation_form").validate({
    errorPlacement: function (error, element) {
      (element.attr("name") == "payment_reconcilation[attachments_attributes][0][content]") ? error.appendTo($(".payment_reconcilation_content_error")) : error.insertAfter(element);
    }
  });
});