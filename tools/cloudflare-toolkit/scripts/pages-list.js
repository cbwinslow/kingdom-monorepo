#!/usr/bin/env node

/**
 * List all Cloudflare Pages projects
 * Usage: npm run pages:list
 */

import { PagesManager } from '../lib/pages-manager.js';
import chalk from 'chalk';
import ora from 'ora';

async function main() {
  const spinner = ora('Fetching Pages projects...').start();
  const manager = new PagesManager();

  try {
    const result = await manager.list();
    spinner.succeed(chalk.green(`Found ${result.projects.length} Pages projects`));

    if (result.projects.length === 0) {
      console.log(chalk.gray('\nNo Pages projects found'));
      console.log(chalk.yellow('Create a project: npm run pages:create <name>'));
      return;
    }

    console.log(chalk.cyan('\nPages Projects:\n'));

    result.projects.forEach((project, index) => {
      console.log(chalk.blue(`[${index + 1}] ${project.name}`));
      console.log(chalk.gray(`    URL: https://${project.subdomain}`));
      console.log(chalk.gray(`    Production Branch: ${project.production_branch || 'main'}`));
      console.log(chalk.gray(`    Created: ${project.created_on}`));
      if (project.latest_deployment) {
        console.log(chalk.gray(`    Latest Deployment: ${project.latest_deployment.id}`));
        console.log(chalk.gray(`    Deployment Status: ${project.latest_deployment.deployment_trigger.type}`));
      }
      if (project.domains && project.domains.length > 0) {
        console.log(chalk.gray(`    Custom Domains: ${project.domains.join(', ')}`));
      }
      console.log('');
    });

    console.log(chalk.blue('\n📊 View detailed analytics in the Cloudflare dashboard'));

  } catch (error) {
    spinner.fail(chalk.red('Failed to list Pages projects'));
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

main();
