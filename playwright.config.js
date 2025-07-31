// @ts-check
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 1000 * 1000,
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1,

  reporter: [
    ['./g8ts-test-reporter.js'],
    ['html', { outputFolder: 'html-report', open: 'never' }],
  ],

  use: {
    testIdAttribute: 'id',
    baseURL: 'https://testing:NoMoreBugPlease01!@preprod.g8ts.online/',
    trace: 'on-first-retry',
    headless: false, 
    viewport: { width: 1280, height: 800 }, 
    // launchOptions: {
    //   slowMo: 100, 
    // },
  },

  projects: [
    {
      name: 'Google Chrome',
      use: {
        ...devices['Desktop Chrome'],
        headless: false,
        slowMo: 100,
    
      },
    },
  ],
});
