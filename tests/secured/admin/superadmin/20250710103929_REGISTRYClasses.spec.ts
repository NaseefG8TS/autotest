import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from '../../../../utils.js';
import { faker } from '@faker-js/faker';
import { checkRow } from '../../../../helper.ts';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('REGISTRYClasses_bot1', async ({ page }) => {

  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.getByRole('link', { name: 'REGISTRY' }).click();
  await page.getByRole('link', { name: 'Add New' }).first().click();
  await page.getByRole('textbox', { name: 'Name' }).click();
  await page.getByRole('textbox', { name: 'Name' }).fill('naseef');
  await page.getByRole('textbox', { name: 'Single Price' }).click();
  await page.getByRole('textbox', { name: 'Single Price' }).fill('1000');
  await page.locator('#event_class_duration').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });
  await page.getByRole('textbox', { name: 'Capacity' }).click();
  await page.getByRole('textbox', { name: 'Capacity' }).fill('nasss');
  await page.locator('#event_class_type').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });
  await page.locator('#event_class_gender').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });
  await page.getByRole('textbox', { name: 'Minimum Age' }).click();
  await page.getByRole('textbox', { name: 'Minimum Age' }).fill('11');
  await page.getByRole('textbox', { name: 'Maximum Age' }).click();
  await page.getByRole('textbox', { name: 'Maximum Age' }).fill('100');
  await page.locator('#event_class_level').selectOption({ index: faker.number.int({ min: 1, max: 3 }) });
  await page.getByRole('textbox', { name: 'Refund Policy' }).click();
  await page.getByRole('textbox', { name: 'Refund Policy' }).fill('1');
  await page.getByRole('textbox', { name: 'Event Location' }).click();
  await page.getByRole('textbox', { name: 'Event Location' }).fill('ssss');
  await page.getByRole('textbox', { name: 'Description' }).click();
  await page.getByRole('textbox', { name: 'Description' }).fill('ssss');
  await page.getByRole('spinbutton', { name: 'Access Control Start' }).click();
  await page.getByRole('spinbutton', { name: 'Access Control Start' }).fill('11');
  await page.getByRole('spinbutton', { name: 'Access Control End' }).click();
  await page.getByRole('combobox').filter({ hasText: /^$/ }).dblclick();
  await page.locator('#class_pack_classes').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });
  await page.getByRole('textbox', { name: 'Min Price' }).click();
  await page.getByRole('textbox', { name: 'Min Price' }).fill('1');
  await page.getByRole('textbox', { name: 'Max Price' }).click();
  await page.getByRole('textbox', { name: 'Max Price' }).fill('1');
  await page.getByRole('textbox', { name: 'Starting Price' }).click();
  await page.getByRole('textbox', { name: 'Starting Price' }).fill('1003');
  await page.getByRole('textbox', { name: 'Efficiency Booking' }).click();
  await page.getByRole('textbox', { name: 'Efficiency Booking' }).fill('01');
  await page.getByRole('checkbox', { name: 'Unrefundable class?' }).check();
  await page.getByRole('checkbox', { name: 'Unbookable class ?' }).check();
  await page.getByRole('checkbox', { name: 'Bowl included in the price' }).check();
  await page.getByRole('checkbox', { name: 'Is Premium?' }).check();
  await page.locator('.flex > div:nth-child(5)').click();
  await page.getByRole('checkbox', { name: 'Remove class icon?' }).check();
  await page.getByRole('link', { name: 'Cancel' }).click();
  await page.getByRole('link', { name: 'Add New' }).first().click();
});

