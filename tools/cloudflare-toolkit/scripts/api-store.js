#!/usr/bin/env node

/**
 * Store Cloudflare API credentials securely
 * Usage: npm run api:store
 */

import { CredentialStore } from '../lib/credential-store.js';
import chalk from 'chalk';
import inquirer from 'inquirer';
import ora from 'ora';

async function main() {
  console.log(chalk.blue('🔐 Store Cloudflare API Credentials\n'));
  console.log(chalk.gray('Your credentials will be encrypted and stored securely.\n'));

  try {
    // Prompt for authentication method
    const { authMethod } = await inquirer.prompt([{
      type: 'list',
      name: 'authMethod',
      message: 'Authentication method:',
      choices: [
        { name: 'API Token (Recommended)', value: 'token' },
        { name: 'API Key + Email (Legacy)', value: 'key' }
      ]
    }]);

    const credentials = {};

    if (authMethod === 'token') {
      const { apiToken } = await inquirer.prompt([{
        type: 'password',
        name: 'apiToken',
        message: 'Cloudflare API Token:',
        mask: '*',
        validate: input => input.length > 0 || 'API Token is required'
      }]);
      credentials.apiToken = apiToken;
    } else {
      const answers = await inquirer.prompt([
        {
          type: 'input',
          name: 'email',
          message: 'Cloudflare Email:',
          validate: input => input.includes('@') || 'Valid email required'
        },
        {
          type: 'password',
          name: 'apiKey',
          message: 'Cloudflare API Key:',
          mask: '*',
          validate: input => input.length > 0 || 'API Key is required'
        }
      ]);
      credentials.email = answers.email;
      credentials.apiKey = answers.apiKey;
    }

    // Prompt for account and zone IDs
    const { accountId, zoneId } = await inquirer.prompt([
      {
        type: 'input',
        name: 'accountId',
        message: 'Cloudflare Account ID:',
        validate: input => input.length > 0 || 'Account ID is required'
      },
      {
        type: 'input',
        name: 'zoneId',
        message: 'Cloudflare Zone ID (optional, press Enter to skip):'
      }
    ]);

    credentials.accountId = accountId;
    if (zoneId) {
      credentials.zoneId = zoneId;
    }

    // Prompt for master password
    const { password, confirmPassword } = await inquirer.prompt([
      {
        type: 'password',
        name: 'password',
        message: 'Create a master password to encrypt credentials:',
        mask: '*',
        validate: input => input.length >= 8 || 'Password must be at least 8 characters'
      },
      {
        type: 'password',
        name: 'confirmPassword',
        message: 'Confirm master password:',
        mask: '*',
        validate: input => input.length >= 8 || 'Password must be at least 8 characters'
      }
    ]);

    if (password !== confirmPassword) {
      console.error(chalk.red('\nError: Passwords do not match'));
      process.exit(1);
    }

    // Store credentials
    const spinner = ora('Storing credentials securely...').start();
    const store = new CredentialStore();
    await store.store(credentials, password);
    spinner.succeed(chalk.green('Credentials stored successfully'));

    console.log(chalk.cyan('\nStored Credentials:'));
    console.log(chalk.gray(`  Authentication: ${authMethod === 'token' ? 'API Token' : 'API Key + Email'}`));
    console.log(chalk.gray(`  Account ID: ${accountId}`));
    if (zoneId) {
      console.log(chalk.gray(`  Zone ID: ${zoneId}`));
    }

    console.log(chalk.yellow('\n⚠️  Important:'));
    console.log(chalk.gray('  - Remember your master password'));
    console.log(chalk.gray('  - Never commit config/.credentials.enc to version control'));
    console.log(chalk.gray('  - Backup your credentials securely'));

    console.log(chalk.blue('\nNext steps:'));
    console.log(chalk.gray('  - Verify credentials: npm run api:verify'));
    console.log(chalk.gray('  - Rotate regularly: npm run api:rotate'));

  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error.message);
    process.exit(1);
  }
}

main();
