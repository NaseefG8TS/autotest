const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 60000,
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
    launchOptions: {
      slowMo: 100, 
    },
    
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

projects: [
  
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },

    
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },

    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    // },

    /* Test against mobile viewports. */
    // {
    //   name: 'Mobile Chrome',
    //   use: { ...devices['Pixel 5'] },
    // },
    // {
    //   name: 'Mobile Safari',
    //   use: { ...devices['iPhone 12'] },
    // },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: { ...devices['Desktop Edge'], channel: 'msedge' },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    // },
  ],
});
