const fixtures_data =  JSON.parse(JSON.stringify(require('./../../.././testing-data.json')));
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test('test_all_pages_links_disconnected', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01!@preprod.g8ts.online/login');
  await page.getByRole('link', { name: 'Forgot password?' }).click();
  await page.getByRole('link', { name: 'Sign In' }).click();
  await page.getByRole('link', { name: 'Register' }).click();
  await page.getByRole('link', { name: 'Use Existing Account' }).click();
  await page.getByText('An issue ? Contact Us').click();
  await page.getByRole('link', { name: 'Return Homepage' }).click();
});