// playwright‑fixtures.ts
import { test as baseTest, Page } from '@playwright/test';

export const test = baseTest.extend<{}, { page: Page }>({
  page: async ({ page }, use) => {
    await page.addInitScript(() => {
      document.addEventListener('click', event => {
        console.log(event,'event event event');
        const el = event.target as HTMLElement;
        console.log(el.id,'id');
        console.log(el.className,'class');
        console.log(el.innerText,'innertext');
      });
    });
    // now run the test
    await use(page);
  },
});
export { expect } from '@playwright/test';
