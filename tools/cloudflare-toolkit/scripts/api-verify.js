#!/usr/bin/env node

/**
 * Verify Cloudflare API credentials
 * Usage: npm run api:verify
 */

import { CloudflareClient } from '../lib/cloudflare-client.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const spinner = ora('Verifying API credentials...').start();
  const client = new CloudflareClient();

  try {
    const result = await client.verify();
    
    if (result.success) {
      spinner.succeed(chalk.green('API credentials verified'));
      console.log(chalk.cyan('\nCredentials Status:'));
      console.log(chalk.gray(`  Status: ${result.status}`));
      console.log(chalk.gray(`  Token ID: ${result.id}`));
      
      // Get account info
      spinner.start('Fetching account information...');
      const account = await client.getAccount();
      spinner.succeed(chalk.green('Account information fetched'));
      
      console.log(chalk.cyan('\nAccount Details:'));
      console.log(chalk.gray(`  Name: ${account.name}`));
      console.log(chalk.gray(`  ID: ${account.id}`));
      console.log(chalk.gray(`  Type: ${account.type || 'standard'}`));
      
      // Get zone info if zone ID is set
      if (client.zoneId) {
        spinner.start('Fetching zone information...');
        const zone = await client.getZone();
        spinner.succeed(chalk.green('Zone information fetched'));
        
        console.log(chalk.cyan('\nZone Details:'));
        console.log(chalk.gray(`  Name: ${zone.name}`));
        console.log(chalk.gray(`  ID: ${zone.id}`));
        console.log(chalk.gray(`  Status: ${zone.status}`));
      }
      
      console.log(chalk.green('\n✓ All credentials are valid and working'));
    } else {
      spinner.fail(chalk.red('API credentials invalid'));
      console.error(chalk.red('Error:'), result.error);
      process.exit(1);
    }
  } catch (error) {
    spinner.fail(chalk.red('Failed to verify credentials'));
    console.error(chalk.red('Error:'), error.message);
    console.log(chalk.yellow('\nPlease check your configuration:'));
    console.log(chalk.gray('  1. Copy config/example.env to config/.env'));
    console.log(chalk.gray('  2. Set CLOUDFLARE_API_TOKEN or CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL'));
    console.log(chalk.gray('  3. Set CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_ZONE_ID'));
    process.exit(1);
  }
}

main();
