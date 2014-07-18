require([
'views/AddArgumentView',
'views/AddDataView',
'views/AddDescriptorView',
'views/AddFeelingView',
'views/AddItemView',
'views/BuyView',
'views/ChatView',
'views/CollaborateView',
'views/compare/BundleTileItem',
'views/compare/CompareView',
'views/compare/DecisionTileItem',
'views/compare/ListTileItem',
'views/compare/ProductTileItem',
'views/compare/TileItem',
'views/compare/TileItemView',
'views/compare/UnauthorizedTileItem',
'views/CompetitiveProcessView',
'views/ContactView',
'views/CouponsView',
'views/DataView',
'views/DecisionPreviewView',
'views/EditDescriptorView',
'views/items/DecisionItem',
'views/items/Item',
'views/ItemView',
'views/OffersView',
'views/ProductAddedView',
'views/ProductClipView',
'views/ProductMenuView',
'views/ProductOverlayView',
'views/ProductPopupView',
'views/ProductPreviewView',
'views/ProductPriceView',
'views/ReviewsView',
'views/SettingsView',
'views/SharedWithYouView',
'views/ShareView',
'views/ShoppingBarView/BarItem',
'views/ShoppingBarView/BarItemView',
'views/ShoppingBarView/BarItemView1',
'views/ShoppingBarView/BeltBarItem',
'views/ShoppingBarView/BundleBarItem',
'views/ShoppingBarView/CompositeBarItem',
'views/ShoppingBarView/CompositeSlotBarItem',
'views/ShoppingBarView/DecisionBarItem',
'views/ShoppingBarView/ListBarItem',
'views/ShoppingBarView/ProductBarItem',
'views/ShoppingBarView/SessionBarItem',
'views/ShoppingBarView/SharedBeltBarItem',
'views/ShoppingBarView/UnauthorizedBarItem',
'views/ShoppingBarView',
'views/SocialShareView',
'views/WebAppView',
'sites/Amazon/AmazonProduct',
'sites/Amazon/AmazonProductScraper',
'sites/Amazon/AmazonSite',
'sites/Amazon/AmazonSiteInjector',
'sites/Amazon/config',
'sites/AmericanApparel/AmericanApparelProduct',
'sites/AmericanApparel/AmericanApparelProductScraper',
'sites/AmericanApparel/AmericanApparelSiteInjector',
'sites/AmericanApparel/config',
'sites/Asos/AsosProduct',
'sites/Asos/AsosProductScraper',
'sites/Asos/AsosSiteInjector',
'sites/Asos/config',
'sites/BarnesAndNoble/BarnesAndNobleProduct',
'sites/BarnesAndNoble/BarnesAndNobleProductScraper',
'sites/BarnesAndNoble/BarnesAndNobleSiteInjector',
'sites/BarnesAndNoble/config',
'sites/BestBuy/BestBuyProduct',
'sites/BestBuy/BestBuyProductScraper',
'sites/BestBuy/BestBuySiteInjector',
'sites/BestBuy/config',
'sites/Bloomingdales/BloomingdalesProduct',
'sites/Bloomingdales/BloomingdalesProductScraper',
'sites/Bloomingdales/BloomingdalesSiteInjector',
'sites/Bloomingdales/config',
'sites/ColdwaterCreek/ColdwaterCreekProduct',
'sites/ColdwaterCreek/ColdwaterCreekProductScraper',
'sites/ColdwaterCreek/ColdwaterCreekSiteInjector',
'sites/ColdwaterCreek/config',
'sites/Costco/config',
'sites/Costco/CostcoProduct',
'sites/Costco/CostcoProductScraper',
'sites/Costco/CostcoSiteInjector',
'sites/CVS/CVSProductScraper',
'sites/CVS/CVSSiteInjector',
'sites/Dev/config',
'sites/Dev/DevProduct',
'sites/Dev/DevProductScraper',
'sites/Dev/DevSiteInjector',
'sites/Diapers/config',
'sites/Diapers/DiapersProduct',
'sites/Diapers/DiapersProductScraper',
'sites/Diapers/DiapersSiteInjector',
'sites/Ebay/config',
'sites/Ebay/EbayProductScraper',
'sites/Ebay/EbaySiteInjector',
'sites/Etsy/config',
'sites/Etsy/EtsyProduct',
'sites/Etsy/EtsyProductScraper',
'sites/Etsy/EtsySiteInjector',
'sites/Express/config',
'sites/Express/ExpressProduct',
'sites/Express/ExpressProductScraper',
'sites/Express/ExpressSiteInjector',
'sites/Fab/config',
'sites/Fab/FabProduct',
'sites/Fab/FabProductScraper',
'sites/Fab/FabSiteInjector',
'sites/Fancy/config',
'sites/Fancy/FancyProduct',
'sites/Fancy/FancyProductScraper',
'sites/Fancy/FancySiteInjector',
'sites/FashionBug/config',
'sites/FashionBug/FashionBugProduct',
'sites/FashionBug/FashionBugSiteInjector',
'sites/Forever21/config',
'sites/Forever21/Forever21ProductScraper',
'sites/Forever21/Forever21SiteInjector',
'sites/FreePeople/config',
'sites/FreePeople/FreePeopleProduct',
'sites/FreePeople/FreePeopleProductScraper',
'sites/FreePeople/FreePeopleSiteInjector',
'sites/Gap/config',
'sites/Gap/GapProductScraper',
'sites/Gap/GapSiteInjector',
'sites/General/config',
'sites/General/GeneralProductScraper',
'sites/General/GeneralSiteInjector',
'sites/HM/config',
'sites/HM/HMProduct',
'sites/HM/HMProductScraper',
'sites/HM/HMSiteInjector',
'sites/HomeDepot/config',
'sites/HomeDepot/HomeDepotProduct',
'sites/HomeDepot/HomeDepotProductScraper',
'sites/HomeDepot/HomeDepotSiteInjector',
'sites/JCPenney/config',
'sites/JCPenney/JCPenneyProduct',
'sites/JCPenney/JCPenneyProductScraper',
'sites/JCPenney/JCPenneySiteInjector',
'sites/JCrew/config',
'sites/JCrew/JCrewProduct',
'sites/JCrew/JCrewProductScraper',
'sites/JCrew/JCrewSiteInjector',
'sites/KateSpade/config',
'sites/KateSpade/KateSpadeProduct',
'sites/KateSpade/KateSpadeProductScraper',
'sites/KateSpade/KateSpadeSiteInjector',
'sites/Kmart/config',
'sites/Kmart/KmartProduct',
'sites/Kmart/KmartProductScraper',
'sites/Kmart/KmartSiteInjector',
'sites/Kohls/config',
'sites/Kohls/KohlsProductScraper',
'sites/Kohls/KohlsSiteInjector',
'sites/LandsEnd/config',
'sites/LandsEnd/LandsEndProduct',
'sites/LandsEnd/LandsEndProductScraper',
'sites/LandsEnd/LandsEndSiteInjector',
'sites/LLBean/config',
'sites/LLBean/LLBeanProduct',
'sites/LLBean/LLBeanProductScraper',
'sites/LLBean/LLBeanSiteInjector',
'sites/Lowes/LowesProductScraper',
'sites/Lowes/LowesSiteInjector',
'sites/LuLus/config',
'sites/LuLus/LuLusProduct',
'sites/LuLus/LulusProductScraper',
'sites/LuLus/LulusSiteInjector',
'sites/Macys/config',
'sites/Macys/MacysProductScraper',
'sites/Macys/MacysSiteInjector',
'sites/MakeMeChic/config',
'sites/MakeMeChic/MakeMeChicProduct',
'sites/MakeMeChic/MakeMeChicProductScraper',
'sites/MakeMeChic/MakeMeChicSiteInjector',
'sites/ModCloth/config',
'sites/ModCloth/ModClothProduct',
'sites/ModCloth/ModClothProductScraper',
'sites/ModCloth/ModClothSiteInjector',
'sites/NastyGal/config',
'sites/NastyGal/NastyGalProduct',
'sites/NastyGal/NastyGalProductScraper',
'sites/NastyGal/NastyGalSiteInjector',
'sites/Newegg/config',
'sites/Newegg/NeweggProductScraper',
'sites/Newegg/NeweggSiteInjector',
'sites/Nordstrom/config',
'sites/Nordstrom/NordstromProduct',
'sites/Nordstrom/NordstromProductScraper',
'sites/Nordstrom/NordstromSiteInjector',
'sites/Overstock/config',
'sites/Overstock/OverstockProductScraper',
'sites/Overstock/OverstockSiteInjector',
'sites/QVC/config',
'sites/QVC/QVCProduct',
'sites/QVC/QVCProductScraper',
'sites/QVC/QVCSiteInjector',
'sites/Rakuten/config',
'sites/Rakuten/RakutenProductScraper',
'sites/Rakuten/RakutenSiteInjector',
'sites/Rei/config',
'sites/Rei/ReiProductScraper',
'sites/Rei/ReiSiteInjector',
'sites/RentTheRunway/config',
'sites/RentTheRunway/RentTheRunwayProduct',
'sites/RentTheRunway/RentTheRunwayProductScraper',
'sites/RentTheRunway/RentTheRunwaySiteInjector',
'sites/SamsClub/config',
'sites/SamsClub/SamsClubProductScraper',
'sites/SamsClub/SamsClubSiteInjector',
'sites/Sears/config',
'sites/Sears/SearsProduct',
'sites/Sears/SearsProductScraper',
'sites/Sears/SearsSiteInjector',
'sites/Singer22/config',
'sites/Singer22/Singer22Product',
'sites/Singer22/Singer22ProductScraper',
'sites/Singer22/Singer22SiteInjector',
'sites/SixPM/config',
'sites/SixPM/SixPmProduct',
'sites/SixPM/SixPMProductScraper',
'sites/SixPM/SixPmSiteInjector',
'sites/Soap/config',
'sites/Soap/SoapProduct',
'sites/Soap/SoapProductScraper',
'sites/Soap/SoapSiteInjector',
'sites/Staples/StaplesProductScraper',
'sites/Staples/StaplesSiteInjector',
'sites/Target/config',
'sites/Target/TargetProductScraper',
'sites/Target/TargetSiteInjector',
'sites/TheLimited/config',
'sites/TheLimited/TheLimitedProduct',
'sites/TheLimited/TheLimitedProductScraper',
'sites/TheLimited/TheLimitedSiteInjector',
'sites/ToysRUs/config',
'sites/ToysRUs/ToysRUsProductScraper',
'sites/ToysRUs/ToysRUsSiteInjector',
'sites/Tutorial/config',
'sites/Tutorial/TutorialSiteInjector',
'sites/Uniqlo/config',
'sites/Uniqlo/UniqloProduct',
'sites/Uniqlo/UniqloProductScraper',
'sites/Uniqlo/UniqloSiteInjector',
'sites/VictoriasSecret/config',
'sites/VictoriasSecret/VictoriasSecretProductScraper',
'sites/VictoriasSecret/VictoriasSecretSiteInjector',
'sites/Vitacost/_SiteInjector',
'sites/Vitacost/VitacostProductScraper',
'sites/Walgreens/config',
'sites/Walgreens/WalgreensProductScraper',
'sites/Walgreens/WalgreensSiteInjector',
'sites/Webapp/config',
'sites/Webapp/WebappProductScraper',
'sites/Webapp/WebappSiteInjector',
'sites/WetSeal/config',
'sites/WetSeal/WetSealProduct',
'sites/WetSeal/WetSealProductScraper',
'sites/WetSeal/WetSealSiteInjector',
'sites/WomanWithin/config',
'sites/WomanWithin/WomanWithinProduct',
'sites/WomanWithin/WomanWithinProductScraper',
'sites/WomanWithin/WomanWithinSiteInjector',
'sites/Zappos/config',
'sites/Zappos/ZapposProduct',
'sites/Zappos/ZapposProductScraper',
'sites/Zappos/ZapposSiteInjector',
])