import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../.././utils.js';
import { faker } from '@faker-js/faker';
import { test, expect } from '@playwright/test';

test.use({ storageState: './superadmin-auth.json' });

test('test', async ({ page }) => {
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/');
      await page.hover('text=REGISTRY');     await page.waitForTimeout(300);     await page.getByRole('link', { name: 'Studio' }).click();
  await page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/registry/studio');
  await page.getByRole('row', { name: '25 Equipt Classe4' }).getByRole('gridcell').first().click();
});

