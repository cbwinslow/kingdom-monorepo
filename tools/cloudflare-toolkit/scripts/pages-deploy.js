#!/usr/bin/env node

/**
 * Deploy to Cloudflare Pages using wrangler
 * Usage: npm run pages:deploy <project-name> <directory>
 */

import chalk from 'chalk';
import ora from 'ora';
import { exec } from 'child_process';
import { promisify } from 'util';
import { existsSync } from 'fs';

const execAsync = promisify(exec);

async function main() {
  const projectName = process.argv[2];
  const directory = process.argv[3] || './dist';

  if (!projectName) {
    console.error(chalk.red('Error: Project name required'));
    console.log(chalk.yellow('Usage: npm run pages:deploy <project-name> <directory>'));
    console.log(chalk.gray('Example: npm run pages:deploy my-site ./dist'));
    process.exit(1);
  }

  if (!existsSync(directory)) {
    console.error(chalk.red(`Error: Directory not found: ${directory}`));
    console.log(chalk.yellow('Please build your project first'));
    process.exit(1);
  }

  console.log(chalk.blue('📄 Deploying to Cloudflare Pages\n'));

  const spinner = ora('Deploying...').start();

  try {
    const { stdout, stderr } = await execAsync(
      `npx wrangler pages deploy ${directory} --project-name=${projectName}`
    );

    spinner.succeed(chalk.green('Deployment complete'));

    console.log(chalk.cyan('\nDeployment Output:'));
    console.log(chalk.gray(stdout));

    if (stderr) {
      console.log(chalk.yellow('\nWarnings:'));
      console.log(chalk.gray(stderr));
    }

    console.log(chalk.blue('\n✓ Your site is now live!'));
    console.log(chalk.gray(`  Preview: https://${projectName}.pages.dev`));

  } catch (error) {
    spinner.fail(chalk.red('Deployment failed'));
    console.error(chalk.red('Error:'), error.message);
    
    console.log(chalk.yellow('\nTroubleshooting:'));
    console.log(chalk.gray('  1. Make sure wrangler is installed: npm install -g wrangler'));
    console.log(chalk.gray('  2. Authenticate: npx wrangler login'));
    console.log(chalk.gray('  3. Check your build output directory is correct'));
    
    process.exit(1);
  }
}

main();
