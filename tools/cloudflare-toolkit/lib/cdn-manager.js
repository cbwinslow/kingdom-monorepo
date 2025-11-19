/**
 * CDNManager - Manage CDN caching and optimization
 */

import { CloudflareClient } from './cloudflare-client.js';

export class CDNManager extends CloudflareClient {
  constructor(options = {}) {
    super(options);
  }

  /**
   * Purge all cache
   */
  async purgeAll() {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/purge_cache`,
        { purge_everything: true }
      );

      return {
        success: true,
        message: 'All cache purged successfully'
      };
    } catch (error) {
      throw new Error(`Failed to purge all cache: ${error.message}`);
    }
  }

  /**
   * Purge cache by URLs
   */
  async purgeUrls(urls) {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/purge_cache`,
        { files: Array.isArray(urls) ? urls : [urls] }
      );

      return {
        success: true,
        message: `${urls.length} URLs purged successfully`
      };
    } catch (error) {
      throw new Error(`Failed to purge URLs: ${error.message}`);
    }
  }

  /**
   * Purge cache by tags (Enterprise)
   */
  async purgeTags(tags) {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/purge_cache`,
        { tags: Array.isArray(tags) ? tags : [tags] }
      );

      return {
        success: true,
        message: `Cache purged for ${tags.length} tags`
      };
    } catch (error) {
      throw new Error(`Failed to purge by tags: ${error.message}`);
    }
  }

  /**
   * Purge cache by hostname
   */
  async purgeHostname(hostname) {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/purge_cache`,
        { hosts: [hostname] }
      );

      return {
        success: true,
        message: `Cache purged for hostname ${hostname}`
      };
    } catch (error) {
      throw new Error(`Failed to purge hostname: ${error.message}`);
    }
  }

  /**
   * Set cache level
   */
  async setCacheLevel(level) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/cache_level`,
        { value: level }
      );

      return {
        success: true,
        level: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set cache level: ${error.message}`);
    }
  }

  /**
   * Set browser cache TTL
   */
  async setBrowserTTL(ttl) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/browser_cache_ttl`,
        { value: ttl }
      );

      return {
        success: true,
        ttl: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set browser TTL: ${error.message}`);
    }
  }

  /**
   * Create page rule
   */
  async createPageRule(rule) {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/pagerules`,
        rule
      );

      return {
        success: true,
        rule: result.result
      };
    } catch (error) {
      throw new Error(`Failed to create page rule: ${error.message}`);
    }
  }

  /**
   * List page rules
   */
  async listPageRules() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/pagerules`
      );

      return {
        success: true,
        rules: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list page rules: ${error.message}`);
    }
  }

  /**
   * Enable/disable minification
   */
  async setMinification(options = {}) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/minify`,
        {
          value: {
            js: options.js !== false,
            css: options.css !== false,
            html: options.html !== false
          }
        }
      );

      return {
        success: true,
        minification: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set minification: ${error.message}`);
    }
  }

  /**
   * Enable/disable Brotli compression
   */
  async setBrotli(enabled) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/brotli`,
        { value: enabled ? 'on' : 'off' }
      );

      return {
        success: true,
        enabled: result.result.value === 'on'
      };
    } catch (error) {
      throw new Error(`Failed to set Brotli: ${error.message}`);
    }
  }

  /**
   * Set Rocket Loader
   */
  async setRocketLoader(mode) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/rocket_loader`,
        { value: mode }
      );

      return {
        success: true,
        mode: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set Rocket Loader: ${error.message}`);
    }
  }

  /**
   * Enable/disable Polish (image optimization)
   */
  async setPolish(level) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/polish`,
        { value: level }
      );

      return {
        success: true,
        level: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set Polish: ${error.message}`);
    }
  }

  /**
   * Enable/disable WebP
   */
  async setWebP(enabled) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/webp`,
        { value: enabled ? 'on' : 'off' }
      );

      return {
        success: true,
        enabled: result.result.value === 'on'
      };
    } catch (error) {
      throw new Error(`Failed to set WebP: ${error.message}`);
    }
  }

  /**
   * Get cache analytics
   */
  async getCacheAnalytics(options = {}) {
    try {
      const since = options.since || new Date(Date.now() - 24 * 60 * 60 * 1000);
      const until = options.until || new Date();

      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/analytics/dashboard?since=${since.toISOString()}&until=${until.toISOString()}`
      );

      return {
        success: true,
        analytics: result.result
      };
    } catch (error) {
      throw new Error(`Failed to get cache analytics: ${error.message}`);
    }
  }

  /**
   * Enable Argo Smart Routing
   */
  async enableArgo(options = {}) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/argo/smart_routing`,
        { value: 'on' }
      );

      return {
        success: true,
        enabled: true
      };
    } catch (error) {
      throw new Error(`Failed to enable Argo: ${error.message}`);
    }
  }
}
