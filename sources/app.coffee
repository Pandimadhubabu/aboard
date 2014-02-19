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
window.addEventListener 'hashchange', -> localStorage['hash'] = window.location.hash.substring 1
window.location.hash = localStorage['hash'] if localStorage['hash']?




# Angular app initialize
app = angular.module 'aboard', []
app.filter 'mature', -> ( tags ) -> if 'mature' in tags.split ' ' then '*' else ''


# Main controller
app.controller 'main', ['$scope', '$http', '$compile', ( $scope, $http, $compile ) ->
  $scope.feeds = []
  $scope.items = []
  $scope.current = false

  http = $http.jsonp 'http://spreadsheets.google.com/feeds/list/0AnqTdoRZw_IRdHctX2RyQncwRVA0eWZsSERsdUxOT0E/od6/public/basic?alt=json-in-script&callback=JSON_CALLBACK'
  http.success ( data ) ->
    feeds = ( JSON.parse '{"id":"'+feed.title['$t']+'", '+(feed.content['$t'].replace /([a-z]+)[\s]*\:[\s]*([^,]+)/g, '"$1":"$2"')+'}' for feed in data.feed.entry )
    # console.log feeds
    if window.location.hash.substring 1
      feed.status = feed.id in hashList() for feed in feeds
    else
      for feed in feeds
        continue if not feed?
        feed.status = if feed.status is "1" then true else false
        hashAppend feed.id if feed.status
    $scope.feeds = feeds
    $scope.loadItems id for id in hashList()

  $scope.loadItems = ( id, current = false ) ->
    feed = item for item in $scope.feeds when item.id is id
    http = $http.jsonp 'https://ajax.googleapis.com/ajax/services/feed/load?v=2.0&callback=JSON_CALLBACK&num=100&q='+( encodeURIComponent feed.feed )
    http.error -> hashRemove feed.id
    http.success ( data ) ->
      ( $scope.items.push {
        feed: feed.id
        source: feed.url.replace /^http(s)\:\/\/(.+)\/*$/, '$1'
        title: item.title
        author: item.author
        date: new Date item.publishedDate
        url: item.link
        image: ( item.content.match /<img[^<>]+src=[\"\']([^\"\']+)[\"\'][^<>]*>/ )[1]
      } for item in data.responseData.feed.entries )
      do updateImages
      $scope.setCurrent id if current

  $scope.removeItems = ( id ) ->
    $scope.items = $scope.items.filter ( item ) -> item.feed isnt id
    do $scope.resetCurrent

  $scope.resetCurrent = -> $scope.setCurrent false
  $scope.setCurrent = ( id ) ->
    if $scope.current = id
      [item, list] = [document.querySelector('#feed-'+id), document.querySelector('.nav-feeds')]
      list.scrollLeft = item.offsetLeft - list.offsetLeft - list.offsetWidth/2 + item.offsetWidth/2
    board.scrollTop = 0
    do updateImages
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
    $scope.feed.status = not $scope.feed.status
    hashToggle $scope.feed.id
    if $scope.feed.status then $scope.loadItems $scope.feed.id, true else $scope.removeItems $scope.feed.id
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