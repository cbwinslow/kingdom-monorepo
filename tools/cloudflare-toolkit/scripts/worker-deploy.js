#!/usr/bin/env node

/**
 * Deploy a Cloudflare Worker
 * Usage: npm run worker:deploy <worker-name> <script-path>
 */

import { WorkerManager } from '../lib/worker-manager.js';
import chalk from 'chalk';
import ora from 'ora';
import { existsSync } from 'fs';

async function main() {
  const workerName = process.argv[2];
  const scriptPath = process.argv[3];

  if (!workerName || !scriptPath) {
    console.error(chalk.red('Error: Worker name and script path required'));
    console.log(chalk.yellow('Usage: npm run worker:deploy <worker-name> <script-path>'));
    console.log(chalk.gray('Example: npm run worker:deploy my-worker ./worker.js'));
    process.exit(1);
  }

  if (!existsSync(scriptPath)) {
    console.error(chalk.red(`Error: Script file not found: ${scriptPath}`));
    process.exit(1);
  }

  const spinner = ora('Deploying worker...').start();
  const manager = new WorkerManager();

  try {
    const result = await manager.deploy(workerName, scriptPath);
    spinner.succeed(chalk.green(`Worker deployed: ${result.name}`));
    
    console.log(chalk.cyan('\nDeployment Details:'));
    console.log(chalk.gray(`  Worker ID: ${result.id}`));
    console.log(chalk.gray(`  Name: ${result.name}`));
    
    // Get subdomain
    spinner.start('Fetching worker URL...');
    const subdomainResult = await manager.getSubdomain();
    spinner.succeed(chalk.green('Worker URL ready'));
    
    console.log(chalk.cyan('\nWorker URL:'));
    console.log(chalk.blue(`  https://${workerName}.${subdomainResult.subdomain}.workers.dev`));
    
    console.log(chalk.yellow('\nNext steps:'));
    console.log(chalk.gray('  - Test your worker at the URL above'));
    console.log(chalk.gray(`  - Create routes: npm run worker:route ${workerName} <pattern>`));
    console.log(chalk.gray('  - View logs: wrangler tail ' + workerName));
  } catch (error) {
    spinner.fail(chalk.red('Failed to deploy worker'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
