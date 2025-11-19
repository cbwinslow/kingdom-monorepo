/**
 * PagesManager - Deploy and manage Cloudflare Pages
 */

import { CloudflareClient } from './cloudflare-client.js';

export class PagesManager extends CloudflareClient {
  constructor(options = {}) {
    super(options);
  }

  /**
   * Create a new Pages project
   */
  async create(name, options = {}) {
    try {
      const result = await this.request(
        'POST',
        `/accounts/${this.accountId}/pages/projects`,
        {
          name,
          production_branch: options.productionBranch || 'main',
          ...options
        }
      );

      return {
        success: true,
        project: result.result
      };
    } catch (error) {
      throw new Error(`Failed to create Pages project: ${error.message}`);
    }
  }

  /**
   * List all Pages projects
   */
  async list() {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/pages/projects`
      );

      return {
        success: true,
        projects: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list Pages projects: ${error.message}`);
    }
  }

  /**
   * Get Pages project details
   */
  async get(projectName) {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/pages/projects/${projectName}`
      );

      return {
        success: true,
        project: result.result
      };
    } catch (error) {
      throw new Error(`Failed to get Pages project: ${error.message}`);
    }
  }

  /**
   * Delete a Pages project
   */
  async delete(projectName) {
    try {
      await this.request(
        'DELETE',
        `/accounts/${this.accountId}/pages/projects/${projectName}`
      );

      return {
        success: true,
        message: `Pages project ${projectName} deleted successfully`
      };
    } catch (error) {
      throw new Error(`Failed to delete Pages project: ${error.message}`);
    }
  }

  /**
   * List deployments for a project
   */
  async listDeployments(projectName) {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/pages/projects/${projectName}/deployments`
      );

      return {
        success: true,
        deployments: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list deployments: ${error.message}`);
    }
  }

  /**
   * Get deployment details
   */
  async getDeployment(projectName, deploymentId) {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/pages/projects/${projectName}/deployments/${deploymentId}`
      );

      return {
        success: true,
        deployment: result.result
      };
    } catch (error) {
      throw new Error(`Failed to get deployment: ${error.message}`);
    }
  }

  /**
   * Retry a deployment
   */
  async retryDeployment(projectName, deploymentId) {
    try {
      const result = await this.request(
        'POST',
        `/accounts/${this.accountId}/pages/projects/${projectName}/deployments/${deploymentId}/retry`
      );

      return {
        success: true,
        deployment: result.result
      };
    } catch (error) {
      throw new Error(`Failed to retry deployment: ${error.message}`);
    }
  }

  /**
   * Rollback to a deployment
   */
  async rollback(projectName, deploymentId) {
    try {
      const result = await this.request(
        'POST',
        `/accounts/${this.accountId}/pages/projects/${projectName}/deployments/${deploymentId}/rollback`
      );

      return {
        success: true,
        deployment: result.result
      };
    } catch (error) {
      throw new Error(`Failed to rollback deployment: ${error.message}`);
    }
  }

  /**
   * Add custom domain to Pages project
   */
  async addDomain(projectName, domain) {
    try {
      const result = await this.request(
        'POST',
        `/accounts/${this.accountId}/pages/projects/${projectName}/domains`,
        { name: domain }
      );

      return {
        success: true,
        domain: result.result
      };
    } catch (error) {
      throw new Error(`Failed to add domain: ${error.message}`);
    }
  }

  /**
   * List domains for a project
   */
  async listDomains(projectName) {
    try {
      const result = await this.request(
        'GET',
        `/accounts/${this.accountId}/pages/projects/${projectName}/domains`
      );

      return {
        success: true,
        domains: result.result
      };
    } catch (error) {
      throw new Error(`Failed to list domains: ${error.message}`);
    }
  }

  /**
   * Remove domain from project
   */
  async removeDomain(projectName, domain) {
    try {
      await this.request(
        'DELETE',
        `/accounts/${this.accountId}/pages/projects/${projectName}/domains/${domain}`
      );

      return {
        success: true,
        message: `Domain ${domain} removed successfully`
      };
    } catch (error) {
      throw new Error(`Failed to remove domain: ${error.message}`);
    }
  }
}
