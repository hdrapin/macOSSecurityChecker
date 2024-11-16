# macOS Security Checker

A command-line (tool) swift script for checking various security parameters and configurations on macOS systems.

## Overview

This tool provides a comprehensive security assessment of your macOS system by checking various security features and configurations. It helps system administrators and security professionals quickly verify the security posture of a macOS device.

## Features

The tool checks and reports on the following security parameters:

### System Information
- Mac Model identification
- iBoot version status
- Current macOS version

### Security Features Status
- XProtect version and status
- MRT (Malware Removal Tool) version
- TCC (Transparency Consent and Control) status
- KEXT (Kernel Extensions) version
- Gatekeeper status
- FileVault encryption status

### Platform Security
- Secure Boot configuration
- System Integrity Protection (SIP) status
- Signed System Volume status
- Kernel CTRR (Configurable Text Region Restrictions)
- Boot Arguments Filtering
- Kernel Extensions permissions
- MDM Operations status
  - User Approved operations
  - DEP Approved operations

## Requirements

- macOS 11.0 or later
- Administrative privileges
- Swift runtime environment

## Status Definitions

- **Active**: Feature is enabled and functioning
- **Inactive**: Feature is disabled
- **Found/Not Found**: Component presence status
- **Yes/No**: Boolean setting state
- **On/Off**: Feature enablement status

## Important Security Notes

1. **FileVault**: Should be "On" for disk encryption
2. **SIP**: Should be "Active" for system file protection
3. **Secure Boot**: Should be "Active" for startup security
4. **Gatekeeper**: Should be "Active" for application security

## Troubleshooting

If the script fails to run:
1. Verify execution permissions:
   ```bash
   chmod +x macsec.swift
   ```
2. Ensure administrative privileges:
   ```bash
   sudo ./macsec.swift
   ```
3. Check system compatibility:
   ```bash
   sw_vers
   ```

## Known Limitations

- Administrative privileges required
- Some features may be hardware-dependent
- Results vary by macOS version

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Disclaimer

This tool is provided as-is. Always verify critical security settings through official Apple tools and documentation.

## Support

For issues and feature requests, please create an issue in the repository.
