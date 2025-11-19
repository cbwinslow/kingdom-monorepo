/**
 * CDN Cache Configuration Example
 * 
 * This example demonstrates:
 * - Configuring cache rules
 * - Setting cache TTLs
 * - Enabling optimizations
 * - Purging cache
 */

import { CDNManager } from '../lib/cdn-manager.js';
import chalk from 'chalk';

async function setupCDNCache() {
  const cdn = new CDNManager();

  try {
    console.log(chalk.blue('⚡ Configuring CDN Cache...\n'));

    // Step 1: Set cache level
    console.log(chalk.yellow('Setting cache level...'));
    await cdn.setCacheLevel('aggressive');
    console.log(chalk.green('✓ Cache level set to aggressive'));

    // Step 2: Set browser cache TTL
    console.log(chalk.yellow('\nSetting browser cache TTL...'));
    await cdn.setBrowserTTL(14400); // 4 hours
    console.log(chalk.green('✓ Browser cache TTL set to 4 hours'));

    // Step 3: Create page rule for static assets
    console.log(chalk.yellow('\nCreating page rule for static assets...'));
    await cdn.createPageRule({
      targets: [{
        target: 'url',
        constraint: {
          operator: 'matches',
          value: '*example.com/static/*'
        }
      }],
      actions: [
        { id: 'edge_cache_ttl', value: 2592000 }, // 30 days
        { id: 'cache_level', value: 'cache_everything' },
        { id: 'browser_cache_ttl', value: 31536000 } // 1 year
      ],
      priority: 1,
      status: 'active'
    });
    console.log(chalk.green('✓ Page rule created for static assets'));

    // Step 4: Create page rule for API responses
    console.log(chalk.yellow('\nCreating page rule for API...'));
    await cdn.createPageRule({
      targets: [{
        target: 'url',
        constraint: {
          operator: 'matches',
          value: '*example.com/api/*'
        }
      }],
      actions: [
        { id: 'edge_cache_ttl', value: 300 }, // 5 minutes
        { id: 'cache_level', value: 'cache_everything' }
      ],
      priority: 2,
      status: 'active'
    });
    console.log(chalk.green('✓ Page rule created for API'));

    // Step 5: Enable minification
    console.log(chalk.yellow('\nEnabling minification...'));
    await cdn.setMinification({
      js: true,
      css: true,
      html: true
    });
    console.log(chalk.green('✓ Minification enabled for JS, CSS, and HTML'));

    // Step 6: Enable Brotli compression
    console.log(chalk.yellow('\nEnabling Brotli compression...'));
    await cdn.setBrotli(true);
    console.log(chalk.green('✓ Brotli compression enabled'));

    // Step 7: Enable Rocket Loader
    console.log(chalk.yellow('\nEnabling Rocket Loader...'));
    await cdn.setRocketLoader('automatic');
    console.log(chalk.green('✓ Rocket Loader enabled'));

    // Step 8: Enable image optimization
    console.log(chalk.yellow('\nEnabling image optimization...'));
    await cdn.setPolish('lossless');
    await cdn.setWebP(true);
    console.log(chalk.green('✓ Image optimization enabled (lossless + WebP)'));

    // Step 9: List all page rules
    console.log(chalk.yellow('\nListing page rules...'));
    const rulesResult = await cdn.listPageRules();
    console.log(chalk.cyan('\nActive Page Rules:'));
    rulesResult.rules.forEach(rule => {
      const target = rule.targets[0];
      console.log(`  - ${target.constraint.value}`);
      rule.actions.forEach(action => {
        console.log(`    ${action.id}: ${action.value}`);
      });
    });

    // Example: Purge cache
    console.log(chalk.yellow('\n\nExample cache purge operations:'));
    console.log(chalk.gray('  // Purge specific URLs'));
    console.log(chalk.gray('  await cdn.purgeUrls(['));
    console.log(chalk.gray('    "https://example.com/page1.html",'));
    console.log(chalk.gray('    "https://example.com/page2.html"'));
    console.log(chalk.gray('  ]);'));
    console.log(chalk.gray('\n  // Purge everything (use with caution!)'));
    console.log(chalk.gray('  await cdn.purgeAll();'));

    console.log(chalk.green('\n✓ CDN cache configuration complete!'));
    console.log(chalk.blue('\n📊 Monitor cache analytics in the Cloudflare dashboard'));

  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error.message);
    process.exit(1);
  }
}

// Run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  setupCDNCache();
}

export { setupCDNCache };
