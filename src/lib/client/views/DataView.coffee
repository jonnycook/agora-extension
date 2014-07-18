define -> d: ['View', 'util', 'icons'], c: -> 
	class DataView extends View
		type: 'Data'
		constructor: ->
			super
			@el = @viewEl '<div class="v-data">
				<div class="cont">
				<ul class="data">
					<li />
				</ul>
				<div class="addWrapper"><input type="text" class="add" placeholder="Paste URL to add content"></div>
				</div>
			</div>'

			util.trapScrolling @el.find('.data')

			opened = false
			addDataView = null
			@el.find('.add').keyup (e) =>
				if e.keyCode == 13
					if opened
						addDataView.submit()
						@event 'addData'
				else
					if @el.find('.add').val() != ''
						if !opened
							opened = true
							@event 'beginAddData'
							addDataView = @createView 'AddData', 
								type:'connected'
								url:@el.find('.add').val()
								args:@args
							addDataView.onSubmit = => @el.find('.add').val ''
							@popout = util.createPopout @el.find('.addWrapper'), el:addDataView.el, side:'left', anchor:'middle', distance:17, onClose: => delete @popout; opened = false
							addDataView.close = @popout.close
					else if opened
						@event 'cancelAddData'
						@popout.close()

		onData: (@data) ->
			dataIface = @listInterface @el, '.data li', (el, data, pos, onRemove) =>
				view = @view()
				onRemove -> view.destruct()

				el.addClass data.type.get()
				switch data.type.get()
					when 'plainText'
						el.html "
							<span class='text' />
							<a href='#' target='_blank' class='url'>Page</a>
							<span class='date' />
						"
						view.valueInterface(el.find('.text')).setDataSource data.text
						view.valueInterface(el.find('.url')).setDataSource data.url, (value, el) -> el.attr 'href', value
					when 'video'
						el.html '
							<a href="#" class="title" />
							<span class="videoWrapper" />
						'
						view.valueInterface(el.find('.title')).setDataSource data.title
						updateForUrl = ->
							matches = /https?:\/\/www\.youtube\.com\/watch\?.*?v=(.*?)(&|$)/.exec data.url.get()
							if matches
								el.find('.videoWrapper').html "<iframe class='videoPlayer' width='314' height='177' src='//www.youtube.com/embed/#{matches[1]}' frameborder='0' allowfullscreen></iframe>"
							el.find('.title').attr 'href', data.url.get()
						updateForUrl()
						data.url.observe updateForUrl
					when 'image'
						el.html '
							<a href="#" class="title" target="_blank" />
							<a class="image" target="_blank" />
							<span class="date" />
						'
						updateForUrl = ->
							el.find('.image').css backgroundImage:"url('#{data.url.get()}')"
							el.find('.image').attr 'href', data.url.get()
						data.url.observe updateForUrl
						updateForUrl()

						view.valueInterface(el.find('.title')).setDataSource data.title
						view.valueInterface(el.find('.title'), 'href').setDataSource data.url
					when 'url'
						el.html '
							<a class="title" target="_blank" />
							<span class="date" />
						'
						view.valueInterface(el.find('.title')).setDataSource data.title
						view.valueInterface(el.find('.title'), 'href').setDataSource data.url

				el.append("<a href='#' class='delete' />").find('.delete').click =>
					@event 'delete'
					@callBackgroundMethod 'delete', data.id
					false
				util.tooltip el.find('.delete'), 'delete', position:'below'
				el

			if data.length()
				@el.removeClass 'empty'
			else
				@el.addClass 'empty'


			updateSize = =>
				if dataIface.length()
					@el.removeClass 'empty'
				else
					@el.addClass 'empty'
				@popout.updatePos() if @popout
				lastEl = @el.find('.data li:last')
				height = 30
				if lastEl.length
					height += lastEl.offset().top - @el.find('.data').offset().top + lastEl.outerHeight() + 10
				@el.find('.cont').css height:height
				@sizeChanged?()

			dataIface.setDataSource data
			dataIface.onLengthChanged = updateSize

			setTimeout updateSize, 0

		shown: ->
			@event 'open'
			_tutorial 'AddData', @el.find('.add')