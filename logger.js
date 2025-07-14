// playwright‑fixtures.js
const base = require('@playwright/test');
const { test: baseTest, expect } = base;

const test = baseTest.extend({
  // override the built‑in `page` fixture
  page: async ({ page }, use) => {
    // 1️⃣ forward browser console messages to Node
    page.on('console', msg => {
      if (msg.type() === 'log')
        console.log(`⮞ [PAGE] ${msg.text()}`);
    });
    // 2️⃣ inject click‑logger before any page script runs
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
    // 3️⃣ hand control back to the test
    await use(page);
  },
});

module.exports = { test, expect };
