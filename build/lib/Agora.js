// Generated by CoffeeScript 1.10.0
var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(['underscore', 'Debug', 'client/ContentScript', 'client/SiteInjector', 'Site', 'siteConfig', 'View', 'clientInterface/ClientValue', 'models/init', 'model/Event', 'Updater2', 'Public', 'views/ProductPriceView', 'views/ProductMenuView', 'views/SettingsView', 'CodeManager', 'Chat'], function(_, Debug, ContentScript, SiteInjector, Site, siteConfig, View, ClientValue, initModels, Event, Updater, Public, ProductPriceView, ProductMenuView, SettingsView, CodeManager, Chat) {
  var Agora;
  return Agora = (function() {
    function Agora(background1, opts) {
      var autoUpdate, createView, createViewQueue, db, j, lastUpdated, len, modelManager, onLoaded, ref, ref1, scrapersTime, settingName, settings, tutorialCheck, updateScrapers, updateScrapersCbs, updateScrapersId, updater, updatingScrapers, user;
      this.background = background1;
      if (opts == null) {
        opts = {};
      }
      if (opts.client == null) {
        opts.client = true;
      }
      ref = initModels(this.background), db = ref.db, modelManager = ref.modelManager;
      this.db = db;
      this.modelManager = modelManager;
      window.Debug = Debug;
      this["public"] = new Public;
      this["public"].agora = this;
      this.background.loadVersion = this.loadVersion = new Date().getTime();
      this.events = {
        onUserChanged: new Event
      };
      lastUpdated = null;
      this.background.state = 0;
      autoUpdate = opts.autoUpdate;
      opts.localTest = (ref1 = env.localTest) != null ? ref1 : opts.localTest;
      this.View = View;
      View.agora = this;
      Site.agora = this;
      _.extend(this.modelManager.getModel('Product'), {
        background: background,
        agora: this
      });
      this.Site = Site;
      this.siteSettings = new ClientValue(this, {}, 'siteSettings');
      this.userId = new ClientValue(this, {}, 0);
      this.errorState = new ClientValue(this);
      settings = ['hideBelt', 'autoFeelings', 'showPreview'];
      this.settings = {};
      for (j = 0, len = settings.length; j < len; j++) {
        settingName = settings[j];
        this.settings[settingName] = new ClientValue(this);
      }
      this.codeManager = new CodeManager(this);
      if (opts.client && !env.core) {
        this.chat = new Chat(this);
        this.chat.init();
      }
      scrapersTime = null;
      if (!env.core) {
        updatingScrapers = false;
        updateScrapersId = null;
        updateScrapersCbs = [];
        this.updateScrapers = updateScrapers = (function(_this) {
          return function(cb) {
            if (cb == null) {
              cb = null;
            }
            if (cb) {
              updateScrapersCbs.push(cb);
            }
            if (updatingScrapers) {
              console.debug('already updating scrapers');
              return;
            }
            background.clearTimeout(updateScrapersId);
            updatingScrapers = true;
            return background.httpRequest('http://ext.agora.sh/getScrapers.php', {
              data: {
                timestamps: true,
                version: _this.background.getVersion(),
                time: scrapersTime != null ? scrapersTime : void 0
              },
              dataType: 'json',
              cb: function(response) {
                var i, k, l, len1, len2, len3, m, n, newScraper, ref2, ref3, ref4, scraper, toRemove;
                background.declarativeScrapers;
                toRemove = [];
                ref2 = response.scrapers;
                for (k = 0, len1 = ref2.length; k < len1; k++) {
                  newScraper = ref2[k];
                  ref3 = background.declarativeScrapers;
                  for (i = l = 0, len2 = ref3.length; l < len2; i = ++l) {
                    scraper = ref3[i];
                    if (scraper.name === newScraper.name && scraper.site === newScraper.site) {
                      toRemove.push(i);
                    }
                  }
                }
                if (toRemove.length) {
                  for (i = m = ref4 = toRemove.length - 1; ref4 <= 0 ? m <= 0 : m >= 0; i = ref4 <= 0 ? ++m : --m) {
                    background.declarativeScrapers.splice(toRemove[i], 1);
                  }
                }
                background.declarativeScrapers = background.declarativeScrapers.concat(response.scrapers);
                scrapersTime = response.time;
                updatingScrapers = false;
                updateScrapersId = background.setTimeout(updateScrapers, 30000);
                for (n = 0, len3 = updateScrapersCbs.length; n < len3; n++) {
                  cb = updateScrapersCbs[n];
                  cb(true);
                }
                return updateScrapersCbs = [];
              },
              error: function() {
                return updateScrapersId = background.setTimeout(updateScrapers, 30000);
              }
            });
          };
        })(this);
      }
      onLoaded = (function(_this) {
        return function(success) {
          var doOnLoaded;
          console.debug('loaded');
          doOnLoaded = function() {
            var args, config, k, len1, name, observeField, observeRecord, ref2, siteName, siteSettings, table;
            _this.modelManager.getModel('Product').init();
            if (!env.core) {
              updateScrapers();
              if (opts.client) {
                observeField = function(record, field) {
                  return record.field(field).observe(function(mutation) {
                    return updater.addUpdate(record, field);
                  });
                };
                observeRecord = function(record) {
                  var field, k, len1, ref2, results;
                  if (record.table.schema.fields) {
                    ref2 = record.table.schema.fields;
                    results = [];
                    for (k = 0, len1 = ref2.length; k < len1; k++) {
                      field = ref2[k];
                      results.push(observeField(record, field));
                    }
                    return results;
                  }
                };
                ref2 = db.tables;
                for (name in ref2) {
                  table = ref2[name];
                  table.records.each(observeRecord);
                  table.records.observe(function(mutation) {
                    if (mutation.type === 'insertion') {
                      updater.addInsertion(mutation.value);
                      return observeRecord(mutation.value);
                    } else if (mutation.type === 'deletion') {
                      return updater.addDeletion(mutation.value);
                    }
                  });
                }
                siteSettings = {};
                for (siteName in siteConfig) {
                  config = siteConfig[siteName];
                  if (!('enabled' in config) || config.enabled === true) {
                    siteSettings[siteName] = {
                      enabled: true
                    };
                  }
                }
                db.tables.site_settings.records.each(function(record) {
                  return siteSettings[record.get('site')] = {
                    enabled: record.get('enabled')
                  };
                });
                _this.siteSettings.set(siteSettings);
                _this.background.getStorage(['options'], function(data) {
                  var k, len1, results, setting;
                  if (data.options) {
                    results = [];
                    for (k = 0, len1 = settings.length; k < len1; k++) {
                      setting = settings[k];
                      results.push(_this.settings[setting].set(data.options[setting]));
                    }
                    return results;
                  }
                });
                db.tables.site_settings.observe(function(mutation) {
                  switch (mutation.type) {
                    case 'deletion':
                      delete _this.siteSettings.get()[mutation.record.get('site')];
                      break;
                    case 'insertion':
                      _this.siteSettings.get()[mutation.record.get('site')] = {};
                      break;
                    case 'update':
                      _this.siteSettings.get()[mutation.record.get('site')][mutation.field] = mutation.record.get(mutation.field);
                  }
                  return _this.siteSettings.set(_this.siteSettings.get());
                });
                if (_this.updater.userId) {
                  if (success) {
                    _this.user = _this.modelManager.getModel('User').withId('G' + _this.updater.userId, false);
                  }
                }
              }
            }
            for (k = 0, len1 = createViewQueue.length; k < len1; k++) {
              args = createViewQueue[k];
              createView.apply(null, args);
            }
            delete createViewQueue;
            _this.loaded = true;
            return typeof opts.onLoaded === "function" ? opts.onLoaded(_this) : void 0;
          };
          if (!env.core) {
            return background.httpRequest('http://ext.agora.sh/getScrapers.php', {
              data: {
                timestamps: true,
                version: _this.background.getVersion()
              },
              dataType: 'json',
              cb: function(response) {
                background.declarativeScrapers = response.scrapers;
                scrapersTime = response.time;
                return doOnLoaded();
              }
            });
          } else {
            return doOnLoaded();
          }
        };
      })(this);
      createView = (function(_this) {
        return function(source, args, sendResponse) {
          var id;
          id = View.createClientView(source.tabId, args.type);
          return sendResponse({
            id: id
          });
        };
      })(this);
      createViewQueue = [];
      this.updater = updater = new Updater(background, db, this.userId, this.errorState);
      if (!autoUpdate) {
        this.updater.autoUpdate = false;
      }
      if (opts.localTest || opts.core) {
        this.loaded = true;
        if (opts.client) {
          if (typeof opts.initDb === "function") {
            opts.initDb(this);
          }
          user = db.tables.users.insert({});
          this.user = modelManager.getInstance('User', user.get('id'));
          db.tables.belts.insert({
            user_id: user.get('id')
          });
          this.userId.set(user.get('id'));
        }
        onLoaded();
      } else {
        if (autoUpdate) {
          this.loaded = false;
          this.background.state = 1;
          updater.init(onLoaded);
        } else {
          this.loaded = true;
          onLoaded();
        }
      }
      if (opts.client) {
        this.background.listen('CreateView', (function(_this) {
          return function(source, args, sendResponse) {
            if (_this.loaded) {
              return createView.apply(_this, arguments);
            } else {
              createViewQueue.push(arguments);
              return true;
            }
          };
        })(this));
        this.background.listen('CallViewBackgroundMethod', function(source, args, sendResponse) {
          View.callMethod(args.id, args.methodName, args.args, args.timestamp, sendResponse);
          return false;
        });
        this.background.listen('ConnectView', (function(_this) {
          return function(source, args, sendResponse) {
            View.connect(_this, args.id, args.args, function(success, data) {
              if (success) {
                return sendResponse({
                  data: data
                });
              } else {
                return sendResponse(false);
              }
            });
            return true;
          };
        })(this));
        this.background.listen('DeleteView', (function(_this) {
          return function(source, args) {
            View.remove(args.id);
            return false;
          };
        })(this));
        this.background.listen('GetClientObjects', function(source, ids, sendResponse) {
          return sendResponse(View.getClientObjects(ids));
        });
        this.background.listen('tracking', (function(_this) {
          return function(source, args) {
            if (!env.core) {
              if (args.type === 'event') {
                tracking.event.apply(tracking, args.args);
              } else if (args.type === 'page') {
                tracking.page(args.path, args.params, args.title);
              } else if (args.type === 'time') {
                tracking.time.apply(tracking, args.args);
              }
            }
            return false;
          };
        })(this));
        this.background.listen('tutorialFinished', (function(_this) {
          return function() {
            if (_this.convert) {
              delete _this.convert;
              _this.background.httpRequest(_this.updater.background.apiRoot + 'convert.php');
            }
            _this.tutorial('end');
            return false;
          };
        })(this));
        this.background.listen('tutorialStep', (function(_this) {
          return function(source, step) {
            _this.tutorial('step', step);
            return false;
          };
        })(this));
        this.background.listen('reloadExtension', (function(_this) {
          return function() {
            chrome.runtime.reload();
            return false;
          };
        })(this));
        this.background.listen('siteVisited', (function(_this) {
          return function(source, site) {
            tracking.event('Site', 'visit', site);
            if (_this.user) {
              _this.updater.transport.ws.send("t" + (_this.user.saneId()) + "\tvisit\t" + site);
            }
            return false;
          };
        })(this));
        tutorialCheck = (function(_this) {
          return function(tutorial) {
            if (_this.user.get('tutorials')) {
              if (indexOf.call(_this.user.get('tutorials').split(' '), tutorial) >= 0) {
                return false;
              } else {
                return true;
              }
            } else {
              return true;
            }
          };
        })(this);
        this.background.listen('tutorialCheck', (function(_this) {
          return function(source, tutorial, sendResponse) {
            var k, len1, t;
            if (env.core) {
              return sendResponse(false);
            } else {
              if (_.isArray(tutorial)) {
                for (k = 0, len1 = tutorial.length; k < len1; k++) {
                  t = tutorial[k];
                  if (tutorialCheck(t)) {
                    sendResponse(t);
                    return;
                  }
                }
              } else {
                if (tutorialCheck(tutorial)) {
                  sendResponse(tutorial);
                  return;
                }
              }
              return sendResponse(false);
            }
          };
        })(this));
        this.background.listen('tutorialSeen', (function(_this) {
          return function(source, tutorial, sendResponse) {
            if (_this.user.get('tutorials')) {
              if (!(indexOf.call(_this.user.get('tutorials').split(' '), tutorial) >= 0)) {
                return _this.user.set('tutorials', (_this.user.get('tutorials')) + " " + tutorial);
              }
            } else {
              return _this.user.set('tutorials', tutorial);
            }
          };
        })(this));
      }
    }

    Agora.prototype._load = function(classes, cb, classDefs) {
      var classFactory, className, deps, factory;
      if (classDefs == null) {
        classDefs = [];
      }
      deps = [];
      for (className in classes) {
        classFactory = classes[className];
        if (typeof classFactory === 'string') {
          deps.push(classFactory);
        } else {
          if (typeof classFactory === 'function') {
            factory = classFactory;
          } else {
            if (classFactory.d) {
              deps = _.union(deps, classFactory.d);
            }
            factory = classFactory.c;
          }
          classDefs.unshift({
            name: className,
            body: factory.toString()
          });
        }
      }
      if (deps.length) {
        return this.background.require(_.map(deps, function(className) {
          return "client/" + className;
        }), (function(_this) {
          return function() {
            var c, i, index, j, ref;
            c = {};
            for (i = j = 0, ref = deps.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
              className = deps[i];
              if ((index = className.lastIndexOf('/')) !== -1) {
                className = className.substr(index + 1);
              }
              classFactory = arguments[i];
              c[className] = classFactory;
            }
            return _this._load(c, cb, classDefs);
          };
        })(this));
      } else {
        return cb(classDefs);
      }
    };

    Agora.prototype._compileContentScript = function(classDefs, site) {
      var body, classCode, classVars, j, len, name, ref, ref1, setting, settingName, settingsStr;
      classVars = classDefs.join('\n');
      classCode = "var __classes = {};\n";
      for (j = 0, len = classDefs.length; j < len; j++) {
        ref = classDefs[j], name = ref.name, body = ref.body;
        classCode += "window." + name + " = __classes." + name + " = (" + body + ")();\n";
      }
      settingsStr = '';
      ref1 = this.settings;
      for (settingName in ref1) {
        setting = ref1[settingName];
        settingsStr += settingName + ": new ClientValue({ _id: " + setting._id + ", _scalar: " + (JSON.stringify(setting.get())) + ", contentScript: contentScript }),";
      }
      return "(function() {\n	/* content script */\n	\n	function run() {\n		var env = " + (JSON.stringify(env)) + ";\n		// CoffeScript system methods\n		\n		var\n		  slice = [].slice,\n			extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },\n		  hasProp = {}.hasOwnProperty;\n\n\n		" + classCode + "\n		window.__classes = __classes;\n\n		var contentScript = window.contentScript = new SpecificContentScript;\n		contentScript.version = " + this.version + ";\n\n		var Agora = window.Agora = {\n			siteSettings: new ClientValue({\n				_id: " + this.siteSettings._id + ",\n				contentScript: contentScript,\n				_scalar:" + (JSON.stringify(this.siteSettings.get())) + "\n			}),\n			settings: {\n				" + settingsStr + "\n			},\n			userId: new ClientValue({\n				_id: " + this.userId._id + ",\n				contentScript: contentScript,\n				_scalar:" + (JSON.stringify(this.userId.get())) + "\n			}),\n			errorState: new ClientValue({\n				_id: " + this.errorState._id + ",\n				contentScript: contentScript,\n				_scalar:" + (JSON.stringify(this.errorState.get())) + "\n			}),\n			dev:" + env.dev + "\n		};\n\n		var siteInjector;\n\n		window.doSiteInjection = function() {\n			siteInjector = window.siteInjector = new window.SpecificSiteInjector(contentScript, " + this.continueTutorial + ", '" + site.name + "');\n\n			siteInjector.run();\n		}\n\n		doSiteInjection()\n\n		if (window.onAgoraInit) {\n			window.onAgoraInit();\n		}\n	}\n	return run();\n})()";
    };

    Agora.prototype.setAutoShowForSite = function(site, value) {
      var record;
      record = this.db.tables.site_settings.select(function(record) {
        return record.get('site') === site;
      })[0];
      if (!record) {
        record = this.db.tables.site_settings.addRecord({
          site: site
        });
      }
      return record.set('enabled', value);
    };

    Agora.prototype.toggleAutoShow = function(site) {
      return this.enabledForSite(site, (function(_this) {
        return function(enabled) {
          return _this.setAutoShowForSite(site, enabled ? 0 : 1);
        };
      })(this));
    };

    Agora.prototype.enabledForUrl = function(url, cb) {
      var site;
      site = Site.siteForUrl(url);
      if (site) {
        return this.enabledForSite(site.id(), cb);
      } else {
        return false;
      }
    };

    Agora.prototype._setSiteEnabled = function(siteID, enabled) {
      var base;
      if (this._sitesEnabledCache == null) {
        this._sitesEnabledCache = {};
      }
      if (enabled) {
        this._sitesEnabledCache[siteID] = true;
      } else {
        delete this._sitesEnabledCache[siteID];
      }
      if ((base = this.siteSettings.get())[siteID] == null) {
        base[siteID] = {};
      }
      this.siteSettings.get()[siteID].enabled = enabled;
      return this.siteSettings.set(this.siteSettings.get());
    };

    Agora.prototype.enabledForSite = function(siteID, cb) {
      var record, site;
      record = this.db.tables.site_settings.select(function(record) {
        return record.get('site') === siteID;
      })[0];
      if (record) {
        return cb(record.get('enabled'));
      } else {
        site = Site.siteById(siteID);
        if (site.config.enabled === 'check') {
          if (this._sitesEnabledCache && siteID in this._sitesEnabledCache) {
            return cb(true);
          } else if (!env.dev) {
            return this.background.httpRequest(this.background.apiRoot + 'merchantCheck.php', {
              data: {
                host: site.host
              },
              cb: (function(_this) {
                return function(response) {
                  if (response === '1') {
                    _this._setSiteEnabled(siteID, true);
                    return cb(true);
                  } else {
                    return cb(false);
                  }
                };
              })(this),
              error: function() {
                return cb(false);
              }
            });
          }
        } else {
          return cb(true);
        }
      }
    };

    Agora.prototype._getContentScript = function(siteInjector, site, cb) {
      var classes, libsScript, mainScript, styleScript, tick;
      mainScript = styleScript = libsScript = null;
      tick = (function(_this) {
        return function() {
          if (mainScript && styleScript && libsScript) {
            return cb(libsScript + "\n" + styleScript + "\n" + mainScript);
          }
        };
      })(this);
      this.background.getStyles((function(_this) {
        return function(styles) {
          styles = styles.replace(/"/g, '\\"').replace(/\n/g, '\\n');
          styleScript = "$('head').append(\"<style id='agoraStylesheet' type='text/css'>" + styles + "</style>\");";
          return tick();
        };
      })(this));
      classes = {
        SpecificSiteInjector: siteInjector,
        SiteInjector: SiteInjector,
        Debug: 'Debug',
        tracking: 'tracking',
        TutorialDialog: 'TutorialDialog',
        ShoppingBarView: 'views/ShoppingBarView',
        ProductPriceView: ProductPriceView.client,
        ProductMenuView: ProductMenuView.client,
        SettingsView: SettingsView.client,
        SpecificContentScript: this.background.contentScript(),
        ContentScript: ContentScript
      };
      this._load(classes, (function(_this) {
        return function(classDefs) {
          mainScript = _this._compileContentScript(classDefs, site);
          return tick();
        };
      })(this));
      return this.background.httpRequest(this.background.clientLibsPath(), {
        method: 'get',
        cb: function(response) {
          libsScript = response;
          return tick();
        }
      });
    };

    Agora.prototype.getContentScript = function(url, cb) {
      return this.getSiteInjector(url, (function(_this) {
        return function(siteInjector, site) {
          if (siteInjector) {
            return _this._getContentScript(siteInjector, site, cb);
          } else {
            console.log("no site injector for " + url);
            return cb('');
          }
        };
      })(this));
    };

    Agora.prototype.getSiteInjector = function(url, cb) {
      var site;
      site = Site.siteForUrl(url);
      if (site) {
        return site.getSiteInjector(this.background, cb);
      } else {
        return cb(null);
      }
    };

    Agora.prototype.getSiteScraper = function(url, cb) {
      var site;
      site = Site.siteForUrl(url);
      if (site) {
        return site.getSiteScraper(this.background, (function(_this) {
          return function(scraperClass) {
            var scraper;
            scraper = new scraperClass(_this.background);
            return cb(scraper);
          };
        })(this));
      } else {
        return cb(null);
      }
    };

    Agora.prototype.product = function(input, cb, create) {
      if (create == null) {
        create = true;
      }
      return this.modelManager.getModel('Product').get(input, cb, create);
    };

    Agora.prototype.tutorial = function(state) {
      var time;
      if (state === 'continue') {
        this.continueTutorial = true;
      } else {
        delete this.continueTutorial;
      }
      if (state === 'start') {
        return this.tutorialStartTime = new Date().getTime();
      } else if (state === 'end') {
        time = new Date().getTime() - this.tutorialStartTime;
        delete this.tutorialStartTime;
        return tracking.time('Tutorial', 'TotalTime', time);
      } else if (state === 'step') {
        if (this.user.get('tutorial_step') < arguments[1]) {
          return this.user.set('tutorial_step', arguments[1]);
        }
      }
    };

    Agora.prototype.setOptions = function(options) {
      return this.background.getStorage(['options'], (function(_this) {
        return function(data) {
          var prevOptions, prop, ref, value;
          prevOptions = (ref = data.options) != null ? ref : {};
          for (prop in options) {
            value = options[prop];
            prevOptions[prop] = value;
            _this.settings[prop].set(value);
          }
          return _this.background.setStorage({
            options: prevOptions
          });
        };
      })(this));
    };

    Agora.prototype.addTab = function(tabId) {
      if (!this.tabs) {
        this.tabs = [];
      }
      this.tabs.push(tabId);
      this.background.contentScriptListen("ClientObjectEvent:" + this.userId._id, tabId);
      this.background.contentScriptListen("ClientObjectEvent:" + this.errorState._id, tabId);
      return this.background.contentScriptListen("ClientObjectEvent:" + this.siteSettings._id, tabId);
    };

    Agora.prototype.removeTab = function(tabId) {
      _.pull(this.tabs, tabId);
      return View.deleteClientViewsInTab(tabId);
    };

    Agora.prototype.signalReload = function() {
      var j, len, ref, results, tab;
      console.log(this.tabs);
      if (this.tabs) {
        ref = this.tabs;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          tab = ref[j];
          results.push(chrome.tabs.sendMessage(tab, 'needsReload'));
        }
        return results;
      }
    };

    Agora.prototype.reset = function() {
      console.debug('reset');
      this.background.loadVersion = this.loadVersion = new Date().getTime();
      this.signalReload();
      this.View.clear();
      return this.background.reset();
    };

    Agora.prototype.onInit = function(success) {
      var ref;
      console.log(success);
      if (this.updater.userId) {
        if (success) {
          this.user = this.modelManager.getModel('User').withId('G' + this.updater.userId);
          if ((ref = this.View.views.ShoppingBar) != null ? ref["null"] : void 0) {
            this.View.views.ShoppingBar["null"].setUser(this.user);
            return this.View.views.Collaborate.ShoppingBar.update();
          }
        }
      } else {
        return delete this.user;
      }
    };

    Agora.prototype.getObject = function(storeId, object) {
      var id, ref, table;
      if (object === '@') {
        return this.db.tables.users.byId("G" + storeId);
      } else if (object === '/') {
        return this.db.tables.users.byId("G" + storeId);
      } else {
        ref = object.split('.'), table = ref[0], id = ref[1];
        return this.db.table(table).byId("G" + storeId);
      }
    };

    return Agora;

  })();
});

//# sourceMappingURL=Agora.js.map
