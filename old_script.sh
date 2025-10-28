#!/bin/bash



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

replace_table_selectors() {
  local file="$1"
  
  local table_id=""
  if grep -q "Services" "$file"; then
    table_id="service-categories-table"
  elif grep -q "Packages" "$file"; then 
    table_id="membership-pack-table"
  elif grep -q "Studio" "$file"; then
    table_id="rooms-table"
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







MODULES=("REGISTRY" "PLANNING" "CRM" "MARKETING" "POS" "TRANSACTIONS")
REGISTRY_SUBMODULES=("Classes" "Services" "Packages" "Studio" "Trainer Profile" "Export")
PLANNING_SUBMODULES=("Classes" "Appointments" "No Shows" "Cancellation")
CRM_SUBMODULES=("Subscriptions" "Staff" "Roles" "Customers")
MARKETING_SUBMODULES=("Notifications" "Popin Home" "News")
POS_SUBMODULES=("Point Of Sale")
TRANSACTIONS_SUBMODULES=("Payments")

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

  echo "Available modules:"
  for i in "${!MODULES[@]}"; do
    echo "$((i+1)). ${MODULES[$i]}"
  done
  
  read -p "Select module number: " MODULE_NUM
  if [[ ! "$MODULE_NUM" =~ ^[0-9]+$ ]] || [[ "$MODULE_NUM" -lt 1 ]] || [[ "$MODULE_NUM" -gt "${#MODULES[@]}" ]]; then
    echo "Error: Invalid module selection."
    exit 1
  fi
  
  SELECTED_MODULE="${MODULES[$((MODULE_NUM-1))]}"
  
  case "$SELECTED_MODULE" in
    "REGISTRY")
      SUBMODULES=("${REGISTRY_SUBMODULES[@]}")
      ;;
    "PLANNING")
      SUBMODULES=("${PLANNING_SUBMODULES[@]}")
      ;;
    "CRM")
      SUBMODULES=("${CRM_SUBMODULES[@]}")
      ;;
    "MARKETING")
      SUBMODULES=("${MARKETING_SUBMODULES[@]}")
      ;;
    "POS")
      SUBMODULES=("${POS_SUBMODULES[@]}")
      ;;
    "TRANSACTIONS")
      SUBMODULES=("${TRANSACTIONS_SUBMODULES[@]}")
      ;;
    *)
      SUBMODULES=()
      ;;
  esac
  
  if [ ${#SUBMODULES[@]} -gt 0 ]; then
    echo "Available submodules for $SELECTED_MODULE:"
    for i in "${!SUBMODULES[@]}"; do
      echo "$((i+1)). ${SUBMODULES[$i]}"
    done
    
    read -p "Select submodule number: " SUBMODULE_NUM
    if [[ ! "$SUBMODULE_NUM" =~ ^[0-9]+$ ]] || [[ "$SUBMODULE_NUM" -lt 1 ]] || [[ "$SUBMODULE_NUM" -gt "${#SUBMODULES[@]}" ]]; then
      echo "Error: Invalid submodule selection."
      exit 1
    fi
    
    SELECTED_SUBMODULE="${SUBMODULES[$((SUBMODULE_NUM-1))]}"
  else
    SELECTED_SUBMODULE=""
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

  if [[ "$AUTH_REQUIRED" == "yes" ]]; then
    BASE_DESTINATION="/tests/secured/$TEST_TYPE/$ROLE"
  else
    BASE_DESTINATION="/tests/unsecured/$TEST_TYPE"
  fi

  MODULE_FOLDER=$(echo "$SELECTED_MODULE" | tr '[:upper:]' '[:lower:]')
  SUBMODULE_FOLDER=$(echo "$SELECTED_SUBMODULE" | tr '[:upper:]' '[:lower:]' | tr -d ' ' | tr ' ' '_')
  
  DESTINATION="$BASE_DESTINATION/$MODULE_FOLDER"
  if [ -n "$SUBMODULE_FOLDER" ]; then
    DESTINATION="$DESTINATION/$SUBMODULE_FOLDER"
  fi

  mkdir -p "$SCRIPT_DIR/$DESTINATION"

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
  echo "Selected Module: $SELECTED_MODULE"
  echo "Selected Submodule: $SELECTED_SUBMODULE"

  TARGET_FILE="$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME" 

  if [[ "$AUTH_REQUIRED" == "yes" ]]; then
    echo "Generating authenticated test..."
    npx playwright codegen --browser=chromium --output="$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME" "https://testing:NoMoreBugPlease01!@preprod.g8ts.online$ROUTE_PATH" --load-storage="$SCRIPT_DIR/$AUTH_FILE"
  else 
    echo "Generating unauthenticated test..."
    npx playwright codegen --browser=chromium --output="$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME" "https://testing:NoMoreBugPlease01!@preprod.g8ts.online/logout"
  fi

  sed -i '' 's|https://preprod\.g8ts\.online/|https://testing:NoMoreBugPlease01\!@preprod.g8ts.online/|g' "$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME"
  sed -i '' "s/test('test',/test('test_$NEW_NAME',/" "$SCRIPT_DIR/$DESTINATION/$NEW_FILENAME"

  if grep -q "getByRole('link', { name: 'Classes' })" "$TARGET_FILE"; then
    if [[ "$SELECTED_MODULE" == "REGISTRY" ]]; then
      echo "Updating Classes navigation for REGISTRY module"
      perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Classes'\'' \}\)\.click\(\);|await page.hover('\''text=REGISTRY'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Classes'\'' }).click();|g' "$TARGET_FILE"
    elif [[ "$SELECTED_MODULE" == "PLANNING" ]]; then
      echo "Updating Classes navigation for PLANNING module"
      perl -i -pe 's|await page\.getByRole\('\''link'\'', \{ name: '\''Classes'\'' \}\)\.click\(\);|await page.hover('\''text=PLANNING'\''); await page.waitForTimeout(300); await page.getByRole('\''link'\'', { name: '\''Classes'\'' }).click();|g' "$TARGET_FILE"
    fi
  fi

  if [ -n "$SELECTED_MODULE" ] && [ -n "$SELECTED_SUBMODULE" ] && [[ "$SELECTED_SUBMODULE" != "Classes" ]]; then
    echo "Updating navigation for $SELECTED_MODULE -> $SELECTED_SUBMODULE"
    
    case "$SELECTED_MODULE" in
      "REGISTRY")
        perl -i -pe "s|await page\.getByRole\('link', \{ name: '$SELECTED_SUBMODULE' \}\)\.click\(\);|await page.hover('text=REGISTRY'); await page.waitForTimeout(300); await page.getByRole('link', { name: '$SELECTED_SUBMODULE' }).click();|g" "$TARGET_FILE"
        ;;
      "PLANNING")
        perl -i -pe "s|await page\.getByRole\('link', \{ name: '$SELECTED_SUBMODULE' \}\)\.click\(\);|await page.hover('text=PLANNING'); await page.waitForTimeout(30); await page.getByRole('link', { name: '$SELECTED_SUBMODULE' }).click();|g" "$TARGET_FILE"
        ;;
      "CRM")
        perl -i -pe "s|await page\.getByRole\('link', \{ name: '$SELECTED_SUBMODULE' \}\)\.click\(\);|await page.hover('text=CRM'); await page.waitForTimeout(300); await page.getByRole('link', { name: '$SELECTED_SUBMODULE' }).click();|g" "$TARGET_FILE"
        ;;
      "MARKETING")
        perl -i -pe "s|await page\.getByRole\('link', \{ name: '$SELECTED_SUBMODULE' \}\)\.click\(\);|await page.hover('text=MARKETING'); await page.waitForTimeout(300); await page.getByRole('link', { name: '$SELECTED_SUBMODULE' }).click();|g" "$TARGET_FILE"
        ;;
      "POS")
        perl -i -pe "s|await page\.getByRole\('link', \{ name: '$SELECTED_SUBMODULE' \}\)\.click\(\);|await page.hover('text=POS'); await page.waitForTimeout(300); await page.getByRole('link', { name: '$SELECTED_SUBMODULE' }).click();|g" "$TARGET_FILE"
        ;;
      "TRANSACTIONS")
        perl -i -pe "s|await page\.getByRole\('link', \{ name: '$SELECTED_SUBMODULE' \}\)\.click\(\);|await page.hover('text=TRANSACTIONS'); await page.waitForTimeout(300); await page.getByRole('link', { name: '$SELECTED_SUBMODULE' }).click();|g" "$TARGET_FILE"
        ;;
    esac
  fi

get_category_id() {
    local file="$1"

    if grep -q "await page\.getByRole('link', { name: 'Add New' })\.nth(1)\.click();" "$file" || \
         grep -q "await page\.locator('#service-pack-table" "$file"; then
        echo "service_pack_salesAttachment"
    fi
}

() {
    local file="$1"

    if grep -q "await page\.getByRole('link', { name: 'Add New' })\.first()\.click();" "$file" || \
       grep -q "await page\.locator('.tabulator-cell').first().click();" "$file"; then
        echo "service_studio"

    elif grep -q "await page\.getByRole('link', { name: 'Add New' })\.nth(1)\.click();" "$file" || \
         grep -q "await page\.locator('#service-pack-table" "$file"; then
        echo "service_category_studio"
    fi
}


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
    "page.getByRole('combobox', { name: 'recovery' })"
    "page.getByRole('textbox', { name: 'recovery' })"
    "page.getByRole('textbox', { name: 'equiptclasses' })"
    "page.getByRole('textbox', { name: 'equiptfitness' })"
    "page.getByRole('combobox', { name: 'opengym' })"
    "page.getByRole('textbox', { name: 'Select a company to attach' })"
    "select2-class_pack_category-container"
    "select2-class_pack_salesAttachment-container"
    "page.getByRole('textbox', { name: 'CREATED' })"
    "page.getByRole('textbox', { name: 'ACCEPTED' })"
    "page.getByRole('textbox', { name: 'DECLINED' })"
    "page.getByRole('textbox', { name: 'CANCELLED' })"
    "page.getByRole('textbox', { name: 'COMPLETED' })"
    "page.getByRole('textbox', { name: 'EXPIRED' })"
    "page.getByRole('textbox', { name: 'Choose and option' })"
    "page.getByRole('textbox', { name: 'Select Payment' })"
    "page.getByRole('textbox', { name: 'Pending Payment' })"
    "page.getByRole('textbox', { name: 'Pay at the lab' })"
    "page.getByRole('textbox', { name: 'Cash' })"
    "page.getByRole('textbox', { name: 'Debit/Credit card (POS)' })"
    "page.getByRole('textbox', { name: /Credit - total \([0-9]+ credits \)/ })"
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
  

if [ "$SELECTED_SUBMODULE" = "Appointments" ]; then
  sed -i '' "s|await page.getByRole('combobox').filter({ hasText: /^\$/ }).nth(1).click();|await page.locator('#booking_nextdays').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
  
  node -e "const { getDays } = require('./utils.js'); getDays().forEach(d => console.log(d));" | while IFS= read -r date; do
    [ -z "$date" ] && continue
    
    sed -i '' "/await page.getByRole('option', { name: '$date'.*}).click();/d" "$FILE"
    sed -i '' "/await page.getByText('$date').click();/d" "$FILE"
  done
  
  sed -i '' "s|await page.getByRole('searchbox', { name: 'Search' }).click();|await page.locator('#booking_nextdays').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
fi


  sed -i '' "s|await page.getByRole('option', { name: 'Credit: .*\. Price' }).click();|await page.getByRole('option', { name: /Credit: .*\\. Price/ }).click();|g" "$FILE"
  sed -i '' -E "s|await page\.getByRole\('row', *\{ *name: *'[^']*' *\}\)\.getByRole\('button'\)\.click\(\);|await page.locator('.table-report tbody tr').first().locator('button').click();|g" "$FILE"

  for selector in "${selector_array[@]}"; do 
    if grep -q "$selector" "$FILE"; then
 if [[ "$selector" == *"page.getByRole('textbox', { name: 'Start' })"* ]]; then

  if grep -q "page.getByRole('textbox', { name: 'Start' }).fill" "$FILE"; then
    sed -i '' "s|page.getByRole('textbox', { name: 'Start' }).fill([^)]*)|page.getByRole('textbox', { name: 'Start' }).fill(CustomgetFormattedDate())|g" "$FILE"
  else
    sed -i '' "s|page.getByRole('textbox', { name: 'Start' }).click();|page.getByRole('textbox', { name: 'Start' }).fill(CustomgetFormattedDate());|g" "$FILE"
  fi




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

  if grep -q "page.getByRole('textbox', { name: 'End' }).fill" "$FILE"; then
    sed -i '' "s|page.getByRole('textbox', { name: 'End' }).fill([^)]*)|page.getByRole('textbox', { name: 'End' }).fill(CustomgetFormattedDate(true))|g" "$FILE"
  else
    sed -i '' "s|page.getByRole('textbox', { name: 'End' }).click();|page.getByRole('textbox', { name: 'End' }).fill(CustomgetFormattedDate(true));|g" "$FILE"
  fi


     
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
    
  elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Equipt Fitness' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Open Gym' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Select Studio' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Recovery' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'Equipt Classes' })"* ]]; then
        sed -i '' "/await page.getByRole('option', { name: 'Equipt Fitness' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'Open Gym' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'Recovery' }).click()/d" "$FILE"
        sed -i '' "/await page.getByRole('option', { name: 'Equipt Classes' }).click()/d" "$FILE"

        for opt in "Equipt Fitness" "Open Gym" "Recovery" "Equipt Classes"; do
        if [ "$SELECTED_SUBMODULE" = "Packages" ]; then
      
          sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#service_pack_studio').selectOption({ index: faker.number.int({ min: 1, max: 3 }) });|g" "$FILE"
        
         elif [ "$SELECTED_SUBMODULE" = "Classes" ]; then
      
          sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#event_class_studio').selectOption({ index: faker.number.int({ min: 1, max: 3 }) });|g" "$FILE"
        

         elif [ "$SELECTED_SUBMODULE" = "Services" ]; then
        SERVICE_ID=$(get_service_id "$FILE")
        
          sed -i '' "s|await page.getByRole('textbox', { name: 'Select Studio' }).click();|await page.locator('#$SERVICE_ID').selectOption({ index: faker.number.int({ min: 1, max: 3 }) });|g" "$FILE"
          sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#$SERVICE_ID').selectOption({ index: faker.number.int({ min: 1, max: 3 }) });|g" "$FILE"
        
        fi
        done

        elif [[ "$selector" == *"page.getByRole('textbox', { name: 'CREATED' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'ACCEPTED' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'DECLINED' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'EXPIRED' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'CANCELLED' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'COMPLETED' })"*  ]]; then
        
    for opt in "CREATED" "ACCEPTED" "DECLINED" "EXPIRED" "CANCELLED" "COMPLETED"; do
        if [ "$SELECTED_SUBMODULE" = "Appointments" ] || [ "$SELECTED_SUBMODULE" = "Classes" ]; then
            sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('#booking_status').selectOption({ index: faker.number.int({ min: 1, max: 3 }) });|g" "$FILE"
        fi
    done
    
    for opt in "CREATED" "ACCEPTED" "DECLINED" "EXPIRED" "CANCELLED" "COMPLETED"; do
        sed -i '' "/await page.getByRole('option', { name: '$opt' }).click();/d" "$FILE"
    done


elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Choose and option' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Select Payment' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Pending Payment' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Pay at the lab' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Cash' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Debit/Credit card (POS)' })"* ]]; then

    for opt in "Choose and option" "Select Payment" "Pending Payment" "Pay at the lab" "Cash" "Debit/Credit card (POS)"; do
        sed -i '' -E "\|await page.getByRole\('option', { name: '$opt' }\)\.click\(\);|d" "$FILE"
    done

    for opt in "Choose and option" "Select Payment" "Pending Payment" "Pay at the lab" "Cash" "Debit/Credit card (POS)"; do
        sed -i '' -E "s|await page.getByRole\('textbox', { name: '$opt' }\)\.click\(\);|await page.locator('#booking_payment').selectOption({ index: faker.number.int({ min: 1, max: 7 }) });|g" "$FILE"
    done




     elif [[ "$selector" == *"select2-class_pack_salesAttachment-container"* || \
        "$selector" == *"select2-class_pack_category-container"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Select Category' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Select a company to attach' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'Select a company to attach' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'equiptfitness' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'equiptclasses' })"* || \
        "$selector" == *"page.getByRole('combobox', { name: 'recovery' })"* || \
        "$selector" == *"page.getByRole('textbox', { name: 'recovery' })"* || \
        "$selector" == *"page.getByRole('combobox', { name: 'opengym' })"* ]]; then

count=0
for opt in "Select Category" "Select a company to attach" "equiptfitness" "equiptclasses" "recovery" "opengym" "select2-class_pack_salesAttachment-container" "select2-class_pack_category-container"; do
    if [ "$SELECTED_SUBMODULE" = "Packages" ]; then
        CAT_ID=$(get_category_id "$FILE")
        
        if [[ "$opt" == "Select Category" || "$opt" == "Select a company to attach" || "$opt" == "equiptfitness" || "$opt" == "equiptclasses" || "$opt" == "recovery" || "$opt" == "opengym" ]]; then
            if [ $count -eq 0 ]; then
                ID="#class_pack_category"
            elif [ -n "$CAT_ID" ]; then
                ID="$CAT_ID"
            else
                ID="#class_pack_salesAttachment"
            fi
            
            sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|await page.locator('$ID').selectOption({ index: faker.number.int({ min: 0, max: 1 }) });|g" "$FILE"
            
            sed -i '' "/await page.getByRole('option', { name: '.*' }).click();/d" "$FILE"
            
        elif [[ "$opt" == "select2-class_pack_salesAttachment-container" || "$opt" == "select2-class_pack_category-container" ]]; then
            if [ $count -eq 0 ]; then
                ID="#class_pack_category"
            elif [ -n "$CAT_ID" ]; then
                ID="$CAT_ID"
            else
                ID="#class_pack_salesAttachment"
            fi
            
            sed -i '' "s|await page.locator('#$opt').click();|await page.locator('$ID').selectOption({ index: faker.number.int({ min: 0, max: 1 }) });|g" "$FILE"
        fi
    fi
    ((count++))
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


CLASSES=()

if [ -f "classes.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        while IFS= read -r name; do
            CLASSES+=("$name")
        done < <(jq -r '.[] | select(type == "string")' "classes.json" 2>/dev/null)
    else
        echo "jq not found, trying grep fallback"
        while IFS= read -r name; do
            CLASSES+=("$name")
        done < <(grep -o '"[^"]*"' "classes.json" | tr -d '"' 2>/dev/null)
    fi
    # echo "Loaded ${#CLASSES[@]} classes from classes.json"
else
    echo "classes.json not found, skipping class processing"
fi

if [[ "$SELECTED_SUBMODULE" = "Classes" && "$SELECTED_MODULE" = "PLANNING" ]]; then
    for classes in "${CLASSES[@]}"; do
        perl -i -0777 -pe "
            # 🔥 Replace any existing selectOption calls with dynamic index range
            s|await page\.locator\('#event_occurrence_class'\)\.selectOption\(\{ index: faker\.number\.int\(\{ min: \d+, max: \d+ \}\) \}\);|await page.locator('#event_occurrence_class').selectOption({ index: faker.number.int({ min: 0, max: $max_index }) });|g;
            
            # 🔥 Replace full sequence: Select Class textbox + option click for specific class
            s|await page\.getByRole\('textbox', \{ name: 'Select Class' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '\Q$classes\E'(, exact: true)? \}\)\.click\(\);|await page.locator('#event_occurrence_class').selectOption({ index: faker.number.int({ min: 0, max: $max_index }) });|gs;
            
            # 🔥 Replace orphaned option clicks for specific class names only
            s|await page\.getByRole\('option', \{ name: '\Q$classes\E'(, exact: true)? \}\)\.click\(\);|await page.locator('#event_occurrence_class').selectOption({ index: faker.number.int({ min: 0, max: $max_index }) });|g;
            
            # 🔥 Replace textbox/combobox clicks for specific class names
            s|await page\.getByRole\('textbox', \{ name: '\Q$classes\E' \}\)\.click\(\);|await page.locator('#event_occurrence_class').selectOption({ index: faker.number.int({ min: 0, max: $max_index }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$classes\E' \}\)\.click\(\);|await page.locator('#event_occurrence_class').selectOption({ index: faker.number.int({ min: 0, max: $max_index }) });|g;
        " "$FILE"
    done
    
    perl -i -0777 -pe "
        s|await page\.getByRole\('textbox', \{ name: 'Select Class' \}\)\.click\(\);|await page.locator('#event_occurrence_class').selectOption({ index: faker.number.int({ min: 0, max: $max_index }) });|g;
        s|await page\.getByRole\('combobox', \{ name: 'Select Class' \}\)\.click\(\);|await page.locator('#event_occurrence_class').selectOption({ index: faker.number.int({ min: 0, max: $max_index }) });|g;
    " "$FILE"

elif [[ "$SELECTED_SUBMODULE" = "Classes" && "$SELECTED_MODULE" = "REGISTRY" ]]; then
    for classes in "${CLASSES[@]}"; do
        perl -i -0777 -pe "
            # 🔥 Replace any existing selectOption calls with dynamic index range
            s|await page\.locator\('#layout_class'\)\.selectOption\(\{ index: faker\.number\.int\(\{ min: \d+, max: \d+ \}\) \}\);|await page.locator('#layout_class').selectOption({ index: faker.number.int({ min: 0, max: 2 }) });|g;
            
            # 🔥 Replace full sequence: Select Class textbox + option click for specific class
            s|await page\.getByRole\('textbox', \{ name: 'Select Class' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '\Q$classes\E'(, exact: true)? \}\)\.click\(\);|await page.locator('#layout_class').selectOption({ index: faker.number.int({ min: 0, max: 2 }) });|gs;
            
            # 🔥 Replace orphaned option clicks for specific class names only
            s|await page\.getByRole\('option', \{ name: '\Q$classes\E'(, exact: true)? \}\)\.click\(\);|await page.locator('#layout_class').selectOption({ index: faker.number.int({ min: 0, max: 1 }) });|g;
            
            # 🔥 Replace textbox/combobox clicks for specific class names
            s|await page\.getByRole\('textbox', \{ name: '\Q$classes\E' \}\)\.click\(\);|await page.locator('#layout_class').selectOption({ index: faker.number.int({ min: 0, max: 2 }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$classes\E' \}\)\.click\(\);|await page.locator('#layout_class').selectOption({ index: faker.number.int({ min: 0, max: 2 }) });|g;
        " "$FILE"
    done

    perl -i -0777 -pe "
        s|await page\.getByRole\('textbox', \{ name: 'Select Class' \}\)\.click\(\);|await page.locator('#layout_class').selectOption({ index: faker.number.int({ min: 0, max: 2 }) });|g;
        s|await page\.getByRole\('combobox', \{ name: 'Select Class' \}\)\.click\(\);|await page.locator('#layout_class').selectOption({ index: faker.number.int({ min: 0, max: 2 }) });|g;
    " "$FILE"
fi


TRAINER_NAMES=()

if [ -f "trainers.json" ]; then

  if command -v jq >/dev/null 2>&1; then

    while IFS= read -r name; do
      TRAINER_NAMES+=("$name")
    done < <(jq -r '.[] | select(type == "string")' "trainers.json" 2>/dev/null)

  else
    echo "jq not found, trying grep fallback"
    while IFS= read -r name; do
      TRAINER_NAMES+=("$name")
    done < <(grep -o '"[^"]*"' "trainers.json" | tr -d '"' 2>/dev/null)
  fi

  # echo "Loaded ${#TRAINER_NAMES[@]} trainer names from trainers.json"
else
  echo "trainers.json not found, skipping trainer name processing"
fi


if [ ${#TRAINER_NAMES[@]} -gt 0 ]; then
  ESCAPED_NAMES=()
  for n in "${TRAINER_NAMES[@]}"; do
    ESCAPED_NAMES+=("$(printf "%s" "$n" | sed 's/[][(){}.^$*+?|\\/]/\\&/g')")
  done

  trainer_pattern=$(printf "%s|" "${ESCAPED_NAMES[@]}")
  trainer_pattern=${trainer_pattern%|}

 
  for trainer in "${TRAINER_NAMES[@]}"; do
    
    if [ "$SELECTED_SUBMODULE" = "Appointments" ]; then
        perl -i -pe "
            s/await page\.getByRole\('textbox', \{ name: 'Select Trainer' \}\)\.click\(\);.*?await page\.getByRole\('option', \{ name: '\Q$trainer\E'(, exact: true)? \}\)\.click\(\);/await page.locator('#booking_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            s/await page\.getByRole\('option', \{ name: '\Q$trainer\E'(, exact: true)? \}\)\.click\(\);//g;
            s|await page\.getByRole\('textbox', \{ name: '\Q$trainer\E' \}\)\.click\(\);|await page.locator('#booking_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$trainer\E' \}\)\.click\(\);|await page.locator('#booking_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('textbox', \{ name: 'Select Trainer' \}\)\.click\(\);|await page.locator('#booking_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
        " "$FILE"
        
    else
        perl -i -pe "
            s/await page\.getByRole\('textbox', \{ name: 'Select Trainer' \}\)\.click\(\);.*?await page\.getByRole\('option', \{ name: '\Q$trainer\E'(, exact: true)? \}\)\.click\(\);/await page.locator('#event_occurrence_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            s/await page\.getByRole\('option', \{ name: '\Q$trainer\E'(, exact: true)? \}\)\.click\(\);//g;
            s|await page\.getByRole\('textbox', \{ name: '\Q$trainer\E' \}\)\.click\(\);|await page.locator('#event_occurrence_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$trainer\E' \}\)\.click\(\);|await page.locator('#event_occurrence_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('textbox', \{ name: 'Select Trainer' \}\)\.click\(\);|await page.locator('#event_occurrence_trainer').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
        " "$FILE"
    fi
done
fi


SERVICES=()

if [ -f "services.json" ]; then
  if command -v jq >/dev/null 2>&1; then
    while IFS= read -r name; do
      SERVICES+=("$name")
    done < <(jq -r '.[] | select(type == "string")' "services.json" 2>/dev/null)
  else
    echo "jq not found, trying grep fallback"
    while IFS= read -r name; do
      SERVICES+=("$name")
    done < <(grep -o '"[^"]*"' "services.json" | tr -d '"' 2>/dev/null)
  fi
else
  echo "services.json not found, skipping service name processing"
fi

if [ ${#SERVICES[@]} -gt 0 ]; then
  ESCAPED_NAMES=()
  for n in "${SERVICES[@]}"; do
    ESCAPED_NAMES+=("$(printf "%s" "$n" | sed 's/[][(){}.^$*+?|\\/]/\\&/g')")
  done

  service_pattern=$(printf "%s|" "${ESCAPED_NAMES[@]}")
  service_pattern=${service_pattern%|}

  if [ "$SELECTED_SUBMODULE" = "Appointments" ]; then
    perl -i -0pe "

      s/await page\.locator\('#booking_service_list'\)\.selectOption\(\{ index: faker\.number\.int\(\{ min: 1, max: 2 \}\) \}\);\s*await page\.getByRole\('option', \{ name: '[^']*' \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/await page\.getByRole\('textbox', \{ name: 'Select Service' \}\)\.click\(\);\s*await page\.locator\('#select2-booking_service_list-result-[^']*'\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/await page\.getByRole\('combobox', \{ name: 'Select Service' \}\)\.click\(\);\s*await page\.locator\('#select2-booking_service_list-result-[^']*'\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/await page\.getByRole\('textbox', \{ name: 'Select Service' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '(?:$service_pattern)'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
      s/await page\.getByRole\('option', \{ name: '(?:$service_pattern)'(?:, exact: true)? \}\)\.click\(\);//g;
      s/await page\.getByRole\('textbox', \{ name: '(?:$service_pattern)' \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/await page\.getByRole\('combobox', \{ name: '(?:$service_pattern)' \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/await page\.getByRole\('textbox', \{ name: 'Select Service' \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
    " "$FILE"
  else
    perl -i -pe "
      s/await page\.getByRole\('textbox', \{ name: 'Select Service' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '(?:$service_pattern)'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
     s/await page\.getByRole\('option', \{ name: '(?:$service_pattern)'(?:, exact: true)? \}\)\.click\(\);//g;
      s/await page\.getByRole\('textbox', \{ name: '(?:$service_pattern)' \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/await page\.getByRole\('combobox', \{ name: '(?:$service_pattern)' \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/await page\.getByRole\('textbox', \{ name: 'Select Service' \}\)\.click\(\);/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
      s/(await page\.locator\('#booking_service_list'\)\.selectOption\(\{ index: faker\.number\.int\(\{ min: 1, max: 2 \}\) \}\);\s*)+/await page.locator('#booking_service_list').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });\n/g;
    " "$FILE"
  fi
fi



ROOMS=()

if [ -f "rooms.json" ]; then

  if command -v jq >/dev/null 2>&1; then

    while IFS= read -r name; do
      ROOMS+=("$name")
    done < <(jq -r '.[] | select(type == "string")' "rooms.json" 2>/dev/null)

  else
    echo "jq not found, trying grep fallback"
    while IFS= read -r name; do
      ROOMS+=("$name")
    done < <(grep -o '"[^"]*"' "rooms.json" | tr -d '"' 2>/dev/null)
  fi

else
  echo "rooms.json not found, skipping trainer name processing"
fi

if [ ${#ROOMS[@]} -gt 0 ]; then
  for room in "${ROOMS[@]}"; do
    if [ "$SELECTED_SUBMODULE" = "Appointments" ]; then
        perl -i -0777 -pe "
            # Handle add page pattern: 'Select Room' textbox + specific room option
            s/await page\.getByRole\('textbox', \{ name: 'Select Room' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#booking_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            
            # Handle edit page pattern: room name textbox + different room option
            s/await page\.getByRole\('textbox', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '[^']*'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#booking_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            
            # Clean up any remaining standalone clicks
            s/await page\.getByRole\('option', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);//g;
            s/await page\.getByRole\('textbox', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#booking_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
            s/await page\.getByRole\('combobox', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#booking_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
        " "$FILE"
    # else
    #     perl -i -0777 -pe "
    #         # Handle add page pattern: 'Select Room' textbox + specific room option
    #         s/await page\.getByRole\('textbox', \{ name: 'Select Room' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#event_occurrence_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            
    #         # Handle edit page pattern: room name textbox + different room option  
    #         s/await page\.getByRole\('textbox', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '[^']*'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#event_occurrence_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            
    #         # Clean up any remaining standalone clicks
    #         s/await page\.getByRole\('option', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);//g;
    #         s/await page\.getByRole\('textbox', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#event_occurrence_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
    #         s/await page\.getByRole\('combobox', \{ name: '\Q$room\E'(?:, exact: true)? \}\)\.click\(\);/await page.locator('#event_occurrence_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/g;
    #     " "$FILE"
    fi
  done
  
  sed -i '' "s|await page.getByRole('textbox', { name: 'Select Room' }).click();|await page.locator('#booking_room').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g" "$FILE"
fi



SERVICE_CATEGORY=()

if [ -f "service_category.json" ]; then
  if command -v jq >/dev/null 2>&1; then
    while IFS= read -r name; do
      SERVICE_CATEGORY+=("$name")
    done < <(jq -r '.[] | select(type == "string")' "service_category.json" 2>/dev/null)
  else
    echo "jq not found, trying grep fallback"
    while IFS= read -r name; do
      SERVICE_CATEGORY+=("$name")
    done < <(grep -o '"[^"]*"' "service_category.json" | tr -d '"' 2>/dev/null)
  fi
else
  echo "service_category.json not found, skipping"
fi

if [ ${#SERVICE_CATEGORY[@]} -gt 0 ]; then
  for category in "${SERVICE_CATEGORY[@]}"; do
    esc_category=$(printf "%s" "$category" | sed -e 's/[]\/$*.^[]/\\&/g' -e "s/'/\\\\'/g")

    if [[ "$SELECTED_SUBMODULE" = "Services" ]]; then
      perl -0777 -i -pe "
        s|await page\.getByRole\('textbox', \{ name: 'Select Category' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '$esc_category'.*?\}\)\.click\(\);|
           await page.locator('#service_category_service').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|gs;
        s|await page\.getByRole\('textbox', \{ name: '$esc_category'.*?\}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '.*?' \}\)\.click\(\);|
           await page.locator('#service_category_service').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|gs;
      " "$FILE"
      else 
        perl -0777 -i -pe "
        s|await page\.getByRole\('textbox', \{ name: 'Select Service Category' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '$esc_category'.*?\}\)\.click\(\);|
           await page.locator('#booking_serviceCategory').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|gs;

        s|await page\.getByRole\('textbox', \{ name: '$esc_category'.*?\}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '.*?' \}\)\.click\(\);|
           await page.locator('#booking_serviceCategory').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|gs;
      " "$FILE"
    fi

  done
fi


LOCATIONS=()

if [ -f "location.json" ]; then

  if command -v jq >/dev/null 2>&1; then

    while IFS= read -r name; do
      LOCATIONS+=("$name")
    done < <(jq -r '.[] | select(type == "string")' "location.json" 2>/dev/null)

  else
    echo "jq not found, trying grep fallback"
    while IFS= read -r name; do
      LOCATIONS+=("$name")
    done < <(grep -o '"[^"]*"' "location.json" | tr -d '"' 2>/dev/null)
  fi

  # echo "Loaded ${#TRAINER_NAMES[@]} trainer names from location.json"
else
  echo "location.json not found, skipping trainer name processing"
fi

if [ ${#LOCATIONS[@]} -gt 0 ]; then
  ESCAPED_NAMES=()
  for n in "${LOCATIONS[@]}"; do
    ESCAPED_NAMES+=("$(printf "%s" "$n" | sed 's/[][(){}.^$*+?|\\/]/\\&/g')")
  done

  location_pattern=$(printf "%s|" "${ESCAPED_NAMES[@]}")
  location_pattern=${location_pattern%|}

 
  for location in "${LOCATIONS[@]}"; do
    
    if [[ "$SELECTED_SUBMODULE" = "Classes" && "$SELECTED_MODULE" = "PLANNING" ]]; then
        perl -i -pe "
            s/await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);.*?await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);/await page.locator('#event_occurrence_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            s/await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);//g;
            s|await page\.getByRole\('textbox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#event_occurrence_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#event_occurrence_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);|await page.locator('#event_occurrence_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
        " "$FILE"
elif [[ "$SELECTED_SUBMODULE" = "Classes" && "$SELECTED_MODULE" = "REGISTRY" ]]; then
  perl -i -pe "
            s/await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);.*?await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);/await page.locator('#layout_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            s/await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);//g;
            s|await page\.getByRole\('textbox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#layout_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#layout_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);|await page.locator('#layout_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
        " "$FILE"
    
    elif [[ "$SELECTED_SUBMODULE" = "Services" ]]; then
  perl -i -pe "
            s/await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);.*?await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);/await page.locator('#service_defaultLocation').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            s/await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);//g;
            s|await page\.getByRole\('textbox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#service_defaultLocation').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#service_defaultLocation').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);|await page.locator('#service_defaultLocation').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
        " "$FILE"
    else

        perl -i -pe "
            s/await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);.*?await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);/await page.locator('#booking_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });/gs;
            s/await page\.getByRole\('option', \{ name: '\Q$location\E'(, exact: true)? \}\)\.click\(\);//g;
            s|await page\.getByRole\('textbox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#booking_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('combobox', \{ name: '\Q$location\E' \}\)\.click\(\);|await page.locator('#booking_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
            s|await page\.getByRole\('textbox', \{ name: 'Select Location' \}\)\.click\(\);|await page.locator('#booking_location').selectOption({ index: faker.number.int({ min: 1, max: 2 }) });|g;
        " "$FILE"
    fi
done
fi



VALIDITY_OPTIONS=()

get_validity_id() {
    local file="$1"

    if grep -q "await page\.getByRole('link', { name: 'Add New' })\.first()\.click();" "$file" || \
       grep -q "await page\.locator('.tabulator-cell').first().click();" "$file"; then
        echo "class_pack_validity"

    elif grep -q "await page\.getByRole('link', { name: 'Add New' })\.nth(1)\.click();" "$file" || \
         grep -q "await page\.locator('#service-pack-table" "$file"; then
        echo "service_pack_validity"

    elif grep -q "await page\.getByRole('link', { name: 'Add New' })\.nth(2)\.click();" "$file"; then
        echo "membership_pack_type"

    else
        echo "class_pack_validity"
    fi
}




if [ -f "validity.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        while IFS= read -r option; do
            VALIDITY_OPTIONS+=("$option")
        done < <(jq -r '.[] | select(type == "string")' "validity.json" 2>/dev/null)
    else
        echo "jq not found, trying grep fallback"
        while IFS= read -r option; do
            VALIDITY_OPTIONS+=("$option")
        done < <(grep -o '"[^"]*"' "validity.json" | tr -d '"' 2>/dev/null)
    fi
    
else
    echo "validity.json not found, skipping validity option processing"
fi

if [ ${#VALIDITY_OPTIONS[@]} -gt 0 ]; then
    ESCAPED_OPTIONS=()
    for option in "${VALIDITY_OPTIONS[@]}"; do
        ESCAPED_OPTIONS+=("$(printf "%s" "$option" | sed 's/[][(){}.^$*+?|\\/]/\\&/g')")
    done
    
    validity_pattern=$(printf "%s|" "${ESCAPED_OPTIONS[@]}")
    validity_pattern=${validity_pattern%|}
    
    for validity in "${VALIDITY_OPTIONS[@]}"; do
        VALIDITY_ID=$(get_validity_id "$FILE")
        
        if [ "$SELECTED_SUBMODULE" = "Packages" ]; then
perl -i -pe "
    s{await page\.getByRole\('textbox', \{ name: 'Select [Vv]alidity' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '\Q$validity\E'(, exact: true)? \}\)\.click\(\);}
     {await page.locator('#booking_validity').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });}gs;

    # Remove standalone option clicks
    s{await page\.getByRole\('option', \{ name: '\Q$validity\E'(, exact: true)? \}\)\.click\(\);}{}g;

    # Replace textbox/combobox with specific validity option
    s{await page\.getByRole\('textbox', \{ name: '\Q$validity\E' \}\)\.click\(\);}
     {await page.locator('#$VALIDITY_ID').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });}g;

    s{await page\.getByRole\('combobox', \{ name: '\Q$validity\E' \}\)\.click\(\);}
     {await page.locator('#$VALIDITY_ID').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });}g;

    # Replace generic Select Validity textbox
    s{await page\.getByRole\('textbox', \{ name: 'Select [Vv]alidity' \}\)\.click\(\);}
     {await page.locator('#$VALIDITY_ID').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });}g;

    # 🔥 New: Replace raw validity-like textboxes (month, months, day, days, week, weeks, year, years)
    s{await page\.getByRole\('(textbox|combobox)', \{ name: '(month|months|day|days|week|weeks|year|years)' \}\)\.click\(\);}
     {await page.locator('#$VALIDITY_ID').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });}gi;
" "$FILE"


        else
            perl -i -pe "
                # Replace the two-line pattern: textbox click followed by option click
                s/await page\.getByRole\('textbox', \{ name: 'Select [Vv]alidity' \}\)\.click\(\);\s*await page\.getByRole\('option', \{ name: '\Q$validity\E'(, exact: true)? \}\)\.click\(\);/await page.locator('#event_occurrence_validity').selectOption({ index: 0 });\nawait page.locator('#event_occurrence_validity').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });/gs;
                
                # Remove standalone option clicks
                s/await page\.getByRole\('option', \{ name: '\Q$validity\E'(, exact: true)? \}\)\.click\(\);//g;
                
                # Replace other selector patterns with reset + random
                s|await page\.getByRole\('textbox', \{ name: '\Q$validity\E' \}\)\.click\(\);|await page.locator('#$VALIDITY_ID').selectOption({ index: 0 });\nawait page.locator('#$VALIDITY_ID').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });|g;
                s|await page\.getByRole\('combobox', \{ name: '\Q$validity\E' \}\)\.click\(\);|await page.locator('#$VALIDITY_ID').selectOption({ index: 0 });\nawait page.locator('#$VALIDITY_ID').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });|g;
                s|await page\.getByRole\('textbox', \{ name: 'Select [Vv]alidity' \}\)\.click\(\);|await page.locator('#$VALIDITY_ID').selectOption({ index: 0 });\nawait page.locator('#$VALIDITY_ID').selectOption({ index: faker.number.int({ min: 1, max: 30 }) });|g;
            " "$FILE"
        fi
    done
fi


sed -i '' -E "s|await page\.locator\('tr:nth-child\([^)]+\) > td:nth-child\([^)]+\) > \.font-medium > div > \.flex\.items-center\.text-theme-6'\)\.click\(\);|await page.locator('.delete-item').last().click();|g" "$FILE"
sed -i '' -E "s|await page\.locator\('tr:nth-child\([^)]+\) > td:nth-child\([^)]+\) > \.font-medium > div > \.flex\.items-center\.text-theme-6'\)\.click\(\);|await page.locator('.delete-item').last().click();|g" "$FILE"
sed -i '' -E "s|await page\.getByRole\('row', *\{ *name: *'[^']*' *\}\)\.getByRole\('link'\)\.nth\(([0-9]+)\)\.click\(\);|await page.getByRole('row', { name: '' }).getByRole('link').nth(3).first().click();|g" "$FILE"
  #  sed -i '' -E "s|await page\.getByRole\('row', *\{ *name: *'[^']*' *\}\)\.getByRole\('link'\)\.nth\(([0-9]+)\)\.click\(\);|await page.getByRole('row', { name: '' }).getByRole('link').last().click();|g" "$FILE"
                                                                                                   
  sed -i '' "s|await page.locator('#classes div').filter({ hasText: .* }).nth(1).click();|await page.locator('.toggle_details').first().click();|g" "$FILE"
  sed -i '' "s|await page.locator('#select2-event_class_classPacks-result-[^']*').click();|await page.locator('#event_class_classPacks').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
  sed -i '' "s|await page.locator('#select2-service_pack_services-result-[^']*').click();|await page.locator('#service_pack_services').selectOption({ index: faker.number.int({ min: 1, max: 10 }) });|g" "$FILE"
  
  
  replace_table_selectors "$TARGET_FILE"
    if grep -q "page.getByRole('link', { name: 'Delete' })" "$TARGET_FILE"; then
      sed -i '' -E "s|await page\.getByRole\('link', \{ name: 'Delete' \}\)(\.nth\([0-9]+\))?\.click\(\);|await deleteRow(page);|g" "$TARGET_FILE"
      echo "import { deleteRow } from './../../../../$SCRIPT_DIR/helper.ts';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
      USE_DELETE_HELPER=true
    fi

# if grep -q "page.goto('https://preprod.g8ts.online/admin/registry/class-pack/form')" "$TARGET_FILE" || 
#    grep -q "page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/registry/class-pack/form')" "$TARGET_FILE"; then
#   echo "Detected class-pack form navigation"
  
 
# fi

#   if grep -qE "await page\.locator\('div:nth-child\([0-9]+\) > div'\)\.first\(\)\.click\(\);" "$TARGET_FILE"; then
#   sed -i '' -i -E "s|await page\.locator\('div:nth-child\([0-9]+\) > div'\)\.first\(\)\.click\(\);|await checkRow(page, 'membership-pack-table');|g" "$TARGET_FILE"
#   echo "import { checkRow } from './../../../../$SCRIPT_DIR/helper.ts';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
#   USE_CLICK_ROW_HELPER=true
# fi

if grep -qE "await page\.locator\('#[^']+ > \.tabulator-tableHolder > \.tabulator-table > div:nth-child\([0-9]+\) > div'\)\.first\(\)\.click\(\);" "$TARGET_FILE"; then
  sed -i '' -E "s|await page\.locator\('#([-a-zA-Z0-9]+) > \.tabulator-tableHolder > \.tabulator-table > div:nth-child\([0-9]+\) > div'\)\.first\(\)\.click\(\);|await checkRow(page, '\1');|g" "$TARGET_FILE"
USE_CLICK_ROW_HELPER=true
fi

if grep -qE "await page\.locator\('#[^']+ \.tabulator-row'\)\.first\(\)\.locator\('\.tabulator-cell'\)\.first\(\)\.click\(\);" "$TARGET_FILE"; then
  sed -i '' -E "s|await page\.locator\('#([-a-zA-Z0-9]+) \.tabulator-row'\)\.first\(\)\.locator\('\.tabulator-cell'\)\.first\(\)\.click\(\);|await checkRow(page, '\1');|g" "$TARGET_FILE"
USE_CLICK_ROW_HELPER=true
fi


  
  { echo "import { checkRow } from './../../../../../../$SCRIPT_DIR/helper.ts';"; cat "$TARGET_FILE"; } > temp && mv temp "$TARGET_FILE"
# fi


  echo "import { faker } from '@faker-js/faker';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"

  if [[ "$AUTH_REQUIRED" == "yes" ]]; then
    echo "import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate } from './../../../../../../$SCRIPT_DIR/utils.js';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
  else
    echo "const fixtures_data = JSON.parse(JSON.stringify(require('./../../../$SCRIPT_DIR/testing-data.json')));" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
  fi

  if [ "$USE_DELETE_HELPER" = true ]; then
    echo "import { deleteRow } from '../helper.ts';"
  fi
   if [ "$USE_CLICK_ROW_HELPER" = true ]; then
    echo "import { checkRow } from '../helper.ts';"
  fi

 

  if [[ "$AUTH_REQUIRED" == "yes" ]]; then
    RELATIVE_PATH="../../../../"
  else
    RELATIVE_PATH="../../../"
  fi


  sed -i '' "s|from './../../../../|from '${RELATIVE_PATH}|g" "$TARGET_FILE"
  sed -i '' "s|from './../../../|from '${RELATIVE_PATH}|g" "$TARGET_FILE"

  read -p "Do you want to run the script again? (yes | no): " RUN_AGAIN
  if [[ "$RUN_AGAIN" == "no" ]]; then
    echo "Exiting script."
    break
  fi
done

printf "%s " "Press enter to quit"
read ans