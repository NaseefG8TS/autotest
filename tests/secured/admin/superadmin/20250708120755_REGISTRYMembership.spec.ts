import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from '../../../../utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('REGISTRYPackages_bot1', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.hover('text=REGISTRY');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Packages' }).click();
  await page.getByRole('link', { name: 'Add New' }).nth(2).click();
  await page.getByRole('textbox', { name: 'Label' }).click();
  await page.getByRole('textbox', { name: 'Label' }).fill('youth');
  await page.getByRole('textbox', { name: 'Select type' }).click();
  await page.getByRole('option', { name: 'year' }).click(); 
  await page.getByRole('textbox', { name: 'Price' }).click();
  await page.getByRole('textbox', { name: 'Price' }).fill('100');
  await page.getByRole('spinbutton', { name: 'Listing Order' }).click();
  await page.getByRole('spinbutton', { name: 'Listing Order' }).fill('1');
  await page.getByRole('textbox', { name: 'Select Location' }).click();
  await page.getByRole('option', { name: 'West Bay - Gate Mall' }).click();
  await page.getByRole('textbox', { name: 'Hour of the day(0-24)' }).click();
  await page.getByRole('textbox', { name: 'Hour of the day(0-24)' }).fill('1');
  await page.getByRole('combobox').filter({ hasText: /^$/ }).first().click();
  await page.getByRole('option', { name: 'Equipt Fitness' }).click();
  await page.getByRole('textbox', { name: 'Select a company to attach' }).click();
  await page.getByRole('option', { name: 'equiptfitness' }).click();
  await page.getByRole('textbox', { name: 'Default Event Date' }).fill(getFormattedDateOnly());
  await page.getByRole('textbox', { name: 'Description' }).click();
  await page.getByRole('textbox', { name: 'Description' }).fill('test memebrship');
  await page.getByRole('checkbox', { name: 'Is this membership visible?' }).uncheck();
  await page.getByRole('checkbox', { name: 'Active in Pos?' }).uncheck();
  await page.locator('#membership_pack_classPacks').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });
  await page.getByRole('combobox').filter({ hasText: /^$/ }).nth(2).click();
  // await page.getByRole('option', { name: 'Equipt Classes' }).click();
  // await page.getByRole('button', { name: 'Save' }).click();
});

