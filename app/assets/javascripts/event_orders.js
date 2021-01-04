$(document).on('turbolinks:load', function() {

    var togglePaymentGateways = function () {

        var paymentGatewayType = $(this).data('type');

        var paymentGatewayFormDiv = $('div#' + $(this).data('id'));

        $('div[data-type=' + paymentGatewayType + ']:visible').toggle();

        $('input[data-type=' + paymentGatewayType + ']:radio:checked').prop('checked', '');

        paymentGatewayFormDiv.show();

        $(this).prop('checked', 'checked');

    };

    $('input:radio:checked').each(togglePaymentGateways);

    $('input:radio').on('click', togglePaymentGateways);

    $('form#edit_registration_details_form').submit(function(){

        var error = false;

        if($("input[name='event_order_action']:checked").length){
            if($("input[name='event_order_action']:checked").val() == "transfer" && $("select[name='event_order[to_event_id]']").val().length == 0){
                toastr.error('Please select the Event for transfer.');
                error = true;
            }
        }else{
            toastr.error('Please select the valid action.');
            error = true;
        }

        if(error) return false;

    });

    $("input[name='event_order_action']").click(function(){

        $("input[type='hidden'][name='event_order[action]']").val($(this).val());
    
        var from_event = $("input[name='event_order[from_event_id]']").val(), event_order = $("input[name='current_event_order']").val();
    
        if($(this).val() == 'transfer'){
    
                var selectedLineItems = []
                _.filter($('.line_item_checkbox'), function(line_item){
                if($(line_item).is(':checked')) selectedLineItems.push($(line_item).closest('tr').attr('id'));
            });
    
            if(selectedLineItems.length){
    
                $.ajax({
                    data: {
                        "selected_line_items": selectedLineItems,
                    },
                    dataType: 'script',
                    url: '/v1/events/'+ from_event +'/event_orders/' + event_order + '/transfered_events',
                    success: function() {
                        $('div.transfer_event_select_div').removeClass('hidden');
                    }
                });
    
            }
    
        }
    
        if($(this).val() == 'upgrade_downgrade'){
            var action = "/v1/events/" + from_event + "/event_orders/" + event_order + "/edit_details"
            $(this).closest('form#edit_registration_details_form').attr('action', action);
    
            $('div.transfer_event_select_div').addClass('hidden');
            $("select[name='event_order[to_event_id]']").html("<option value=''>----- Select -----</option>");
    
        }
    
        if($(this).val() == 'cancel'){
    
            var action = "/v1/events/" + from_event + "/event_orders/" + event_order + "/cancel_registrations"
            $(this).closest('form#edit_registration_details_form').attr('action', action);
    
            $('div.transfer_event_select_div').addClass('hidden');
            $("select[name='event_order[to_event_id]']").html("<option value=''>----- Select -----</option>");
            
        }
        
    });

});

$(document).on('submit', '#gateway-payment-form', function() {
    // Disable the submit button to prevent repeated clicks:
    $(this).find('button').prop('disabled', true);
    $(this).find('button').html('Processing Payment....');
});

$(document).on('click', '.line_item_edit_checkbox', function(){
    var checkedItems = _.filter($('.line_item_edit_checkbox'), function(item){
        return $(item).is(":checked");
    });
    if($(this).is(":checked")){
        if($('.line_item_edit_checkbox').length == checkedItems.length) $('.select_all_line_item_edit_checkbox').prop('checked', true);
        $('.edit_pre_approval_items_button').removeClass('hidden');
    }else{
        $('.select_all_line_item_edit_checkbox').prop('checked', false);
        if(checkedItems.length == 0) $('.edit_pre_approval_items_button').addClass('hidden');
    }
});

function onSelectAllCheckboxClick(){
    var currentStatus = $(this).is(":checked"); 
    $('.line_item_edit_checkbox').prop('checked', currentStatus);
    (currentStatus) ? $('.edit_pre_approval_items_button').removeClass('hidden') : $('.edit_pre_approval_items_button').addClass('hidden');
};

$(document).on('click', '.line_item_checkbox', function(){

    if($(this).is(':checked')){
        $('div.reg_details_toggle_div').removeClass('hidden');
    }else{
        checkedItems = _.find($('.line_item_checkbox'), function(line_item){
            return $(line_item).is(':checked');
        });
        if($(checkedItems).length == 0) $('div.reg_details_toggle_div').addClass('hidden');
    }

    $("input[name='event_order_action']:checked").prop('checked', false);

    ($("[name='event_order[event_order_line_item_ids][]']:checked").length == $("[name='event_order[event_order_line_item_ids][]']").length) ? $('.select_all_line_item_checkbox').prop('checked', true) : $('.select_all_line_item_checkbox').prop('checked', false);

    $('div.transfer_event_select_div').addClass('hidden');
    $("select[name='event_order[to_event_id]']").html("<option value=''>----- Select -----</option>");

});

$(document).on('click', '.select_all_line_item_checkbox', function(){

    var selectedProp = $(this).is(':checked');

    _.find($('.line_item_checkbox'), function(line_item){
        $(line_item).prop('checked', selectedProp)
    });

    selectedProp ? $('div.reg_details_toggle_div').removeClass('hidden') : $('div.reg_details_toggle_div').addClass('hidden');

});

function onTransferEventSelect(e){
    var action = "/v1/events/" + $(e).val() + "/event_orders/" + $("input[name='current_event_order']").val() + "/edit_details"
    $('form#edit_registration_details_form').attr('action', action);
}

$(document).on('change', '.event-order-edit-seating-category-select-tag', function(){

    var selectedCategory = $(this).val();

    var category = _.find($(this).data('seating-categories'), function(category){
        return category.id === selectedCategory; 
    });

    (typeof category != "undefined" && category) ? $(this).closest('tr').find('td.category_price').html(category.price) : $(this).closest('tr').find('td.category_price').html(" - ");

});

$(document).on('click', '.modal_back_button', function() {
    $("div.event-registration.forgotsyid").addClass('hidden');
    $("div.registeredshivyog").removeClass('hidden');
});

$(document).on('click', '.shadhak-edit-modal-anchor', function(){
    if($(this).closest('tr').data('sadhak').match(/SY\d+/)){
    $("input[type='hidden'][name='sadhak_profile[from_syid]']").val($(this).closest('tr').data('sadhak'));
    $("input[type='hidden'][name='sadhak_profiles[from_syid]']").val($(this).closest('tr').data('sadhak'));
    $('div#shadhakeditmodal').modal('show');
    }else{
    $('div#shadhakeditmodal').modal('hide');
    }    
});