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

replace_dynamic_id_locators() {
  local file="$1"

 sed -i '' -E "s|await page\.locator\('\[id=\"[0-9]+\"\] > \.table-report__action > \.flex\.justify-center > \.flex\.items-center\.ml-4'\)\.click\(\);|await page.locator('.table-report__action >> .flex.justify-center >> .flex.items-center.ml-4').last().click();|g" "$file"

  sed -i '' -E "s|await page\.locator\('\[id=\"[0-9]+\"\] > \.table-report__action > \.flex\.justify-center > \.flex\.items-center\.text-theme-6'\)\.click\(\);|await page.locator('.table-report__action >> .flex.justify-center >> .flex.items-center.text-theme-6').last().click();|g" "$file"

echo "llooopps"
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
    echo "Error: Invalid module selection"
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

# get_category_id() {
#     local file="$1"

#     if grep -q "await page\.getByRole('link', { name: 'Add New' })\.nth(1)\.click();" "$file" || \
#          grep -q "await page\.locator('#service-pack-table" "$file"; then
#         echo "service_pack_salesAttachment"
#     fi
# }

# get_service_id() {
#     local file="$1"

#     if grep -q "await page\.getByRole('link', { name: 'Add New' })\.first()\.click();" "$file" || \
#        grep -q "await page\.locator('.tabulator-cell').first().click();" "$file"; then
#         echo "service_studio"

#     elif grep -q "await page\.getByRole('link', { name: 'Add New' })\.nth(1)\.click();" "$file" || \
#          grep -q "await page\.locator('#service-pack-table" "$file"; then
#         echo "service_category_studio"
#     fi
# }

perl -i -pe "s|(await page\.getByRole\('option', \{[^\}]+\}\))\.click\(\);|\$1.last().click();|g" "$TARGET_FILE"
perl -i -pe "s|await page.getByRole\('option', { name: 'Credit: [0-9]+\. Price' }\)\.last\(\)\.click\(\);|await page.getByRole('option', { name: /Credit: .*\\. Price/ }).last().click();|g" "$TARGET_FILE"
perl -i -pe "s/(page\.locator\('\.flex\.items-center\.text-theme-6\.delete-item\.tooltip'\))\.click\(\)/\$1.last().click()/g" "$TARGET_FILE"

 replace_dynamic_id_locators "$TARGET_FILE"


  selector_array=(
    "page.getByRole('textbox', { name: 'days' })"
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
    "page.getByText('Select a status')"
    "page.getByRole('textbox', { name: 'Select an option' })"
    "page.getByRole('option', { name: 'Mohammed Naseef MM Pin: 58694' })"
    "page.getByText('Phone:')"
    "page.getByRole('textbox', { name: 'Pincode' })"
    "page.getByText('' +  Pin: 58694')"
    "page.goto('https://testing:NoMoreBugPlease01%21@preprod.g8ts.online/admin/planning/event-occurrence');"
    "page.getByRole('link', { name: 'Export' })"
    "page.getByRole('link', { name: 'Trainer Profile' })"
    "page.getByRole('link', { name: 'Studio' })"
    "page.getByRole('link', { name: 'Packages' })"
    "page.getByRole('link', { name: 'Services' })"
    "page.getByRole('link', { name: 'Customers' })"
    "page.locator('#select2-class_booking_status-result-[^-]*-[1-4]')"
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
    "page.getByRole('textbox', { name: 'days' })"
    "page.getByRole('textbox', { name: 'day' })"
    "page.getByRole('textbox', { name: 'weeks' })"  
    "page.getByRole('textbox', { name: 'month' })"
    "page.getByRole('textbox', { name: 'months' })"
    "page.getByRole('textbox', { name: 'week' })"
    "page.locator('#select2-service_pack_services-result-"
    "page.locator('#select2-membership_pack_classPacks-result-"
    "page.locator('#event_occurrence_date')"
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


sed -i '' -E "s|getByRole\('row', *\{ *name: *'([0-9]+ )([^']+)' *\}\)|getByRole('row', { name: /\2/ })|g" "$FILE"


if grep -q "page.locator.*getByRole('link', { name: 'Delete' })" "$TARGET_FILE" || \
   grep -q "page.getByRole('link', { name: 'Delete' })" "$TARGET_FILE"; then
  
  sed -i '' -E "s|await page\.locator\('\[id=\"[0-9]+\"\]'\)\.getByRole\('link', \{ name: 'Delete' \}\)\.click\(\);|await page.getByRole('link', { name: 'Delete' }).first().click();|g" "$TARGET_FILE"
  
  sed -i '' -E "s|await page\.getByRole\('link', \{ name: 'Delete' \}\)(\.nth\([0-9]+\))?\.click\(\);|await page.getByRole('link', { name: 'Delete' }).first().click();|g" "$TARGET_FILE"
  
  echo "✓ Replaced Delete selectors with .first() pattern"
fi

if grep -q "page.locator.*getByRole('link', { name: 'Edit' })" "$TARGET_FILE" || \
   grep -q "page.getByRole('link', { name: 'Edit' })" "$TARGET_FILE"; then
  
  sed -i '' -E "s|await page\.locator\('\[id=\"[0-9]+\"\]'\)\.getByRole\('link', \{ name: 'Edit' \}\)\.click\(\);|await page.getByRole('link', { name: 'Edit' }).first().click();|g" "$TARGET_FILE"
  
  sed -i '' -E "s|await page\.getByRole\('link', \{ name: 'Edit' \}\)(\.nth\([0-9]+\))?\.click\(\);|await page.getByRole('link', { name: 'Edit' }).first().click();|g" "$TARGET_FILE"
  
  echo "✓ Replaced Delete selectors with .first() pattern"
fi

if grep -qE "page\.locator\('\[id=\"[0-9]+\"\]" "$TARGET_FILE"; then
  
  sed -i '' -E "s|await page\.locator\('\[id=\"[0-9]+\"\] div'\)\.filter\(\{ hasText: '([^']+)' \}\)\.first\(\)\.click\(\);|await page.locator('div').filter({ hasText: '\1' }).first().click();|g" "$TARGET_FILE"
  
  sed -i '' -E "s|await page\.locator\(\"\[id=\\\"[0-9]+\\\"\] div\"\)\.filter\(\{ hasText: \"([^\"]+)\" \}\)\.first\(\)\.click\(\);|await page.locator('div').filter({ hasText: \"\1\" }).first().click();|g" "$TARGET_FILE"
  
  perl -i -pe "s|await page\.locator\('\[id=\"\d+\"\] div'\)\.filter\(\{ hasText: '([^']+)' \}\)\.first\(\)\.click\(\);|await page.locator('div').filter({ hasText: '\$1' }).first().click();|g" "$TARGET_FILE"
  
  echo "✓ Replaced dynamic ID selectors with .filter() pattern"
fi

  for selector in "${selector_array[@]}"; do 
    if grep -q "$selector" "$FILE"; then


      if [[ "$selector" == *"page.getByRole('textbox', { name: 'days' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'weeks' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'week' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'day' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'month' })"* || \
            "$selector" == *"page.getByRole('textbox', { name: 'months' })"* ]]; then
       for opt in days day weeks week months month; do
  sed -i '' "s|await page.getByRole('textbox', { name: '$opt' }).click();|const displayedValue = await page.getByRole('textbox', { name: '$opt' }).evaluate(el => el.textContent?.trim());\nawait page.getByRole('textbox', { name: displayedValue }).click();|g" "$FILE"
  done

 elif [[ "$selector" == *"page.getByRole('textbox', { name: 'Start' })"* ]]; then

  if grep -q "page.getByRole('textbox', { name: 'Start' }).fill" "$FILE"; then
    sed -i '' "s|page.getByRole('textbox', { name: 'Start' }).fill([^)]*)|page.getByRole('textbox', { name: 'Start' }).fill(CustomgetFormattedDate())|g" "$FILE"
  else
    sed -i '' "s|page.getByRole('textbox', { name: 'Start' }).click();|page.getByRole('textbox', { name: 'Start' }).fill(CustomgetFormattedDate());|g" "$FILE"
  fi

  elif [[ "$selector" == *"page.locator('#event_occurrence_date')"* ]]; then
  
            grep "page.locator('#event_occurrence_date').fill" "$FILE" | \
            sed -n "s/.*fill('\([^']*\)').*/\1/p" | while read -r value; do
                date_filled=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
                sed -i '' "s|page.locator('#event_occurrence_date').fill('$date_filled')|page.locator('#event_occurrence_date').fill(getCurrentDate())|g" "$FILE"
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


sed -i '' -E "s|await page\.locator\('tr:nth-child\([^)]+\) > td:nth-child\([^)]+\) > \.font-medium > div > \.flex\.items-center\.text-theme-6'\)\.click\(\);|await page.locator('.delete-item').last().click();|g" "$FILE"
sed -i '' -E "s|await page\.locator\('tr:nth-child\([^)]+\) > td:nth-child\([^)]+\) > \.font-medium > div > \.flex\.items-center\.text-theme-6'\)\.click\(\);|await page.locator('.delete-item').last().click();|g" "$FILE"
sed -i '' -E "s|await page\.getByRole\('row', *\{ *name: *'[^']*' *\}\)\.getByRole\('link'\)\.nth\(([0-9]+)\)\.click\(\);|await page.getByRole('row', { name: '' }).getByRole('link').nth(3).first().click();|g" "$FILE"                                                                                                   
sed -i '' "s|await page.locator('#classes div').filter({ hasText: .* }).nth(1).click();|await page.locator('.toggle_details').first().click();|g" "$FILE"

  if [[ "$AUTH_REQUIRED" == "yes" ]]; then
    echo "import { getFormattedDate,getFormattedDateOnly,CustomgetFormattedDate,getCurrentDate } from './../../../../../../$SCRIPT_DIR/utils.js';" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
  else
    echo "const fixtures_data = JSON.parse(JSON.stringify(require('./../../../$SCRIPT_DIR/testing-data.json')));" | cat - "$TARGET_FILE" > temp && mv temp "$TARGET_FILE"
  fi

  if [ "$USE_DELETE_HELPER" = true ]; then
    echo "import { deleteRow } from '../helper.ts';"
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

