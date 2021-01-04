$(document).on('change', '.event_pga_checkbox', function() {

    var payment_gateway_id = $(this).data('event-payment-gateway-checkbox');
    $("div.pga-start-end-date-div#" + payment_gateway_id).toggleClass('overlay-active');

    if ($(this).is(':checked')) {
        $(this).parents('div.div' + payment_gateway_id + '').find('input.gateway_start_date').rules('add', { required: true });
        $(this).parents('div.div' + payment_gateway_id + '').find('input.gateway_end_date').rules('add', { required: true });
    } else {
        $(this).parents('div.div' + payment_gateway_id + '').find('input.gateway_start_date').rules('remove');
        $(this).parents('div.div' + payment_gateway_id + '').find('input.gateway_end_date').rules('remove');
    }

});

$(document).on('submit', '#event_payment_gateway_assosiation_form', function() {

    $(".event_pga_checkbox").each(function() {

        if ((!$(this).prop("checked")) && ($(this).data("gateway-association-id").length != 0)) {

            var name = "event[event_payment_gateway_associations_attributes][" + $(this).data("association-index") + "][_destroy]",
                input = '<input type="hidden" name=' + name + ' value="1" />';
            $('#event_payment_gateway_assosiation_form').append(input)

        }

    });

});

$(document).on("turbolinks:load", function() {

    $("#edit_event").validate(event_form_validation_obj());

    /*payment gateways JS*/

    $("#event_payment_gateway_assosiation_form").validate();

    $(".event_pga_checkbox").each(function() {

        var id = $(this).data("event-payment-gateway-checkbox");

        if ($(this).prop("checked")) $("div.pga-start-end-date-div#" + id).removeClass('overlay-active');

    });

    /*end of payment gateways JS*/

});

function onEventTypeChange(e){

    var preApprovalCheckox = $("[name='event[pre_approval_required]']"), companySelect = $("[name='event[sy_event_company_id]']"), fullProfileCheckbox = $("[name='event[full_profile_needed]']");

    if($(e).find(":selected").text() == ASHRAM_RESIDENTIAL_SHIVIR)
    {
        preApprovalCheckox.prop('checked', true);
        $('div.pre_approval_required_overlay_div').addClass('overlay-active');
        $("#pre_approval_event_requirement").removeClass("overlay-active");

        fullProfileCheckbox.prop('checked', true);
        $('div.full_profile_needed_overlay_div').addClass('overlay-active');

        companySelect.val('').trigger('change');
        $('div.sy_event_company_overlay_div').addClass('overlay-active');

        $("input[name='event[payment_category]'][value='free']").prop('checked', true);
        $('div.payment_category_overlay_div').addClass('overlay-active');
       
    }
    else{

        $('div.pre_approval_required_overlay_div').removeClass('overlay-active');

        $('div.full_profile_needed_overlay_div').removeClass('overlay-active');

        $('div.sy_event_company_overlay_div').removeClass('overlay-active');

        $('div.payment_category_overlay_div').removeClass('overlay-active');

    }
}