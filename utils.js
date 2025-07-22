const fs = require('fs');

export function getFormattedDate({ hoursOffset = 0, daysOffset = 0, monthsOffset = 0 } = {}) {
  const date = new Date();

  date.setHours(date.getHours() + hoursOffset); 
  date.setDate(date.getDate() + daysOffset);    
  date.setMonth(date.getMonth() + monthsOffset); 

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); 
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day}T${hours}:${minutes}`;

}

export function getFormattedDateWithOffset(offset) {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); 
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day}T${hours}:${minutes}`;
}



export function getFormattedDateOnly() {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}
  
export async function saveTitle(page) {
    const title = await page.title();
    const sanitizedTitle = title.replace(/[^a-z0-9]/gi, '_').toLowerCase(); 
    const fileName = `titles/${sanitizedTitle}.txt`;
  
    if (!fs.existsSync('titles')) {
      fs.mkdirSync('titles');
    }
  
    fs.writeFileSync(fileName, title, 'utf-8');
  }

  
export  function getRandomNumber() {
    return Math.floor(Math.random() * 249).toString(); 
  }

  
export function CustomgetFormattedDate(end =false,{ hoursOffset = 0, daysOffset = 0, monthsOffset = 0} = {}) {

  console.log(end,'sjsjsjjsjs');
  const date = new Date();


  date.setHours(date.getHours() + hoursOffset); 
  date.setMonth(date.getMonth() + monthsOffset); 

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); 
  const day = String(date.getDate()).padStart(2, '0');
  const hours =end ? '01' : '00' ;
  const minutes = end ? '00' : '00' ;
 

 return `${year}-${month}-${day}T${hours}:${minutes}`;

}
