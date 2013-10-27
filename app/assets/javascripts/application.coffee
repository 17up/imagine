#= require jquery
#= require jquery_ujs
#= require jquery.remotipart
#= require hamlcoffee
#= require underscore
#= require backbone
#= require backbone.marionette
#= require websocket_rails/main
#= require_tree ./lib
#= require_tree ./templates
#= require_tree ./backbone/models
#= require backbone/welcome
#= require backbone/veggie
#= require backbone/olive
#= require backbone/user_show


$ ->
	$('body').on 'click',"span.close", ->
		$(@).parent().remove()
	soundManager.setup
		useHTML5Audio: true
		preferFlash: false
	$init = $("#init")
	if $init.length is 1
		js_class = $init.data().js
		new window[js_class]
