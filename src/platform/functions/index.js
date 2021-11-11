const functions = require('firebase-functions');
// const puppeteer = require('puppeteer');
const admin = require('firebase-admin');
const { Cluster } = require('puppeteer-cluster');

admin.initializeApp();

const timeout = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

exports.scrapeEventbrite = functions
  .runWith({
    timeoutSeconds: 60,
    memory: '1GB',
  })
  .https.onRequest(async (req, res) => {
    functions.logger.info('Starting to scrape...');
    let eventsArray = [];
    let collectiveEventsArray = [];

    /** This is a bug with firestore. For some reason, if you try to write to a nested
     * collection, it will not work, unless you write to the parent collection first. */
    await admin.firestore().collection('events').doc('scraped-events').set({});

    let city = '';
    if (req.method === 'GET') {
      if (req.query.city.length !== 0 && typeof req.query.city !== 'undefined') {
        city = req.query.city;
        functions.logger.info('City: ' + city);
      } else {
        functions.logger.error('No city name provided');
      }
    }

    const cluster = await Cluster.launch({
      concurrency: Cluster.CONCURRENCY_CONTEXT,
      maxConcurrency: 3,
    });

    // get request as a parameter from the url
    let city = '';
    if (req.method === 'GET') {
      if (req.query.city.length !== 0 && typeof req.query.city !== 'undefined') {
        city = req.query.city;
        functions.logger.info('City: ' + city);
      } else {
        functions.logger.error('No city name provided');
        res.send('Please provide a city/town name');
      }
    }

    // this is my futile attempt to prevent it from pushing events for the same city :(
    // const collectionExists = admin
    //   .firestore()
    //   .collection('events')
    //   .doc('eventbrite')
    //   .collection(city)
    //   .limit(1)
    //   .get();

    // if (!collectionExists.empty) {
    //   res.send('Scraped Events already exist for this city');
    //   functions.logger.error('Scraped Events already exist for this city');
    // }

    await page.goto(webpageUrl, { waitUntil: 'networkidle2' });
    await page.type('#locationPicker', city);
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

    collectiveEventsArray = await Promise.all([
      cluster.execute('https://www.eventbrite.ca/d/'+ city + '/all-events/?page=1'),
      cluster.execute('https://www.eventbrite.ca/d/' + city + '/all-events/?page=2'),
      cluster.execute('https://www.eventbrite.ca/d/' + city + '/all-events/?page=3'),
    ]);

    await cluster.idle();
    await cluster.close();

    // many more page
    functions.logger.info('starting upload');
    functions.logger.info(collectiveEventsArray);

    collectiveEventsArray.forEach((currPageEvents) => {
      functions.logger.info('adding in progress');
      currPageEvents.forEach((event) => {
        (async () => {
          await admin
            .firestore()
            .collection('events')
            .doc('scraped-events')
            .collection(city)
            .add(event)
            .catch((err) => functions.logger.info(err));
        })();
      });
      functions.logger.info('Uploaded to firestore');
    });
    res.send(collectiveEventsArray);
  });
