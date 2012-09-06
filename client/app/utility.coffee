define (require, exports) ->
	exports.template = (elementId)->
		_.template($(elementId).html().trim())
	exports.later = (action, delta)->
		delta ?= 0
		setTimeout(action,delta)
	exports.getRandomBetween = (l,r)->
		r = Math.random() * (r-l) + l
		Math.round(r)
	exports
	