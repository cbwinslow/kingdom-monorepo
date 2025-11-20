#!/usr/bin/env node

/**
 * List all Cloudflare Tunnels
 * Usage: npm run tunnel:list
 */

import { TunnelManager } from '../lib/tunnel-manager.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const spinner = ora('Fetching tunnels...').start();
  const manager = new TunnelManager();

  try {
    const result = await manager.list();
    spinner.succeed(chalk.green('Tunnels fetched'));
    
    console.log(chalk.cyan('\nActive Tunnels:'));
    console.log(chalk.gray(result.output));
  } catch (error) {
    spinner.fail(chalk.red('Failed to list tunnels'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
