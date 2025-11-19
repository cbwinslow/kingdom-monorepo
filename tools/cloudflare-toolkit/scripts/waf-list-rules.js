#!/usr/bin/env node

/**
 * List WAF firewall rules
 * Usage: npm run waf:list-rules
 */

import { WAFManager } from '../lib/waf-manager.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const spinner = ora('Fetching firewall rules...').start();
  const waf = new WAFManager();

  try {
    const result = await waf.listRules();
    spinner.succeed(chalk.green(`Found ${result.rules.length} firewall rules`));

    if (result.rules.length === 0) {
      console.log(chalk.gray('\nNo firewall rules configured'));
      console.log(chalk.yellow('Create a rule: npm run waf:create-rule'));
      return;
    }

    console.log(chalk.cyan('\nFirewall Rules:\n'));

    result.rules.forEach((rule, index) => {
      console.log(chalk.blue(`[${index + 1}] ${rule.description || 'Unnamed rule'}`));
      console.log(chalk.gray(`    ID: ${rule.id}`));
      console.log(chalk.gray(`    Action: ${rule.action}`));
      console.log(chalk.gray(`    Priority: ${rule.priority || 'default'}`));
      console.log(chalk.gray(`    Enabled: ${rule.paused === false ? 'Yes' : 'No'}`));
      if (rule.filter) {
        console.log(chalk.gray(`    Expression: ${rule.filter.expression}`));
      }
      console.log('');
    });

    // Also list rate limits
    spinner.start('Fetching rate limits...');
    const rateLimits = await waf.listRateLimits();
    spinner.succeed(chalk.green(`Found ${rateLimits.rateLimits.length} rate limits`));

    if (rateLimits.rateLimits.length > 0) {
      console.log(chalk.cyan('Rate Limits:\n'));

      rateLimits.rateLimits.forEach((limit, index) => {
        console.log(chalk.blue(`[${index + 1}] ${limit.description || 'Unnamed limit'}`));
        console.log(chalk.gray(`    ID: ${limit.id}`));
        console.log(chalk.gray(`    Threshold: ${limit.threshold} requests per ${limit.period}s`));
        console.log(chalk.gray(`    Action: ${limit.action.mode}`));
        console.log(chalk.gray(`    Disabled: ${limit.disabled ? 'Yes' : 'No'}`));
        console.log('');
      });
    }

    // Also list IP rules
    spinner.start('Fetching IP access rules...');
    const ipRules = await waf.listIPRules();
    spinner.succeed(chalk.green(`Found ${ipRules.rules.length} IP access rules`));

    if (ipRules.rules.length > 0) {
      console.log(chalk.cyan('IP Access Rules:\n'));

      ipRules.rules.forEach((rule, index) => {
        console.log(chalk.blue(`[${index + 1}] ${rule.notes || 'Unnamed rule'}`));
        console.log(chalk.gray(`    ID: ${rule.id}`));
        console.log(chalk.gray(`    Mode: ${rule.mode}`));
        console.log(chalk.gray(`    Target: ${rule.configuration.target} = ${rule.configuration.value}`));
        console.log('');
      });
    }

    console.log(chalk.blue('📊 View detailed analytics in the Cloudflare dashboard'));

  } catch (error) {
    spinner.fail(chalk.red('Failed to list rules'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
