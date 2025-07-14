import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('PlanningCancellation_bot1', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.hover('text=PLANNING');     await page.waitForTimeout(300); await page.getByRole('link', { name: 'Cancellation' }).click();
  await page.getByRole('row', { name: '' }).getByRole('link').nth(3).click();
  await page.getByRole('button', { name: 'Delete' }).click();
  await page.getByRole('button', { name: 'Ok' }).click();
});

