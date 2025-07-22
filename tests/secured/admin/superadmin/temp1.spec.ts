import { test, expect } from '@playwright/test';

test.use({
  storageState: './superadmin-auth.json'
});

test('test', async ({ page }) => {
  await page.goto('https://preprod.g8ts.online/admin/');
});