// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function onPercentTypeChange(e){
  if($("[name='payment_gateway_mode_association[percent_type]']").val() == 'range'){
    $('#payment_gateway_mode_association_range_tr').removeClass('hidden');
    $("[name='payment_gateway_mode_association[percent]']").val("0.0")
                                                            .closest("td").addClass("tdoverlay");
  }else{
    $('#payment_gateway_mode_association_range_tr').addClass('hidden');
    $("[name='payment_gateway_mode_association[percent]']").closest("td").removeClass("tdoverlay");
  }
}

$(document).on('turbolinks:load', function() {
  $('form#admin_payment_gateway_mode_association_form').validate();
});

$(document).on("focusout",".mode_association_range_max_value",function(){

    var currentRow = $(this).closest('tr'), nextRow = currentRow.nextAll('tr').first();
    if(currentRow.find("input[name*='[min_value]']").val() == currentRow.find("input[name*='[max_value]']").val())
    {
      toastr.error("Minimum and maximun value cannot be same.");
      currentRow.find("input[name*='[max_value]']").val("");
    }else if(nextRow.length){
      nextRow.find("input[name*='[min_value]']").val(currentRow.find("input[name*='[max_value]']").val());
    }

});

$(document).on("cocoon:after-insert","#payment_gateway_mode_association_tax_type_tbody",function(e, insertedItem){
  $(".basic-single").select2({
      minimumResultsForSearch: Infinity
  });
});

$(document).on("cocoon:before-insert","#payment_gateway_mode_association_range_tbody",function(e, insertedItem){

  var mode_rows = $('#payment_gateway_mode_association_range_tbody').find('tr');

  if(mode_rows.length){

    if(mode_rows.last().find("input[name*='[max_value]']").val() == "Infinity"){
      toastr.error("You have already inserted an infinity limit. You are not allowed to add more.");
      insertedItem.addClass('deletable_payment_gateway_mode_association_range_tr');
    }else if(!$.isNumeric(mode_rows.last().find("input[name*='[max_value]']").val())){
      toastr.error("Please enter a valid max value.");
      insertedItem.addClass('deletable_payment_gateway_mode_association_range_tr');
    }
    else{
      insertedItem.find("input[name*='[min_value]']").val(mode_rows.last().find("input[name*='[max_value]']").val()); 
      insertedItem.find("input[name*='[percent]']").val(mode_rows.last().find("input[name*='[percent]']").val()); 
    }

  }

});

$(document).on("cocoon:after-insert","#payment_gateway_mode_association_range_tbody",function(e, addedItem){
  if(addedItem.hasClass('deletable_payment_gateway_mode_association_range_tr')){
    addedItem.remove();
  }
});

$(document).on("keypress keyup blur", ".mode_association_range_max_value", function (event) {
  var currentRow = $(this).closest('tr'), nextRow = currentRow.nextAll('tr').first();
  if(nextRow.length){
    $(this).val($(this).val().replace(/[^\d].+/, ""));
    if ((event.which < 48 || event.which > 57)) {
        event.preventDefault();
    }
  } 
});
