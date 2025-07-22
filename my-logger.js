// global-setup.js

const { chromium } = require('@playwright/test');

let browser;
let page;

async function checkEvents() {
  // Launch the browser before any tests run
  browser = await chromium.launch({
    headless: false, // Set to false if you want to see the browser
  });

  // Create a new page
  page = await browser.newPage();

  // Set up any global event listeners or other setup tasks
  await page.evaluate(() => {
    document.addEventListener('click', (event) => {
      const clickedElement = event.target;
      console.log('Logging Clicked Element:', clickedElement);
      // console.log('Tag Name:', clickedElement.tagName);
      // console.log('Class:', clickedElement.className);
      // console.log('ID:', clickedElement.id);
      // console.log('Inner Text:', clickedElement.innerText);
    });
  });

  // Return the browser and page to be used in the test files
  return { browser, page };
}

async function closeBrowser() {
  // Clean up after tests are finished
  await browser.close();
}

module.exports = { checkEvents, closeBrowser };
