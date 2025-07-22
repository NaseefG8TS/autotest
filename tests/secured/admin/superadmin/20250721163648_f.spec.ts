import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('test', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
      await page.hover('text=REGISTRY');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Studio' }).click();
  await page.locator('#rooms-table .tabulator-row').first().locator('.tabulator-cell').first().click();
  await page.getByRole('textbox', { name: 'Name' }).click();
  await page.getByRole('textbox', { name: 'Name' }).fill('Equipt Classe4swsss');
  await page.getByRole('textbox', { name: 'Classes' }).click();
  await page.getByRole('option', { name: 'Classes' }).click();
  await page.getByRole('spinbutton', { name: 'Refund Policy' }).click();
  await page.getByRole('spinbutton', { name: 'Refund Policy' }).fill('1');
  await page.getByRole('textbox', { name: 'Email' }).click();
  await page.getByRole('textbox', { name: 'Email' }).fill('nas@');
});

