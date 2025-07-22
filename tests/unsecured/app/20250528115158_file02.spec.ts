import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/studios');
  await page.locator('a:nth-child(6)').click();
});