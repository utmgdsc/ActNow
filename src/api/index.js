import 'core-js/stable';
import 'regenerator-runtime/runtime';
import express from 'express';

const puppeteer = require('puppeteer');
const app = express();
const port = 3000;

const timeout = (ms) => 
    new Promise(resolve => setTimeout(resolve, ms));

app.get('/', (req, res) => {
  var eventsArray = [];
  (async () => {
    // ADD WEBPAGE LINK HERE
    let webpageUrl = "https://www.eventbrite.ca";

    // SET HEADLESS TO TRUE TO NOT HAVE THE BROWSER OPEN
    let browser = await puppeteer.launch({ headless: false });
    let page = await browser.newPage();
    await page.setViewport({
      width: 1920,
      height: 1080
    });

    await page.goto(webpageUrl, { waitUntil: 'networkidle2' });

    await timeout(3000);
    
    await page.type("#locationPicker", "Toronto");

    await page.keyboard.press('Enter');

    await timeout(3000);

    eventsArray = await page.evaluate(() => {

        // // ADD QUERIES INSIDE THE EMPTY STRINGS BELOW
        var events = [];
        for (let i = 1; i < 9; i++) {
          console.log(i);
          let eventTitle =  document.querySelector("#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(" + i.toString() + ") > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__primary-content > a > h3 > div > div.eds-event-card__formatted-name--is-clamped.eds-event-card__formatted-name--is-clamped-three.eds-text-weight--heavy");
          let eventDate =   document.querySelector("#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(" + i.toString() + ") > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__primary-content > div");
          let eventLoc =    document.querySelector("#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(" + i.toString() + ") > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(1) > div");
          let organizedBy = document.querySelector("#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(" + i.toString() + ") > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(3) > div > div.eds-event-card__sub-content--organizer.eds-text-color--ui-800.eds-text-weight--heavy.card-text--truncated__two")
          let cost =        document.querySelector("#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(" + i.toString() + ") > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(2)");
          events.push(
            {
              title: eventTitle ? eventTitle.innerHTML : "",
              date: eventDate ? eventDate.innerHTML : "",
              location: eventLoc ? eventLoc.innerHTML : "",
              ticket: cost ? cost.innerHTML : "",
              organization: organizedBy ? organizedBy.innerHTML : ""
              // img: eventImg,
              // description: eventDesc
          });
        }    

        return events;
    });

    // await page.waitForNavigation();
    console.log(eventsArray);
    res.send(eventsArray);
    // await browser.close();
  })();
  
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
});

