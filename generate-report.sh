#!/bin/bash
# exit 1;
rm -rf report-output.txt
# npx playwright test >> generated-report.txt
npx playwright test
# npx playwright test --reporter=./g8ts-test-reporter.js  >> report-output.txt
report_file="report-output.txt"

if grep -q "FAILED" "$report_file"; then
    echo "Test Failed:: Sending email"
    php ../g8ts-app/bin/console app:send-report
else
    echo "SUCCESS"
fi



