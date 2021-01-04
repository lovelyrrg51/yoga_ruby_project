// Event handler: To make Ajax call  get all events associated a discount plan 

function onDiscountPlanChange() {
    var selectedOption = $('#event_discount_plan_id').val();

    $.ajax({
        data: {
            discount_plan_id: selectedOption
        },
        url: '/v1/events/shivir_details/event_discount_plan_associations',
        dataType: 'script',
        success: function(data) {

        }
    });
}