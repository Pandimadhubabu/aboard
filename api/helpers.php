<?php
  function csvToArray($file, $delimiter = ',') {
    if (($handle = fopen($file, 'r')) === FALSE) return false;
    while (($lineArr = fgetcsv($handle, 4000, $delimiter, '"')) !== FALSE)
      $keys ? $arr[] = array_combine($keys, (array)$lineArr) : $keys = $lineArr;
    fclose($handle);
    return (array)$arr;
  }
  
  function toBoard($feed) {
    $data = simplexml_load_string(utf8_encode(file_get_contents($feed['feed'])), 'SimpleXMLElement', LIBXML_NOCDATA);
    $output = array();
    foreach ($data->channel->item as $item) {
      $content = $item->children('http://purl.org/rss/1.0/modules/content/');
      if ($content) $item->description = $content->encoded;
      preg_match('/<img.+src=["\'](.+)["\']/U', $item->description, $m);
      if (!$m[1] OR !in_array(strtolower(strrchr($m[1], '.')), array('.jpg', '.jpeg', '.png', '.gif'))) continue;
      $output[] = array(
        'feed'    => (string)$feed['id'],
        'source'  => (string)str_replace('http://', '', trim($feed['url'], '/')),
        'title'   => (string)utf8_decode($item->title),
        'author'  => (string)utf8_decode($item->author),
        'date'    => (string)(strtotime($item->pubDate)*1000),
        'url'     => (string)$item->guid,
        'image'   => (string)$m[1]
      );
    }
    return $output;
  }
  
  function cache($callback, $dir, $expire = false) {
    if ($expire === false) return $callback();
    ob_start();
    $file = $dir.sha1('//'.$_SERVER['HTTP_HOST'].$_SERVER["REQUEST_URI"]);
    if (!is_file($file) OR ($expire > 0 AND (time() - @filemtime($file) >= $expire))) $callback();
    if ($c = ob_get_clean() OR !is_file($file)) file_put_contents($file, $c, LOCK_EX);
    include $file;
    ob_end_flush();
  }