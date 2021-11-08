const functions = require('firebase-functions');
// const puppeteer = require('puppeteer');
const admin = require('firebase-admin');
const { Cluster } = require('puppeteer-cluster');

admin.initializeApp();

const timeout = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

exports.scrapeEventbrite = functions
  .runWith({
    timeoutSeconds: 120,
    memory: '2GB',
  })
  .https.onRequest(async (_, res) => {
    functions.logger.info('Starting to scrape...');
    let eventsArray = [];
    const collectiveEventsArray = [];

    (async () => {
      const cluster = await Cluster.launch({
        concurrency: Cluster.CONCURRENCY_CONTEXT,
        maxConcurrency: 3,
      });

      await cluster.task(async ({ page, data: webpageUrl }) => {
        await page.setViewport({
          width: 1920,
          height: 1080,
        });

        await page.goto(webpageUrl, { waitUntil: 'networkidle2' });
        await timeout(2000);

        eventsArray = await page.evaluate(async () => {
          const events = [];
          // for (let x = 1; x <= 3; x += 1) {
          for (let i = 1; i <= 60; i += 1) {
            // console.log(i);
            const eventTitle = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > a > h3 > div > div.eds-event-card__formatted-name--is-clamped.eds-event-card__formatted-name--is-clamped-three.eds-text-weight--heavy`);
            const eventDate = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > div`);
            const eventLoc = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(1) > div`);
            const cost = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(2)`);
            const organizedBy = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(3) > div > div.eds-event-card__sub-content--organizer.eds-text-color--ui-800.eds-text-weight--heavy.card-text--truncated__two`);
            const imgUrl = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.image-action-container > aside > a > div > div > img`);
            const eventUrl = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > a`);

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
          functions.logger.error('No events scrapped');
        } else {
          functions.logger.info('Number of scrapper events:', eventsArray.length);
        }
        return eventsArray;
      });

      const eventArray1 = await Promise.all(await cluster.queue('https://www.eventbrite.ca/d/Toronto/all-events/?page=1'));
      const eventArray2 = await Promise.all(await cluster.queue('https://www.eventbrite.ca/d/Toronto/all-events/?page=2'));
      const eventArray3 = await Promise.all(await cluster.queue('https://www.eventbrite.ca/d/Toronto/all-events/?page=3'));
      // many more pages
      collectiveEventsArray.concat(eventArray1, eventArray2, eventArray3);
      functions.logger.info('startomg upload');
      functions.logger.info(collectiveEventsArray);
      collectiveEventsArray.forEach((event) => {
        functions.logger.info('adding in progress');
        (async () => {
          await admin
            .firestore()
            .collection('events')
            .doc('eventbrite')
            .collection('toronto')
            .add(event);
        })();
        functions.logger.info('Uploaded to firestore');
      });
      res.send(collectiveEventsArray);
      await cluster.idle();
      await cluster.close();
    })();
  });
