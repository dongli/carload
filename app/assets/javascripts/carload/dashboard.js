//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require select2
//= require upload-image
//= require remarkable/remarkable.min
//= require_tree .

$(document).on('turbolinks:load', function() {
  $('.use-select2').select2({
    placeholder: $(this).data('placeholder')
  })
})
