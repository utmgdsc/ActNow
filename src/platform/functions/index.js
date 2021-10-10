const functions = require('firebase-functions');
const puppeteer = require('puppeteer');

const timeout = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

exports.scrapeEventbrite = functions
  .runWith({
    timeoutSeconds: 300,
    memory: '256MB',
  })
  .https.onRequest(async (_, response) => {
    functions.logger.info('Starting to scrape...');
    let eventsArray = [];
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
        const eventTitle = document.querySelector(
          `#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(${i.toString()}) > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__primary-content > a > h3 > div > div.eds-event-card__formatted-name--is-clamped.eds-event-card__formatted-name--is-clamped-three.eds-text-weight--heavy`,
        );
        const eventDate = document.querySelector(
          `#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(${i.toString()}) > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__primary-content > div`,
        );
        const eventLoc = document.querySelector(
          `#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(${i.toString()}) > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(1) > div.card-text--truncated__one`,
        );
        const organizedBy = document.querySelector(
          `#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(${i.toString()}) > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div > div > div.eds-event-card__sub-content--organizer.eds-text-color--ui-800.eds-text-weight--heavy.card-text--truncated__two`,
        );
        const cost = document.querySelector(
          `#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(${i.toString()}) > div > div > article > div.eds-event-card-content__content-container.eds-event-card-content__content-container--consumer > div.eds-event-card-content__content > div > div.eds-event-card-content__sub-content > div:nth-child(2)`,
        );
        const imgUrl = document.querySelector(
          `#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(${i.toString()}) > div > div > article > aside.eds-event-card-content__image-container > a.eds-event-card-content__action-link img`,
        );
        const eventUrl = document.querySelector(
          `#panel0 > div > div.feed-events-bucket.feed-events--primary_bucket > div.feed-events-bucket__content > div:nth-child(${i.toString()}) > div > div > article > aside.eds-event-card-content__image-container > a.eds-event-card-content__action-link`,
        );

        const newEvent = {
          title: eventTitle ? eventTitle.innerText : '',
          date: eventDate ? eventDate.innerText : '',
          location: eventLoc ? eventLoc.innerText : '',
          ticket: cost ? cost.innerText : '',
          organization: organizedBy ? organizedBy.innerText : '',
          img: imgUrl ? imgUrl.getAttribute('src') : '',
          url: eventUrl ? eventUrl.getAttribute('href') : '',
        };

        if (
          !(
            newEvent.ticket.substring(0, 4) === 'Free' ||
            newEvent.ticket.substring(0, 9) === 'Starts at'
          )
        ) {
          newEvent.ticket = '';
        }

        if (!(newEvent.title === '')) {
          events.push(newEvent);
        }
      }
      return events;
    });

    if (eventsArray.length === 0) {
      functions.logger.error('No events found');
    } else {
      functions.logger.info('Number of scrapper events:', eventsArray.length);
    }

    await browser.close();
    response.send(eventsArray);
  });
