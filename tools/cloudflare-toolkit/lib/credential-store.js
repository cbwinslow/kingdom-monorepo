/**
 * CredentialStore - Securely store and manage credentials
 */

import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class CredentialStore {
  constructor(configPath = null) {
    this.configPath = configPath || path.join(__dirname, '../config/.credentials.enc');
    this.algorithm = 'aes-256-gcm';
  }

  /**
   * Encrypt data
   */
  encrypt(data, password) {
    const salt = crypto.randomBytes(16);
    const key = crypto.scryptSync(password, salt, 32);
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, key, iv);
    
    let encrypted = cipher.update(JSON.stringify(data), 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted,
      salt: salt.toString('hex'),
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    };
  }

  /**
   * Decrypt data
   */
  decrypt(encryptedData, password) {
    try {
      const salt = Buffer.from(encryptedData.salt, 'hex');
      const key = crypto.scryptSync(password, salt, 32);
      const iv = Buffer.from(encryptedData.iv, 'hex');
      const authTag = Buffer.from(encryptedData.authTag, 'hex');
      
      const decipher = crypto.createDecipheriv(this.algorithm, key, iv);
      decipher.setAuthTag(authTag);
      
      let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
      decrypted += decipher.final('utf8');
      
      return JSON.parse(decrypted);
    } catch (error) {
      throw new Error('Failed to decrypt credentials. Wrong password?');
    }
  }

  /**
   * Store credentials
   */
  async store(credentials, password) {
    const encrypted = this.encrypt(credentials, password);
    const dir = path.dirname(this.configPath);
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    fs.writeFileSync(this.configPath, JSON.stringify(encrypted, null, 2));
    
    return {
      success: true,
      message: 'Credentials stored successfully'
    };
  }

  /**
   * Load credentials
   */
  async load(password) {
    if (!fs.existsSync(this.configPath)) {
      throw new Error('No credentials found. Run store command first.');
    }
    
    const encrypted = JSON.parse(fs.readFileSync(this.configPath, 'utf8'));
    return this.decrypt(encrypted, password);
  }

  /**
   * Check if credentials exist
   */
  exists() {
    return fs.existsSync(this.configPath);
  }

  /**
   * Remove stored credentials
   */
  remove() {
    if (fs.existsSync(this.configPath)) {
      fs.unlinkSync(this.configPath);
      return {
        success: true,
        message: 'Credentials removed successfully'
      };
    }
    return {
      success: false,
      message: 'No credentials found'
    };
  }
}
