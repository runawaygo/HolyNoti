seajs.config({
	base: './',
	debug:true,
  	preload: ['plugin-coffee', 'plugin-less']
});


define(function(require) {
	console.log('seajs start');
	require('index.coffee');	
	require('index.less');
});
