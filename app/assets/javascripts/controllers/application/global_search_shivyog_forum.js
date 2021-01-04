var renderAutocompleteItemSyClub = function (ul, item) {
  $('<li>').append(item.label).appendTo('ul.list-unstyled.forum-list');
  return ul;
};

var autocompleteClearSyClub = function (event, ui) {
  if ($(event.target).val().length > 0){
    var searchbgDiv = $('.searchbg');
    searchbgDiv.find('div.dropdown-menu').removeClass('hidden').end()
    .find('div.loadercontent').removeClass('hidden').end()
    .find('div.input-group').find('div.dropdown-menu').find('ul.list-unstyled').addClass('hidden');
    searchbgDiv.find('div.notfound').addClass('hidden');
  }
  return ui;
};

var autocompleteResponseSyClub = function (event, ui) {
  if ($(event.target).val().length == 0){
    autocompleteHideDropdownSyClub();
    return;
  };
  var searchbgDiv = $('.searchbg');
  searchbgDiv.find('div.dropdown-menu').removeClass('hidden');
  if (ui.content && ui.content.length) {
    searchbgDiv.find('div.input-group').find('div.dropdown-menu').find('ul.list-unstyled').removeClass('hidden').html('');
    searchbgDiv.find('div.input-group').addClass('open').end()
    .find('div.notfound').addClass('hidden').end()
    .find('div.loadercontent').addClass('hidden');
  } else {
    searchbgDiv.find('div.input-group').addClass('open').end()
    .find('div.notfound').removeClass('hidden').end()
    .find('div.input-group').find('div.dropdown-menu').find('ul.list-unstyled').addClass('hidden');
    searchbgDiv.find('div.loadercontent').addClass('hidden');
  }
};

var autocompleteHideDropdownSyClub = function () {
  var searchbgDiv = $('.searchbg');
  searchbgDiv.find('div.dropdown-menu').addClass('hidden').end()
  .find('div.loadercontent').addClass('hidden').end()
  .find('div.input-group').find('div.dropdown-menu').find('ul.list-unstyled').addClass('hidden').html('');
  searchbgDiv.find('div.notfound').addClass('hidden').end()
  .find('div.input-group').removeClass('open').end()
  .find('input.form-control').val("");
};

var autocompleteOpenSyClub= function(event, ui) {
  equalheight('.searchbg ul li .searchlist');
}

$(document).on('turbolinks:load', function () {
  $('.searchbg').find('div.input-group').on('hidden.bs.dropdown', autocompleteHideDropdownSyClub);
})
