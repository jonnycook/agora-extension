define -> d: ['SiteInjector', 'views/ShoppingBarView', 'views/compare/CompareView'], c: ->
	class TutorialSiteInjector extends SiteInjector
		siteName: 'Tutorial'

		run: ->
			@initPage =>
				shoppingBarView = new ShoppingBarView @contentScript, context:'tutorial'
				shoppingBarView.el.appendTo document.body
				shoppingBarView.represent()

				window.suppressPopups = true
				window.tutorialInProgress = true

				done = false
				$(window).bind 'beforeunload', ->
					if !done
						'You haven\'t finished the tour yet.'

				tutorialStepsText =
					intro:
						text: "<p>Welcome to Agora, a tool to improve your online shopping. Let's run through a brief tour of our main features.</p> <p><a href=\"#\" class=\"button begin\">Okay, let's begin.</a></p>"
						audio: "http://files.agora.sh/tutorialaudio/01_01.mp3"

					productHover:
						text: "First, move your mouse over this product image."
						audio: "http://files.agora.sh/tutorialaudio/02_01.mp3"

					enterPortal:
						text: "Next, click the <b>Inspect button</b> that appears when you hover. It looks like an eye, and it will appear on the product images on all our supported sites."
						audio: "http://files.agora.sh/tutorialaudio/03_01.mp3"

					closePortal:
						text: "<h2>Product Portal</h2> <p>Welcome to the <b>Product Portal</b>. You can access it from from any product on our growing list of supported sites by clicking the inspect button on product images.</p> <p>Take a look around at the features it provides and when you're done, close the portal by pressing the ESC key or clicking the close button at the top right.</p>"
						audio: "http://files.agora.sh/tutorialaudio/04_01.mp3"

					dragProduct:
						text: "Okay, let’s learn how to collect products that you may want to consider purchasing. Start by dragging this image..."
						audio: "http://files.agora.sh/tutorialaudio/05_01.mp3"

					dropProduct:
						text: "...and drop it down here on the <b>Belt</b>."
						audio: "http://files.agora.sh/tutorialaudio/06_01.mp3"

					addFeeling:
						text: "<!--<h2>Thoughts and Feelings</h2>--> <p>You can record the feelings and thoughts you have about the products you are shopping for.</p> <p>Type a thought or feeling and <b>press enter</b>, or just <b>press ESC</b> to close this dialog and continue on to the next step.</p>"
						audio: "http://files.agora.sh/tutorialaudio/07_01.mp3"

					# explainDecision: "<h2>Decision</h2> <p>You are now viewing a Decision. Decisions are used to store all the products you are considering for one particular purchase, and represents a single \"buying decision.\"</p> <p><a href=\"#\" class=\"button next\">Okay, got it.</a></p>"
					# visitProduct: "<b>Click the product</b> to visit its retail page."

				for el in $('#products .product[data-product]')
					[__, siteName, productSid] = /([^\/]*)\/(.*)/.exec($(el).attr('data-product'))
					@initProductEl $(el).find('.picture img'), {siteName:siteName, productSid:productSid},
						initOverlay: (overlay) ->
							overlay.autoFixPosition()
							overlay.showPreview = false

				callWhen = (el, cb) ->
					timerId = setInterval (->
						if $(el).length
							cb()
							clearInterval timerId
					), 50



				tutorialSteps = [
					# intro: ->
					(next) ->
						tutorial.showCenter 400, tutorialStepsText.intro
						tutorial.frameEl.find('.begin').click =>
							next()
							++ tutorialStep
							false

					# productHover: ->
					(next) ->
						tutorial.show $('#product1'), 'left', tutorialStepsText.productHover
						$('#product1').mouseover =>
							if tutorialStep == 1
								next()
								++ tutorialStep

					# enterPortal: ->
					(next) ->
						tutorial.show $('#product1 img').data('agora').overlayView.el, 'below', tutorialStepsText.enterPortal
						$('#product1 img').data('agora').overlayView.el.click =>
							if tutorialStep == 2
								setTimeout (=>
									next()
								), 500

					# closePortal: ->
					(next) ->
						tutorial.show {left:$(window).width()/2 - 300, top:$(window).height()/2 - 100, pointer:false}, 'below', tutorialStepsText.closePortal
						timerId = setInterval (=>
							if !$('.v-productPreview2').length
								clearInterval timerId
								setTimeout (=>
									next()
								), 200
						), 100

					# dragProduct1: ->
					(next) ->
						tutorial.show $('#product1 img'), 'right', tutorialStepsText.dragProduct
						$('#product1 img').mousedown =>
							if tutorialStep == 2
								next()

					# dropProduct1: ->
					(next) ->
						tutorial.show $('.v-shoppingBar'), 'above', tutorialStepsText.dropProduct
						++ tutorialStep

						timerId = setInterval (=>
							if $('.v-addFeeling').length
								clearInterval timerId
								next()
						), 100


					# addFeeling: ->
					(next) ->
						tutorial.show $('.v-addFeeling'), 'above', tutorialStepsText.addFeeling

						timerId = setInterval (=>
							if !$('.v-addFeeling').length
								window.suppressAddFeeling = true
								clearInterval timerId
								next()
						), 100

					# dragProduct2: ->
					(next) ->
						tutorial.show $('#product2 img'), 'below', {text:'Now start dragging this product image, but this time don\'t drop it directly onto the Belt.', audio:'http://files.agora.sh/tutorialaudio/08_01.mp3'}
						$('#product2 img').one 'mousedown', =>
							next()

					# dropProduct2: ->
					(next) ->
						tutorial.show $('.v-shoppingBar .product'), 'above', {text:'Instead, drop it down onto this product.', audio:'http://files.agora.sh/tutorialaudio/09_01.mp3'}

						timerId = setInterval (=>
							if $('.v-shoppingBar .decision').length
								clearInterval timerId
								next()
						), 100

					# enterDecision: ->
					(next) ->
						tutorial.show $('.v-shoppingBar .decision'), 'above', {text:'<p>You\'ve created a <b>Decision</b>. Decisions are used to store all the products you are considering for one particular purchase, and represents a single "buying decision."</p> <p>Now click the Decision to view the products you added to it.</b>', audio:'http://files.agora.sh/tutorialaudio/10_01.mp3'}
						timerId = setInterval (=>
							if $('.v-shoppingBar.Decision').length
								clearInterval timerId
								next()
						), 100

					# visitProduct: ->
					(next) ->
						callWhen '.v-shoppingBar .product:last', ->
							tutorial.show $('.v-shoppingBar .product:last'), 'above', {text:'<p>You can think of the products on your Belt as special browser bookmarks just for shopping. All the products you add to it will be available to you any time you visit one of our supported sites. You\'ll also be able to add new products by dropping any product image you see on a supported site onto the Belt.</p> <p>Next, click this product to visit its retail page.</p>', audio:'http://files.agora.sh/tutorialaudio/11_01.mp3'}
							done = true
							next()

							if chrome.extension
								chrome.runtime.sendMessage 'continueTutorial'
							else
								chrome.runtime.sendMessage 'jhlelmocecgfffgmpbkjjgkdjlpbjain', 'continueTutorial'
								chrome.runtime.sendMessage 'ejlcjafiokgjbepfhclmlmlkkjnjadej', 'continueTutorial'
								chrome.runtime.sendMessage 'eikmdfdlppngdbmdllhkmkchnkiiecea', 'continueTutorial'
				]
	
				tutorialStep = 0

				tutorial = new TutorialDialog 20, 1

				stepStartTime = null
				doTutorial = (i) ->
					if i > 0
						console.debug 'time', i, new Date().getTime() - stepStartTime
						tracking.time 'Tutorial', "Step#{i}", new Date().getTime() - stepStartTime

					if tutorialSteps[i]
						@contentScript.triggerBackgroundEvent 'tutorialStep', i + 1
						console.debug i + 1
						stepStartTime = new Date().getTime()
						tutorialSteps[i] -> doTutorial i + 1

				startTutorial = ->
					chrome.runtime.sendMessage 'startTutorial'
					doTutorial 0

				$ startTutorial
