const base = require('@playwright/test');
const { test: baseTest, expect } = base;

const test = baseTest.extend({
  page: async ({ page }, use) => {
    page.on('console', msg => {
      if (msg.type() === 'log')
        console.log(`⮞ [PAGE] ${msg.text()}`);
    });

    await page.addInitScript(() => {
      document.addEventListener('click', e => {
        const el = /** @type {HTMLElement} */(e.target);
        console.log(
          `Clicked: <${el.tagName.toLowerCase()}>` +
          (el.id    ? `#${el.id}`     : '') +
          (el.className ? `.${el.className.split(' ').join('.')}` : '') +
          (el.innerText.trim() ? ` text="${el.innerText.trim()}"` : '')
        );
      });
    });

    await use(page);
  },
});

module.exports = { test, expect };
