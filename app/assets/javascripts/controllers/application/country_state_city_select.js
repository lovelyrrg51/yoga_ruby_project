// city select
function citySelectChange(dataChangableId) {

    var targetEl = $('#city_' + dataChangableId); // city select dropdown
    var otherCity = $('#otherCity_' + dataChangableId);
    var otherCityOverl = $('#otherCityOverl_' + dataChangableId);

    if ($(targetEl).children(':selected').text() == "Others") {

        otherCityOverl.removeClass('overlay-active');

    } else {
        otherCity.val('');
        otherCityOverl.addClass('overlay-active');
    }
    otherCity.valid();
}



// state select
function stateSelectChange(dataChangableId) {

    var targetEl = $('#state_' + dataChangableId); // state select dropdown
    var selectedStateId = targetEl.val(); // selected state code

    var otherState = $('#otherState_' + dataChangableId);
    var otherStateOverl = $('#otherStateOverl_' + dataChangableId);
    var otherCity = $('#otherCity_' + dataChangableId);
    var otherCityOverl = $('#otherCityOverl_' + dataChangableId);

    if ($(targetEl).children(':selected').val() == OTHER_STATE_ID) {

        var targetCitySelect = $("#city_" + dataChangableId);
        otherStateOverl.removeClass('overlay-active');
        otherCityOverl.removeClass('overlay-active');
        targetCitySelect.empty()
            .append('<option value="">----- Select -----</option>' + '<option selected="selected" value="999999">Others</option>');
        targetCitySelect.removeAttr("data-autocomplete-city");

    } else {

        otherState.val('');
        otherCity.val('');

        $("#city_" + dataChangableId).empty()
            .append('<option value="">----- Select -----</option>');
        otherStateOverl.addClass('overlay-active');
        otherCityOverl.addClass('overlay-active');

         if ($(targetEl).children(':selected').val().length > 0 && ($('.filter-panel').length > 0 ? checkStateCityVisibility(dataChangableId) : true)) {
        // get cities
            $.ajax({
                data: {
                    "changable_id": dataChangableId,
                    "state_id": selectedStateId,
                    "noLoading": true
                },
                dataType: 'script',
                url: '/v1/db_cities',
                success: function(data, textStatus, jqXHR) {
                    var ajax_params = this.url.queryParams(),
                        city_ele = $('#city_' + ajax_params['changable_id']);
                    if(city_ele.length && city_ele.attr('data-autocomplete-city')){
                        setTimeout(function(){
                            var city_option = city_ele.find('option').filter(function () { return $(this).html() == city_ele.attr('data-autocomplete-city'); });
                            if(city_option.length){
                                city_ele.val(city_option.get(0).value).trigger('change');
                            }else{
                                var otherCity = $('#otherCity_' + city_ele.attr('data-changable-id')),
                                    otherCityOverl = $('#otherCityOverl_' + city_ele.attr('data-changable-id'));
                                otherCity.val(city_ele.attr('data-autocomplete-city'));
                                otherCityOverl.removeClass('overlay-active');
                                city_ele.val(OTHER_CITY_ID).trigger('change');
                            }
                            city_ele.removeAttr("data-autocomplete-city");
                        }, 0, city_ele);
                    }
                }
            });
        }
    }
    if(otherCity.length > 0 ){otherCity.valid();}
    if(otherState.length > 0 ){otherState.valid();}
}



// country select
function countrySelectChange(dataChangableId) {

    var countryId = $('#country_' + dataChangableId).val(); // selected country code
    var otherState = $('#otherState_' + dataChangableId);
    otherState.val('');
    var otherStateOverl = $('#otherStateOverl_' + dataChangableId);
    otherStateOverl.addClass('overlay-active');
    var otherCity = $('#otherCity_' + dataChangableId);
    otherCity.val('');
    var otherCityOverl = $('#otherCityOverl_' + dataChangableId);
    otherCityOverl.addClass('overlay-active');

    $("#city_" + dataChangableId).empty()
        .append('<option value="">----- Select -----</option>');
    $("#state_" + dataChangableId).empty()
        .append('<option value="">----- Select -----</option>');
    if (countryId.length != 0 && ($('.filter-panel').length > 0 ? checkStateCityVisibility(dataChangableId) : true))   {
        // get states
        $.ajax({
            data: {
                "changable_id": dataChangableId,
                "country_id": countryId,
                "noLoading":true
            },
            dataType: 'script',
            url: '/v1/db_states',
            success: function(data, textStatus, jqXHR) {
                var ajax_params = this.url.queryParams(),
                    state_ele = $('#state_' + ajax_params['changable_id']);
                if(state_ele.length && state_ele.attr('data-autocomplete-state')){
                    setTimeout(function(){
                        var state_option = state_ele.find('option').filter(function () { return $(this).html() == state_ele.attr('data-autocomplete-state'); });
                        if(state_option.length){
                            state_ele.val(state_option.get(0).value).trigger('change');
                        }else{
                            var otherState = $('#otherState_' + state_ele.attr('data-changable-id')),
                                otherStateOverl = $('#otherStateOverl_' + state_ele.attr('data-changable-id'));
                            otherState.val(state_ele.attr('data-autocomplete-state'));
                            otherStateOverl.removeClass('overlay-active');
                            state_ele.val(OTHER_STATE_ID).trigger('change');
                        }
                        state_ele.removeAttr("data-autocomplete-state");
                    }, 0, state_ele);
                }
            }
        });
    }
    if(otherCity.length > 0 ){otherCity.valid();}
    if(otherState.length > 0 ){otherState.valid();}
}

function checkStateCityVisibility(dataChangableId){
    // check whether city should be visible or not?
    var premiumCountries = ['Canada', 'United States'];
    var bigCountries = ['India'];
    var stateSelectBox =  $('#state_' + dataChangableId).parents('.col-sm-6');
    var citySelectBox =  $('#city_' + dataChangableId).parents('.col-sm-6');
    var country_name = $("select[name='country_id'] option:selected").text();
    var stateCityVisibility = true;
    if (bigCountries.includes(country_name)){
        stateSelectBox.show();
        citySelectBox.show();
        return true;
    }
    else if (premiumCountries.includes(country_name)){
        stateSelectBox.show();
        citySelectBox.hide();
        $('#city_' + dataChangableId).html('');
        return true;
    }else{
        stateSelectBox.hide();
        $('#state_' + dataChangableId).html('');
        citySelectBox.hide();
        $('#city_' + dataChangableId).html('');
        return false;
    }
}
