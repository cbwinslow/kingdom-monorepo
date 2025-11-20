#!/usr/bin/env node

/**
 * Create a new Cloudflare Tunnel
 * Usage: npm run tunnel:create <tunnel-name>
 */

import { TunnelManager } from '../lib/tunnel-manager.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const tunnelName = process.argv[2];

  if (!tunnelName) {
    console.error(chalk.red('Error: Tunnel name required'));
    console.log(chalk.yellow('Usage: npm run tunnel:create <tunnel-name>'));
    process.exit(1);
  }

  const spinner = ora('Creating tunnel...').start();
  const manager = new TunnelManager();

  try {
    const result = await manager.create(tunnelName);
    spinner.succeed(chalk.green(`Tunnel created: ${result.id}`));
    
    console.log(chalk.cyan('\nTunnel Details:'));
    console.log(chalk.gray(result.message));
    
    console.log(chalk.blue('\nNext steps:'));
    console.log(chalk.gray('1. Create a config file at ~/.cloudflared/config.yml'));
    console.log(chalk.gray('2. Configure your ingress rules'));
    console.log(chalk.gray(`3. Create DNS routes: npm run tunnel:route ${tunnelName} <hostname>`));
    console.log(chalk.gray(`4. Run the tunnel: npm run tunnel:run ${tunnelName}`));
  } catch (error) {
    spinner.fail(chalk.red('Failed to create tunnel'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
