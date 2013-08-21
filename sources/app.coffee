# Prevent off-screen image to load
updateImages = ->
  setTimeout ( ->
    for image in [].slice.call document.getElementsByClassName( 'js-img' ), 0
      if image.getBoundingClientRect().top < window.innerHeight*2
        image.style.backgroundImage = 'url('+image.dataset.src+')' if image.style.backgroundImage == ''
  ), 0
window.addEventListener 'scroll', updateImages
window.addEventListener 'resize', updateImages




# Hash manipulation
hashList = -> id for id in window.location.hash.substring( 1 ).split '-' when id
hashToggle = ( id ) -> if id in hashList() then hashRemove id else hashAppend id
hashRemove = ( id ) -> window.location.hash = hashList().filter( ( a ) -> a isnt id ).join '-'
hashAppend = ( id ) -> window.location.hash = hashList().concat( id ).sort( ( a, b ) -> parseInt( a, 16 ) - parseInt( b, 16 ) ).join '-' if id not in hashList()
window.addEventListener 'hashchange', -> localStorage['hash'] = window.location.hash.substring 1
window.location.hash = localStorage['hash'] if localStorage['hash']




# Angular app initialize
app = angular.module 'aboard', []
app.filter 'mature', -> ( tags ) -> if 'mature' in tags.split ' ' then '*' else ''


# Main controller
app.controller 'main', ( $scope, $http, $compile ) ->
  $scope.feeds = []
  $scope.items = []
  $scope.current = ''
  
  http = $http.jsonp 'api/feeds?callback=JSON_CALLBACK'
  http.success ( feeds ) -> 
    if window.location.hash.substring 1
      feed.status = feed.id in hashList() for feed in feeds
    else
      for feed in feeds
        feed.status = if feed.status is "1" then true else false
        hashAppend feed.id if feed.status
    $scope.loadItems id for id in hashList()
    $scope.feeds = feeds
    
  $scope.showItems = ( id = '' ) -> 
    ( feed.current = feed.id is id ) for feed in $scope.feeds
    $scope.current = id
    do updateImages
    window.scrollTo 0
  
  $scope.toggleEdit = ->
    $scope.edit = not $scope.edit
    do $scope.showItems if not $scope.edit
    
  $scope.loadItems = ( id, callback = false ) ->
    http = $http.jsonp 'api/feed/'+id+'/?callback=JSON_CALLBACK'
    http.error -> hashRemove id
    http.success ( items ) ->
      ( $scope.items.push item for item in items )
      do updateImages
      do callback if callback
      
  $scope.removeItems = ( id ) ->
    $scope.items = $scope.items.filter ( item ) -> item.feed isnt id
    do $scope.showItems
    
 
# Feed controller
app.controller 'feed', ( $scope, $http ) ->
  $scope.toggleFeed = ->
    $scope.feed.status = not $scope.feed.status
    hashToggle $scope.feed.id
    if $scope.feed.status then $scope.loadItems $scope.feed.id, $scope.toggleItems else $scope.removeItems $scope.feed.id
      
  $scope.toggleItems = -> $scope.showItems $scope.feed.id
  



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