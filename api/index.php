<?php
# Initialize
  include 'r76.php';
  include 'helpers.php';

  define('cache',   'cache/');
  define('expire',  3600);
  define('gsheet',  'https://docs.google.com/spreadsheet/pub?key=0AnqTdoRZw_IRdHctX2RyQncwRVA0eWZsSERsdUxOT0E&output=csv');
  define('db',      cache.'db.json');
  define('pass',    'efc9fa3dd9dd2e513af2603cf0452cdcad9c97a8');

# Update feeds
  get('/update', function() {
    if (sha1(get('pass')) != pass) go(url('../'));
    array_map('unlink', glob(cache.'*'));
    file_put_contents(db, json_encode(csvToArray(gsheet)), LOCK_EX);
    go(url('../'));
  });

# Count nav clicks
  get('/nav', function() { file_put_contents('count.txt', file_get_contents('count.txt').date('Y-m-d H:i:s').' — '.$_SERVER['REMOTE_ADDR']."\n", LOCK_EX); });

# Get feeds
  get('/feeds', function() {
    header('Content-Type:application/javascript;Charset:UTF-8');
    cache(function() {
      $feeds = array_values(array_filter(json_decode(file_get_contents(db), true), function($a) { return $a['online']; }));
      echo $_GET['callback'],'(',json_encode($feeds),');';
    }, cache, expire);
  });

# Get feed items
  get('/feed/@id', function() {
    header('Content-Type:application/javascript;Charset:UTF-8');
    cache(function() {
      $feeds = json_decode(file_get_contents(db), true);
      $feeds = array_combine(array_map('array_shift', $feeds), $feeds);
      if (!($feed = $feeds[(string)uri('id')]) OR !$feed['online']) { header('HTTP/1.0 400 Bad Request', true, 400); exit('Invalid ID'); }
      else echo $_GET['callback'],'(',json_encode(toBoard($feed)),');';
    }, cache, expire);
  });

# Get feeds if no cache, then run
  if (!is_file(db)) file_put_contents(db, json_encode(csvToArray(gsheet)), LOCK_EX);
  run(function() { header('HTTP/1.0 404 Not Found', true, 404); exit('404 Error'); }); 