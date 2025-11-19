/**
 * Cloudflare Worker with Routes Example
 * 
 * This example demonstrates:
 * - Deploying a worker
 * - Creating routes
 * - Managing worker configuration
 */

import { WorkerManager } from '../lib/worker-manager.js';
import { writeFileSync } from 'fs';
import { join } from 'path';
import chalk from 'chalk';

// Sample worker script
const workerScript = `
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Simple API router
    if (url.pathname === '/api/hello') {
      return Response.json({ message: 'Hello from Worker!' });
    }
    
    if (url.pathname === '/api/time') {
      return Response.json({ 
        timestamp: Date.now(),
        datetime: new Date().toISOString()
      });
    }
    
    if (url.pathname.startsWith('/api/')) {
      return Response.json({ 
        error: 'Not Found',
        path: url.pathname
      }, { status: 404 });
    }
    
    // Default response
    return new Response('Worker is running!', {
      headers: { 'Content-Type': 'text/plain' }
    });
  }
};
`;

async function deployWorkerWithRoutes() {
  const manager = new WorkerManager();
  const workerName = 'my-api-worker';
  const workerPath = join('/tmp', 'worker.js');

  try {
    console.log(chalk.blue('🚀 Deploying Cloudflare Worker...\n'));

    // Step 1: Write worker script to file
    console.log(chalk.yellow('Creating worker script...'));
    writeFileSync(workerPath, workerScript);
    console.log(chalk.green('✓ Worker script created'));

    // Step 2: Deploy the worker
    console.log(chalk.yellow('\nDeploying worker...'));
    const deployResult = await manager.deploy(workerName, workerPath);
    console.log(chalk.green('✓ Worker deployed:'), deployResult.name);

    // Step 3: Create routes
    console.log(chalk.yellow('\nCreating routes...'));
    const routes = [
      'example.com/api/*',
      'api.example.com/*'
    ];

    for (const pattern of routes) {
      const routeResult = await manager.createRoute(pattern, workerName);
      console.log(chalk.green('✓ Route created:'), pattern);
    }

    // Step 4: List all routes
    console.log(chalk.yellow('\nListing all routes...'));
    const listResult = await manager.listRoutes();
    console.log(chalk.cyan('\nActive Routes:'));
    listResult.routes.forEach(route => {
      console.log(`  - ${route.pattern} → ${route.script}`);
    });

    // Step 5: Get worker subdomain
    const subdomainResult = await manager.getSubdomain();
    console.log(chalk.cyan('\nWorker URLs:'));
    console.log(`  - https://${workerName}.${subdomainResult.subdomain}.workers.dev`);
    routes.forEach(pattern => {
      const url = pattern.replace('*', '');
      console.log(`  - https://${url}`);
    });

    console.log(chalk.green('\n✓ Worker deployment complete!'));

  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error.message);
    process.exit(1);
  }
}

// Run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  deployWorkerWithRoutes();
}

export { deployWorkerWithRoutes };
