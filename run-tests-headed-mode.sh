
read -p "Do you want to run only the latest test? (y/n): " choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
  LATEST_TEST=$(find tests -type f \( -name "*.spec.js" -o -name "*.spec.ts" \) -print0 | xargs -0 ls -t | head -n 1)

  if [ -z "$LATEST_TEST" ]; then
    echo "No test files found"
    exit 1
  fi

  echo "Running latest test: $LATEST_TEST"
  npx playwright test "$LATEST_TEST" --headed
else
  echo "Running all Playwright tests in headed mode"
  npx playwright test --headed
fi
