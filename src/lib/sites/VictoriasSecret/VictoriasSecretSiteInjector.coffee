define -> d: ['DataDrivenSiteInjector'], c: ->
  class VictoriasSecretSiteInjector extends DataDrivenSiteInjector
    productListing:
      imgSelector: 'a span img[src^="//dm.victoriassecret.com/product/"]'
      overlayPosition: 'topLeft'
      productSid: (href, a, img) -> 
        # id = a.parents('.item:first').get(0).className.match(/item-(\d*)/)[1]
        name = href.match(/ProductID=([^&]+)/)?[1]
        # "#{id}:#{name}"
        sid = name
        if !sid
          href = unescape href
          match = /(https:\/\/www\.victoriassecret.com\/.*?)(?:&|$)/.exec(href)?[1]
          if match
            sid = match
        sid


    productPage:
      test: -> $('meta[content^="https://dm.victoriassecret.com/product/"]')
      productSid: -> document.location.href.match(/ProductID=([^&]+)/)[1]
      imgEl: '#mainView'
      waitFor: '#mainView'
      overlayEl: '#zoom-lens .lens-container .lens-border span'
      overlayPosition: 'topLeft'


      # initPage: ->
      # initProduct: ->