define -> -> 
	class WebAppView extends View
		type: 'WebApp'
		onData: (data) ->
			$('<div id="agoraCont" class="-agora" />').appendTo document.body

			resizeTimerId = null
			resize = =>
				clearTimeout resizeTimerId
				resizeTimerId = setTimeout (=>
					width = $(window).width()
					$('#agoraCont').width width
					$('#agoraCont').triggerHandler 'resize'
				), 10
				true

			$(window).resize resize
			resize()
			if data.accessDenied
				$('#agoraCont').addClass 'accessDenied'
			else if data.decisionId
				compareView = new CompareView @contentScript, $('#agoraCont'), $(document.body), true
				compareView.el.appendTo '#agoraCont'
				compareView.represent public:true, decision:id:data.decisionId