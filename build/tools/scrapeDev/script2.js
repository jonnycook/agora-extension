// Generated by CoffeeScript 1.10.0
chrome.storage.local.get('scrapeDev', function(data) {
  var Data, ref;
  Data = (ref = data.scrapeDev) != null ? ref : {
    "pages": [
      {
        "url": "http://www.amazon.com/gp/product/B00FGL5IG4/ref=s9_simh_gw_p193_d0_i2?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=0H7C5ADJE855G6BA582X&pf_rd_t=101&pf_rd_p=1688200382&pf_rd_i=507846"
      }
    ],
    "rootCaptures": [
      {
        "pattern": "<div id=\"rev-dpReviewsMostHelpfulAUI-R3QD2CF3I9ZMPQ\" class=\"a-section\">([\\S\\s]*?)<a id=\"R3QD2CF3I9ZMPQ.2115.Helpful.Reviews\"></a>",
        "captures": [
          {
            "pattern": "title=\"(\\S+) out of 5 stars\"",
            "captures": []
          }, {
            "pattern": "<a href=\"/gp/pdp/profile/[^/]*/ref=cm_cr_dp_pdp\" class=\"noTextDecoration\">([^<]*)</a>",
            "captures": []
          }, {
            "pattern": "<span class=\"a-color-secondary\"> on ([^<]*)</span>",
            "captures": []
          }, {
            "pattern": "<div class=\"a-section\">\\s*([\\S\\s]*?)\\s*</div>",
            "captures": []
          }
        ],
        "name": "reviews",
        "global": true
      }
    ]
  };
  return $(function() {
    var ListInterface, Pages, _getCode, add, addPage, addPageEl, encodeHtml, getCode, pagesEl, pagesIface, save;
    save = function() {
      return chrome.storage.local.set({
        scrapeDev: Data
      });
    };
    ListInterface = (function() {
      function ListInterface(args) {
        var el, j, len, ref1;
        this["new"] = args["new"];
        this.el = args.el;
        this.array = args.array;
        if (this.array) {
          ref1 = this.array;
          for (j = 0, len = ref1.length; j < len; j++) {
            el = ref1[j];
            this._add(el);
          }
        }
      }

      ListInterface.prototype._add = function(data) {
        var el, removeFunc;
        removeFunc = null;
        el = this["new"](data, {
          remove: (function(_this) {
            return function() {
              el.remove();
              if (typeof removeFunc === "function") {
                removeFunc();
              }
              if (_this.array) {
                return _.pull(_this.array, data);
              }
            };
          })(this),
          onRemove: function(func) {
            return removeFunc = func;
          }
        });
        return this.el.append(el);
      };

      ListInterface.prototype.add = function(data) {
        this._add(data);
        if (this.array) {
          this.array.push(data);
        }
        return save();
      };

      return ListInterface;

    })();
    $('<button>Reload CSS</button>').appendTo('body').click(function() {
      $('link').remove();
      return $('<link rel="stylesheet" type="text/css" href="scrapeDev/styles.css?' + new Date().getTime() + '">').appendTo('head');
    });
    $('<button>Get Data</button>').appendTo('body').click(function() {
      var el;
      el = $('<textarea />').html(JSON.stringify(Data)).appendTo('body').select();
      document.execCommand('copy');
      return el.remove();
    });
    _getCode = function(args) {
      var capture, captureId, code, i, i2, name, pattern, ref1, ref2, subCaptures;
      i = (ref1 = args.indent) != null ? ref1 : '';
      i2 = i + '	';
      code = i + "((subject, data) ->\n";
      ref2 = args.captures;
      for (captureId in ref2) {
        capture = ref2[captureId];
        name = "data." + capture.name;
        pattern = capture.pattern.replace(/\//g, '\\/');
        if (capture.global) {
          if (capture.captures.length) {
            subCaptures = _getCode({
              captures: capture.captures,
              subject: "match.match(/" + pattern + "/)[" + capture.group + "]",
              object: 'obj',
              indent: i2 + '	'
            });
            code += i2 + "matches = subject.match(/" + pattern + "/g)\n" + i2 + name + " = for match in matches\n" + i2 + "	obj = {}\n" + i + subCapture + "\n" + i2 + "	obj";
          } else {
            code += "" + i2 + name + " = match.match(/" + pattern + "/)[" + capture.group + "] for match in subject.match(/" + pattern + "/g)\n";
          }
        } else {
          if (capture.captures.length) {
            code += "" + i2 + name + " = {}\n";
            code += i2 + "matches = /" + pattern + "/.exec(subject)[" + capture.group + "]\n";
            subCaptures = _getCode({
              captures: capture.captures,
              subject: "matches",
              object: name,
              indent: i2
            });
            code += "" + i + subCaptures + "\n";
          } else {
            code += "" + i2 + name + " = /" + pattern + "/.exec(subject)[" + capture.group + "]\n";
          }
        }
      }
      code += i + ")(" + args.subject + ", " + args.object + ")\n";
      return code;
    };
    getCode = function() {
      return _getCode({
        captures: Data.rootCaptures,
        subject: 'STRING',
        object: 'ROOT'
      });
    };
    console.debug(getCode());
    $('<button>Get Code</button>').appendTo('body').click(function() {
      var el;
      el = $('<textarea />').html(getCode()).appendTo('body').select();
      document.execCommand('copy');
      return el.remove();
    });
    encodeHtml = function(html) {
      return html.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    };
    pagesEl = $('<ul id="pages" />').appendTo('body');
    addPageEl = $('<input type="text">').keydown(function(e) {
      if (e.keyCode === 13) {
        addPage();
        return $(this).val('');
      }
    }).appendTo('body');
    Pages = {
      pageCount: 0,
      pages: []
    };
    pagesIface = new ListInterface({
      array: Data.pages,
      el: pagesEl,
      "new": function(data, control) {
        var page, pageEl, url;
        url = data.url;
        pageEl = $("<li> <span class='url'>" + url + "</span> <div class='source' /> </li>");
        $('<input value="Toggle Size" type="button">').appendTo(pageEl).click(function() {
          return pageEl.toggleClass('fullscreen');
        });
        page = {};
        Pages.pages[Pages.pageCount++] = page;
        $.get(url, function(response) {
          page.content = response;
          return pageEl.find('.source').html(encodeHtml(response));
        });
        return pageEl;
      }
    });
    addPage = function() {
      return pagesIface.add({
        url: addPageEl.val()
      });
    };
    add = function(parentEl, contentFunc, array) {
      var captures, capturesEl, capturesIface, contEl, update;
      update = function() {
        var capture, content, contentId, i, j, len, regExp, results;
        results = [];
        for (i = j = 0, len = captures.length; j < len; i = ++j) {
          capture = captures[i];
          regExp = new RegExp(capture.pattern);
          results.push((function() {
            var k, len1, ref1, results1;
            ref1 = contentFunc();
            results1 = [];
            for (contentId = k = 0, len1 = ref1.length; k < len1; contentId = ++k) {
              content = ref1[contentId];
              results1.push(capture.update(contentId, regExp.exec(content)));
            }
            return results1;
          })());
        }
        return results;
      };
      captures = [];
      contEl = $('<div />').appendTo(parentEl);
      capturesEl = $('<ul id="captures" />').appendTo(contEl);
      capturesIface = new ListInterface({
        el: capturesEl,
        array: array,
        "new": function(data, control) {
          var capture, captureData, captureEl, capturesIndex;
          captureData = {};
          capture = {
            pattern: data.pattern,
            update: function(contentId, matches) {
              var results;
              captureData[contentId] = matches;
              captureEl.children('.captureData').html('');
              results = [];
              for (contentId in captureData) {
                matches = captureData[contentId];
                results.push((function(contentId, matches) {
                  var el, i, j, len, match, results1;
                  el = $('<li />').appendTo(captureEl.children('.captureData'));
                  if (matches) {
                    el.append('<ol />');
                    results1 = [];
                    for (i = j = 0, len = matches.length; j < len; i = ++j) {
                      match = matches[i];
                      results1.push(el.find('ol').append($('<li class="match" />').addClass(i === data.group ? 'selected' : void 0).html(encodeHtml(match))));
                    }
                    return results1;
                  } else {
                    return el.html('no matches');
                  }
                })(contentId, matches));
              }
              return results;
            }
          };
          capturesIndex = captures.length;
          captures.push(capture);
          captureEl = $('<li> <button class="update">Update</button> <input type="checkbox" class="global"> <input type="text" class="name" value="" placeholder="Name"> <input type="text" class="group" value="" placeholder="Group"> <input type="text" class="pattern" value="" placeholder="Pattern"> <ol class="captureData" /> </li>').find('.update').click(function() {
            return update();
          }).end().find('.global').prop('checked', data.global).change(function() {
            data.global = this.checked;
            return save();
          }).end().find('.name').val(data.name).keyup(function() {
            data.name = $(this).val();
            return save();
          }).end().find('.pattern').val(data.pattern).keyup(function() {
            data.pattern = capture.pattern = $(this).val();
            update();
            return save();
          }).end().find('.group').val(data.group).keyup(function() {
            data.group = parseInt($(this).val());
            update();
            return save();
          }).end();
          add(captureEl, (function() {
            var contentId, matches, results;
            results = [];
            for (contentId in captureData) {
              matches = captureData[contentId];
              results.push(matches[0]);
            }
            return results;
          }), data.captures);
          captureEl.append($('<button>Remove</button>').click(function() {
            return control.remove();
          }));
          control.onRemove(function() {
            return captures.splice(capturesIndex, 1);
          });
          return captureEl;
        }
      });
      return $('<button>Add Capture</button>').appendTo(contEl).click(function() {
        return capturesIface.add({
          pattern: '',
          captures: []
        });
      });
    };
    return add('body', (function() {
      var j, len, page, ref1, results;
      ref1 = Pages.pages;
      results = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        page = ref1[j];
        results.push(page.content);
      }
      return results;
    }), Data.rootCaptures);
  });
});

//# sourceMappingURL=script2.js.map
