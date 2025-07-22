import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from '../../../../utils.js';
import { faker } from '@faker-js/faker';
import { checkRow } from '../../../../helper.ts';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('CRMCustomers_bot1', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.hover('text=CRM');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Customers' }).click();
  await page.getByRole('link', { name: 'Add New' }).click();
  await page.getByRole('textbox', { name: 'Email' }).click();
  await page.getByRole('textbox', { name: 'Email' }).fill('test@mail.com');
  await page.getByRole('textbox', { name: 'First name' }).click();
  await page.getByRole('textbox', { name: 'First name' }).fill('testuser');
  await page.getByRole('textbox', { name: 'Last name' }).click();
  await page.getByRole('textbox', { name: 'Last name' }).fill('testuser');
  await page.getByRole('radio', { name: 'Male', exact: true }).check();
  await page.getByRole('textbox', { name: 'Birthday' }).fill('2025-07-13');
  await page.getByRole('textbox', { name: 'Phone' }).click();
  await page.getByRole('textbox', { name: 'Phone' }).fill('71236015');
  await page.getByRole('textbox', { name: 'Pin' }).click();
  await page.getByRole('textbox', { name: 'Pin' }).fill('1001');
  await page.getByRole('button', { name: 'Save' }).click();
  await page.getByRole('link', { name: 'Account', exact: true }).click();
});

