const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const $ = require('jquery');
const AdblockerPlugin = require('puppeteer-extra-plugin-adblocker');
var express = require("express");
var app = express();
var path = require("path");
var multer = require("multer");
var fs = require("fs");
var bodyParser = require("body-parser");
 
var HTTP_PORT = process.env.PORT || 8080;

var cookiesList;

function onHttpStart()
{
  console.log("Express http server listening on: " + HTTP_PORT);
 
  console.log("FUCK KANYE");
}
 
(async () => {
    const proxyUrl = '';
    const username = null;
    const password = null;
 
    const args = [
        '--no-sandbox',
        '--disable-gpu',
        '--disable-infobars',
        '--disable-dev-shm-usage',
        `--disable-setuid-sandbox`,
        '--ignore-certifcate-errors',
        '--ignore-certifcate-errors-spki-list',
        `--proxy-server=${proxyUrl}`,
        // '--disable-extensions-except=',
        // '--load-extension=/autofill/manifest.js'
    ];
 
    const options = {
        args,
        headless: true,
        ignoreHTTPSErrors: true
    };
 
    puppeteer.use(AdblockerPlugin());
    puppeteer.use(StealthPlugin());
 
    const browser = await puppeteer.launch(options);
    const page = await browser.newPage();
    await page.authenticate({
        username: username,
        password: password
    });
    //Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36
    await page.setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148');
    await page.goto('https://yeezysupply.com');
    await page.setViewport({
        width: 1000,
        height: 700
    });
 
    console.log('{success: True}');

    setInterval(async() => {
    let cookie = await page.evaluate(() => {
        let text = document.cookie.split('; ').filter(cookie => cookie.includes('_abck')).pop();
        if (!text) return text;
        return text.split(/\=(.+)/).reduce((obj, part, i) => {
            if (i === 0) obj.key = part;
            if (i === 1) obj.val = part;
            return obj;
        }, {});
    });
    console.log('Generating New _abck Cookie', cookie);
    cookiesList = cookie;
    await page.reload();
    await Promise.all([
        page.waitForNavigation()
    ]);
}, 1500);
 
app.use(express.static('public'));
 
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
 
app.get("/", (req, res) =>
{
  res.send("ABCK COOKIE GENERATOR BY: GOOMBA/SHROOMS");
});
 
app.get("/abck", function(req,res)
{
    res.json(cookiesList);
});
 
app.listen(HTTP_PORT, onHttpStart);
 
})();