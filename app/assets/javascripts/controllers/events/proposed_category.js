$(document).on("turbolinks:load", function() {
    var event_category_proposed_form = $('form#event_category_proposed_form'),
        event_category_proposed_form_origForm = event_category_proposed_form.serialize();
    event_category_proposed_form.validate();
    $('#save_category_proposed').click(function() {
        return event_category_proposed_form.serialize() !== event_category_proposed_form_origForm
    });
});