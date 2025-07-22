const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    httpCredentials: {
      username: 'testing',
      password: 'NoMoreBugPlease01!',
    },
    storageState: 'superadmin-auth.json',  
  });

  const page = await context.newPage();

  await page.goto('https://preprod.g8ts.online/admin');

  // Optional: Keep browser open for you to record actions
  console.log('Browser open. You can record actions now.');

  // Close manually when done
  // or add logic to save new storage state on exit if needed
})();
