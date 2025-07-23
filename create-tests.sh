#!/bin/bash

case "$(uname -s)" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    CYGWIN*)    OS=Windows;;
    MINGW*)     OS=Windows;;
    *)          OS="UNKNOWN"
esac


if [ "$OS" = "Mac" ]; then
echo "mac"
    SED="sed -i ''"
    GREP="grep"
    AWK="awk"
elif [ "$OS" = "Linux" ]; then
echo "linux"

    SED="sed -i"
    GREP="grep"
    AWK="awk"
elif [ "$OS" = "Windows" ]; then
echo "windows"

    SED="sed -i"
    GREP="grep"
    AWK="awk"
else
    echo "Unsupported OS detected. Exiting."
    exit 1
fi

if [ "$OS" = "Mac" ] && command -v gsed >/dev/null 2>&1; then
    SED="gsed -i ''"
fi


detect_duration_dropdown_id() {
  local file="$1"

  if grep -q "page.getByRole('link', { name: 'Services' })" "$file" || grep -q "service" "$file"; then
    echo "#service_duration"
  elif grep -q "Classes" "$file" || grep -q "event_class_duration" "$file"; then
    echo "#event_class_duration"
  elif grep -q "Appointments" "$file" || grep -q "appointment_duration" "$file"; then
    echo "#appointment_duration"
  else
    echo "#event_class_duration" 
  fi
}

add_menu_hover_interactions() {
  local file="$1"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Services'\'' \}\)\.click\(\);|await page.hover('\''text=REGISTRY'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Services'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Packages'\'' \}\)\.click\(\);|await page.hover('\''text=REGISTRY'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Packages'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Studio'\'' \}\)\.click\(\);|await page.hover('\''text=REGISTRY'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Studio'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Trainer Profile'\'' \}\)\.click\(\);|await page.hover('\''text=REGISTRY'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Trainer Profile'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Export'\'' \}\)\.click\(\);|await page.hover('\''text=REGISTRY'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Export'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Classes'\'' \}\)\.click\(\);|await page.hover('\''text=PLANNING'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Classes'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Appointments'\'' \}\)\.click\(\);|await page.hover('\''text=PLANNING'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Appointments'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''No Shows'\'' \}\)\.click\(\);|await page.hover('\''text=PLANNING'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''No Shows'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Cancellation'\'' \}\)\.click\(\);|await page.hover('\''text=PLANNING'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Cancellation'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Roles'\'' \}\)\.click\(\);|await page.hover('\''text=CRM'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Roles'\'' }).click();|g' "$file"

  perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Customers'\'' \}\)\.click\(\);|await page.hover('\''text=CRM'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Customers'\'' }).click();|g' "$file"
}

replace_table_selectors() {
  local file="$1"
  
  add_menu_hover_interactions "$file"
  
  local table_id=""
  if grep -q "Services" "$file"; then
    table_id="service-categories-table"
  elif grep -q "Packages" "$file"; then
    table_id="class-pack-table"
  elif grep -q "Studio" "$file"; then
    table_id="studios-table"
  elif grep -q "Trainer Profile" "$file"; then
    table_id="trainers-table"
  elif grep -q "Export" "$file"; then
    table_id="export-table"
  elif grep -q "Classes" "$file"; then
    table_id="layout-table"
  elif grep -q "Appointments" "$file"; then
    table_id="appointments-table"
  fi

  if [ -n "$table_id" ]; then

    perl -i -pe "s|await page\.getByRole\('row', \{ name: '[^']*' \}\)\.getByRole\('gridcell'\)\.first\(\)\.click\(\);|await page.locator('#${table_id} .tabulator-row').first().locator('.tabulator-cell').first().click();|g" "$file"
    
    perl -i -pe "s|await page\.getByRole\('row', \{ name: '[^']*' \}\)\.getByRole\('button'\)\.click\(\);|await page.locator('#${table_id} .tabulator-row').first().locator('button').click();|g" "$file"
 fi
}

while true; do
  read -p "Select type of test (admin | app): " TEST_TYPE
  if [[ "$TEST_TYPE" != "admin" && "$TEST_TYPE" != "app" ]]; then
    echo "Error: Invalid test type. Choose 'admin' or 'app'."
    exit 1
  fi

  read -p "Does it need an authenticated user? (yes | no): " AUTH_REQUIRED
  if [[ "$AUTH_REQUIRED" != "yes" && "$AUTH_REQUIRED" != "no" ]]; then
    echo "Error: Invalid input. Choose 'yes' or 'no'."
    exit 1
  fi

  if [[ "$AUTH_REQUIRED" == "yes" ]]; then
    read -p "Which role? (user | superadmin): " ROLE
    if [[ "$ROLE" != "user" && "$ROLE" != "superadmin" ]]; then
      echo "Error: Invalid role. Choose 'user' or 'superadmin'."
      exit 1
    fi
  fi


 AUTH_FILE=""
if [[ "$AUTH_REQUIRED" == "yes" && "$ROLE" == "superadmin" ]]; then
  AUTH_FILE="superadmin-auth.json"
elif [[ "$AUTH_REQUIRED" == "yes" && "$ROLE" == "user" ]]; then
  AUTH_FILE="user-auth.json"
else
  AUTH_FILE=""
fi


SCRIPT_DIR=$(dirname "$0")


ROUTE_PATH="/"
[[ "$TEST_TYPE" == "admin" ]] && ROUTE_PATH="/admin"

AUTH_FILE=""
[[ "$AUTH_REQUIRED" == "yes" && "$ROLE" == "superadmin" ]] && AUTH_FILE="superadmin-auth.json"
[[ "$AUTH_REQUIRED" == "yes" && "$ROLE" == "user" ]] && AUTH_FILE="user-auth.json"


if [[ "$AUTH_REQUIRED" == "yes" ]]; then
  DESTINATION="/tests/secured/$TEST_TYPE/$ROLE"
  
else
  DESTINATION="/tests/unsecured/$TEST_TYPE"
fi

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
read -p "Enter a new name for the test file (no spaces allowed): " NEW_NAME
if [[ -z "$NEW_NAME" || "$NEW_NAME" =~ \  ]]; then
  echo "Error: Invalid file name. It cannot be empty or contain spaces."
  exit 1
fi

NEW_FILENAME="${TIMESTAMP}_${NEW_NAME}.spec.ts"

NEW_FILENAME_AT_PATH="$SCRIPT_DIR/$NEW_FILENAME"
touch $NEW_FILENAME_AT_PATH

mv "$NEW_FILENAME_AT_PATH" "$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME"


echo "File moved to $DESTINATION/"

TARGET_FILE="$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME" 

if [[ "$AUTH_REQUIRED" == "yes" ]]; then
echo "sjsjjsjsjs"
echo "$ROUTE_PATH"

  npx playwright codegen  --browser=chromium --output=$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME  "https://testing:NoMoreBugPlease01!@preprod.g8ts.online$ROUTE_PATH" --load-storage="$SCRIPT_DIR/$AUTH_FILE"
else 
echo "nbdnbdbd"

  npx playwright codegen --browser=chromium --output=$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME  "https://testing:NoMoreBugPlease01!@preprod.g8ts.online/logout"
  
fi

sed -i '' 's|https://preprod\.g8ts\.online/|https://testing:NoMoreBugPlease01\!@preprod.g8ts.online/|g' $SCRIPT_DIR/$DESTINATION/$NEW_FILENAME
sed -i '' "s/test('test',/test('test_$NEW_NAME',/" $SCRIPT_DIR/$DESTINATION/$NEW_FILENAME



  selector_array=(
    "page.getByRole('textbox', { name: 'Start' })"
    "page.getByRole('textbox', { name: 'Default Event Date' })"
     "page.getByRole('textbox', { name: 'Started' })"
    "page.getByLabel('Start')" 
    "page.getByRole('textbox', { name: 'Select Studio' })"
    "page.getByRole('textbox', { name: 'Select Category' })"
    "page.getByRole('textbox', { name: 'End' })"
     "page.getByRole('textbox', { name: 'Expiry' })"
    "page.getByLabel('Date/Time')"
    "page.getByRole('combobox').filter({ hasText: /^$/ })"
    "page.getByRole('textbox', { name: 'Date/Time' })"
    "page.getByRole('textbox', { name: 'Event Start' })"
    "page.getByRole('textbox', { name: 'Event End' })"
    "page.getByRole('textbox', { name: 'Publish Start' })"
    "page.getByRole('textbox', { name: 'Publish End' })"
    "page.locator('#start')"
    "page.locator('#order_start')"
    "page.locator('#payment_recurring_start')"
    "a:nth-child(6)"
    "page.getByRole('link', { name: 'Appointments' })"
    "page.getByRole('link', { name: 'No Shows' })"
    "page.getByRole('link', { name: 'Cancellation' })"
    "page.getByRole('link', { name: 'Subscriptions' })"
    "page.getByRole('link', { name: 'Staff' })"
    "page.getByRole('link', { name: 'Notifications' })"
    "page.getByRole('link', { name: 'Popin Home' })"
    "page.getByRole('link', { name: 'News' })"
    "Firstname"
    "page.locator(\"a[onclick*='/user/profile']\")"
    "page.getByRole('textbox', { name: 'cycling' })"
    "page.getByRole('textbox', { name: 'classic' })"
    "page.getByRole('textbox', { name: 'beatbox' })"
    "page.getByRole('textbox', { name: 'male' })"
    "page.getByRole('textbox', { name: 'mixed' })"
    "page.getByRole('textbox', { name: 'female' })"
    "page.getByRole('combobox', { name: 'male' })"
    "page.getByRole('combobox', { name: 'mixed' })"
    "page.getByRole('combobox', { name: 'female' })"
    "page.getByRole('textbox', { name: 'Beginner' })"
    "page.getByRole('textbox', { name: 'Advanced' })"
    "page.getByRole('textbox', { name: 'Intermediate' })"
    "page.getByRole('textbox', { name: 'All Levels' })"
    "page.getByRole('textbox', { name: 'West Bay - Gate Mall' })"
    "page.getByRole('textbox', { name: 'The Pearl Qatar' })"
    "page.getByRole('textbox', { name: 'Test Class' }))"
    "page.getByRole('textbox', { name: 'FITNESS CHALLENGE' })"
    "page.getByText('Select a status')"
    "page.getByRole('textbox', { name: 'Select an option' })"
    "page.getByRole('option', { name: 'Mohammed Naseef MM Pin: 58694' })"
    "page.getByText('Phone:')"
    "page.getByRole('textbox', { name: 'Pincode' })"
    "page.getByText('' +  Pin: 58694')"
    "page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/planning/event-occurrence');"
    "page.getByRole('textbox', { name: 'Equipt Classes' })"
    "page.getByRole('textbox', { name: 'Recovery' })"
    "page.getByRole('textbox', { name: 'Open Gym' })"
    "page.getByRole('textbox', { name: 'Equipt Fitness' })"
    "page.getByRole('link', { name: 'Export' })"
    "page.getByRole('link', { name: 'Trainer Profile' })"
    "page.getByRole('link', { name: 'Studio' })"
    "page.getByRole('link', { name: 'Packages' })"
    "page.getByRole('link', { name: 'Services' })"
    "page.getByRole('textbox', { name: 'Personal Training"
    "page.getByRole('textbox', { name: 'Events' })"
    "page.getByRole('textbox', { name: 'Room Rental' })"
    "page.getByRole('textbox', { name: 'Servicetestcat' })"
    "page.getByRole('textbox', { name: 'category' })"
    "page.getByRole('link', { name: 'Customers' })"
  "page.locator('#select2-class_booking_status-result-[^-]*-[1-4]')"
  "page.getByRole('textbox', { name: 'Private Session' })"
"page.getByRole('textbox', { name: 'Classes' })"
"page.getByRole('combobox', { name: 'Private Session' })"
"page.getByRole('combobox', { name: 'Classes' })"

  )

  FILE="$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME"

for i in 1 2 3 4; do
    case $i in
        1) label="ENROLLED" ;;
        2) label="COMPLETED" ;;
        3) label="LATE CANCELLED" ;;
        4) label="NOSHOWED" ;;
    esac

    escaped_label=$(printf '%s\n' "$label" | sed 's/[][\.*^$/]/\\&/g')

    sed -i '' "s|await page\.locator('#select2-class_booking_status-result-[^-]*-$i')\.click();|await page.locator('.select2-results__option', { hasText: '$escaped_label' }).click();|g" "$FILE"
done


  sed -i '' "s|await page.getByRole('option', { name: 'Credit: .*\. Price' }).click();|await page.getByRole('option', { name: /Credit: .*\\. Price/ }).click();|g" "$FILE"
  sed -i '' -E "s|await page\.getByRole\('row', *\{ *name: *'[^']*' *\}\)\.getByRole\('button'\)\.click\(\);|await page.locator('.table-report tbody tr').first().locator('button').click();|g" "$FILE"

  for selector in "${selector_array[@]}"; do
    if grep -q "$selector" "$FILE"; then
      if [[ "$selector" == *"page.getByRole('textbox', { name: 'Start' })"* ]]; then
        grep "page.getByRole('textbox', { name: 'Start' }).fill" "$FILE" | \
        sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
          date_filled=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
          sed -i '' "s|page.getByRole('textbox', { name: 'Start' }).fill('$date_filled')|page.getByRole('textbox', { name: 'Start' }).fill(CustomgetFormattedDate())|g" "$FILE"
        done
           elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Started' })"* ]]; then
        grep "page.getByRole('textbox', { name: 'Started' }).fill" "$FILE" | \
        sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
          date_filled=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
          sed -i '' "s|page.getByRole('textbox', { name: 'Started' }).fill('$date_filled')|page.getByRole('textbox', { name: 'Started' }).fill(getFormattedDateOnly())|g" "$FILE"
        done
           elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Expiry' })"* ]]; then
        grep "page.getByRole('textbox', { name: 'Expiry' }).fill" "$FILE" | \
        sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
          date_filled=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
          sed -i '' "s|page.getByRole('textbox', { name: 'Expiry' }).fill('$date_filled')|page.getByRole('textbox', { name: 'Expiry' }).fill(getFormattedDateOnly())|g" "$FILE"
        done
         elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Default Event Date' })"* ]]; then
        grep "page.getByRole('textbox', { name: 'Default Event Date' }).fill" "$FILE" | \
        sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
          date_filled=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
          sed -i '' "s|page.getByRole('textbox', { name: 'Default Event Date' }).fill('$date_filled')|page.getByRole('textbox', { name: 'Default Event Date' }).fill(getFormattedDateOnly())|g" "$FILE"
        done

      elif [[ "$selector" == *"page.getByRole('textbox', { name: 'End' })"* ]]; then
        grep "page.getByRole('textbox', { name: 'End' }).fill" "$FILE" | \
        sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
          date_filled=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
          sed -i '' "s|page.getByRole('textbox', { name: 'End' }).fill('$date_filled')|page.getByRole('textbox', { name: 'End' }).fill(CustomgetFormattedDate(true))|g" "$FILE"
        done
     
      elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Pincode' })"* ]]; then
        grep "page.getByRole('textbox', { name: 'Pincode' }).fill" "$FILE" | sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
          escaped=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
          sed -i '' "s|await page.getByRole('textbox', { name: 'Pincode' }).fill('$escaped')|await page.getByRole('textbox', { name: 'Pincode' }).type('$escaped', { delay: 100 })|g" "$FILE"
        done
      elif [[ "$selector" == *"page.getByRole('textbox', { name: 'cycling' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'classic' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'beatbox' })"* ]]; then
        sed -i '' "/await page.getByRole('option', { name: 'classic' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'beatbox' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'cycling' }).click()/d" "$FILE"
        for opt in classic beatbox cycling; do
          sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#event_class_type').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g" "$FILE"
        done

      elif [[ "$selector" == *"page.getByRole('textbox', { name: 'male' })"* || \
              "$selector" == *"page.getByRole('textbox', { name: 'female' })"* || \
              "$selector" == *"page.getByRole('textbox', { name: 'mixed' })"* || \
              "$selector" == *"page.getByRole('combobox', { name: 'male' })"* || \
              "$selector" == *"page.getByRole('combobox', { name: 'female' })"* || \
              "$selector" == *"page.getByRole('combobox', { name: 'mixed' })"* ]]; then
        for opt in female male mixed; do  
          sed -i '' "/await page.getByRole('option', { name: '$opt' }).click()/d" "$FILE"
          sed -i '' "/await page.getByRole('option', { name: '$opt', exact: true }).click()/d" "$FILE"
        done
        for opt in female male mixed; do
          sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#event_class_gender').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g" "$FILE"
          sed -i '' "s|await page.getByRole('combobox', { name: '$opt' }).click();|await page.locator('#event_class_gender').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g" "$FILE"
        done
      elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Beginner' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Advanced' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Intermediate' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'All Levels' })"* ]]; then
        sed -i '' "/await page.getByRole('option', { name: 'Beginner' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'Advanced' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'Intermediate' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'All Levels' }).click()/d" "$FILE"
        for opt in "Beginner" "Advanced" "Intermediate" "All Levels"; do
          sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#event_class_level').selectOption({ index: faker.number.int({ min: 1, max: 3 }) });|g" "$FILE"
        done

    
    elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Private Session' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Classes' })"* || \
        "$selector" == *"page.getByRole('combobox', { name: 'Private Session' })"* || \
        "$selector" == *"page.getByRole('combobox', { name: 'Classes' })"* ]]; then

    sed -i '' "/await page.getByRole('option', { name: 'Private Session' }).click()/d" "$FILE"
    sed -i '' "/await page.getByRole('option', { name: 'Classes' }).click()/d" "$FILE"

    for opt in "Private Session" "Classes"; do
        sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#studio_category').selectOption({ index: faker.number.int({ min: 0, max: 1 }) });|g" "$FILE"
        sed -i '' "s|await page.getByRole('combobox', { name: '$opt' }).click();|await page.locator('#studio_category').selectOption({ index: faker.number.int({ min: 0, max: 1 }) });|g" "$FILE"
    done



      elif [[ "$selector" == *"page.getByRole('link', { name: 'Subscriptions' })"* ]]; then
        sed -i '' "s|await page.getByRole('link', { name: 'Subscriptions' }).click();|await page.hover('text=CRM'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Subscriptions' }).click();|g" "$FILE"
      elif [[ "$selector" == *"page.getByRole('link', { name: 'Staff' })"* ]]; then
        sed -i '' "s|await page.getByRole('link', { name: 'Staff' }).click();|await page.hover('text=CRM'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Staff' }).click();|g" "$FILE"
     
      elif [[ "$selector" == *"page.getByRole('link', { name: 'Roles' })"* ]]; then
      echo "role"
        sed -i '' "s|await page.getByRole('link', { name: 'Roles' }).click();|await page.hover('text=CRM'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Roles' }).click();|g" "$FILE"
     
      elif [[ "$selector" == *"page.getByRole('link', { name: 'Notifications' })"* ]]; then
        sed -i '' "s|await page.getByRole('link', { name: 'Notifications' }).click();|await page.hover('text=MARKETING'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Notifications' }).click();|g" "$FILE"
      elif [[ "$selector" == *"page.getByRole('link', { name: 'Popin Home' })"* ]]; then
        sed -i '' "s|await page.getByRole('link', { name: 'Popin Home' }).click();|await page.hover('text=MARKETING'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Popin Home' }).click();|g" "$FILE"
      elif [[ "$selector" == *"page.getByRole('link', { name: 'News' })"* ]]; then
        sed -i '' "s|await page.getByRole('link', { name: 'News' }).click();|await page.hover('text=MARKETING'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'News' }).click();|g" "$FILE"
  
      elif [[ "$selector" == *"getByLabel('Start')"* ]]; then
        sed -i '' "s|page.getByLabel('Start').click()|page.getByLabel('Start').fill(getFormattedDate())|g" "$FILE"
      elif [[ "$selector" == *"getByLabel('Date/Time')"* || "$selector" == *"page.getByRole('textbox', { name: 'Date/Time' })"* ]]; then
        grep "page.getByRole('textbox', { name: 'Date/Time' }).fill" "$FILE" | \
        sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
          date_filled=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
          sed -i '' "s|page.getByRole('textbox', { name: 'Date/Time' }).fill('$date_filled')|page.getByRole('textbox', { name: 'Date/Time' }).fill(getFormattedDate())|g" "$FILE"
        done
      elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Event Start' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Event End' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Publish Start' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Publish End' })"* ]]; then
        for field in "Event Start" "Event End" "Publish Start" "Publish End"; do
          grep "page.getByRole('textbox', { name: '$field' }).fill" "$FILE" | \
          sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
            safe_value=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
            sed -i '' "s|page.getByRole('textbox', { name: '$field' }).fill('$safe_value')|page.getByRole('textbox', { name: '$field' }).fill(getFormattedDateOnly())|g" "$FILE"
          done
        done
      elif [[ "$selector" == *"page.locator('#start')"* ]]; then
        sed -i '' "s|page.locator('#start').click()|page.locator('#start').fill(getFormattedDate({daysOffset:-90}))|g" "$FILE"
        sed -i '' "s|page.locator('#end').click()|page.locator('#end').fill(getFormattedDate({daysOffset:1}))|g" "$FILE"
      elif [[ "$selector" == *"a:nth-child(6)"* ]]; then
        sed -i '' "s|page.locator('a:nth-child(6)').click()|page.locator(\"a[onclick*='/user/profile']\").click({timeout: 10000})|g" "$FILE"
        sed -i '' "s|page.locator('a:nth-child(6)')|page.locator(\"a[onclick*='/user/profile']\")|g" "$FILE"
        sed -i '' "s|page.locator('a:nth-child(6)')|page.locator('a:has(svg path[d^=\"M28.866\"])')|g" "$FILE"
      fi
    fi
  done

DURATION_ID=$(detect_duration_dropdown_id "$FILE")

for i in $(seq 0 5 240); do
  sed -i '' "/await page.getByRole('option', { name: '$i', exact: true }).click()/d" "$FILE"
  sed -i '' "/await page.getByRole('option', { name: '$i' }).click()/d" "$FILE"
  sed -i '' "s|await page.getByRole('textbox', { name: 'Select Duration' }).click();|await page.locator('$DURATION_ID').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
  sed -i '' "s|await page.getByRole('textbox', { name: '$i', exact: true }).click();|await page.locator('$DURATION_ID').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
  sed -i '' "s|await page.getByRole('textbox', { name: '$i' }).click();|await page.locator('$DURATION_ID').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
  sed -i '' "s|await page.getByRole('textbox', { name: '$i',  }).click();|await page.locator('$DURATION_ID').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
done


perl -0777 -i -pe "
s|await page\.getByRole\('link', \{ name: 'REGISTRY' \}\)\.click\(\);\s*await page\.getByRole\('link', \{ name: 'Classes' \}\)\.click\(\);|await page.hover('text=REGISTRY'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Classes' }).click();|g
" "$FILE"
if grep -q "page.getByRole('link', { name: 'PLANNING' }).click()" "$FILE"; then
    sed -i '' "s|await page.getByRole('link', { name: 'Classes' }).click();|await page.hover('text=PLANNING'); await page.waitForTimeout(300); await page.getByRole('link', { name: 'Classes' }).click();|g" "$FILE"
fi

sed -i '' -E "s|await page\.getByRole\('row', *\{ *name: *'[^']*' *\}\)\.getByRole\('link'\)\.nth\(4\)\.click\(\);|await page.getByRole('row', { name: '' }).getByRole('link').last().click();|g" "$FILE"
  sed -i '' "s|await page.locator('#classes div').filter({ hasText: .* }).nth(1).click();|await page.waitForTimeout(3150); await page.locator('.toggle_details').first().click();|g" "$FILE"
  sed -i '' "s|await page.locator('#select2-event_class_classPacks-result-[^']*').click();|await page.locator('#event_class_classPacks').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
  
  replace_table_selectors "$TARGET_FILE"

  for (( i=1; i<=BOT_COUNT; i++ )); do
    if grep -q "page.getByRole('link', { name: 'Delete' })" "$TARGET_FILE"; then
      sed -i '' -E "s|await page\.getByRole\('link', \{ name: 'Delete' \}\)(\.nth\([0-9]+\))?\.click\(\);|await smartDeleteLast(page);|g" "$TARGET_FILE"
      echo "import { smartDeleteLast } from './../../../../$SCRIPT_DIR/helper.ts';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
      USE_DELETE_HELPER=true
    fi
  done

if grep -q "page.goto('https://preprod.g8ts.online/admin/registry/class-pack/form')" "$TARGET_FILE" || 
   grep -q "page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/registry/class-pack/form')" "$TARGET_FILE"; then
  echo "Detected class-pack form navigation"
  
 
fi

  if grep -qE "await page\.locator\('div:nth-child\([0-9]+\) > div'\)\.first\(\)\.click\(\);" "$TARGET_FILE"; then
  sed -i '' -i -E "s|await page\.locator\('div:nth-child\([0-9]+\) > div'\)\.first\(\)\.click\(\);|await checkRow(page, 'class-pack-table');|g" "$TARGET_FILE"
  echo "import { checkRow } from './../../../../$SCRIPT_DIR/helper.ts';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
  USE_CLICK_ROW_HELPER=true
fi


  echo "import { faker } from '@faker-js/faker';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"

  if [[ "$AUTH_REQUIRED" == "yes" ]]; then
    echo "import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../../$SCRIPT_DIR/utils.js';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
  else
    echo "const fixtures_data = JSON.parse(JSON.stringify(require('./../../../$SCRIPT_DIR/testing-data.json')));" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
  fi

  if [ "$USE_DELETE_HELPER" = true ]; then
    echo "import { smartDeleteLast } from '../helper.ts';"
  fi
   if [ "$USE_CLICK_ROW_HELPER" = true ]; then
    echo "import { checkRow } from '../helper.ts';"
  fi

  read -p "Do you want to run the script again? (yes | no): " RUN_AGAIN
  if [[ "$RUN_AGAIN" == "no" ]]; then
    echo "Exiting script."
    break
  fi
done

printf "%s " "Press enter to quit"
read ans