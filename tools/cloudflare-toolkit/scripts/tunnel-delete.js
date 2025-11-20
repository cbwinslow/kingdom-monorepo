#!/usr/bin/env node

/**
 * Delete a Cloudflare Tunnel
 * Usage: npm run tunnel:delete <tunnel-name>
 */

import { TunnelManager } from '../lib/tunnel-manager.js';
import chalk from 'chalk';
import inquirer from 'inquirer';
import ora from 'ora';

async function main() {
  const tunnelName = process.argv[2];

  if (!tunnelName) {
    console.error(chalk.red('Error: Tunnel name required'));
    console.log(chalk.yellow('Usage: npm run tunnel:delete <tunnel-name>'));
    process.exit(1);
  }

  // Confirm deletion
  const { confirm } = await inquirer.prompt([{
    type: 'confirm',
    name: 'confirm',
    message: chalk.yellow(`Are you sure you want to delete tunnel "${tunnelName}"?`),
    default: false
  }]);

  if (!confirm) {
    console.log(chalk.gray('Operation cancelled'));
    process.exit(0);
  }

  const spinner = ora('Deleting tunnel...').start();
  const manager = new TunnelManager();

  try {
    const result = await manager.delete(tunnelName);
    spinner.succeed(chalk.green(`Tunnel "${tunnelName}" deleted successfully`));
    
    console.log(chalk.yellow('\nNote:'));
    console.log(chalk.gray('  DNS records may still exist. Clean them up manually if needed.'));
  } catch (error) {
    spinner.fail(chalk.red('Failed to delete tunnel'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
