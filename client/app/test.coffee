define (require, exports)->
	$(->	
		limitWidth = 100
		startX = lastX = 0
		startY = lastY = 0
		swiping = false
		dragging = false
		$(document)
		.delegate('li','touchstart',(e)->
			$(this).addClass('hover')
			
			startX = lastX = e.touches[0].clientX
			startY = lastY = e.touches[0].clientY
			
			swiping = true
		)
		.delegate('li','touchend',(e)->			
			$itemLi = $(this)
			if dragging
				$itemLi
					.removeClass('hover moving')
					.css('-webkit-transform', '')
				dragging = false
				
			if swiping
				distanceX = lastX - startX
				percentage = distanceX/limitWidth
				
				$itemLi
					.removeClass('hover')
					.css('-webkit-transform', '')
					
				$itemLi.find('.delete-line')
					.css('-webkit-transform', 'scaleX(0)')
					
				if -1<percentage<1 then $(this).removeClass('done removing').css('opacity','1')
				else if percentage<=-1
					$itemLi.css('opacity','0')
					setTimeout((->$itemLi.remove()),300)
					
				swiping = false
		)
		.delegate('li','touchmove',(e)->
			if not dragging and not swiping then return
			
			point = e.touches[0]
			lastX = point.clientX
			lastY = point.clientY
			if dragging
				distanceY = point.clientY - startY
				index = $(this).index()
				if distanceY >= 28	
					$('ul.item-list li:nth-child('+(index+2)+')').after(this)
					startY += 56 
				if distanceY <= -28
					$('ul.item-list li:nth-child('+(index)+')').before(this)					
					startY -= 56
					
				distanceY = point.clientY - startY
				$(this).css('-webkit-transform', 'translate3d(0,'+distanceY+'px, 0) scale(1.05)')
				
				
			if swiping
				distanceX = point.clientX - startX
				percentage = distanceX/limitWidth
				$(this).removeClass('done removing')
				
				if 0<percentage<1
					$(this).find('.delete-line').css('-webkit-transform', 'scaleX('+percentage+')')
				else if percentage>=1
					$(this).find('.delete-line').css('-webkit-transform', 'scaleX(1)')
					$(this).addClass('done')
				else if percentage>-1
					$(this).css('opacity', 1 + percentage/2)
				else if percentage <-1
					$(this).addClass('removing')
					
					
				$(this).css('-webkit-transform', 'translate3d('+distanceX+'px,0, 0) scale(1.05)')					
		)
		.delegate('li','longTap',(e)->
			$(this).addClass('moving')
			dragging = true
			swiping = false

		)
		# .delegate('li','click',(e)->
		# 	move(this).x(20).end()
		# 	index = $(this).index()
		# )
		
		# $('li').css('-webkit-transform', 'translate3d(100px,0, 20px)');

	)