#!/usr/bin/env node

/**
 * Create a WAF firewall rule
 * Usage: npm run waf:create-rule
 */

import { WAFManager } from '../lib/waf-manager.js';
import chalk from 'chalk';
import inquirer from 'inquirer';
import ora from 'ora';

async function main() {
  console.log(chalk.blue('🛡️  Create Firewall Rule\n'));

  try {
    // Prompt for rule details
    const answers = await inquirer.prompt([
      {
        type: 'input',
        name: 'description',
        message: 'Rule description:',
        validate: input => input.length > 0 || 'Description is required'
      },
      {
        type: 'input',
        name: 'expression',
        message: 'Rule expression:',
        default: '(http.request.uri.path contains "/admin")',
        validate: input => input.length > 0 || 'Expression is required'
      },
      {
        type: 'list',
        name: 'action',
        message: 'Action to take:',
        choices: [
          { name: 'Block - Return 403 Forbidden', value: 'block' },
          { name: 'Challenge - Show CAPTCHA', value: 'challenge' },
          { name: 'JS Challenge - JavaScript challenge', value: 'js_challenge' },
          { name: 'Managed Challenge - Cloudflare-managed challenge', value: 'managed_challenge' },
          { name: 'Log - Log only, no action', value: 'log' },
          { name: 'Allow - Bypass all rules', value: 'allow' }
        ]
      },
      {
        type: 'number',
        name: 'priority',
        message: 'Priority (1-1000, lower = higher priority):',
        default: 1,
        validate: input => (input >= 1 && input <= 1000) || 'Priority must be between 1 and 1000'
      }
    ]);

    const spinner = ora('Creating firewall rule...').start();
    const waf = new WAFManager();

    const result = await waf.createRule(answers);
    spinner.succeed(chalk.green('Firewall rule created'));

    console.log(chalk.cyan('\nRule Details:'));
    console.log(chalk.gray(`  ID: ${result.rule.id}`));
    console.log(chalk.gray(`  Description: ${answers.description}`));
    console.log(chalk.gray(`  Expression: ${answers.expression}`));
    console.log(chalk.gray(`  Action: ${answers.action}`));
    console.log(chalk.gray(`  Priority: ${answers.priority}`));

    console.log(chalk.yellow('\nNote:'));
    console.log(chalk.gray('  Monitor the rule in simulate/log mode before switching to block'));
    console.log(chalk.gray('  View firewall events: npm run waf:list-events'));

  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error.message);
    process.exit(1);
  }
}

main();
