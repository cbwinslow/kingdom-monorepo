#!/usr/bin/env node

/**
 * Purge Cloudflare cache
 * Usage: npm run cdn:purge-cache [--all] [--urls url1,url2,url3]
 */

import { CDNManager } from '../lib/cdn-manager.js';
import chalk from 'chalk';
import inquirer from 'inquirer';
import ora from 'ora';

async function main() {
  const args = process.argv.slice(2);
  const hasAllFlag = args.includes('--all');
  const urlsIndex = args.indexOf('--urls');
  const urls = urlsIndex !== -1 ? args[urlsIndex + 1]?.split(',') : null;

  const cdn = new CDNManager();

  try {
    if (hasAllFlag) {
      // Confirm before purging everything
      const { confirm } = await inquirer.prompt([{
        type: 'confirm',
        name: 'confirm',
        message: chalk.yellow('⚠️  Are you sure you want to purge ALL cache? This cannot be undone.'),
        default: false
      }]);

      if (!confirm) {
        console.log(chalk.gray('Operation cancelled'));
        process.exit(0);
      }

      const spinner = ora('Purging all cache...').start();
      await cdn.purgeAll();
      spinner.succeed(chalk.green('All cache purged successfully'));
      
      console.log(chalk.yellow('\nNote:'));
      console.log(chalk.gray('  It may take a few minutes for the purge to propagate globally'));
      
    } else if (urls && urls.length > 0) {
      const spinner = ora(`Purging ${urls.length} URLs...`).start();
      await cdn.purgeUrls(urls);
      spinner.succeed(chalk.green(`${urls.length} URLs purged successfully`));
      
      console.log(chalk.cyan('\nPurged URLs:'));
      urls.forEach(url => console.log(chalk.gray(`  - ${url}`)));
      
    } else {
      // Interactive mode
      const { purgeType } = await inquirer.prompt([{
        type: 'list',
        name: 'purgeType',
        message: 'What would you like to purge?',
        choices: [
          { name: 'Specific URLs', value: 'urls' },
          { name: 'Everything (use with caution!)', value: 'all' }
        ]
      }]);

      if (purgeType === 'all') {
        const { confirm } = await inquirer.prompt([{
          type: 'confirm',
          name: 'confirm',
          message: chalk.yellow('⚠️  Are you sure? This will purge ALL cached content.'),
          default: false
        }]);

        if (!confirm) {
          console.log(chalk.gray('Operation cancelled'));
          process.exit(0);
        }

        const spinner = ora('Purging all cache...').start();
        await cdn.purgeAll();
        spinner.succeed(chalk.green('All cache purged successfully'));
      } else {
        const { urlInput } = await inquirer.prompt([{
          type: 'input',
          name: 'urlInput',
          message: 'Enter URLs to purge (comma-separated):',
          validate: input => input.length > 0 || 'At least one URL required'
        }]);

        const urlsToPurge = urlInput.split(',').map(u => u.trim());
        const spinner = ora(`Purging ${urlsToPurge.length} URLs...`).start();
        await cdn.purgeUrls(urlsToPurge);
        spinner.succeed(chalk.green(`${urlsToPurge.length} URLs purged successfully`));
        
        console.log(chalk.cyan('\nPurged URLs:'));
        urlsToPurge.forEach(url => console.log(chalk.gray(`  - ${url}`)));
      }
    }

    console.log(chalk.blue('\nCache purge complete!'));

  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error.message);
    process.exit(1);
  }
}

main();
