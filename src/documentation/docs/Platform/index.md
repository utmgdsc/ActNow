---
sidebar_position: 1
---


# Intro
The main focus of the platform team is to handle the back-end of the ActNow application. Our main focus right now is to create a web-scraping bot that scrapes events from different event websites like Eventbrite.

## Path
To find our code for the web-scraper, follow the path `src/platform` in the GitHub repository.

For now all our main work is in `functions/index.js` where you can find the code for the Eventbrite web-scraper.

## Usage Example
### Requirements:
- Need to have Node.js / npm
- Firebase cli
- Java

### Steps to setup
1. Clone the repository from Github
2. Run `firebase login` and follow the popped up instructions to login
3. Go into the `functions` directory and run `npm ci` to install the necessary packages

### Step to run the backend
#### Option 1: Only run the functions
1. Go into the `functions` directory and run `npm run serve` to start a local firebase emulator with only the cloud functions
2. Go into the cloud functions console and trigger any function you want to test

*Note*: This options will **only** run the functions. So if you functions depends on other firebase tools, go to option 2.

#### Option 2: Serve up all enabled firebase tools
1. Go into `src/platform` and run `firebase emulators:start` to start a local firebase emulator with all the enabled firebase tools (currently we enabled cloud functions and firestore for local development)
2. Go into the cloud functions console and trigger any function you want to test that edits firestore
3. Go into the firestore console to verify the changes were correct


### Step to deploy cloud functions
**Notes**: Do not deploy unless you have tested and are very sure the changes you made are correct. This is because deployment is a paid service and have a very low daily free limit.

1. Go into the `functions` directory and run `npm run deploy`
2. Wait for the deployment to finish, then go into the firebase cloud functions console and verify the deployment was successful