var app,board,hashAppend,hashList,hashLoad,hashRemove,hashToggle,paginate,__indexOf=[].indexOf||function(c){for(var b=0,a=this.length;b<a;b++){if(b in this&&this[b]===c){return b}}return -1};board=document.querySelector(".board");hashList=function(){var e,d,b,c,a;c=window.location.hash.substring(1).split("-");a=[];for(d=0,b=c.length;d<b;d++){e=c[d];if(e){a.push(e)}}return a};hashToggle=function(a){if(__indexOf.call(hashList(),a)>=0){return hashRemove(a)}else{return hashAppend(a)}};hashRemove=function(a){return window.location.hash=hashList().filter(function(b){return b!==a}).join("-")};hashAppend=function(a){if(__indexOf.call(hashList(),a)<0){return window.location.hash=hashList().concat(a).sort(function(d,c){return parseInt(d,16)-parseInt(c,16)}).join("-")}};hashLoad=function(a){return window.location.hash=a.sort(function(d,c){return parseInt(d,16)-parseInt(c,16)}).join("-")};if((localStorage.hash!=null)&&!hashList().length){window.location.hash=localStorage.hash}(function(){var a;a=document.createElement("div");a.className="progress";document.body.appendChild(a);return window.progress={speed:500,start:function(){return this.go(0.01)},done:function(){return this.go(1)},val:function(){return 0.01*parseInt(a.style.width||0)},cancel:function(b){if(b==null){b=0}setTimeout((function(){return a.style.opacity=0}),b+300);return setTimeout((function(){return a.style.width=0}),b+300+this.speed)},go:function(b,c){if(c==null){c=false}if(c!==false){this.speed=c}a.style.webKitTransition=a.style.transition="opacity .3s, width "+this.speed/1000+"s";a.style.opacity=1;b=Math.min(1,Math.max(0,b));a.style.width=b*100+"%";if(b===1){return progress.cancel(progress.speed)}}}})();app=angular.module("aboard",[]);app.filter("mature",function(){return function(a){if(__indexOf.call(a.split(" "),"mature")>=0){return"*"}else{return""}}});app.filter("hashList",function(){return function(a){var f,e,c,d,b;b=[];for(e=0,c=a.length;e<c;e++){f=a[e];if(d=f.id,__indexOf.call(hashList(),d)>=0){b.push(f)}}return b}});app.filter("inHashList",function(){return function(a){return __indexOf.call(hashList(),a)>=0}});paginate=5;app.controller("main",["$scope","$http","$compile",function(a,e,c){var b,d;d=[[],[],false,0,0,paginate-1,false],a.feeds=d[0],a.items=d[1],a.total=d[2],a.loading=d[3],a.current=d[4],a.fit=d[5],a.limit=d[6];b=e.jsonp("http://spreadsheets.google.com/feeds/list/1QgkAchwwtS8IH9GPBD-LPLY41_okXHGHw7UTFGa-a18/od6/public/basic?alt=json-in-script&callback=JSON_CALLBACK");b.success(function(g){var f;a.feeds=((function(){var k,j,h,i;h=g.feed.entry;i=[];for(k=0,j=h.length;k<j;k++){f=h[k];i.push(JSON.parse('{"id":"'+f.title["$t"]+'", '+(f.content["$t"].replace(/([a-z]+)[\s]*\:[\s]*([^,]+)/g,'"$1":"$2"'))+"}"))}return i})()).filter(function(h){return h.online!=="0"});a.feeds=((function(){var k,j,h,i;h=g.feed.entry;i=[];for(k=0,j=h.length;k<j;k++){f=h[k];i.push(JSON.parse('{"id":"'+f.title["$t"]+'", '+(f.content["$t"].replace(/([a-z]+)[\s]*\:[\s]*([^,]+)/g,'"$1":"$2"'))+"}"))}return i})()).filter(function(h){return h.online!=="0"});if(hashList().length){return a.loadItems()}else{return hashLoad((function(){var k,j,h,i;h=a.feeds;i=[];for(k=0,j=h.length;k<j;k++){f=h[k];if(f.status==="1"){i.push(f.id)}}return i})())}});a.loadFeed=function(h){var g,f;g=((function(){var l,k,i,j;i=a.feeds;j=[];for(l=0,k=i.length;l<k;l++){f=i[l];if(f.id===h){j.push(f)}}return j})()).pop();b=e.jsonp("https://ajax.googleapis.com/ajax/services/feed/load?v=2.0&callback=JSON_CALLBACK&num=100&q="+(encodeURIComponent(g.feed)));b.error(function(){return hashRemove(g.id)});return b.success(function(m){var j,l,k,i;i=m.responseData.feed.entries;for(l=0,k=i.length;l<k;l++){f=i[l];a.items.push({feed:g.id,source:g.url.replace(/^http(?:s)?\:\/\/([^\/]+)\/*$/,"$1"),title:f.title,author:f.author,date:new Date(f.publishedDate),url:f.link,image:(j=f.content.match(/<img[^<>]+src=[\"\']([^\"\']+)[\"\'][^<>]*>/))?j[1].replace(/\&amp;/g,"&"):false})}a.items=a.items.filter(function(n){return n.image});a.setCurrent(a.current);a.loading--;progress.go(1-a.loading/a.total);if(!a.loading){a.limit=a.fit;return a.fill()}})};a.loadItems=function(){var j,h,i,g,f;progress.start();a.items=a.items.filter(function(l){var k;return k=l.feed,__indexOf.call(hashList(),k)>=0});a.loading=hashList().filter(function(l){var k;return __indexOf.call((function(){var p,o,m,n;m=a.items;n=[];for(p=0,o=m.length;p<o;p++){k=m[p];n.push(k.feed)}return n})(),l)<0}).length;a.total=a.loading;f=hashList();for(i=0,g=f.length;i<g;i++){j=f[i];if(__indexOf.call((function(){var m,l,n,k;n=a.items;k=[];for(m=0,l=n.length;m<l;m++){h=n[m];k.push(h.feed)}return k})(),j)<0){a.loadFeed(j)}}if(!a.$$phase){return a.$apply()}};a.resetCurrent=function(){return a.setCurrent(false)};a.setCurrent=function(i){var g,h,f;f=[i,0,document.querySelector("#feed-"+i),document.querySelector(".nav-feeds")],a.current=f[0],document.body.scrollTop=f[1],g=f[2],h=f[3];if(g){h.scrollLeft=g.offsetLeft-h.offsetLeft-h.offsetWidth/2+g.offsetWidth/2}if(!a.loading){a.limit=a.fit}if(!a.$$phase){return a.$apply()}};a.more=function(){a.limit+=paginate;if(!a.$$phase){return a.$apply()}};a.fill=function(){a.more();if(board.clientHeight<=window.innerHeight*1.1){return setTimeout(arguments.callee,10)}else{return a.fit=a.limit}};window.addEventListener("scroll",function(){if(document.body.scrollTop>document.body.scrollHeight-window.innerHeight*1.2&&a.limit<a.items.length){return a.more()}});window.addEventListener("hashchange",function(){localStorage.hash=window.location.hash.substring(1);return a.loadItems()});return window.addEventListener("keydown",function(g){var f;switch(g.which){case 37:f=a.current?document.querySelector("#feed-"+a.current).previousSibling:document.querySelector(".nav-feed:last-child");break;case 39:f=a.current?document.querySelector("#feed-"+a.current).nextSibling:document.querySelector(".nav-feed:first-child")}if(f){if(f.getAttribute){return a.setCurrent(f.getAttribute("id").replace("feed-",""))}else{return a.resetCurrent()}}})}]);app.controller("feed",["$scope","$http",function(a,b){a.showItems=function(){return a.setCurrent(a.feed.id)};return a.toggleFeed=function(){var c;hashToggle(a.feed.id);return a.setCurrent((c=a.feed.id,__indexOf.call(hashList(),c)>=0)?a.feed.id:false)}}]);(function(){var h,g,f,c,b,d,e,a;e=(function(){var l,j,k,i;k=["logo","wave","boat"];i=[];for(l=0,j=k.length;l<j;l++){g=k[l];i.push(document.getElementById(g))}return i})(),f=e[0],d=e[1],h=e[2];a=[0,false],c=a[0],b=a[1];f.addEventListener("mouseout",function(){return clearInterval(b)});return f.addEventListener("mouseover",function(){var i,j,k;k=[1000/24,4],j=k[0],i=k[1];return b=setInterval((function(){var l;l=i*Math.sin(c*Math.PI*j/1000/2);d.setAttribute("transform","translate(-"+l+")");h.setAttribute("transform","translate("+l+")");return c++}),j)})})();
