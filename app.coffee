# Prevent off-screen image to load
board = document.querySelector '.board'
updateImages = ->
  setTimeout ( ->
    for image in [].slice.call document.getElementsByClassName( 'js-img' ), 0
      if image.getBoundingClientRect().top < window.innerHeight*2
        image.style.backgroundImage = 'url('+image.dataset.src+')' if not image.style.backgroundImage
  ), 0
board.addEventListener 'scroll', updateImages
board.addEventListener 'touchmove', updateImages
window.addEventListener 'resize', updateImages




# Hash manipulation
hashList = -> id for id in window.location.hash.substring( 1 ).split '-' when id
hashToggle = ( id ) -> if id in hashList() then hashRemove id else hashAppend id
hashRemove = ( id ) -> window.location.hash = hashList().filter( ( a ) -> a isnt id ).join '-'
hashAppend = ( id ) -> window.location.hash = hashList().concat( id ).sort( ( a, b ) -> parseInt( a, 16 ) - parseInt( b, 16 ) ).join '-' if id not in hashList()
window.location.hash = localStorage['hash'] if localStorage['hash']? and not hashList().length




# Angular app & filters
app = angular.module 'aboard', []
app.filter 'mature', -> ( tags ) -> if 'mature' in tags.split ' ' then '*' else ''
app.filter 'hashList', -> ( feeds ) -> feed for feed in feeds when feed.id in hashList()
app.filter 'inHashList', -> ( id ) -> id in hashList()


# Main controller
app.controller 'main', ['$scope', '$http', '$compile', ( $scope, $http, $compile ) ->
  $scope.feeds = []
  $scope.items = []
  $scope.current = false

  http = $http.jsonp 'http://spreadsheets.google.com/feeds/list/0AnqTdoRZw_IRdHctX2RyQncwRVA0eWZsSERsdUxOT0E/od6/public/basic?alt=json-in-script&callback=JSON_CALLBACK'
  http.success ( data ) ->
    feeds = ( JSON.parse '{"id":"'+feed.title['$t']+'", '+(feed.content['$t'].replace /([a-z]+)[\s]*\:[\s]*([^,]+)/g, '"$1":"$2"')+'}' for feed in data.feed.entry )
    feeds = ( feed for feed in feeds when feed.online isnt "0" )
    if not hashList().length
      hashAppend feed.id for feed in feeds when feed.status is "1"
    $scope.feeds = feeds
    do $scope.loadItems

  $scope.loadFeed = ( id ) ->
    feed = ( item for item in $scope.feeds when item.id is id ).pop()
    http = $http.jsonp 'https://ajax.googleapis.com/ajax/services/feed/load?v=2.0&callback=JSON_CALLBACK&num=100&q='+( encodeURIComponent feed.feed )
    http.error -> hashRemove feed.id
    http.success ( data ) ->
      $scope.items.push {
        feed: feed.id
        source: feed.url.replace /^http(?:s)?\:\/\/([^\/]+)\/*$/, '$1'
        title: item.title
        author: item.author
        date: new Date item.publishedDate
        url: item.link
        image: if images = ( item.content.match /<img[^<>]+src=[\"\']([^\"\']+)[\"\'][^<>]*>/ ) then images[1] else false
      } for item in data.responseData.feed.entries
      $scope.items = $scope.items.filter ( item ) -> item.image
      $scope.setCurrent $scope.current

  $scope.loadItems = ->
    $scope.items = $scope.items.filter ( item ) -> item.feed in hashList()
    $scope.loadFeed id for id in hashList() when id not in ( item.feed for item in $scope.items )
    do $scope.$apply if not $scope.$$phase

  $scope.resetCurrent = -> $scope.setCurrent false
  $scope.setCurrent = ( id ) ->
    $scope.current = id
    [item, list] = [document.querySelector('#feed-'+id), document.querySelector('.nav-feeds')]
    list.scrollLeft = item.offsetLeft - list.offsetLeft - list.offsetWidth/2 + item.offsetWidth/2 if item
    board.scrollTop = 0
    do updateImages
    do $scope.$apply if not $scope.$$phase

  $scope.setCallback = ( fn ) -> $scope.callback = fn
  window.addEventListener 'hashchange', ->
    localStorage['hash'] = window.location.hash.substring 1
    do $scope.loadItems
    do $scope.$apply if not $scope.$$phase

  # Keyboard navigation
  window.addEventListener 'keydown', (e) ->
    switch e.which
      when 37 then ( target = if $scope.current then document.querySelector('#feed-'+$scope.current).previousSibling else document.querySelector('.nav-feed:last-child') )
      when 39 then ( target = if $scope.current then document.querySelector('#feed-'+$scope.current).nextSibling else document.querySelector('.nav-feed:first-child') )
    ( if target.getAttribute then $scope.setCurrent target.getAttribute('id').replace('feed-', '') else do $scope.resetCurrent ) if target
]


# Feed controller
app.controller 'feed', ['$scope', '$http', ( $scope, $http ) ->
  $scope.showItems = -> $scope.setCurrent $scope.feed.id
  $scope.toggleFeed = ->
    hashToggle $scope.feed.id
    $scope.setCurrent if $scope.feed.id in hashList() then $scope.feed.id else false
]



# Logo animation
do ->
  logo = document.getElementById 'logo'
  wave = document.getElementById 'wave'
  boat = document.getElementById 'boat'
  t = 0
  token = false

  logo.addEventListener 'mouseout', -> clearInterval token
  logo.addEventListener 'mouseover', ->
    speed = 1000/24
    shift = 4
    token = setInterval ( ->
      x = shift*Math.sin t*Math.PI*speed/1000/2
      wave.setAttribute 'transform', 'translate(-'+x+')'
      boat.setAttribute 'transform', 'translate('+x+')'
      t++
    ), speed