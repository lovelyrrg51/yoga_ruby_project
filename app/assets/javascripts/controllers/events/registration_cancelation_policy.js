$(document).on('click', '#ecp li', function() {
    var form = $('form#event_cancellation_plan_item_find_plan_items');
    $("span#selected_ecp_text").text($(this).text());
    form.html('')
        .append("<input type='hidden' name='event_cancellation_plan_id' value=" + $(this).val() + ">");
    form.submit();
})


function onChangeCancelationPlan(e) {
    var form = $('form#event_cancellation_plan_item_find_plan_items');
    form.html('')
        .append("<input type='hidden' name='event_cancellation_plan_id' value=" + $(e).val() + ">");
    form.submit();
}