# Encryption in Frappe and ERPNext

## Overview

This document provides a comprehensive overview of all encryption methods, algorithms, and security implementations used in the Frappe framework and ERPNext applications.

## Table of Contents

1. [Encryption Libraries](#encryption-libraries)
2. [Password Hashing](#password-hashing)
3. [Data Encryption at Rest](#data-encryption-at-rest)
4. [API Key and Secret Encryption](#api-key-and-secret-encryption)
5. [Signature and Message Authentication](#signature-and-message-authentication)
6. [Configuration Keys](#configuration-keys)
7. [Security Best Practices](#security-best-practices)

---

## Encryption Libraries

### 1. Cryptography (Fernet)

**Primary encryption library for sensitive data**

- **Algorithm**: Fernet (AES-128 in CBC mode with HMAC authentication)
- **Library**: `cryptography~=44.0.1`
- **Implementation**: [frappe/utils/password.py](../frappe/frappe/utils/password.py)

**Key Functions**:
```python
encrypt(txt, encryption_key=None)    # Encrypts sensitive data
decrypt(txt, encryption_key=None)    # Decrypts sensitive data
```

**Used For**:
- Password field encryption
- API secrets
- OAuth credentials
- 2FA secrets
- Any sensitive configuration data

### 2. Passlib

**Password hashing library**

- **Algorithms**: PBKDF2-SHA256 (primary), Argon2 (secondary)
- **Library**: `passlib~=1.7.4`
- **Implementation**: [frappe/utils/password.py](../frappe/frappe/utils/password.py)

### 3. PyOTP

**One-Time Password implementation**

- **Purpose**: Two-Factor Authentication (2FA)
- **Algorithms**: TOTP (Time-based), HOTP (HMAC-based)
- **Library**: `pyotp~=2.8.0`
- **Implementation**: [frappe/twofactor.py](../frappe/frappe/twofactor.py)

### 4. Additional Cryptographic Libraries

- **PyJWT** (`~2.8.0`): JWT token handling
- **PyOpenSSL** (`~25.0.0`): SSL/TLS certificate handling
- **RSA** (`>=4.1`): Public-key cryptography
- **oauthlib** (`~3.2.2`): OAuth protocol implementation

---

## Password Hashing

### User Password Storage

**Location**: `__Auth` database table

**Hashing Algorithms**:
1. **PBKDF2-SHA256** (Primary)
   - Key derivation function with SHA-256
   - Industry standard for password storage
   - Resistant to brute-force attacks

2. **Argon2** (Secondary)
   - Modern memory-hard algorithm
   - Winner of Password Hashing Competition
   - Resistant to GPU/ASIC attacks

**Implementation Details**:
```python
# Password hashing context
passlibctx = CryptContext(schemes=["pbkdf2_sha256", "argon2"])

# Hashing
hashed = passlibctx.hash(password)

# Verification
is_valid = passlibctx.verify(password, hashed)

# Automatic upgrade to newer algorithm
if passlibctx.needs_update(hashed):
    # Rehash with current best algorithm
```

**Storage**:
- Table: `__Auth`
- Field: `password` (TEXT)
- Flag: `encrypted = 0` (indicates hashed, not encrypted)
- Key format: `doctype.name.fieldname`

**Important**: User passwords are HASHED, not encrypted. This is a one-way function and cannot be reversed.

---

## Data Encryption at Rest

### 1. Fernet Symmetric Encryption

**Used For**: All password-type fields in documents

**Algorithm Details**:
- **Cipher**: AES-128-CBC
- **Authentication**: HMAC using SHA-256
- **Key Size**: 256 bits (32 bytes, base64-encoded)
- **Implementation**: Fernet specification (symmetric encryption)

**How It Works**:
```python
# Encryption
from cryptography.fernet import Fernet

cipher_suite = Fernet(encryption_key)
encrypted = cipher_suite.encrypt(plaintext.encode())

# Decryption
decrypted = cipher_suite.decrypt(encrypted)
```

**Encryption Key**:
- Stored in: `site_config.json`
- Key name: `encryption_key`
- Auto-generated if missing using `Fernet.generate_key()`
- **Critical**: Losing this key means losing access to all encrypted data

### 2. Password Field Encryption

**Process**:
1. Fields with `fieldtype="Password"` are automatically encrypted
2. On save, the actual password is encrypted using Fernet
3. Encrypted value stored in `__Auth` table with `encrypted = 1`
4. Field in main document replaced with asterisks (`****`)
5. Retrieved via `get_decrypted_password()` when needed

**Database Schema**:
```sql
CREATE TABLE `__Auth` (
    `doctype` VARCHAR(140) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `fieldname` VARCHAR(140) NOT NULL,
    `password` TEXT NOT NULL,
    `encrypted` INT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`doctype`, `name`, `fieldname`)
)
```

### 3. Backup Encryption

**Algorithm**: GPG (GNU Privacy Guard) symmetric encryption

**Implementation**: [frappe/utils/backups.py](../frappe/frappe/utils/backups.py)

**Process**:
```bash
gpg --yes --passphrase {key} --pinentry-mode loopback -c {file}
```

**Configuration**:
- Enable via: System Settings → "Encrypt Backup"
- Key stored in: `site_config.json` as `backup_encryption_key`
- Separate from main `encryption_key` for security isolation

**Encrypted Files**:
- Database dumps (`*.sql.gz`)
- Public file archives (`*.tar`)
- Private file archives (`*.tar`)
- Site configuration backups (`*.json`)

**Important**: Backup encryption key is separate from the main encryption key to prevent a single point of failure.

---

## API Key and Secret Encryption

### 1. User API Credentials

**Fields**:
- `api_key`: Stored as plain text (15-character hash)
- `api_secret`: Encrypted as Password field

**Generation**:
```python
api_key = frappe.generate_hash(length=15)      # Plain text
api_secret = frappe.generate_hash(length=15)   # Encrypted in __Auth
```

**Storage**:
- `api_key`: User doctype (plain text)
- `api_secret`: `__Auth` table (Fernet encrypted)

**Permissions**: Requires System Manager role to generate

### 2. OAuth Client Credentials

**Doctypes**:
- OAuth Client
- Social Login Key

**Encrypted Fields**:
- `client_secret` (Password field)

**Retrieval**:
```python
client_secret = get_decrypted_password("Social Login Key", provider, "client_secret")
```

**Supported Providers**:
- Google
- Facebook
- GitHub
- Office 365
- Salesforce
- Keycloak
- Custom OAuth providers

### 3. Integration Secrets

**Examples**:
- Google Settings: `client_secret`
- Payment Gateway credentials
- Third-party API keys
- Webhook secrets

**All stored using Password field encryption with Fernet**

---

## Signature and Message Authentication

### HMAC-SHA512 Request Signing

**Purpose**: Verify request authenticity and prevent tampering

**Algorithm**: HMAC (Hash-based Message Authentication Code) with SHA-512

**Implementation**: [frappe/utils/verified_command.py](../frappe/frappe/utils/verified_command.py)

```python
import hmac
import hashlib

def _sign_message(message: str) -> str:
    return hmac.new(
        get_secret().encode(),
        message.encode(),
        digestmod=hashlib.sha512
    ).hexdigest()
```

**Secret Source**:
```python
def get_secret():
    # Uses "secret" from site_config, falls back to encryption_key
    return frappe.local.conf.get("secret") or get_encryption_key()
```

**Verification**:
```python
# Timing-safe comparison to prevent timing attacks
valid = hmac.compare_digest(given_signature, computed_signature)
```

**Use Cases**:
- API request verification
- Webhook payload validation
- Command execution authentication

### Additional Hash Functions

**SHA-256**: General-purpose hashing
```python
hashlib.sha256(input).hexdigest()
```

**MD5** (Non-security contexts only):
- Email gravatar generation
- Identicon creation
- File checksums

**Note**: MD5 is NOT used for security-critical operations due to known vulnerabilities.

---

## Configuration Keys

### Site Configuration (`site_config.json`)

**Encryption Keys**:

1. **`encryption_key`**
   - Primary encryption key for all Fernet operations
   - Format: 32-byte URL-safe base64-encoded string
   - Auto-generated on first use
   - **Critical**: Backup this key securely

2. **`backup_encryption_key`**
   - Separate key for backup encryption
   - Uses GPG symmetric encryption
   - Independent from main encryption key
   - Also auto-generated if missing

3. **`secret`**
   - Used for HMAC request signing
   - Falls back to `encryption_key` if not set
   - Optional but recommended for separation of concerns

**Example**:
```json
{
    "encryption_key": "abcdefghijklmnopqrstuvwxyz0123456789ABCD=",
    "backup_encryption_key": "zyxwvutsrqponmlkjihgfedcba9876543210WXYZ=",
    "secret": "your-secret-for-hmac-signing"
}
```

### System Settings

**Backup Encryption Toggle**:
- Setting: `encrypt_backup`
- Type: Boolean
- Effect: Enables/disables GPG encryption of backups
- Default: Disabled

---

## Security Best Practices

### Key Management

1. **Backup Encryption Keys**
   - Store `encryption_key` securely outside the server
   - Use a password manager or secure vault
   - Document key recovery procedures

2. **Key Rotation**
   - Plan for periodic key rotation
   - Test decryption before rotating
   - Maintain old keys for historical data

3. **Separate Keys**
   - Use different keys for production/staging/development
   - Keep backup encryption key separate
   - Use unique `secret` for HMAC signing

### Data Protection

1. **Password Fields**
   - Always use `fieldtype="Password"` for sensitive data
   - Never log or display encrypted passwords
   - Use `get_decrypted_password()` only when necessary

2. **API Credentials**
   - Regenerate compromised API keys immediately
   - Use role-based access control
   - Audit API key usage regularly

3. **Backups**
   - Enable backup encryption in production
   - Store backup encryption key separately
   - Test backup restoration regularly

### Algorithm Selection

**Current Best Practices**:
- **Passwords**: PBKDF2-SHA256 or Argon2 (automatic)
- **Symmetric Encryption**: Fernet (AES-128-CBC + HMAC-SHA256)
- **Request Signing**: HMAC-SHA512
- **Backup Encryption**: GPG symmetric

**Automatic Upgrades**:
- Frappe automatically upgrades password hashes to newer algorithms
- Happens transparently during user login
- No manual intervention required

---

## Summary Table

| Use Case | Algorithm | Method | Reversible |
|----------|-----------|--------|------------|
| User Passwords | PBKDF2-SHA256, Argon2 | Hashing | No |
| Password Fields | Fernet (AES-128-CBC) | Encryption | Yes |
| API Secrets | Fernet (AES-128-CBC) | Encryption | Yes |
| 2FA Secrets | Fernet (AES-128-CBC) | Encryption | Yes |
| Backups | GPG Symmetric | Encryption | Yes |
| Request Signing | HMAC-SHA512 | MAC | No |
| File Checksums | SHA-256 | Hashing | No |

---

## Important Notes

1. **ERPNext Encryption**: ERPNext does not implement additional encryption beyond what Frappe provides. All ERPNext security relies on the Frappe framework's encryption infrastructure.

2. **Key Loss Recovery**: If encryption keys are lost, encrypted data CANNOT be recovered. Always maintain secure backups of `site_config.json`.

3. **Migration**: Frappe includes patches to ensure encryption keys are properly configured during version upgrades.

4. **Compliance**: The encryption methods used are suitable for:
   - PCI DSS (Payment Card Industry)
   - GDPR (General Data Protection Regulation)
   - HIPAA (Health Insurance Portability and Accountability Act)
   - SOC 2 (Service Organization Control)

---

## References

- [Frappe Password Utilities](../frappe/frappe/utils/password.py)
- [Frappe Backup Encryption](../frappe/frappe/utils/backups.py)
- [Frappe Two-Factor Authentication](../frappe/frappe/twofactor.py)
- [Fernet Specification](https://github.com/fernet/spec/)
- [PBKDF2 RFC 2898](https://tools.ietf.org/html/rfc2898)
- [Argon2 Specification](https://github.com/P-H-C/phc-winner-argon2)

---

**Document Version**: 1.0
**Last Updated**: 2026-01-11
**Frappe Framework**: Compatible with v14.0+
**ERPNext**: Compatible with all versions using Frappe v14.0+
