define (require, exports)->
	utility = require('./utility.coffee')
	template = utility.template
	
	class BaseView extends Backbone.View
		_remove:=>
			@undelegateEvents()
			@$el.remove()
			@
		_wrap:(obj)->
			_.extend({},@options,obj)
	class ListModel extends Backbone.Model
		defaults:
			title:''
			count:0
			status:'todo'
		
	class ListCollection extends Backbone.Collection
		model:ListModel
		localStorage: new Store("ListCollection")
		
		
	class ItemModel extends Backbone.Model
		defaults:
			title:""
			createOn:new Date()
			alertOn:null
			listId:0
			order:0
			status:'todo'
			priority:3
			
	
	class ItemCollection extends Backbone.Collection
		model: ItemModel
		localStorage: new Store("ItemCollection")
		queryByListId:(listId)=>
			@filter((item)->item.get('listId') is listId)
		
		
	class ListView extends BaseView
		tagName:'li'
		_template:template('#listTemplate')
		limitWidth:80
		startX:0
		startY:0
		lastX:0
		lastY:0
		liIndex:-1
		liCount:0
		swiping:false
		dragging:false
		multi:false
		events:
			'singleTap'		:'_open'
			'doubleTap'		:'_edit'
			'longTap'		:'_longTap'
			'touchstart'	:'_touchstart'
			'touchend'		:'_touchend'
			'touchmove'		:'_touchmove'
			
			'focusout input'	:'_updateTitle'			
			'keypress input'	:'_enterOrUpdateTitle'
			
			'dblclick'			:'edit'
			'click'				:'_open'
			'mousedown'		:'_touchstart'
			'mouseup'		:'_touchend'
			'mousemove'		:'_touchmove'
			
		initialize:=>
			@model.on('change:title',@render)
			@model.on('destroy',@_remove)
			
		_longTap:(e)=>
			@$el.addClass('moving')
			@dragging = true
			@swiping = false
			
		_touchstart:(e)=>
			point = e.touches?[0] ? e
			@startX = @lastX = point.clientX
			@startY = @lastY = point.clientY
			@swiping = true
			
			@liIndex = @$el.index()
			@liCount = @$el.parent().children('li').length
			
			if @model.get('status') is 'done'
				return
			else if @model.get('status') is 'todo'
				@$el.addClass('hover')
			
		_touchmove:(e)=>
			if not @dragging and not @swiping then return
			
			if @model.get('status') is 'done'
				return
			else if @model.get('status') is 'todo'
				point = e.touches?[0] ? e
				@lastX = point.clientX
				@lastY = point.clientY
				if @dragging
					distanceY = point.clientY - @startY
					
					if distanceY>=25 and @liIndex<@liCount-1
						$target = @$el.parent().children('li:nth-child('+(@liIndex+2)+')')
						@liIndex++
						# if $target[0] is not @$el[0]
						$target.after(@$el)
						@startY += 50 
					if distanceY < -25 and @liIndex >0
						$target = @$el.parent().children('li:nth-child('+(@liIndex)+')')
						@liIndex--
						# if $target[0] is not @$el[0]
						$target.before(@$el)
						@startY -= 50
					
					distanceY = point.clientY - @startY
					@$el.css('-webkit-transform', 'translate3d(0,'+distanceY+'px, 0) scale(1.05)')
				
				if @swiping
					distanceX = point.clientX - @startX
					percentage = distanceX/@limitWidth
				
					if 0<percentage<1
						@$el.removeClass('doing removing')
						@$('.delete-line').css('-webkit-transform', 'scaleX('+percentage+')')
					else if percentage>=1
						@$('.delete-line').css('-webkit-transform', 'scaleX(1)')
						@$el.addClass('doing')
					else if percentage>-1
						@$el.css('opacity', 1 + percentage/2)
					else if percentage <-1
						@$el.addClass('removing')
					
					@$el.css('-webkit-transform', 'translate3d('+distanceX+'px,0, 0) scale(1.01)')
				
		_touchend:(e)=>
			if @model.get('status') is 'done' 
				return
			else if @model.get('status') is 'todo'
				if @dragging
					@$el.removeClass('hover moving')
						.css('-webkit-transform', '')
					@dragging = false
				
				if @swiping
					distanceX = @lastX - @startX
					percentage = distanceX/@limitWidth
				
					@$el.removeClass('hover doing removing')
						.css('-webkit-transform', '')
						.css('opacity','')
					
					@$('.delete-line')
						.css('-webkit-transform', 'scaleX(0)')
					
					if percentage<=-1
						@$el.css('opacity','0')
						setTimeout((=>@_remove()),300)
					else if percentage >= 1
						@model.set('status','done')
					
					@swiping = false
		
		_updateTitle:=>
			title = @$('input').val()
			if not title or title.trim() is ''
				@model.destroy()
			else
				@model.save({title:title})
				@$el.removeClass('editing')
				
			@options.eventBus.trigger('list:edited')
		_enterOrUpdateTitle:(e)=>	
			if e.keyCode is 13
				@_updateTitle()
			else if e.keyCode is 27
				@$('input').val('')
				@_updateTitle()
			@
		_open:(e)=>
			@options.eventBus.trigger('openList',@model.id)
			e.stopPropagation()
			e.preventDefault()
			@
		_edit:(e)=>
			e.preventDefault()
			e.stopPropagation()
			@edit()
		_remove:=>			
			@model.off('change:title',@render)
			@model.off('destroy',@_remove)
			super()
		
		edit:=>
			@$el.addClass('editing')
			@$('input').focus()
			
			@options.eventBus.trigger('list:editing')
		render:=>
			$(@el).html(@_template(@model.toJSON()))
			@
		
		
	class ListCollectionView extends BaseView
		tagName:'ul'
		className:'list-list'
		events:
			'doubleTap'			:'_doubleTap'
			# 'dblclick'			:'_doubleTap'
			'touchstart'	:'_touchstart'
			'touchend'		:'_touchend'
			'touchmove'		:'_touchmove'
		initialize:->
			@model.on('add',@_newOne)
			@options.eventBus.on('list:editing',@_listEditing)
			@options.eventBus.on('list:edited',@_listEdited)
			
		_listEditing:=>
			@$el.addClass('editing')
		_listEdited:=>
			@$el.removeClass('editing')
		_doubleTap:=>
			@model.create({title:''})
			
		_newOne:(item)=>			
			view = new ListView(@_wrap({model:item}))
			@$el.append(view.render().el)
			view.edit()
			
		_touchstart:(e)=>
		_touchmove:(e)=>
		_touchend:(e)=>
		_addOne:(item)=>
			view = new ListView(@_wrap({model:item}))
			@$el.append(view.render().el)
		render:=>
			@$el.html('')
			@model.forEach(@_addOne)
			@
	
	class ItemView extends BaseView
		tagName:'li'
		_template:_.template('<div><%= title%><div class="delete-line" /></div>')
		_editTemplate:_.template('<input value="<%= title%>" />')
		limitWidth:80
		startX:0
		startY:0
		lastX:0
		lastY:0
		liIndex:-1
		liCount:0
		swiping:false
		dragging:false
		multi:false
		events:
			'touchstart'	:'_touchstart'
			'touchend'		:'_touchend'
			'touchmove'		:'_touchmove'
			'mousedown'	:'_touchstart'
			'mouseup'		:'_touchend'
			'mousemove'	:'_touchmove'
		_touchstart:(e)=>			
			point = e.touches?[0] ? e
			@startX = @lastX = point.clientX
			@startY = @lastY = point.clientY
			@swiping = true
			
			@liIndex = @$el.index()
			@liCount = @$el.parent().children('li').length
			
			if @model.get('status') is 'done'
				return
			else if @model.get('status') is 'todo'
				@$el.addClass('hover')
			
		_touchmove:(e)=>
			if not @dragging and not @swiping then return

			if @model.get('status') is 'done'
				return
			else if @model.get('status') is 'todo'
				point = e.touches?[0] ? e
				@lastX = point.clientX
				@lastY = point.clientY
				if @dragging
					distanceY = point.clientY - @startY

					if distanceY>=25 and @liIndex<@liCount-1
						$target = @$el.parent().children('li:nth-child('+(@liIndex+2)+')')
						@liIndex++
						# if $target[0] is not @$el[0]
						$target.after(@$el)
						@startY += 50 
					if distanceY < -25 and @liIndex >0
						$target = @$el.parent().children('li:nth-child('+(@liIndex)+')')
						@liIndex--
						# if $target[0] is not @$el[0]
						$target.before(@$el)
						@startY -= 50

					distanceY = point.clientY - @startY
					@$el.css('-webkit-transform', 'translate3d(0,'+distanceY+'px, 0) scale(1.05)')

				if @swiping
					distanceX = point.clientX - @startX
					percentage = distanceX/@limitWidth

					if 0<percentage<1
						@$el.removeClass('doing removing').css('opacity','1')
						@$('.delete-line').css('-webkit-transform', 'scaleX('+percentage+')')
					else if percentage>=1
						@$('.delete-line').css('-webkit-transform', 'scaleX(1)')
						@$el.addClass('doing')
					else if percentage>-1
						@$el.css('opacity', 1 + percentage/2)
					else if percentage <-1
						@$el.addClass('removing')

					@$el.css('-webkit-transform', 'translate3d('+distanceX+'px,0, 0) scale(1.01)')

		_touchend:(e)=>
			if @model.get('status') is 'done' 
				return
				
			else if @model.get('status') is 'todo'
				if @dragging
					@$el.removeClass('hover moving')
						.css('-webkit-transform', '')
					@dragging = false

				if @swiping
					distanceX = @lastX - @startX
					percentage = distanceX/@limitWidth

					@$el.removeClass('hover doing removing')
						.css('-webkit-transform', '')
						.css('opacity','')

					@$('.delete-line')
						.css('-webkit-transform', '')

					if percentage<=-1
						@$el.css('opacity','0')
						setTimeout((=>@_remove()),300)
					else if percentage >= 1
						@model.set('status','done')
						@$el.addClass('done')

					@swiping = false

		_updateTitle:=>
			title = @$('input').val()
			if not title or title.trim() is ''
				@model.destroy()
			else
				@model.save({title:title})
				@$el.removeClass('editing')

			@options.eventBus.trigger('item:edited')
			
		_enterOrUpdateTitle:(e)=>	
			if e.keyCode is 13
				@_updateTitle()
			else if e.keyCode is 27
				@$('input').val('')
				@_updateTitle()
			@
		edit:=>
			@$el.addClass('editing')
			@$el.html(@_editTemplate(@model.toJSON()))
			@$('input').focus()
			@options.eventBus.trigger('item:editing', @model)
			
		render:=>
			$(@el).html(@_template(@model.toJSON()))
			@
							
	class ItemCollectionView extends BaseView
		tagName:'ul'
		className:'item-list'
		multitouch:true
		distanceY:0
		lastTouches:null
		events:
			'touchstart'	:'_touchstart'
			'touchend'		:'_touchend'
			'touchmove'		:'_touchmove'
			# 'mousedown'		:'_touchstart'
			# 'mouseup'		:'_touchend'
			# 'mousemove'		:'_touchmove'
		initialize:=>
			@options.eventBus.on('item:editing',@_itemEditing)
			@options.eventBus.on('item:edited',@_itemEdited)
		_itemEditing:=>
			@$el.addClass('editing')
			
		_itemEdited:=>
			@$el.removeClass('editing')
			
		_touchstart:(e)=>
			# eLog(@$el.height())
			if e.touches.length > 1
				@multitouch = true
				@distanceY = Math.abs(e.touches[0].clientY - e.touches[1].clientY)
				
		_touchend:(e)=>
			try
				lastTouches = @lastTouches
				if lastTouches.length <2 then return
				else if Math.abs(lastTouches[0].clientY - lastTouches[1].clientY) < @distanceY
					#do someting animation here by add a fadeout class
						setTimeout((=>@options.eventBus.trigger('returnHome')),300)
			catch error
				alert(error)
				console.log(error)
			
		_touchmove:(e)=>
			@lastTouches = e.touches
			
		_addOne:(item)=>
			view = new ItemView(@_wrap({model:item}))
			@$el.append(view.render().el)
			
		renderByListId:(listId)=>
			@$el.html('')			
			@model.queryByListId(listId).forEach(@_addOne)
			@
			
		render:=>
			@$el.html('')
			@model.forEach(@_addOne)
			@
		
		
	class EventBus extends Backbone.Model
		initialize:->
			@on('openList',@_printMessage('openList'))
			@on('returnHome',@_printMessage('returnHome'))
			@on('list:editing',@_printMessage('list:editing'))
			@on('list:edited',@_printMessage('list:edited'))
			
		_printMessage:(msg)->
			return -> console.log 'eventbus:'+ msg		
	
	class AppModel extends Backbone.Model
		initialize:->
			@listCollection = new ListCollection([{id:0,title:'Beijing',count:10},{id:1,title:'Shanghai',count:100},{id:2,title:'Zeatle',count:1000}])
			@itemCollection = new ItemCollection([{title:'fox1'},{title:'superwolf',listId:1},{title:'Bluewing'}])
			
	class AppView extends BaseView
		el:$('#app')
		initialize:->
			@listCollectionView = new ListCollectionView(@_wrap({model:@model.listCollection}))
			@itemCollectionView = new ItemCollectionView(@_wrap({model:@model.itemCollection}))
			
			@options.eventBus.on('openList',@renderByListId)
			@options.eventBus.on('returnHome',@renderListCollection)
		
		renderByListId:(listId)=>
			@listCollectionView.$el.addClass('bounceOutUp animated')
			setTimeout(()=>
				@listCollectionView.$el.removeClass('bounceOutUp animated')
				@$el.html('')
				@$el.append(@itemCollectionView.renderByListId(listId).el)
				@itemCollectionView.$el.addClass('fadeInDown animated')
				Backbone.history.navigate('/list/'+listId,{trigger:false, replace:false})
			,500)
			

		renderListCollection:=>
			@$el.html('')			
			@$el.append(@listCollectionView.render().el)
			Backbone.history.navigate('',{trigger:false, replace:false})
		render:=>
			@renderListCollection()
		
	class App extends Backbone.Router
		constructor:->
			super()
			console.log 'router construction'
			@appModel = new AppModel()
			@appView = new AppView({model:@appModel,appModel:@appModel,eventBus:new EventBus()})

		routes:
			"list/:id":"list"
			"":"lists"
			
		lists:()->
			@appView.render()
			
		list:(id)->
			@appView.renderByListId(parseInt(id))
		start:->
			Backbone.history.start()
	
  	exports = App