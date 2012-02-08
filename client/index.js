seajs.config({
	base: 'http://127.0.0.1:8000/client/',
	debug:true,
  	preload: ['plugin-coffee', 'plugin-less']
});


define(function(require) {
	console.log('begin');
	$LAB
	.script('/client/lib/less.js')
	.script('/client/lib/json2.js')
	.script('/client/lib/jquery-1.7.1.min.js')
	.script('/client/lib/jquery.tmpl.js')
	.script('/client/lib/underscore-1.3.1.js').wait()
	.script('/client/lib/backbone.js')
	.script('/client/bootstrap/js/bootstrap.js').wait(function(){
		require('index.coffee');	
		require('index.less');
	})
	

	// var Constellation = require('./logic/constellation.coffee');
	// 
	// var dd =new Constellation.Constellation();
	// 
	// console.log(dd);
});
