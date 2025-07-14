const { Reporter } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

  class G8tsTestReporter {
    constructor(options = {}) {
      // Counters to track test results
      this.totalPassed = 0;
      this.totalFailed = 0;
      this.totalRun = 0;
      this.testResults = [];
      this.outputFile = options.outputFile || 'report-output.txt'; // Default output file
    }

    onTestEnd(test, result) {
      console.log('ontestend logg');
      // Increment total test count
      this.totalRun++;

      // Check the status and increment the respective counter
      if (result.status === 'passed') {
        this.totalPassed++;
      } else if (result.status === 'failed' || result.status === 'timedOut') {
        this.totalFailed++;
      }

      // Collect test details
      this.testResults.push({
        title: test.title,
        status: result.status,
        error: result.errors?.[0]?.message || (result.status === 'timedOut' ? 'Test timed out' : null),
      });
    }

    async onEnd() {
      console.log('skskksks');
      // Log the final counts
      // console.log(`Total Run: ${this.totalRun}`);
      // console.log(`Total Passed: ${this.totalPassed}`);
      // console.log(`Total Failed: ${this.totalFailed}`);
      const outputPath = path.resolve(this.outputFile);
      fs.writeFileSync(outputPath, "DONE", 'utf-8');
      if (this.totalFailed > 0) {
        console.log(`FAILED`);
        fs.writeFileSync(outputPath, "FAILED", 'utf-8');
      }else{
        console.log(`SUCCESS`);
        fs.writeFileSync(outputPath, "SUCCESS", 'utf-8');
      }
    }
  }

  module.exports = G8tsTestReporter;
