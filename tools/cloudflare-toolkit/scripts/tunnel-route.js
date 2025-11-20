#!/usr/bin/env node

/**
 * Create a DNS route for a Cloudflare Tunnel
 * Usage: npm run tunnel:route <tunnel-name> <hostname>
 */

import { TunnelManager } from '../lib/tunnel-manager.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const tunnelName = process.argv[2];
  const hostname = process.argv[3];

  if (!tunnelName || !hostname) {
    console.error(chalk.red('Error: Tunnel name and hostname required'));
    console.log(chalk.yellow('Usage: npm run tunnel:route <tunnel-name> <hostname>'));
    console.log(chalk.gray('Example: npm run tunnel:route my-tunnel app.example.com'));
    process.exit(1);
  }

  const spinner = ora('Creating DNS route...').start();
  const manager = new TunnelManager();

  try {
    const result = await manager.createRoute(tunnelName, hostname);
    spinner.succeed(chalk.green(`DNS route created for ${hostname}`));
    
    console.log(chalk.cyan('\nRoute Details:'));
    console.log(chalk.gray(result.message));
    
    console.log(chalk.blue('\nNext steps:'));
    console.log(chalk.gray('1. Configure your tunnel ingress rules'));
    console.log(chalk.gray(`2. Run the tunnel: npm run tunnel:run ${tunnelName}`));
    console.log(chalk.gray(`3. Test the connection: curl https://${hostname}`));
  } catch (error) {
    spinner.fail(chalk.red('Failed to create route'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
