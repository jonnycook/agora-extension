// Generated by CoffeeScript 1.7.1
require(['Agora', '../webapp/WebappBackground'], function(Agora, WebappBackground) {
  window.webappBackground = new WebappBackground('tutorial');
  return window.agora = new Agora(webappBackground, {
    localTest: true,
    autoUpdate: true,
    onLoaded: function(agora) {
      var siteInjector;
      siteInjector = function() {};
      return agora.getContentScript('http://tutorial.agora', function(script) {
        return eval(script);
      });
    },
    initDb: function(agora) {
      return agora.db.setData({
        products: {
          1: {
            "siteName": "Amazon",
            "productSid": "B00EIRFYS4",
            "image": "http://ecx.images-amazon.com/images/I/51a868WEvjL._SY300_.jpg",
            "title": "Hannspree Hanns.G Hl273hpb 27-Inch Widescreen Led Monitor Full Hd 1080p W/Hdmi & Speakers",
            "reviews": {
              "reviews": [
                {
                  "rating": 5,
                  "url": "http://www.amazon.com/review/R6UYECP7WW5JT/ref=cm_cr_dp_title?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc",
                  "title": "Hannspree Hanns.G Hl273hpb 27-Inch Widescreen Led Monitor Full Hd 1080p..",
                  "time": "February 5, 2014",
                  "review": "this was the second one I ordered, now i have 2 monitors for my desktop. Its great when i am doing research for my family tree and when i am looking at patterns for quilts.",
                  "author": {
                    "url": "http://www.amazon.com/gp/pdp/profile/A1Q97J4ZY3N5SQ/ref=cm_cr_dp_pdp",
                    "name": "nora"
                  },
                  "helpfulCount": "1",
                  "helpfulTotal": "1",
                  "amazonVerifiedPurchase": true,
                  "comments": {
                    "url": "http://www.amazon.com/review/R6UYECP7WW5JT/ref=cm_cr_dp_cmt?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc#wasThisHelpful",
                    "count": "0"
                  }
                }, {
                  "rating": 5,
                  "url": "http://www.amazon.com/review/RYYMKI6EOJT6/ref=cm_cr_dp_title?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc",
                  "title": "Good Monitor",
                  "time": "February 1, 2014",
                  "review": "I bought two of these for my home office. They were easy to attach to my current monitor stands on the desk. I have had no problems with them at all. I have used Hanns monitors before and all of them have worked well.",
                  "author": {
                    "url": "http://www.amazon.com/gp/pdp/profile/AWJJLJNGZXGAR/ref=cm_cr_dp_pdp",
                    "name": "AU69"
                  },
                  "amazonVerifiedPurchase": true,
                  "comments": {
                    "url": "http://www.amazon.com/review/RYYMKI6EOJT6/ref=cm_cr_dp_cmt?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc#wasThisHelpful",
                    "count": "0"
                  }
                }, {
                  "rating": 4,
                  "url": "http://www.amazon.com/review/R22UW9RRFAJTGH/ref=cm_cr_dp_title?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc",
                  "title": "Picture quality is good, sound is awful",
                  "time": "February 1, 2014",
                  "review": "Very happy with the picture quality but the sound is terrible.  The speaker openings are in the back of the monitor making the sound very muted and tin can like.",
                  "author": {
                    "url": "http://www.amazon.com/gp/pdp/profile/A2CNIM0Q8XPFL3/ref=cm_cr_dp_pdp",
                    "name": "dave"
                  },
                  "amazonVerifiedPurchase": true,
                  "comments": {
                    "url": "http://www.amazon.com/review/R22UW9RRFAJTGH/ref=cm_cr_dp_cmt?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc#wasThisHelpful",
                    "count": "0"
                  }
                }, {
                  "rating": 5,
                  "url": "http://www.amazon.com/review/RZPO7OQ6JQRPC/ref=cm_cr_dp_title?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc",
                  "title": "wife has 2",
                  "time": "January 30, 2014",
                  "review": "my wife does hobbies/crafts and just wanted an evil lair of huge monitors--great quality and they really fill up her desk",
                  "author": {
                    "url": "http://www.amazon.com/gp/pdp/profile/A2TTAOPA03TO26/ref=cm_cr_dp_pdp",
                    "name": "DKtucson"
                  },
                  "amazonVerifiedPurchase": true,
                  "comments": {
                    "url": "http://www.amazon.com/review/RZPO7OQ6JQRPC/ref=cm_cr_dp_cmt?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc#wasThisHelpful",
                    "count": "0"
                  }
                }, {
                  "rating": 5,
                  "url": "http://www.amazon.com/review/RQBQ1PNTMMU16/ref=cm_cr_dp_title?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc",
                  "title": "Remember this brand! It is awsome!",
                  "time": "January 29, 2014",
                  "review": "Even though not a famous brand I like this product and it has a very high quality with amazingly cheap price.",
                  "author": {
                    "url": "http://www.amazon.com/gp/pdp/profile/A3EEFV6O568AJ9/ref=cm_cr_dp_pdp",
                    "name": "MPRobert Karapetian"
                  },
                  "amazonVerifiedPurchase": true,
                  "comments": {
                    "url": "http://www.amazon.com/review/RQBQ1PNTMMU16/ref=cm_cr_dp_cmt?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc#wasThisHelpful",
                    "count": "0"
                  }
                }, {
                  "rating": 4,
                  "url": "http://www.amazon.com/review/RO92MZ0N5NRNJ/ref=cm_cr_dp_title?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc",
                  "title": "beautiful display, wobbly stand",
                  "time": "January 22, 2014",
                  "review": "The monitor gives a beautiful display. The stand could have been designed differently. The monitor shakes with any minor bump to the surface it sits on.",
                  "author": {
                    "url": "http://www.amazon.com/gp/pdp/profile/A3A596GYMPLSZ8/ref=cm_cr_dp_pdp",
                    "name": "Paul"
                  },
                  "amazonVerifiedPurchase": true,
                  "comments": {
                    "url": "http://www.amazon.com/review/RO92MZ0N5NRNJ/ref=cm_cr_dp_cmt?ie=UTF8&ASIN=B00EIRFYS4&channel=detail-glance&nodeID=541966&store=pc#wasThisHelpful",
                    "count": "0"
                  }
                }
              ],
              "url": "http://www.amazon.comhttp://www.amazon.com/Hannspree-Hanns-G-Hl273hpb-Wides…_dp_see_all_btm?ie=UTF8&showViewpoints=1&sortBy=bySubmissionDateDescending",
              "count": "11"
            },
            "sem3_id": null,
            "coupons": null,
            "inShoppingBar": false,
            "more": {
              "images": {},
              "currentStyle": "initial",
              "features": ["HannsG HL273HPB 27\" Class 1920x1080 LED Monitor"]
            },
            "offers": {
              "new": [
                {
                  "phase": 1,
                  "query": {
                    "sku": "B00EIRFYS4",
                    "site": "Amazon"
                  },
                  "title": "Hannspree Hanns.G Hl273hpb 27-Inch Widescreen Led Monitor Full Hd 1080p W/Hdmi & Speakers",
                  "api": "amazon",
                  "lastUpdated": "2014-03-01 03:04:29",
                  "images": ["http://ecx.images-amazon.com/images/I/51f2ehLhbwL._SL75_.jpg", "http://ecx.images-amazon.com/images/I/41naRi4FSjL._SL75_.jpg"],
                  "upc": "887239005880",
                  "ean": "0887239005880",
                  "brand": "Hannspree",
                  "site": "Amazon Marketplace",
                  "price": 199.99,
                  "condition": "new",
                  "url": "http://www.amazon.com/gp/offer-listing/B00EIRFYS4%3FSubscriptionId%3DAKIAJB…nkCode%3Dsp1%26camp%3D2025%26creative%3D386001%26creativeASIN%3DB00EIRFYS4"
                }, {
                  "phase": 1,
                  "query": {
                    "sku": "B00EIRFYS4",
                    "site": "Amazon"
                  },
                  "title": "Hannspree Hanns.G Hl273hpb 27-Inch Widescreen Led Monitor Full Hd 1080p W/Hdmi & Speakers",
                  "api": "amazon",
                  "lastUpdated": "2014-03-01 03:04:29",
                  "images": ["http://ecx.images-amazon.com/images/I/51f2ehLhbwL._SL75_.jpg", "http://ecx.images-amazon.com/images/I/41naRi4FSjL._SL75_.jpg"],
                  "upc": "887239005880",
                  "ean": "0887239005880",
                  "brand": "Hannspree",
                  "site": "Amazon",
                  "price": 279.99,
                  "condition": "new",
                  "url": "http://www.amazon.com/Hannspree-Hanns-G-Hl273hpb-Widescreen-Speakers/dp/B00…nkCode%3Dsp1%26camp%3D2025%26creative%3D165953%26creativeASIN%3DB00EIRFYS4"
                }
              ]
            },
            "offer": null
          }
        }
      });
    }
  });
});

//# sourceMappingURL=init.map
