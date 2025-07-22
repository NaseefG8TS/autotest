import { Page, TestInfo } from '@playwright/test';


export async function smartDeleteLast(page: Page) {
  try {
    
    
    await page.waitForLoadState('networkidle');
    
   
    const deleteButtons = page.getByRole('link', { name: 'Delete' });
    const count = await deleteButtons.count().catch(() => 0);
    
    
    if (count === 0) {
     
      await page.screenshot({ path: 'no-delete-buttons.png' });
      throw new Error('No Delete button found');
    }

    
    if (count === 1) {
      await deleteButtons.first().click();
    } else {
      await deleteButtons.last().click();
    }
    
    
  } catch (error) {
    await page.screenshot({ path: 'delete-error.png' });
    throw error;
  }

  
}


  export async function checkRow(page: Page, tableId: string) {
  try {
   
    await page.waitForLoadState('networkidle');

    const rows = page.locator(`#${tableId} .tabulator-table .tabulator-row`);

    await rows.first().waitFor({ timeout: 5000 });

    const rowCount = await rows.count();

    if (rowCount === 0) {
      await page.screenshot({ path: 'no-table-rows.png' });
      throw new Error('No rows found in the Tabulator table.');
    }

    const targetRow = rowCount > 1 ? rows.last() : rows.first();
       await targetRow.waitFor({ timeout: 5000 });
   await targetRow.locator('a.tabulator-action-btn:has(svg.feather-edit)').click();

  } catch (error) {
    await page.screenshot({ path: 'row-click-error.png' });
    throw error;
  }
}