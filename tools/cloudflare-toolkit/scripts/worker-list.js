#!/usr/bin/env node

/**
 * List all Cloudflare Workers
 * Usage: npm run worker:list
 */

import { WorkerManager } from '../lib/worker-manager.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const spinner = ora('Fetching workers...').start();
  const manager = new WorkerManager();

  try {
    const result = await manager.list();
    spinner.succeed(chalk.green(`Found ${result.workers.length} workers`));

    if (result.workers.length === 0) {
      console.log(chalk.gray('\nNo workers deployed'));
      console.log(chalk.yellow('Deploy a worker: npm run worker:deploy <name> <script>'));
      return;
    }

    console.log(chalk.cyan('\nDeployed Workers:\n'));

    result.workers.forEach((worker, index) => {
      console.log(chalk.blue(`[${index + 1}] ${worker.id}`));
      console.log(chalk.gray(`    Created: ${worker.created_on}`));
      console.log(chalk.gray(`    Modified: ${worker.modified_on}`));
      console.log(chalk.gray(`    Size: ${(worker.size || 0).toLocaleString()} bytes`));
      console.log('');
    });

    // Get subdomain for URL info
    spinner.start('Fetching worker subdomain...');
    const subdomainResult = await manager.getSubdomain();
    spinner.succeed();

    console.log(chalk.cyan('Worker URLs:'));
    result.workers.forEach(worker => {
      console.log(chalk.blue(`  https://${worker.id}.${subdomainResult.subdomain}.workers.dev`));
    });

  } catch (error) {
    spinner.fail(chalk.red('Failed to list workers'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
