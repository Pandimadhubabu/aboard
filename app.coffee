# Thanks Paul Irish: http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/
window.requestAnimFrame = do -> window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or ( callback ) -> window.setTimeout callback, 1000/60
timeout = (d, c) -> setTimeout c, d



# Hash manipulation
hashList = -> id for id in window.location.hash.substring( 1 ).split '-' when id
hashToggle = ( id ) -> if id in hashList() then hashRemove id else hashAppend id
hashRemove = ( id ) -> window.location.hash = hashList().filter( ( a ) -> a isnt id ).join '-'
hashAppend = ( id ) -> window.location.hash = hashList().concat( id ).sort( ( a, b ) -> parseInt( a, 16 ) - parseInt( b, 16 ) ).join '-' if id not in hashList()
hashLoad = ( ids ) -> window.location.hash = ids.sort( ( a, b ) -> parseInt( a, 16 ) - parseInt( b, 16 ) ).join '-'
window.location.hash = localStorage['hash'] if localStorage['hash']? and not hashList().length



# Lazy loading images
lazyLoad = ->
  for item in document.querySelectorAll('[data-src]') when item.getBoundingClientRect().top < window.innerHeight*1.1
    if item.tagName is 'IMG' then item.src = item.dataset.src else item.style.backgroundImage = 'url('+item.dataset.src+')'
    delete item.dataset.src



# App
App = new Vue
  el: '#app'
  data: feeds: [], items: [], loaded: [], settings: false, current: false
  watch:
    'hashlist': -> App.feeds.reverse().reverse() # force DOM update
    'items': -> Vue.nextTick lazyLoad
    'current': ->
      Vue.nextTick lazyLoad
      if not App.settings then window.scrollTo 0, document.body.scrollTop + (document.getElementById('board').getBoundingClientRect().top - 70) # skip header
    'settings': ->
      window.scrollTo 0, 0
      if App.settings is true then Vue.nextTick ->
        loadFeeds ((feeds) -> App.feeds = feeds), false
        document.getElementById('search').focus()
      else Vue.nextTick lazyLoad
  methods:
    setCurrent: (id, e) ->
      App.$set 'current', if id in hashList() then id else false
      [nav, target] = [document.getElementById('nav'), document.getElementById('feed-'+id)]
      nav.scrollLeft = if id is false then 0 else (target.offsetLeft+target.offsetWidth/2) - (nav.offsetLeft+nav.offsetWidth/2) # center tab
    prev: -> App.setCurrent ( if App.current then document.getElementById('feed-'+App.current).previousElementSibling else document.querySelector('.nav-tab:last-child') ).getAttribute('id').replace('feed-', '')
    next: -> App.setCurrent ( document.getElementById('feed-'+App.current).nextElementSibling or document.querySelector('.nav-tab') ).getAttribute('id').replace('feed-', '')
    toggleFeed: (id) -> hashToggle id
  filters:
    datetime: (date) -> [date.getFullYear(),date.getMonth()+1,date.getDate()].join('-')+' '+[date.getHours(),date.getMinutes(),date.getSeconds()].join(':')
    day: (date) -> date.getMonth()+1+'/'+date.getDate()
    feedsOn: (feeds) -> feeds.filter (f) -> f.id in hashList()
    matchFeed: (items, value) -> items.filter (a) -> value in [false, a.feed]
  ready: ->
    window.addEventListener 'scroll', -> requestAnimFrame lazyLoad
    window.addEventListener 'keydown', (e) -> # keyboard navigation
      switch e.which
        when 27 then do e.preventDefault; App.$set 'settings', not App.settings
        when 37 then do e.preventDefault; do App.prev
        when 39 then do e.preventDefault; do App.next



# Update feeds & items
update = ->
  hashLoad (feed.id for feed in App.feeds when feed.status is '1') if not hashList().length
  localStorage['hash'] = window.location.hash.substring 1
  loadFeed id for id in hashList() when id not in (item.feed for item in App.items when item.feed) # add new items
  App.items = App.items.filter ( item ) -> item.feed in hashList() # remove old items
  App.$set 'current', false if App.current not in hashList()
  App.$set 'hashlist', hashList()



# Load feed items
loading = []
loadFeed = (id) ->
  feed = App.feeds.filter( (f) -> f.id is id ).pop()
  return if not feed? or id in loading
  loading.push id
  Vue.http.get('https://rss2json.com/api.json?rss_url='+encodeURIComponent(feed.feed)).then (res) ->
    items = ({
      feed: feed.id
      source: feed.domain
      title: item.title
      author: item.author
      date: new Date item.pubDate
      url: item.link
      image: if images = ( item.content.match /<img[^<>]+src=[\"\']([^\"\']+)[\"\'][^<>]*>/ ) then images[1].replace /\&amp;/g, '&' else false
    } for item in res.data.items)
    App.items.push item for item in items when item.image
    loading.splice loading.indexOf(id), 1
    App.loaded.push id # display favicon
  , (res) -> hashRemove id



# Load feeds list
loadFeeds = (callback, cache = true) ->
  if localStorage['feeds'] and cache then callback JSON.parse localStorage['feeds']
  else Vue.http.jsonp('https://spreadsheets.google.com/feeds/list/1njVykVGrYQxtBdhIqhtOcGD0yKuccJJN8gnbY3l4Wh8/od6/public/basic?alt=json-in-script').then (res) ->
    feeds = ( JSON.parse '{"id":"'+feed.title['$t']+'", '+(feed.content['$t'].replace /([a-z]+)[\s]*\:[\s]*([^,]+)/g, '"$1":"$2"')+'}' for feed in res.data.feed.entry ).filter ( feed ) -> feed.online isnt "0"
    localStorage['feeds'] = JSON.stringify feeds
    callback feeds



# Init
if App instanceof Vue then do ->
  document.body.removeChild document.getElementById('no-js')
  document.getElementById('app').style.display = 'block'
  loadFeeds (feeds) ->
    App.feeds = feeds
    hashLoad hashList() # sort ids
    do update
    window.addEventListener 'hashchange', update
