/**
 * CloudflareClient - Base client for Cloudflare API interactions
 */

import Cloudflare from 'cloudflare';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables
dotenv.config({ path: join(__dirname, '../config/.env') });

export class CloudflareClient {
  constructor(options = {}) {
    this.apiToken = options.apiToken || process.env.CLOUDFLARE_API_TOKEN;
    this.apiKey = options.apiKey || process.env.CLOUDFLARE_API_KEY;
    this.email = options.email || process.env.CLOUDFLARE_EMAIL;
    this.accountId = options.accountId || process.env.CLOUDFLARE_ACCOUNT_ID;
    this.zoneId = options.zoneId || process.env.CLOUDFLARE_ZONE_ID;

    if (!this.apiToken && !(this.apiKey && this.email)) {
      throw new Error(
        'Cloudflare credentials required. Set CLOUDFLARE_API_TOKEN or CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL'
      );
    }

    // Initialize Cloudflare SDK client
    this.client = new Cloudflare(
      this.apiToken
        ? { apiToken: this.apiToken }
        : { apiKey: this.apiKey, email: this.email }
    );
  }

  /**
   * Verify API credentials
   */
  async verify() {
    try {
      const result = await this.client.user.tokens.verify();
      return {
        success: true,
        status: result.status,
        id: result.id
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Get zone information
   */
  async getZone(zoneId = this.zoneId) {
    if (!zoneId) {
      throw new Error('Zone ID required');
    }
    return await this.client.zones.get({ zone_id: zoneId });
  }

  /**
   * List zones
   */
  async listZones() {
    return await this.client.zones.list();
  }

  /**
   * Get account information
   */
  async getAccount(accountId = this.accountId) {
    if (!accountId) {
      throw new Error('Account ID required');
    }
    return await this.client.accounts.get({ account_id: accountId });
  }

  /**
   * Make a custom API request
   */
  async request(method, endpoint, data = null) {
    const url = `https://api.cloudflare.com/client/v4${endpoint}`;
    const headers = {
      'Content-Type': 'application/json',
      ...(this.apiToken
        ? { Authorization: `Bearer ${this.apiToken}` }
        : {
            'X-Auth-Key': this.apiKey,
            'X-Auth-Email': this.email
          })
    };

    const options = {
      method,
      headers
    };

    if (data && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
      options.body = JSON.stringify(data);
    }

    const response = await fetch(url, options);
    const result = await response.json();

    if (!result.success) {
      throw new Error(
        `Cloudflare API error: ${result.errors?.map(e => e.message).join(', ')}`
      );
    }

    return result;
  }
}
