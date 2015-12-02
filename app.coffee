### TODO convert XML to JSON
https://davidwalsh.name/convert-xml-json
https://developer.mozilla.org/fr/docs/JXON
http://goessner.net/download/prj/jsonxml/
https://github.com/metatribal/xmlToJSON
###

board = document.querySelector '.board'

# Hash manipulation
hashList = -> id for id in window.location.hash.substring( 1 ).split '-' when id
hashToggle = ( id ) -> if id in hashList() then hashRemove id else hashAppend id
hashRemove = ( id ) -> window.location.hash = hashList().filter( ( a ) -> a isnt id ).join '-'
hashAppend = ( id ) -> window.location.hash = hashList().concat( id ).sort( ( a, b ) -> parseInt( a, 16 ) - parseInt( b, 16 ) ).join '-' if id not in hashList()
hashLoad = ( ids ) -> window.location.hash = ids.sort( ( a, b ) -> parseInt( a, 16 ) - parseInt( b, 16 ) ).join '-'
window.location.hash = localStorage['hash'] if localStorage['hash']? and not hashList().length




# Progress bar
do ->
  bar = document.createElement 'div'
  bar.className = 'progress'
  document.body.appendChild bar

  window.progress =
    speed: 500
    start: -> @go 0.01
    done: -> @go 1
    val: -> 0.01*parseInt bar.style.width or 0
    cancel: ( delay = 0 ) ->
      setTimeout ( -> bar.style.opacity = 0 ), delay+300
      setTimeout ( -> bar.style.width = 0 ), delay+300+@speed
    go: ( x, speed = false ) ->
      @speed = speed if speed isnt false
      bar.style.webKitTransition = bar.style.transition = 'opacity .3s, width '+@speed/1000+'s'
      bar.style.opacity = 1
      x = Math.min( 1, Math.max( 0, x ) )
      bar.style.width = x*100+'%'
      progress.cancel progress.speed if x is 1




# Angular app & filters
app = angular.module 'aboard', []
app.filter 'mature', -> ( tags ) -> if 'mature' in tags.split ' ' then '*' else ''
app.filter 'hashList', -> ( feeds ) -> feed for feed in feeds when feed.id in hashList()
app.filter 'inHashList', -> ( id ) -> id in hashList()




# Main controller
paginate = 5
app.controller 'main', ['$scope', '$http', '$compile', ( $scope, $http, $compile ) ->
  [$scope.feeds, $scope.items, $scope.total, $scope.loading, $scope.current, $scope.fit, $scope.limit] = [[], [], false, 0, 0, paginate-1, false]

  http = $http.jsonp 'http://spreadsheets.google.com/feeds/list/1QgkAchwwtS8IH9GPBD-LPLY41_okXHGHw7UTFGa-a18/od6/public/basic?alt=json-in-script&callback=JSON_CALLBACK'
  http.success ( data ) ->
    $scope.feeds = ( JSON.parse '{"id":"'+feed.title['$t']+'", '+(feed.content['$t'].replace /([a-z]+)[\s]*\:[\s]*([^,]+)/g, '"$1":"$2"')+'}' for feed in data.feed.entry ).filter ( feed ) -> feed.online isnt "0"
    if hashList().length then do $scope.loadItems else hashLoad ( feed.id for feed in $scope.feeds when feed.status is "1" )

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
        image: if images = ( item.content.match /<img[^<>]+src=[\"\']([^\"\']+)[\"\'][^<>]*>/ ) then images[1].replace /\&amp;/g, '&' else false
      } for item in data.responseData.feed.entries
      $scope.items = $scope.items.filter ( item ) -> item.image
      $scope.setCurrent $scope.current
      $scope.loading--
      progress.go 1-$scope.loading/$scope.total
      if not $scope.loading
        $scope.limit = $scope.fit
        do $scope.fill

  $scope.loadItems = ->
    do progress.start
    $scope.items = $scope.items.filter ( item ) -> item.feed in hashList()
    $scope.loading = hashList().filter( ( feed ) ->  feed not in ( item.feed for item in $scope.items ) ).length
    $scope.total = $scope.loading
    $scope.loadFeed id for id in hashList() when id not in ( item.feed for item in $scope.items )
    do $scope.$apply if not $scope.$$phase

  $scope.resetCurrent = -> $scope.setCurrent false
  $scope.setCurrent = ( id ) ->
    [$scope.current, document.body.scrollTop, item, list] = [id, 0, document.querySelector('#feed-'+id), document.querySelector('.nav-feeds')]
    list.scrollLeft = item.offsetLeft - list.offsetLeft - list.offsetWidth/2 + item.offsetWidth/2 if item
    $scope.limit = $scope.fit if not $scope.loading
    do $scope.$apply if not $scope.$$phase

  # Paginate
  $scope.more = ->
    $scope.limit += paginate
    do $scope.$apply if not $scope.$$phase
  $scope.fill = ->
    do $scope.more
    if board.clientHeight <= window.innerHeight*1.1 then setTimeout arguments.callee, 10 else $scope.fit = $scope.limit
  window.addEventListener 'scroll', -> do $scope.more if document.body.scrollTop > document.body.scrollHeight - window.innerHeight*1.2 and $scope.limit < $scope.items.length


  # Hashchance
  window.addEventListener 'hashchange', ->
    localStorage['hash'] = window.location.hash.substring 1
    do $scope.loadItems

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
  [logo, wave, boat] = ( document.getElementById id for id in ['logo', 'wave', 'boat'] )
  [t, token] = [0, false]
  logo.addEventListener 'mouseout', -> clearInterval token
  logo.addEventListener 'mouseover', ->
    [speed, shift] = [1000/24, 4]
    token = setInterval ( ->
      x = shift*Math.sin t*Math.PI*speed/1000/2
      wave.setAttribute 'transform', 'translate(-'+x+')'
      boat.setAttribute 'transform', 'translate('+x+')'
      t++
    ), speed
