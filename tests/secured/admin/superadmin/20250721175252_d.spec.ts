import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('test', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
      await page.hover('text=PLANNING');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Classes' }).click();
  await page.locator('.button.inline-block').first().click();
  await page.getByRole('textbox', { name: 'Select Class' }).click();
  await page.getByRole('link', { name: 'Back' }).click();
  await page.waitForTimeout(3150); await page.locator('.toggle_details').first().click();
  await page.getByRole('link', { name: 'Book', exact: true }).click();
  await page.getByRole('textbox', { name: 'Pincode' }).click();
  await page.getByRole('textbox', { name: 'Pincode' }).type('77', { delay: 100 });
  await page.getByRole('button', { name: 'Cancel' }).click();
});

