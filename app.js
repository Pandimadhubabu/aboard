var App,hashAppend,hashList,hashLoad,hashRemove,hashToggle,lazyLoad,loadFeed,loadFeeds,loading,timeout,update,__indexOf=[].indexOf||function(e){for(var t=0,n=this.length;n>t;t++)if(t in this&&this[t]===e)return t;return-1};window.requestAnimFrame=function(){return window.requestAnimationFrame||window.webkitRequestAnimationFrame||window.mozRequestAnimationFrame||function(e){return window.setTimeout(e,1e3/60)}}(),timeout=function(e,t){return setTimeout(t,e)},hashList=function(){var e,t,n,r,o;for(r=window.location.hash.substring(1).split("-"),o=[],t=0,n=r.length;n>t;t++)e=r[t],e&&o.push(e);return o},hashToggle=function(e){return __indexOf.call(hashList(),e)>=0?hashRemove(e):hashAppend(e)},hashRemove=function(e){return window.location.hash=hashList().filter(function(t){return t!==e}).join("-")},hashAppend=function(e){return __indexOf.call(hashList(),e)<0?window.location.hash=hashList().concat(e).sort(function(e,t){return parseInt(e,16)-parseInt(t,16)}).join("-"):void 0},hashLoad=function(e){return window.location.hash=e.sort(function(e,t){return parseInt(e,16)-parseInt(t,16)}).join("-")},null==localStorage.hash||hashList().length||(window.location.hash=localStorage.hash),lazyLoad=function(){var e,t,n,r,o;for(r=document.querySelectorAll("[data-src]"),o=[],t=0,n=r.length;n>t;t++)e=r[t],e.getBoundingClientRect().top<1.1*window.innerHeight&&("IMG"===e.tagName?e.src=e.dataset.src:e.style.backgroundImage="url("+e.dataset.src+")",o.push(delete e.dataset.src));return o},App=new Vue({el:"#app",data:{feeds:[],items:[],loaded:[],settings:!1,current:!1},watch:{hashlist:function(){return App.feeds.reverse().reverse()},items:function(){return Vue.nextTick(lazyLoad)},current:function(){return Vue.nextTick(lazyLoad),App.settings?void 0:window.scrollTo(0,document.body.scrollTop+(document.getElementById("board").getBoundingClientRect().top-70))},settings:function(){return window.scrollTo(0,0),App.settings===!0?Vue.nextTick(function(){return loadFeeds(function(e){return App.feeds=e},!1),document.getElementById("search").focus()}):Vue.nextTick(lazyLoad)}},methods:{setCurrent:function(e){var t,n,r;return App.$set("current",__indexOf.call(hashList(),e)>=0?e:!1),r=[document.getElementById("nav"),document.getElementById("feed-"+e)],t=r[0],n=r[1],t.scrollLeft=e===!1?0:n.offsetLeft+n.offsetWidth/2-(t.offsetLeft+t.offsetWidth/2)},prev:function(){return App.setCurrent((App.current?document.getElementById("feed-"+App.current).previousElementSibling:document.querySelector(".nav-tab:last-child")).getAttribute("id").replace("feed-",""))},next:function(){return App.setCurrent((document.getElementById("feed-"+App.current).nextElementSibling||document.querySelector(".nav-tab")).getAttribute("id").replace("feed-",""))},toggleFeed:function(e){return hashToggle(e)}},filters:{datetime:function(e){return[e.getFullYear(),e.getMonth()+1,e.getDate()].join("-")+" "+[e.getHours(),e.getMinutes(),e.getSeconds()].join(":")},day:function(e){return e.getMonth()+1+"/"+e.getDate()},feedsOn:function(e){return e.filter(function(e){var t;return t=e.id,__indexOf.call(hashList(),t)>=0})},matchFeed:function(e,t){return e.filter(function(e){return t===!1||t===e.feed})}},ready:function(){return window.addEventListener("scroll",function(){return requestAnimFrame(lazyLoad)}),window.addEventListener("keydown",function(e){switch(e.which){case 27:return e.preventDefault(),App.$set("settings",!App.settings);case 37:return e.preventDefault(),App.prev();case 39:return e.preventDefault(),App.next()}})}}),update=function(){var e,t,n,r,o,i,a;for(hashList().length||hashLoad(function(){var t,n,r,o;for(r=App.feeds,o=[],t=0,n=r.length;n>t;t++)e=r[t],"1"===e.status&&o.push(e.id);return o}()),localStorage.hash=window.location.hash.substring(1),i=hashList(),r=0,o=i.length;o>r;r++)t=i[r],__indexOf.call(function(){var e,t,r,o;for(r=App.items,o=[],e=0,t=r.length;t>e;e++)n=r[e],n.feed&&o.push(n.feed);return o}(),t)<0&&loadFeed(t);return App.items=App.items.filter(function(e){var t;return t=e.feed,__indexOf.call(hashList(),t)>=0}),a=App.current,__indexOf.call(hashList(),a)<0&&App.$set("current",!1),App.$set("hashlist",hashList())},loading=[],loadFeed=function(e){var t;return t=App.feeds.filter(function(t){return t.id===e}).pop(),null==t||__indexOf.call(loading,e)>=0?void 0:(loading.push(e),Vue.http.get("https://mnrlive.github.io/api/website_data.json?rss_url="+encodeURIComponent(t.feed)).then(function(n){var r,o,i,a,s;for(i=function(){var e,i,a,s;for(a=n.data.items,s=[],e=0,i=a.length;i>e;e++)o=a[e],s.push({feed:t.id,source:t.domain,title:o.title,author:o.author,date:new Date(o.pubDate),url:o.link,image:(r=o.content.match(/<img[^<>]+src=[\"\']([^\"\']+)[\"\'][^<>]*>/))?r[1].replace(/\&amp;/g,"&"):!1});return s}(),a=0,s=i.length;s>a;a++)o=i[a],o.image&&App.items.push(o);return loading.splice(loading.indexOf(e),1),App.loaded.push(e)},function(){return hashRemove(e)}))},loadFeeds=function(e,t){return null==t&&(t=!0),localStorage.feeds&&t?e(JSON.parse(localStorage.feeds)):Vue.http.jsonp("https://spreadsheets.google.com/feeds/list/1njVykVGrYQxtBdhIqhtOcGD0yKuccJJN8gnbY3l4Wh8/od6/public/basic?alt=json-in-script").then(function(t){var n,r;return r=function(){var e,r,o,i;for(o=t.data.feed.entry,i=[],e=0,r=o.length;r>e;e++)n=o[e],i.push(JSON.parse('{"id":"'+n.title.$t+'", '+n.content.$t.replace(/([a-z]+)[\s]*\:[\s]*([^,]+)/g,'"$1":"$2"')+"}"));return i}().filter(function(e){return"0"!==e.online}),localStorage.feeds=JSON.stringify(r),e(r)})},App instanceof Vue&&!function(){return document.body.removeChild(document.getElementById("no-js")),document.getElementById("app").style.display="block",loadFeeds(function(e){return App.feeds=e,hashLoad(hashList()),update(),window.addEventListener("hashchange",update)})}();
