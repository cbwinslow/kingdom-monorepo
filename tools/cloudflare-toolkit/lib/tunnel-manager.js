/**
 * TunnelManager - Manage Cloudflare Tunnels
 */

import { CloudflareClient } from './cloudflare-client.js';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export class TunnelManager extends CloudflareClient {
  constructor(options = {}) {
    super(options);
  }

  /**
   * Create a new tunnel using cloudflared CLI
   */
  async create(name) {
    try {
      const { stdout } = await execAsync(`cloudflared tunnel create ${name}`);
      
      // Parse tunnel ID from output
      const match = stdout.match(/Created tunnel .+ with id ([a-f0-9-]+)/);
      const tunnelId = match ? match[1] : null;
      
      return {
        success: true,
        name,
        id: tunnelId,
        message: stdout
      };
    } catch (error) {
      throw new Error(`Failed to create tunnel: ${error.message}`);
    }
  }

  /**
   * List all tunnels
   */
  async list() {
    try {
      const { stdout } = await execAsync('cloudflared tunnel list');
      return {
        success: true,
        output: stdout
      };
    } catch (error) {
      throw new Error(`Failed to list tunnels: ${error.message}`);
    }
  }

  /**
   * Delete a tunnel
   */
  async delete(name) {
    try {
      const { stdout } = await execAsync(`cloudflared tunnel delete ${name}`);
      return {
        success: true,
        message: stdout
      };
    } catch (error) {
      throw new Error(`Failed to delete tunnel: ${error.message}`);
    }
  }

  /**
   * Create DNS route for tunnel
   */
  async createRoute(tunnelName, hostname) {
    try {
      const { stdout } = await execAsync(
        `cloudflared tunnel route dns ${tunnelName} ${hostname}`
      );
      return {
        success: true,
        message: stdout
      };
    } catch (error) {
      throw new Error(`Failed to create route: ${error.message}`);
    }
  }

  /**
   * Get tunnel information
   */
  async info(name) {
    try {
      const { stdout } = await execAsync(`cloudflared tunnel info ${name}`);
      return {
        success: true,
        output: stdout
      };
    } catch (error) {
      throw new Error(`Failed to get tunnel info: ${error.message}`);
    }
  }

  /**
   * Run a tunnel (non-blocking, returns immediately)
   */
  async run(name, configPath = null) {
    const command = configPath
      ? `cloudflared tunnel --config ${configPath} run`
      : `cloudflared tunnel run ${name}`;
    
    try {
      // Run in background
      exec(command, (error, stdout, stderr) => {
        if (error) {
          console.error(`Tunnel error: ${error.message}`);
        }
      });
      
      return {
        success: true,
        message: `Tunnel ${name} started`
      };
    } catch (error) {
      throw new Error(`Failed to run tunnel: ${error.message}`);
    }
  }

  /**
   * Login to cloudflared
   */
  async login() {
    try {
      const { stdout } = await execAsync('cloudflared tunnel login');
      return {
        success: true,
        message: stdout
      };
    } catch (error) {
      throw new Error(`Failed to login: ${error.message}`);
    }
  }
}
