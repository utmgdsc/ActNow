import 'core-js/stable';
import 'regenerator-runtime';
import express from 'express';
import puppeteer from 'puppeteer';

const app = express();
const port = 3000;

const timeout = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

app.get('/', (req, res) => {
  let eventsArray = [];
  (async () => {
    const webpageUrl = 'https://www.eventbrite.ca';

    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    await page.setViewport({
      width: 1920,
      height: 1080,
    });

    await page.goto(webpageUrl, { waitUntil: 'networkidle2' });

    await page.type('#locationPicker', 'Toronto');

    await page.keyboard.press('Enter');

    await timeout(2000);

    eventsArray = await page.evaluate(() => {
      const events = [];
      for (let i = 1; i < 9; i += 1) {
        console.log(i);
        const eventTitle = document.querySelector(
          '#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(' +
            i.toString() +
            ') > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__primary-content > a > h3 > div > div.eds-event-card__formatted-name--is-clamped.eds-event-card__formatted-name--is-clamped-three.eds-text-weight--heavy',
        );
        const eventDate = document.querySelector(
          '#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(' +
            i.toString() +
            ') > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__primary-content > div',
        );
        const eventLoc = document.querySelector(
          '#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(' +
            i.toString() +
            ') > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(1) > div',
        );
        const organizedBy = document.querySelector(
          '#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(' +
            i.toString() +
            ') > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(3) > div > div.eds-event-card__sub-content--organizer.eds-text-color--ui-800.eds-text-weight--heavy.card-text--truncated__two',
        );
        const cost = document.querySelector(
          '#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(' +
            i.toString() +
            ') > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(2)',
        );
        events.push({
          title: eventTitle ? eventTitle.innerHTML : '',
          date: eventDate ? eventDate.innerHTML : '',
          location: eventLoc ? eventLoc.innerHTML : '',
          ticket: cost ? cost.innerHTML : '',
          organization: organizedBy ? organizedBy.innerHTML : '',
          // img: eventImg,
          // description: eventDesc
        });
      }

      return events;
      
    });

    console.log(eventsArray);
    res.send(eventsArray);
    // await browser.close();
  })();
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
