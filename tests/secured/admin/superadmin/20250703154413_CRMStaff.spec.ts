import { getFormattedDate, getFormattedDateOnly, CustomgetFormattedDate } from '../../../../utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('CRMStaff_bot1', async ({ page }) => {

  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.hover('text=CRM'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Staff' }).click();
  await page.getByRole('link', { name: 'Add New' }).click();
  await page.getByRole('textbox', { name: 'Choose an option' }).click();
  await page.getByRole('option', { name: 'studio' }).click();
  await page.getByRole('textbox', { name: 'Select Company' }).click();
  await page.getByRole('option', { name: 'Equipt Classes' }).click();
  await page.getByRole('combobox', { name: 'User' }).click();
  await page.getByRole('combobox', { name: 'User' }).fill('58700');
  await page.getByText('Ramzey Mohammed Pin: 58700 (').click();
  await page.getByRole('checkbox', { name: 'Active' }).check();
  await page.getByRole('button', { name: 'Save' }).click();
  await page.getByRole('list').filter({ hasText: '2 3' }).getByRole('link').nth(4).click();
  await page.getByRole('row', { name: '' }).getByRole('link').last().click();
  await page.getByRole('button', { name: 'Delete' }).click();
  await page.getByRole('button', { name: 'Ok' }).click();
});

