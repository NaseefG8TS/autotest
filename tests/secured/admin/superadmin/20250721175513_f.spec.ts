import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('test', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
      await page.hover('text=PLANNING');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Classes' }).click();
  await page.locator('.button.inline-block').first().click();
  await page.getByRole('link', { name: 'Back' }).click();
  await page.waitForTimeout(3150); await page.locator('.toggle_details').first().click();
  await page.getByRole('link', { name: 'Book', exact: true }).click();
  await page.getByRole('combobox', { name: 'Search user by oxpin/' }).click();
  await page.getByRole('combobox', { name: 'Search user by oxpin/' }).fill('58694');
  await page.getByText('Mohammed Naseef MM Pin: 58694').click();
  await page.getByRole('textbox', { name: 'Select a status' }).click();
  await page.getByRole('option', { name: 'COMPLETED' }).click();
  await page.getByRole('textbox', { name: 'Select an option' }).click();
  await page.getByRole('option', { name: 'Cash' }).click();
  await page.getByRole('textbox', { name: 'Pincode' }).click();
  await page.getByRole('textbox', { name: 'Pincode' }).type('77', { delay: 100 });
  await page.getByRole('button', { name: 'Save' }).click();
});

