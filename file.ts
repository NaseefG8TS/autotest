import { getFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({
  storageState: './superadmin-auth.json'
});

test('test_reg1', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01!@preprod.g8ts.online/admin/');
  await page.getByRole('link', { name: 'REGISTRY' }).click();
  await page.getByRole('textbox', { name: 'classic' }).click();
});