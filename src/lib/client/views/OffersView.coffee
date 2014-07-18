define -> d: ['View', 'Frame'], c: ->
	class OffersView extends View
		type: 'Offers'
		constructor: (@contentScript) ->
			super @contentScript
			@el = $ '
				<div class="-agora v-offers images">
					<div class="cont">
						Loading offers...
					</div>
				</div>'
				
			@el.find('.n-remove').click =>
				@callBackgroundMethod 'remove'

			util.trapScrolling @el.find('.cont')
			
		onData: (data) ->
			updateOffers = =>
				contEl = @el.find('.cont')
				if data.offers.get()
					contEl.html ''
					offers = data.offers.get()
					if offers.length
						for offerSection in offers
							sectionEl = $('<div class="section" />')
							sectionEl.append("<h2>#{offerSection.heading}</h2>")

							offersEl = $('<ul class="offers" />')
							for offer in offerSection.offers
								do (offer) =>
									offerEl = $("
										<li class='offer' data-api='#{offer.api}' offerid='#{offer.id}'>
												<a href='#{offer.url}' target='_blank' class='photo' style='background-image:url('#{offer.image}')'></a>
												<a href='#{offer.url}' target='_blank' class='title'>#{offer.title}</a>
												<span class='site'>#{offer.site}</span>
												<span class='price'>#{offer.price}</span>
										</li>")

									offerEl.find('.price').click =>
										@event 'setOffer'
										@callBackgroundMethod 'setOffer', offer.data
										false

									offersEl.append offerEl

							sectionEl.append offersEl

							contEl.append sectionEl
					else
						contEl.html 'No offers'
				@sizeChanged?()

				updateSelectedOffer()


			updateSelectedOffer = =>
				@el.find('.offer.selected').removeClass 'selected'
				@el.find("[offerid='#{data.selectedOffer.get()}'").addClass 'selected'

			data.offers.observe updateOffers
			updateOffers()

			data.selectedOffer.observe updateSelectedOffer

		shown: ->
			@event 'open'