seajs.config({
	base: './',
	debug:true,
  	preload: ['plugin-coffee', 'plugin-less']
});


define(function(require) {
	console.log('seajs start');
	$LAB
	.script('./lib/less.js')
	.script('./lib/json2.js')
	.script('./lib/jquery-1.7.1.min.js')
	.script('./lib/jquery.tmpl.js')
	.script('./lib/underscore-1.3.1.js').wait()
	.script('./lib/backbone.js')
	.script('./bootstrap/js/google-code-prettify/prettify.js')
	.script('./bootstrap/js/bootstrap-transition.js')
	.script('./bootstrap/js/bootstrap-alert.js')
	.script('./bootstrap/js/bootstrap-modal.js')
	.script('./bootstrap/js/bootstrap-dropdown.js')
	.script('./bootstrap/js/bootstrap-scrollspy.js')
	.script('./bootstrap/js/bootstrap-tab.js')
	.script('./bootstrap/js/bootstrap-tooltip.js')
	.script('./bootstrap/js/bootstrap-popover.js')
	.script('./bootstrap/js/bootstrap-button.js')
	.script('./bootstrap/js/bootstrap-collapse.js')
	.script('./bootstrap/js/bootstrap-carousel.js')
	.script('./bootstrap/js/bootstrap-typeahead.js')
	.wait(function(){
		require('index.coffee');	
		require('index.less');
	})
});
