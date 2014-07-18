###
http://www.amazon.com/dp/product-description/B003D7KV0Q/ref=dp_proddesc_0?ie=UTF8&n=672123011&s=shoes



rating
	*
		pages

more.description
	*
		pages
			http://www.amazon.com/gp/product/B00E8PAAUS/
			http://www.amazon.com/gp/product/B00IO9PBPS/
			http://www.amazon.com/gp/product/B004OBY8IG/
			http://www.amazon.com/Stanley-90-947-6-Inch-MaxSteel-Adjustable/dp/B000NIK9S2/
			http://www.amazon.com/Handy-Living-Full-Wood-Frame/dp/B002KQ5KQ6

		thumbprint
			<div class="bucket" id="productDescription">

	*
		pages

		thumbprint
			<div id="productDescription" class="a-section a-spacing-small">

	*
		pages
			http://www.amazon.com/gp/product/1561457752
		thumbprint
			<div id="bookDescription_feature_div" class="feature" data-feature-name="bookDescription">

###


define ['scraping/resourceScrapers/PatternResourceScraper', 'scraping/resourceScrapers/DeclarativeResourceScraper'], (PatternResourceScraper, DeclarativeResourceScraper) ->
	more: (switches, more) ->

		# http://www.amazon.com/gp/customer-reviews/aj/fit-recommendations/get-fit-recommendations/ref=cm_cr_fit_ppd_aui_expT4?asin=B00631VEN2&dataset=2&pipelineTreatment=expT4&isClick=1
		# $fitsAsExpected = /(.*?) of customers say this fits as expected\./.exec(subject)[1].trim()

		# sizeMatches = matchAll /<span class="a-letter-space"><\/span><span class="a-letter-space"><\/span>\s*(.*?)\s*<span class="a-letter-space"><\/span>/

		# peopleMatches = matchAll /<span>\s*([\d,]*)\s*<\/span>/

		# $sizes = {}
		# for sizeMatch,i in sizeMatches
		# 	$sizes[sizeMatch[1]] = peopleMatches[i][1]

		more.reviews = @declarativeScraper 'scraper', 'reviews'


		more.sizes = @resource.matchAll /<option value="[^"]*" class="dropdownAvailable" data-a-css-class="dropdownAvailable" id="native_size_name_\d+" data-a-id="size_name_\d+" data-a-html-content="([^"]*)">/, 1
		more.howItFits = @resource.match(/<span class="a-size-small">How it fits:<span class="a-text-bold"> ([^<]*)/)?[1]


		if switches.description && !more.description
			# <div class="bucket" id="productDescription">\s*<h2>Product Description<\/h2>\s*<div class="content">\s*<h3 class="productDescriptionSource"><\/h3>\s*
			matches = @resource.match /<div class="productDescriptionWrapper">\s*([\S\s]*?)<div class="emptyClear">/
			if matches
				more.description = matches[1].trim()




