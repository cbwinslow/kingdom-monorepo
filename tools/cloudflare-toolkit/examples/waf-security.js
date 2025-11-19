/**
 * WAF Security Rules Example
 * 
 * This example demonstrates:
 * - Creating firewall rules
 * - Setting up rate limiting
 * - Blocking malicious traffic
 */

import { WAFManager } from '../lib/waf-manager.js';
import chalk from 'chalk';

async function setupWAFSecurity() {
  const waf = new WAFManager();

  try {
    console.log(chalk.blue('🛡️  Setting up WAF Security...\n'));

    // Step 1: Block known bad IPs
    console.log(chalk.yellow('Creating IP block rules...'));
    await waf.createIPRule('192.0.2.1', 'block', 'Known malicious IP');
    console.log(chalk.green('✓ IP block rule created'));

    // Step 2: Protect admin area
    console.log(chalk.yellow('\nProtecting admin area...'));
    await waf.createRule({
      description: 'Challenge admin area access',
      expression: '(http.request.uri.path contains "/admin" and cf.threat_score > 5)',
      action: 'challenge',
      priority: 1
    });
    console.log(chalk.green('✓ Admin protection rule created'));

    // Step 3: Block SQL injection attempts
    console.log(chalk.yellow('\nCreating SQL injection protection...'));
    await waf.createRule({
      description: 'Block SQL injection',
      expression: `(
        http.request.uri.query contains "union select" or
        http.request.uri.query contains "drop table" or
        http.request.uri.query contains "'; drop" or
        http.request.uri.query contains "1=1"
      )`,
      action: 'block',
      priority: 1
    });
    console.log(chalk.green('✓ SQL injection rule created'));

    // Step 4: Set up rate limiting for login
    console.log(chalk.yellow('\nSetting up rate limiting for login...'));
    await waf.createRateLimit({
      description: 'Login rate limit',
      match: {
        request: {
          url_pattern: '*/login',
          methods: ['POST']
        }
      },
      threshold: 5,
      period: 300, // 5 minutes
      action: {
        mode: 'block',
        timeout: 3600 // 1 hour block
      }
    });
    console.log(chalk.green('✓ Login rate limit created'));

    // Step 5: Set up API rate limiting
    console.log(chalk.yellow('\nSetting up API rate limiting...'));
    await waf.createRateLimit({
      description: 'API rate limit per IP',
      match: {
        request: {
          url_pattern: '*/api/*'
        }
      },
      threshold: 100,
      period: 60, // 1 minute
      action: {
        mode: 'challenge'
      }
    });
    console.log(chalk.green('✓ API rate limit created'));

    // Step 6: Block automated tools
    console.log(chalk.yellow('\nBlocking automated tools...'));
    await waf.createRule({
      description: 'Block automated tools',
      expression: `(
        http.user_agent contains "curl" or
        http.user_agent contains "wget" or
        http.user_agent contains "python-requests" or
        http.user_agent eq ""
      )`,
      action: 'challenge',
      priority: 2
    });
    console.log(chalk.green('✓ Automated tools rule created'));

    // Step 7: Set security level
    console.log(chalk.yellow('\nSetting security level...'));
    await waf.setSecurityLevel('high');
    console.log(chalk.green('✓ Security level set to high'));

    // Step 8: Enable bot fight mode
    console.log(chalk.yellow('\nEnabling bot fight mode...'));
    await waf.setBotFightMode(true);
    console.log(chalk.green('✓ Bot fight mode enabled'));

    // Step 9: List all rules
    console.log(chalk.yellow('\nListing all firewall rules...'));
    const rulesResult = await waf.listRules();
    console.log(chalk.cyan('\nActive Firewall Rules:'));
    rulesResult.rules.forEach(rule => {
      console.log(`  - ${rule.description} (${rule.action})`);
    });

    console.log(chalk.green('\n✓ WAF security setup complete!'));
    console.log(chalk.blue('\n📊 Monitor your firewall events in the Cloudflare dashboard'));

  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error.message);
    process.exit(1);
  }
}

// Run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  setupWAFSecurity();
}

export { setupWAFSecurity };
