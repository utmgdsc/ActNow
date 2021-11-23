const functions = require('firebase-functions');
const admin = require('firebase-admin');
// const { Cluster } = require('puppeteer-cluster');
const scraper = require('./scraper');

admin.initializeApp();

exports.periodicScraper = functions
  .runWith({
    timeoutSeconds: 60,
    memory: '1GB',
  })
  .https.onRequest(async (req, res) => {
    const today = new Date();
    (async () => {
      await admin
        .firestore()
        .collection('events')
        .doc('scraped-events')
        .collection('timestamp')
        .get()
        .then((querySnapshot) => {
          querySnapshot.forEach((doc) => {
            functions.logger.info(doc.id, ' => ', doc.data());
            if ((today - doc.data().timestamp) < )
          });
        });
    })();

    res.send(scraper(req));
  });
