this.autoComplete = function() {
  return $('.autocomplete').each(function() {
    $(this).autocomplete({
      source: function(request, response){
        $.ajax({
            url: '/v1/forums/autocomplete',
            dataType: "json",
            data: {
                term : request.term,
                noLoading : true
            },
            success: function(data) {
                response(data);
            }
        });
      },
      minLength: 0,
      delay: 1000,
      messages: {
        noResults: '',
        results: function () { }
      },
      change: window[$(this).data('autocompletechange')] || function (event, ui) {},
      close: window[$(this).data('autocompleteclose')] || function (event, ui) {},
      search: window[$(this).data('autocompletesearch')] || function (event, ui) {},
      response: window[$(this).data('autocompleteresponse')] || function (event, ui) {},
      open: window[$(this).data('autocompleteopen')] || function (event, ui) {}
    });
     $('ul.list-unstyled').parents('div.mCustomScrollbar').mCustomScrollbar();
    return $(this).autocomplete().data("uiAutocomplete")._renderItem = window[$(this).data('render-item')] || function(ul, item) {};
    return $(this).autocomplete().data("uiAutocomplete")._renderMenu = window[$(this).data('render-menu')] || function (ul, items) {};
  });
};

$(document).on('turbolinks:load', this.autoComplete);

