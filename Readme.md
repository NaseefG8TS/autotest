# 🛠️ Playwright Test Automation Suite

## 🎯 Key Features
-  Replace fragile selectors with robust alternatives
-  Auto-convert dates using  helper function modified with custom reusbale date
-  Realistic hover interactions before clicks
-  context detection on prompted name (PLANNING vs REGISTRY flows)
-  Automatic failure screenshots
-  timeout handling before Save/Submit clicks (PIN check)

## 🚀 Quick Start

### 1. Initial Setup

```bash (terminal)

# Install dependencies
npm install -g @playwright/test @faker-js/faker

# Clone repository
git clone "https://github.com/g8ts/g8ts-autotest.git"
cd g8ts-autotest


## 🔧 Playwright Installation & Setup
```bash (terminal)


# Install Playwright
npm init playwright@latest

# Install browsers (all or specific)
npx playwright install
npx playwright install chromium

# Verify installation
npx playwright --version

# Make script executable
chmod +x create-tests.sh

#run the script 
./create-tests.sh

# Run all tests
npx playwright test

# Run specific test file
npx playwright test tests/test_file_name.spec.ts

# Headed mode (visible browser)
npx playwright test --headed

# Slow down execution (ms)
npx playwright test --slowmo=1000


# HTML report
npx playwright show-report


