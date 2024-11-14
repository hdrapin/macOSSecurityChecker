# macOS Security Checker

A command-line tool for checking various security parameters and configurations on macOS systems.

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
- Administrative privileges for certain checks

## Installation

1. Clone this repository: 
git clone [repository-url]



## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License


## Disclaimer

This tool is provided as-is, without any warranties. Always verify critical security settings through official Apple tools and documentation.
