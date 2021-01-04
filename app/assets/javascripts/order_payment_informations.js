function changePaymentModeDetails(e, amt){

  $('div.ccavenueDetailOverlay').removeClass('overlay-active');

  var event_id = $(e).data('event'), event_order_id = $(e).data('order'), eleId = e.id, upgrade = $("input[type=hidden][name='payment_details[upgrade]']").val(), parent_event_order_id = $("input[type=hidden][name='payment_details[parent_event_order_id]']").val();

  $.ajax({
      data: {
          "payment_gateway_mode_association_id": eleId,
          "amount": amt,
          "upgrade": upgrade,
          "parent_event_order_id": parent_event_order_id
      },
      dataType: 'script',
      url: '/v1/events/' + event_id + '/event_orders/' + event_order_id + '/payment_mode_details' ,
      complete: function() {

      }
  });

}

$(document).on('turbolinks:load', function() {

  $('#ccavenue-gateway-payment-form').validate();

  $('#ccavenue-gateway-payment-form').submit(function(){
    if(($('input[name=ccavenue_modes]').length) && (!$('input[name=ccavenue_modes]:checked').length)){
      toastr.error("You have not selected any Mode of Payment.");
      return false;
    }
  });

});