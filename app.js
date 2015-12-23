(function() {
  var App, SLEEP, hashAppend, hashList, hashLoad, hashRemove, hashToggle, lazyLoad, loadFeed, loadFeeds, timeout, update,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.requestAnimFrame = (function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || function(callback) {
      return window.setTimeout(callback, 1000 / 60);
    };
  })();

  timeout = function(d, c) {
    return setTimeout(c, d);
  };

  hashList = function() {
    var id, _i, _len, _ref, _results;
    _ref = window.location.hash.substring(1).split('-');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      id = _ref[_i];
      if (id) {
        _results.push(id);
      }
    }
    return _results;
  };

  hashToggle = function(id) {
    if (__indexOf.call(hashList(), id) >= 0) {
      return hashRemove(id);
    } else {
      return hashAppend(id);
    }
  };

  hashRemove = function(id) {
    return window.location.hash = hashList().filter(function(a) {
      return a !== id;
    }).join('-');
  };

  hashAppend = function(id) {
    if (__indexOf.call(hashList(), id) < 0) {
      return window.location.hash = hashList().concat(id).sort(function(a, b) {
        return parseInt(a, 16) - parseInt(b, 16);
      }).join('-');
    }
  };

  hashLoad = function(ids) {
    return window.location.hash = ids.sort(function(a, b) {
      return parseInt(a, 16) - parseInt(b, 16);
    }).join('-');
  };

  if ((localStorage['hash'] != null) && !hashList().length) {
    window.location.hash = localStorage['hash'];
  }

  lazyLoad = function() {
    var item, _i, _len, _ref, _results;
    _ref = document.querySelectorAll('[data-src]');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (!(item.getBoundingClientRect().top < window.innerHeight * 1.1)) {
        continue;
      }
      if (item.tagName === 'IMG') {
        item.src = item.dataset.src;
      } else {
        item.style.backgroundImage = 'url(' + item.dataset.src + ')';
      }
      _results.push(delete item.dataset.src);
    }
    return _results;
  };

  SLEEP = false;

  App = new Vue({
    el: '#app',
    data: {
      feeds: [],
      items: [],
      loaded: [],
      settings: false,
      current: false,
      sleep: false
    },
    watch: {
      'hashlist': function() {
        return App.feeds.reverse().reverse();
      },
      'items': function() {
        return Vue.nextTick(lazyLoad);
      },
      'current': function() {
        Vue.nextTick(lazyLoad);
        if (!App.settings) {
          return window.scrollTo(0, document.body.scrollTop + (document.getElementById('board').getBoundingClientRect().top - 70));
        }
      },
      'settings': function() {
        window.scrollTo(0, 0);
        if (App.settings === true) {
          return Vue.nextTick(function() {
            loadFeeds((function(feeds) {
              return App.feeds = feeds;
            }), false);
            return document.getElementById('search').focus();
          });
        } else {
          return Vue.nextTick(lazyLoad);
        }
      }
    },
    methods: {
      setCurrent: function(id, e) {
        var nav, target, _ref;
        App.$set('current', __indexOf.call(hashList(), id) >= 0 ? id : false);
        _ref = [document.getElementById('nav'), document.getElementById('feed-' + id)], nav = _ref[0], target = _ref[1];
        return nav.scrollLeft = id === false ? 0 : (target.offsetLeft + target.offsetWidth / 2) - (nav.offsetLeft + nav.offsetWidth / 2);
      },
      prev: function() {
        return App.setCurrent((App.current ? document.getElementById('feed-' + App.current).previousElementSibling : document.querySelector('.nav-tab:last-child')).getAttribute('id').replace('feed-', ''));
      },
      next: function() {
        return App.setCurrent((document.getElementById('feed-' + App.current).nextElementSibling || document.querySelector('.nav-tab')).getAttribute('id').replace('feed-', ''));
      },
      toggleFeed: function(id) {
        return hashToggle(id);
      }
    },
    filters: {
      datetime: function(date) {
        return [date.getFullYear(), date.getMonth() + 1, date.getDate()].join('-') + ' ' + [date.getHours(), date.getMinutes(), date.getSeconds()].join(':');
      },
      day: function(date) {
        return date.getMonth() + 1 + '/' + date.getDate();
      },
      feedsOn: function(feeds) {
        return feeds.filter(function(f) {
          var _ref;
          return _ref = f.id, __indexOf.call(hashList(), _ref) >= 0;
        });
      },
      matchFeed: function(items, value) {
        return items.filter(function(a) {
          return value === false || value === a.feed;
        });
      }
    },
    ready: function() {
      window.addEventListener('scroll', function() {
        return requestAnimFrame(lazyLoad);
      });
      window.addEventListener('keydown', function(e) {
        switch (e.which) {
          case 27:
            e.preventDefault();
            return App.$set('settings', !App.settings);
          case 37:
            e.preventDefault();
            return App.prev();
          case 39:
            e.preventDefault();
            return App.next();
        }
      });
      return SLEEP = timeout(3000, function() {
        return App.$set('sleep', true);
      });
    }
  });

  update = function() {
    var feed, id, item, _i, _len, _ref, _ref1;
    if (!hashList().length) {
      hashLoad((function() {
        var _i, _len, _ref, _results;
        _ref = App.feeds;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          feed = _ref[_i];
          if (feed.status === '1') {
            _results.push(feed.id);
          }
        }
        return _results;
      })());
    }
    localStorage['hash'] = window.location.hash.substring(1);
    _ref = hashList();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      id = _ref[_i];
      if (__indexOf.call((function() {
        var _j, _len1, _ref1, _results;
        _ref1 = App.items;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          item = _ref1[_j];
          if (item.feed) {
            _results.push(item.feed);
          }
        }
        return _results;
      })(), id) < 0) {
        loadFeed(id);
      }
    }
    App.items = App.items.filter(function(item) {
      var _ref1;
      return _ref1 = item.feed, __indexOf.call(hashList(), _ref1) >= 0;
    });
    if (_ref1 = App.current, __indexOf.call(hashList(), _ref1) < 0) {
      App.$set('current', false);
    }
    return App.$set('hashlist', hashList());
  };

  loadFeed = function(id) {
    var feed;
    feed = App.feeds.filter(function(f) {
      return f.id === id;
    }).pop();
    if (feed == null) {
      return;
    }
    return Vue.http.jsonp('http://aboardio.herokuapp.com/?num=100&q=' + feed.feed).then(function(res) {
      var images, item, items, _i, _len;
      items = (function() {
        var _i, _len, _ref, _results;
        _ref = res.data.responseData.feed.entries;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          _results.push({
            feed: feed.id,
            source: feed.domain,
            title: item.title,
            author: item.author,
            date: new Date(item.publishedDate),
            url: item.link,
            image: (images = item.content.match(/<img[^<>]+src=[\"\']([^\"\']+)[\"\'][^<>]*>/)) ? images[1].replace(/\&amp;/g, '&') : false
          });
        }
        return _results;
      })();
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        if (item.image) {
          App.items.push(item);
        }
      }
      clearTimeout(SLEEP);
      return App.loaded.push(id);
    }, function(res) {
      return hashRemove(id);
    });
  };

  loadFeeds = function(callback, cache) {
    if (cache == null) {
      cache = true;
    }
    if (localStorage['feeds'] && cache) {
      return callback(JSON.parse(localStorage['feeds']));
    } else {
      return Vue.http.jsonp('http://spreadsheets.google.com/feeds/list/1QgkAchwwtS8IH9GPBD-LPLY41_okXHGHw7UTFGa-a18/od6/public/basic?alt=json-in-script').then(function(res) {
        var feed, feeds;
        feeds = ((function() {
          var _i, _len, _ref, _results;
          _ref = res.data.feed.entry;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            feed = _ref[_i];
            _results.push(JSON.parse('{"id":"' + feed.title['$t'] + '", ' + (feed.content['$t'].replace(/([a-z]+)[\s]*\:[\s]*([^,]+)/g, '"$1":"$2"')) + '}'));
          }
          return _results;
        })()).filter(function(feed) {
          return feed.online !== "0";
        });
        localStorage['feeds'] = JSON.stringify(feeds);
        return callback(feeds);
      });
    }
  };

  if (App instanceof Vue) {
    (function() {
      document.body.removeChild(document.getElementById('no-js'));
      document.getElementById('app').style.display = 'block';
      return loadFeeds(function(feeds) {
        App.feeds = feeds;
        hashLoad(hashList());
        update();
        return window.addEventListener('hashchange', update);
      });
    })();
  }

}).call(this);
