/**
 * WAFManager - Manage Web Application Firewall rules
 */

import { CloudflareClient } from './cloudflare-client.js';

export class WAFManager extends CloudflareClient {
  constructor(options = {}) {
    super(options);
  }

  /**
   * Create a firewall rule
   */
  async createRule(options = {}) {
    try {
      // First, create the filter
      const filterResult = await this.request(
        'POST',
        `/zones/${this.zoneId}/filters`,
        [{
          expression: options.expression,
          description: options.description
        }]
      );

      const filterId = filterResult.result[0].id;

      // Then, create the firewall rule
      const ruleResult = await this.request(
        'POST',
        `/zones/${this.zoneId}/firewall/rules`,
        [{
          filter: { id: filterId },
          action: options.action || 'block',
          priority: options.priority || 1,
          description: options.description
        }]
      );

      return {
        success: true,
        rule: ruleResult.result[0]
      };
    } catch (error) {
      throw new Error(`Failed to create firewall rule: ${error.message}`);
    }
  }

  /**
   * List firewall rules
   */
  async listRules() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/firewall/rules`
      );

      return {
        success: true,
        rules: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list firewall rules: ${error.message}`);
    }
  }

  /**
   * Update a firewall rule
   */
  async updateRule(ruleId, updates = {}) {
    try {
      const result = await this.request(
        'PUT',
        `/zones/${this.zoneId}/firewall/rules/${ruleId}`,
        updates
      );

      return {
        success: true,
        rule: result.result
      };
    } catch (error) {
      throw new Error(`Failed to update firewall rule: ${error.message}`);
    }
  }

  /**
   * Delete a firewall rule
   */
  async deleteRule(ruleId) {
    try {
      await this.request(
        'DELETE',
        `/zones/${this.zoneId}/firewall/rules/${ruleId}`
      );

      return {
        success: true,
        message: `Rule ${ruleId} deleted successfully`
      };
    } catch (error) {
      throw new Error(`Failed to delete firewall rule: ${error.message}`);
    }
  }

  /**
   * Create rate limit rule
   */
  async createRateLimit(options = {}) {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/rate_limits`,
        {
          description: options.description,
          match: options.match || {
            request: {
              url_pattern: options.urlPattern || '*'
            }
          },
          threshold: options.threshold || 100,
          period: options.period || 60,
          action: options.action || { mode: 'challenge' }
        }
      );

      return {
        success: true,
        rateLimit: result.result
      };
    } catch (error) {
      throw new Error(`Failed to create rate limit: ${error.message}`);
    }
  }

  /**
   * List rate limits
   */
  async listRateLimits() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/rate_limits`
      );

      return {
        success: true,
        rateLimits: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list rate limits: ${error.message}`);
    }
  }

  /**
   * Create IP access rule
   */
  async createIPRule(ip, mode = 'block', notes = '') {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/firewall/access_rules/rules`,
        {
          mode, // block, challenge, whitelist, js_challenge
          configuration: {
            target: 'ip',
            value: ip
          },
          notes
        }
      );

      return {
        success: true,
        rule: result.result
      };
    } catch (error) {
      throw new Error(`Failed to create IP rule: ${error.message}`);
    }
  }

  /**
   * List IP access rules
   */
  async listIPRules() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/firewall/access_rules/rules`
      );

      return {
        success: true,
        rules: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list IP rules: ${error.message}`);
    }
  }

  /**
   * Block a country
   */
  async blockCountry(countryCode, notes = '') {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/firewall/access_rules/rules`,
        {
          mode: 'block',
          configuration: {
            target: 'country',
            value: countryCode
          },
          notes
        }
      );

      return {
        success: true,
        rule: result.result
      };
    } catch (error) {
      throw new Error(`Failed to block country: ${error.message}`);
    }
  }

  /**
   * Set security level
   */
  async setSecurityLevel(level) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/security_level`,
        { value: level }
      );

      return {
        success: true,
        level: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set security level: ${error.message}`);
    }
  }

  /**
   * Enable/disable bot fight mode
   */
  async setBotFightMode(enabled) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/bot_fight_mode`,
        { value: enabled ? 'on' : 'off' }
      );

      return {
        success: true,
        enabled: result.result.value === 'on'
      };
    } catch (error) {
      throw new Error(`Failed to set bot fight mode: ${error.message}`);
    }
  }

  /**
   * Get firewall analytics
   */
  async getAnalytics(options = {}) {
    try {
      const since = options.since || new Date(Date.now() - 24 * 60 * 60 * 1000);
      const until = options.until || new Date();

      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/firewall/analytics?since=${since.toISOString()}&until=${until.toISOString()}`
      );

      return {
        success: true,
        analytics: result.result
      };
    } catch (error) {
      throw new Error(`Failed to get analytics: ${error.message}`);
    }
  }
}
