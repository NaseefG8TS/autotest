import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('CRMRoles_bot1', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.hover('text=CRM');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Roles' }).click();
  await page.getByRole('textbox', { name: 'Select Type of Company' }).click();
  await page.getByRole('option', { name: 'Studioww' }).click();
  await page.getByRole('textbox', { name: 'Select a company' }).click();
  await page.getByRole('option', { name: 'Equipt fitness' }).click();
  await page.getByText('Ramzey Mohammed 16 roles').click();
  await page.locator('#ROLE_MARKETING').click();
  await page.getByRole('link', { name: 'IMPORT' }).click();
  await page.getByRole('link', { name: 'NIYA YOGA' }).click();
  await page.locator('#ROLE_DASHBOARD').click();
  await page.getByRole('link', { name: 'PREMIUM' }).click();
  await page.getByRole('link', { name: 'MANAGER' }).click();
  await page.getByRole('link', { name: 'STAFF' }).click();
  await page.locator('#ROLE_PLANNING').click();
  await page.getByRole('link', { name: 'ORDERS' }).click();
  await page.getByRole('link', { name: 'PAYMENT' }).click();
  await page.locator('#ROLE_POS').click();
  await page.locator('#ROLE_REGISTRY').click();
  await page.getByRole('link', { name: 'EXPORT' }).click();
  await page.getByRole('link', { name: 'USERS' }).click();
  await page.getByRole('link', { name: 'CASHIER', exact: true }).click();
  await page.getByRole('link', { name: 'REFILL CASHIER' }).click();
  await page.getByRole('link', { name: 'Save Changes' }).click();
  await page.locator('#ROLE_MARKETING').click();
  await page.getByRole('link', { name: 'IMPORT' }).click();
  await page.getByRole('link', { name: 'NIYA YOGA' }).click();
  await page.locator('#ROLE_DASHBOARD').click();
  await page.getByRole('link', { name: 'PREMIUM' }).click();
  await page.getByRole('link', { name: 'MANAGER' }).click();
  await page.getByRole('link', { name: 'STAFF' }).click();
  await page.locator('#ROLE_PLANNING').click();
  await page.getByRole('link', { name: 'ORDERS' }).click();
  await page.getByRole('link', { name: 'PAYMENT' }).click();
  await page.locator('#ROLE_POS').click();
  await page.locator('#ROLE_REGISTRY').click();
  await page.getByRole('link', { name: 'EXPORT' }).click();
  await page.getByRole('link', { name: 'USERS' }).click();
  await page.getByRole('link', { name: 'CASHIER', exact: true }).click();
  await page.getByRole('link', { name: 'REFILL CASHIER' }).click();
  await page.getByRole('link', { name: 'Save Changes' }).click();
  
});

