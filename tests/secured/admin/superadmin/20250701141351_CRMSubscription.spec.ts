import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('CRMSubscription_bot1', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.hover('text=CRM'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Subscriptions' }).click();
  await page.locator('.tabulator-cell').first().click();
  await page.getByRole('button', { name: 'Remove all items' }).click();
  await page.getByRole('option', { name: 'EQUIPT - Performance Pro - 3' }).click();
  await page.getByRole('textbox', { name: 'Started' }).fill(getFormattedDateOnly());
  await page.getByRole('textbox', { name: 'Expiry' }).fill(getFormattedDateOnly());
  await page.getByRole('checkbox', { name: 'Auto renew' }).uncheck();
  await page.getByRole('checkbox', { name: 'Auto renew' }).check();
  await page.getByRole('checkbox', { name: 'Is active' }).check();
  await page.getByRole('button', { name: 'Save' }).click();
});

