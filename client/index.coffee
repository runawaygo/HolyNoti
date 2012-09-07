define (require,exports)->

	# Test = require('./app/test.coffee')	
	App = require('./app/app.coffee')
	dutyStaff =->
		$(document).on('touchmove',(e)->e.preventDefault())
		eLogOpen = false
		$eLogContainer = $('#debug-container')
		window.eLog = (str)->
			if not eLogOpen then $eLogContainer.show() 
			$eLogContainer[0].innerHTML += '<br/>' + str
			
	$(->
		dutyStaff()
		try
			app = new App()
			app.start()
		catch error
			console.log error
			alert(error)
	)