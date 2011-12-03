var express = require('express'),
	app = express.createServer();

var fs = require('fs');

app.use(express.logger({ format: ':method :url :status' }));
app.use(express.bodyParser());
app.use(express.cookieParser());
app.use(express.session({ secret: 'superwolf' }));
app.use(app.router);


app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
app.use('/client',express.static(__dirname + '/client',{ cache:false}));
app.error(function(err, req, res){
	console.log("500:" + err + " file:" + req.url)
	res.render('500');
});


app.get('/', function(req, res){
	res.redirect('/client/index.html');
});

var port = process.env.PORT || 8888;
console.log("service run on " + port);

app.listen(port);