/**
 * Basic Cloudflare Tunnel Setup Example
 * 
 * This example demonstrates:
 * - Creating a tunnel
 * - Configuring DNS routes
 * - Running the tunnel
 */

import { TunnelManager } from '../lib/tunnel-manager.js';
import chalk from 'chalk';

async function setupBasicTunnel() {
  const manager = new TunnelManager();
  const tunnelName = 'my-app-tunnel';
  const hostname = 'app.example.com';

  try {
    console.log(chalk.blue('🚇 Setting up Cloudflare Tunnel...\n'));

    // Step 1: Create the tunnel
    console.log(chalk.yellow('Creating tunnel...'));
    const createResult = await manager.create(tunnelName);
    console.log(chalk.green('✓ Tunnel created:'), createResult.id);

    // Step 2: Create DNS route
    console.log(chalk.yellow('\nCreating DNS route...'));
    const routeResult = await manager.createRoute(tunnelName, hostname);
    console.log(chalk.green('✓ Route created for:'), hostname);

    // Step 3: Display tunnel info
    console.log(chalk.yellow('\nGetting tunnel info...'));
    const infoResult = await manager.info(tunnelName);
    console.log(chalk.cyan('\nTunnel Information:'));
    console.log(infoResult.output);

    // Instructions for next steps
    console.log(chalk.blue('\n📝 Next Steps:\n'));
    console.log('1. Create a config file at ~/.cloudflared/config.yml:');
    console.log(chalk.gray(`
tunnel: ${tunnelName}
credentials-file: ~/.cloudflared/${createResult.id}.json

ingress:
  - hostname: ${hostname}
    service: http://localhost:8080
  - service: http_status:404
    `));

    console.log('\n2. Run the tunnel:');
    console.log(chalk.gray(`   cloudflared tunnel run ${tunnelName}`));
    console.log(chalk.gray('   or'));
    console.log(chalk.gray(`   npm run tunnel:run ${tunnelName}`));

    console.log(chalk.green('\n✓ Tunnel setup complete!'));

  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error.message);
    process.exit(1);
  }
}

// Run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  setupBasicTunnel();
}

export { setupBasicTunnel };
