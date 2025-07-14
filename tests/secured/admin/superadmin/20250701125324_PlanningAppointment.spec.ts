import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { smartDeleteLast } from './../../../.././helper.ts';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('PlanningAppointment_bot1', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
  await page.hover('text=PLANNING'); await page.waitForTimeout(300);     await page.hover('text=PLANNING');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Appointments' }).click();
  await page.locator('#admin_planning_private_booking').getByRole('link').nth(2).click();
  await page.getByRole('textbox', { name: 'Select Service Category' }).click();
  await page.getByRole('option', { name: 'Equipt Fitness / Personal' }).click();
  await page.getByRole('textbox', { name: 'Select Service' }).click();
  await page.getByRole('option', { name: 'Equipt B.O.W.' }).click();
  await page.getByRole('textbox', { name: 'Select Room' }).click();
  await page.getByRole('option', { name: 'Open Gym' }).click();
  await page.getByRole('textbox', { name: 'Select Trainer' }).click();
  await page.getByPlaceholder('Search').click();
  await page.getByPlaceholder('Search').fill('omar');
  await page.getByRole('option', { name: 'Omar g8ts' }).click();
  await page.getByRole('textbox', { name: 'Date/Time' }).click();
  await page.getByRole('textbox', { name: 'Date/Time' }).press('ArrowLeft');
  await page.getByRole('textbox', { name: 'Date/Time' }).press('ArrowRight');
  await page.getByRole('textbox', { name: 'Date/Time' }).fill(getFormattedDate());
  await page.getByRole('combobox', { name: 'User' }).click();
  await page.getByRole('combobox', { name: 'User' }).fill('58694');
  await page.getByText('Mohammed Naseef MM Pin: 58694').click();
  await page.getByRole('textbox', { name: 'Select Location' }).click();
  await page.getByRole('option', { name: 'West Bay - Gate Mall' }).click();
  await page.getByRole('combobox', { name: 'CREATED' }).getByLabel('Remove all items').click();
  await page.getByRole('option', { name: 'COMPLETED' }).click();
  await page.getByRole('combobox').filter({ hasText: /^$/ }).nth(1).click();
  await page.getByRole('textbox', { name: 'Select Payment Method' }).click();
  await page.getByRole('option', { name: 'Cash' }).click();
  await page.getByRole('textbox', { name: 'Pincode' }).click();
  await page.getByRole('textbox', { name: 'Pincode' }).type('777777', { delay: 100 });
  await page.getByRole('button', { name: 'Save' }).click();
  await smartDeleteLast(page);
  await page.getByRole('button', { name: 'Delete' }).click();
  await page.getByRole('button', { name: 'Ok' }).click();
});

