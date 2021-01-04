// Event Handler when checked select option for bulk Approve Or Reject order-events
$(document).on('change', '#select_event_order_update_status', function() {
    if (this.checked) {
        if ($(".status_change_checkbox:enabled").length > 0) {
            $(".update-event-order-status").prop('disabled', false);
            $(".update-event-order-status").removeClass('disabled-button');
            $(".status_change_checkbox:enabled").prop('checked', true);
        }
    } else {
        $(".status_change_checkbox:enabled").prop('checked', false);
        $(".update-event-order-status").prop('disabled', true);
        $(".update-event-order-status").addClass('disabled-button');
    }
});

// Handler for Approve Or Reject orderEvent Button Click
function approveRejectSelectedEventOrder(status) {
    var selectedEventOrderIds = [],
        form = $('<form></form>');
    $(".status_change_checkbox:checked").map(function() {
        selectedEventOrderIds.push(this.value);
    });
    var hiddenAttrIds = $('<input></input>')
        .attr('type', 'hidden')
        .attr('name', 'event_order[event_order_ids]')
        .attr('value', selectedEventOrderIds);
    var hiddenAttrStatusType = $('<input></input>')
        .attr('type', 'hidden')
        .attr('name', 'event_order[status]')
        .attr('value', status);
    $(form).attr('method', "get")
        .attr('action', '/v1/event_orders/bulk_update_event_order_status')
        .append($(hiddenAttrIds))
        .append($(hiddenAttrStatusType));
    $(document.body).append(form);
    if (selectedEventOrderIds.length == 0){
        toastr.error("Please select atleast one application which is pending");
        return true;
    }
    else{
        $(form).submit();
    }
}

$(document).on('change', '.status_change_checkbox', function() {

    var status_change_checkboxes = $(".status_change_checkbox").length;

    if ($(".status_change_checkbox:checked").length == status_change_checkboxes){

        $('#select_event_order_update_status').prop("checked", true);
    }
    else{
        $('#select_event_order_update_status').prop("checked", false);
    }

    // if ($(".status_change_checkbox:checked").length > 0) {
    //     // $('#select_event_order_update_status').attr('checked', true);
    //     $(".update-event-order-status").prop('disabled', false);
    //     $(".update-event-order-status").removeClass('disabled-button');
    // } else {
    //     // $('#select_event_order_update_status').attr('checked', false);
    //     $(".update-event-order-status").prop('disabled', true);
    //     $(".update-event-order-status").addClass('disabled-button');
    // }




});


//check for change in status when there is any change in dropdown value of status
function checkForStatusChange(scope) {
    document.getElementById(scope.id + '_btn').disabled = (scope.value ? scope.value === scope.dataset.selectedStatus : true);
}

//save the changes
function saveChanges(scope) {
    var selectedStatusValue = scope.parentElement.parentElement.getElementsByTagName('select')[0].value;

    jQuery.ajax({
        url: "/v1/event_orders/" + scope.dataset.eventorderid + "/update_status",
        type: "GET",
        data: { "status": selectedStatusValue },
        success: function(data) {
            console.log('current event order saved successfully');
            $(".simple-single").select2({
                minimumResultsForSearch: Infinity
            });
        }
    });
}