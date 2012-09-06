seajs.config({
	base:'./',
	debug: true,
	alias: {
	    'coffee': 'lib/coffee-script',
    	'less': 'lib/less'
  	},
  	preload: ['plugin-coffee', 'plugin-less']
});


define(function(require) {
	console.log('seajs start');	

	require('index.coffee');	
	require('index.less');
});
