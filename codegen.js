const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    httpCredentials: {
      username: 'testing',
      password: 'NoMoreBugPlease01!',
    },
  });

  const page = await context.newPage();

  await page.goto('https://preprod.g8ts.online/admin');

  console.log('Please complete login and then press Enter here...');
  process.stdin.once('data', async () => {
    await context.storageState({ path: 'superadmin-auth.json' });
    console.log('Storage saved to superadmin-auth.json');
    await browser.close();
    process.exit(0);
  });
})();
