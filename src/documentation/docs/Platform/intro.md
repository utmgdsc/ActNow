# Intro
The main focus of the platform team is to handle the back-end of the ActNow application. Our main focus right now is to create a web-scraping bot that scrapes events from different event websites like Eventbrite.

## Path
To find our code for the web-scraper, follow the path **src/api** in the GitHub repository.

For now all our main work is in **scraper.js** where you can find the code for the Eventbrite web-scraper.

## Usage Example
### Requirements:
- Need to have Node.js / npm

Running the web-scraper locally is very simple. For now we suggest only running the dev version to test the application.
### Steps to use Web-Scraper
#### Server-side: These two steps get the server running on localhost:3000
- `npm install`
- `npm run dev`


#### Client-side:
- Open any browser or postman (or any other api tool). This should launch a new browser window which shows the bot scraping the data.
- You can see the scraped data as a JSON object in the server console.