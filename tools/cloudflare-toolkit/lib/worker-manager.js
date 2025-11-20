/**
 * WorkerManager - Deploy and manage Cloudflare Workers
 */

import { CloudflareClient } from './cloudflare-client.js';
import { readFileSync } from 'fs';

export class WorkerManager extends CloudflareClient {
  constructor(options = {}) {
    super(options);
  }

  /**
   * Deploy a worker script
   */
  async deploy(name, scriptPath, options = {}) {
    try {
      const scriptContent = readFileSync(scriptPath, 'utf-8');
      
      const result = await this.request(
        'PUT',
        `/accounts/${this.accountId}/workers/scripts/${name}`,
        {
          script: scriptContent,
          bindings: options.bindings || [],
          compatibility_date: options.compatibilityDate || '2024-01-01',
          compatibility_flags: options.compatibilityFlags || []
        }
      );

      return {
        success: true,
        name,
        id: result.result.id,
        message: `Worker ${name} deployed successfully`
      };
    } catch (error) {
      throw new Error(`Failed to deploy worker: ${error.message}`);
    }
  }

  /**
   * List all workers
   */
  async list() {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/workers/scripts`
      );

      return {
        success: true,
        workers: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list workers: ${error.message}`);
    }
  }

  /**
   * Get worker details
   */
  async get(name) {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/workers/scripts/${name}`
      );

      return {
        success: true,
        worker: result.result
      };
    } catch (error) {
      throw new Error(`Failed to get worker: ${error.message}`);
    }
  }

  /**
   * Delete a worker
   */
  async delete(name) {
    try {
      await this.request(
        'DELETE',
        `/accounts/${this.accountId}/workers/scripts/${name}`
      );

      return {
        success: true,
        message: `Worker ${name} deleted successfully`
      };
    } catch (error) {
      throw new Error(`Failed to delete worker: ${error.message}`);
    }
  }

  /**
   * Create a worker route
   */
  async createRoute(pattern, workerName) {
    try {
      const result = await this.request(
        'POST',
        `/zones/${this.zoneId}/workers/routes`,
        {
          pattern,
          script: workerName
        }
      );

      return {
        success: true,
        route: result.result
      };
    } catch (error) {
      throw new Error(`Failed to create route: ${error.message}`);
    }
  }

  /**
   * List worker routes
   */
  async listRoutes() {
    try {
      const result = await this.request(
        'GET',
        `/zones/${this.zoneId}/workers/routes`
      );

      return {
        success: true,
        routes: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list routes: ${error.message}`);
    }
  }

  /**
   * Delete a worker route
   */
  async deleteRoute(routeId) {
    try {
      await this.request(
        'DELETE',
        `/zones/${this.zoneId}/workers/routes/${routeId}`
      );

      return {
        success: true,
        message: `Route ${routeId} deleted successfully`
      };
    } catch (error) {
      throw new Error(`Failed to delete route: ${error.message}`);
    }
  }

  /**
   * Create KV namespace
   */
  async createKVNamespace(title) {
    try {
      const result = await this.request(
        'POST',
        `/accounts/${this.accountId}/storage/kv/namespaces`,
        { title }
      );

      return {
        success: true,
        namespace: result.result
      };
    } catch (error) {
      throw new Error(`Failed to create KV namespace: ${error.message}`);
    }
  }

  /**
   * Get worker subdomain
   */
  async getSubdomain() {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/workers/subdomain`
      );

      return {
        success: true,
        subdomain: result.result.subdomain
      };
    } catch (error) {
      throw new Error(`Failed to get subdomain: ${error.message}`);
    }
  }
}
