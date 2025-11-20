#!/usr/bin/env node

/**
 * Run a Cloudflare Tunnel
 * Usage: npm run tunnel:run <tunnel-name> [config-path]
 */

import { TunnelManager } from '../lib/tunnel-manager.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const tunnelName = process.argv[2];
  const configPath = process.argv[3];

  if (!tunnelName) {
    console.error(chalk.red('Error: Tunnel name required'));
    console.log(chalk.yellow('Usage: npm run tunnel:run <tunnel-name> [config-path]'));
    console.log(chalk.gray('Example: npm run tunnel:run my-tunnel'));
    console.log(chalk.gray('Example: npm run tunnel:run my-tunnel ~/.cloudflared/config.yml'));
    process.exit(1);
  }

  console.log(chalk.blue(`🚇 Starting tunnel: ${tunnelName}\n`));
  
  const spinner = ora('Starting tunnel...').start();
  const manager = new TunnelManager();

  try {
    const result = await manager.run(tunnelName, configPath);
    spinner.succeed(chalk.green('Tunnel started'));
    
    console.log(chalk.cyan('\nTunnel is now running in the background'));
    console.log(chalk.gray(`  Tunnel: ${tunnelName}`));
    if (configPath) {
      console.log(chalk.gray(`  Config: ${configPath}`));
    }
    
    console.log(chalk.yellow('\nNote:'));
    console.log(chalk.gray('  - Check tunnel status: cloudflared tunnel info ' + tunnelName));
    console.log(chalk.gray('  - View logs: journalctl -u cloudflared -f (if running as service)'));
    console.log(chalk.gray('  - Stop tunnel: pkill cloudflared'));
    
  } catch (error) {
    spinner.fail(chalk.red('Failed to start tunnel'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
