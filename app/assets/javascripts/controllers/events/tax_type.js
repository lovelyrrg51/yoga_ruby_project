$(document).on("turbolinks:load", function() {
    $("form#event_tax_type_form").validate();
    $('#tableappend').on('cocoon:after-insert', function(e, insertedItem) {
        $(".basic-single").select2();
    });
});