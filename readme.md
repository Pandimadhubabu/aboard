# Aboard

[![MIT license](https://img.shields.io/badge/license-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

**ANNOUNCEMENT:** Aboard.io will shut down on August 2016. It will remain accessible for free on its Github Pages URL https://noclat.github.io/aboard. Thank you for your support.

[Aboard](https://noclat.github.io/aboard) is an inspiration board for artists and designers which combines the most beautiful RSS feeds from the Web. You can create your own list, Aboard will remember it the next time you come.

## What's new since December 23, 2015

- New design with wider images
- Improved performances and reliability
- Feeds favicons displayed
- Right click on images enabled
- Lazy loading images to avoid consuming mobile data
- Switched from Google Feed API to ~~[feedrapp](https://github.com/sdepold/feedrapp) (may experience downtimes due to Heroku free plan)~~ [rss2json](http://rss2json.com/)

## Which RSS feeds are compatible?

To make your RSS feed compatible with Aboard, please follow these rules:
- put your images in `<img>` tags inside the `<description>` tag of your XML tree;
- use images at least 400 x 300px wide;
- there is no item count limitation, but 10 or more is better for the users.

Then report an issue with your feed URL so I can add it to Aboard.

## Categories

Aboard uses categories to help you filter and discover feeds:
- architecture
- art (real life art)
- design (industrial design, furnitures)
- digital (digital art)
- fashion
- interface (web design, apps, UI)
- lettering
- photography

## About Aboard

The project was first created in two days as a personal challenge. It was initially running on [AngularJS](http://angularjs.org) and a simple [Google Spreadsheet](https://docs.google.com/spreadsheets/d/1QgkAchwwtS8IH9GPBD-LPLY41_okXHGHw7UTFGa-a18) (using the [Google Spreadsheet to JSON API](https://developers.google.com/gdata/samples/spreadsheet_sample) and the [Google Feed API](https://developers.google.com/feed/)).

On november 2015, Google closed its Feed API and Aboard couldn't fetch RSS anymore. I took the opportunity to redesign Aboard with some improvements I had noted in background until then, and give a try at [Vue.js](http://vuejs.org/).
