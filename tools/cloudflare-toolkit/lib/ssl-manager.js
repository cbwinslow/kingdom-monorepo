/**
 * SSLManager - Manage SSL/TLS certificates
 */

import { CloudflareClient } from './cloudflare-client.js';

export class SSLManager extends CloudflareClient {
  constructor(options = {}) {
    super(options);
  }

  /**
   * Set SSL mode
   */
  async setMode(mode) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/ssl`,
        { value: mode }
      );

      return {
        success: true,
        mode: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set SSL mode: ${error.message}`);
    }
  }

  /**
   * Get SSL settings
   */
  async getSettings() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/settings/ssl`
      );

      return {
        success: true,
        settings: result.result
      };
    } catch (error) {
      throw new Error(`Failed to get SSL settings: ${error.message}`);
    }
  }

  /**
   * Enable/disable Always Use HTTPS
   */
  async setAlwaysUseHTTPS(enabled) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/always_use_https`,
        { value: enabled ? 'on' : 'off' }
      );

      return {
        success: true,
        enabled: result.result.value === 'on'
      };
    } catch (error) {
      throw new Error(`Failed to set Always Use HTTPS: ${error.message}`);
    }
  }

  /**
   * Enable/disable Automatic HTTPS Rewrites
   */
  async setAutomaticHTTPSRewrites(enabled) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/automatic_https_rewrites`,
        { value: enabled ? 'on' : 'off' }
      );

      return {
        success: true,
        enabled: result.result.value === 'on'
      };
    } catch (error) {
      throw new Error(`Failed to set Automatic HTTPS Rewrites: ${error.message}`);
    }
  }

  /**
   * Enable/disable Opportunistic Encryption
   */
  async setOpportunisticEncryption(enabled) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/opportunistic_encryption`,
        { value: enabled ? 'on' : 'off' }
      );

      return {
        success: true,
        enabled: result.result.value === 'on'
      };
    } catch (error) {
      throw new Error(`Failed to set Opportunistic Encryption: ${error.message}`);
    }
  }

  /**
   * Set minimum TLS version
   */
  async setMinTLSVersion(version) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/min_tls_version`,
        { value: version }
      );

      return {
        success: true,
        version: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to set minimum TLS version: ${error.message}`);
    }
  }

  /**
   * Enable HSTS
   */
  async enableHSTS(options = {}) {
    try {
      const result = await this.request(
        'PATCH',
        `/zones/${this.zoneId}/settings/security_header`,
        {
          value: {
            strict_transport_security: {
              enabled: true,
              max_age: options.maxAge || 31536000,
              include_subdomains: options.includeSubdomains !== false,
              preload: options.preload || false,
              nosniff: options.nosniff !== false
            }
          }
        }
      );

      return {
        success: true,
        hsts: result.result.value
      };
    } catch (error) {
      throw new Error(`Failed to enable HSTS: ${error.message}`);
    }
  }

  /**
   * Get universal SSL settings
   */
  async getUniversalSSL() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/ssl/universal/settings`
      );

      return {
        success: true,
        settings: result.result
      };
    } catch (error) {
      throw new Error(`Failed to get Universal SSL settings: ${error.message}`);
    }
  }

  /**
   * List SSL certificates
   */
  async listCertificates() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/ssl/certificate_packs`
      );

      return {
        success: true,
        certificates: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list certificates: ${error.message}`);
    }
  }
}
