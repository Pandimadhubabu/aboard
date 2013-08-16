<?php
# Initialize
  include 'helpers.php';
  $api = include 'r76.php';
  
  define('cache',   'cache/');
  define('expire',  3600);
  define('gsheet',  'https://docs.google.com/spreadsheet/pub?key=0AnqTdoRZw_IRdHctX2RyQncwRVA0eWZsSERsdUxOT0E&output=csv');
  define('db',      cache.'db.json');
  define('pass',    'efc9fa3dd9dd2e513af2603cf0452cdcad9c97a8');

# Update feeds
  $api->get('/update', function() {
    if (sha1(param('pass')) != pass) go(url('../'));
    array_map('unlink', glob(cache.'*'));
    file_put_contents(db, json_encode(csvToArray(gsheet)), LOCK_EX);
    go(url('../'));
  });

# Get feeds
  $api->get('/feeds', function() {
    header('Content-Type:application/javascript;Charset:UTF-8');
    cache(function() {
      $feeds = array_values(array_filter(json_decode(file_get_contents(db), true), function($a) { return $a['online']; }));
      echo param('callback'),'(',json_encode($feeds),');';
    }, cache, expire);
  });

# Get feed items
  $api->get('/feed/@id', function() {
    header('Content-Type:application/javascript;Charset:UTF-8');
    cache(function() {
      $feeds = json_decode(file_get_contents(db), true);
      $feeds = array_combine(array_map('array_shift', $feeds), $feeds);
      if (!($feed = $feeds[(string)path('id')]) OR !$feed['online']) { header('HTTP/1.0 400 Bad Request', true, 400); exit('Invalid ID'); }
      else echo param('callback'),'(',json_encode(toBoard($feed)),');';
    }, cache, expire);
  });

# Get feeds if no cache, then run
  if (!is_file(db)) file_put_contents(db, json_encode(csvToArray(gsheet)), LOCK_EX);
  $api->run(function() { header('HTTP/1.0 404 Not Found', true, 404); exit('404 Error'); }); 