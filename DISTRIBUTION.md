# macOS Security Checker - Distribution & Executable Guide

## 🎯 Distribution Methods

The macOS Security Checker can be distributed in several ways:

### Method 1: Direct Script Distribution (Recommended)
The simplest method - distribute the `.swift` script directly:

```bash
# Users simply need Swift installed (comes with macOS)
./macOSSecurityChecker.release.swift
```

**Advantages:**
- ✅ No compilation needed
- ✅ Works on all macOS versions 11.0+
- ✅ Easy to verify source code
- ✅ Small file size (28 KB)

**Requirements:**
- Xcode Command Line Tools (pre-installed on most Macs)

---

### Method 2: Pre-compiled Binaries via GitHub Releases
Distribute compiled binaries for faster execution:

```bash
# Download from GitHub Releases
# https://github.com/hdrapin/macOSSecurityChecker/releases

# Extract and run
tar -xzf macOSSecurityChecker-macos-14.tar.gz
./macOSSecurityChecker-macos-14
```

**Advantages:**
- ✅ No Swift installation required
- ✅ 2x faster execution
- ✅ Ready to run immediately
- ✅ Easier for non-technical users

**Binaries provided for:**
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)
- macOS 15 (Sequoia)
- macOS 16 (Tahoe)

---

### Method 3: Homebrew Distribution
For Mac package manager users:

```bash
# Future: Install via Homebrew
brew install hdrapin/security/macos-security-checker

# Run
macos-security-checker --help
```

**Setup (for maintainers):**
1. Create Homebrew formula: `Formula/macos-security-checker.rb`
2. Submit to Homebrew
3. Users install with: `brew install macos-security-checker`

---

### Method 4: DMG Distribution
For GUI distribution (future enhancement):

```bash
# Download macOSSecurityChecker-2.0.0.dmg
# Double-click to mount
# Drag application to Applications folder
```

---

## 📦 Building Executable for Distribution

### Option A: Swift Compiled Binary

```bash
# Compile with optimizations
swiftc -O -o macOSSecurityChecker macOSSecurityChecker.release.swift

# Or use provided script
./BUILD_FOR_MACOS.sh

# Result: Ready-to-distribute binary in ./build/
```

### Option B: Using GitHub Actions (Automated)

The repository includes GitHub Actions workflow that automatically:
1. Compiles binary for multiple macOS versions
2. Creates compressed archives
3. Uploads to GitHub Releases
4. Generates release notes

**Workflow file:** `.github/workflows/release.yml`

```yaml
# Triggers on git tag creation
git tag v2.0.0
git push origin v2.0.0

# GitHub Actions automatically:
# - Compiles for macOS 12, 13, 14
# - Creates .tar.gz archives
# - Uploads to Releases page
# - Generates release notes
```

---

## 🚀 Distribution via GitHub

### Automated Release Process

1. **Create Release in Code:**
```bash
# Update version in code
VERSION = "2.0.1"
BUILD_DATE = "2024-05-04"

# Commit
git add -A
git commit -m "Release v2.0.1"

# Tag for release
git tag v2.0.1
git push origin main
git push origin v2.0.1
```

2. **GitHub Actions Builds:**
   - Automatically triggers on tag push
   - Compiles binary for each macOS version
   - Creates release archives
   - Uploads to GitHub Releases

3. **Users Download:**
   - From: https://github.com/hdrapin/macOSSecurityChecker/releases
   - Download appropriate binary
   - Extract and run

---

## 📥 Installation from Releases

### For End Users

```bash
# Option 1: Download latest release
# Visit: https://github.com/hdrapin/macOSSecurityChecker/releases

# Option 2: Using curl
LATEST=$(curl -s https://api.github.com/repos/hdrapin/macOSSecurityChecker/releases/latest | jq -r '.tag_name')
curl -L -o macOSSecurityChecker.tar.gz https://github.com/hdrapin/macOSSecurityChecker/releases/download/$LATEST/macOSSecurityChecker-macos-14.tar.gz

# Option 3: Direct download
curl -L -o macOSSecurityChecker.tar.gz https://github.com/hdrapin/macOSSecurityChecker/releases/download/v2.0.0/macOSSecurityChecker-macos-14.tar.gz

# Extract and run
tar -xzf macOSSecurityChecker.tar.gz
./macOSSecurityChecker-macos-14 --help
```

---

## 🔐 Signing & Notarization (macOS Requirements)

### Code Signing (for paid Apple Developer Account)

```bash
# Sign the binary
codesign -s "Developer ID Application" ./build/macOSSecurityChecker

# Verify signature
codesign -v ./build/macOSSecurityChecker
spctl -a -v ./build/macOSSecurityChecker
```

### Apple Notarization (Future)

```bash
# Notarize for Gatekeeper
xcrun altool --notarize-app \
    -f ./build/macOSSecurityChecker \
    -t macOS \
    -u your-apple-id@icloud.com \
    -p your-app-password
```

**Current Status:** Not signed/notarized (users see warning on first run)
- Can be disabled in System Settings > Security & Privacy
- Or run with: `xattr -d com.apple.quarantine ./macOSSecurityChecker`

---

## 📋 Distribution Checklist

### Pre-Release
- [ ] Update version number
- [ ] Update BUILD_DATE
- [ ] Update CHANGELOG.md
- [ ] Test on multiple macOS versions
- [ ] Run full test suite
- [ ] Update README_DETAILED.md

### Release
- [ ] Create git tag
- [ ] Push to GitHub
- [ ] GitHub Actions builds automatically
- [ ] Review generated releases
- [ ] Add release notes

### Post-Release
- [ ] Verify downloads work
- [ ] Test downloaded binaries
- [ ] Update documentation links
- [ ] Announce in discussions/issues

---

## 🔄 Continuous Distribution

### GitHub Actions Workflow

The `.github/workflows/release.yml` file handles automatic distribution:

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    # Compiles for multiple macOS versions
    # Creates compressed archives
    # Uploads artifacts

  create-release:
    # Creates GitHub release
    # Uploads binaries
    # Generates release notes
```

**To trigger:** Push a tag like `v2.0.1`
```bash
git tag v2.0.1
git push origin v2.0.1
```

---

## 📊 Available Distributions

### Script (.swift)
- Size: 28 KB
- Requires: Swift 5.5+
- Time to run: ~5 seconds first time (compilation)
- Advantage: Source visible, small, flexible

### Compiled Binary (.tar.gz)
- Size: ~500 KB compressed
- Requires: None (native binary)
- Time to run: ~2 seconds (immediate execution)
- Advantage: Fast, no compilation needed

### Homebrew (Future)
- Installation: `brew install macos-security-checker`
- Updates: Automatic with `brew upgrade`
- Advantage: Easy management, version tracking

---

## 🌐 Distribution Across Platforms

### macOS Only
Currently designed for macOS exclusively (uses macOS-specific APIs)

### Future: Cross-Platform Support
To support Linux/Windows:
1. Refactor system checks to use common APIs
2. Implement platform detection
3. Create platform-specific check modules
4. Test on multiple platforms
5. Distribute multi-platform binaries

---

## 📈 Release Version Scheme

**Version Format:** `MAJOR.MINOR.PATCH`

- **2.0.0**: Major release (88 security checks, new UI)
- **2.0.1**: Patch (bug fixes)
- **2.1.0**: Minor (new features, backward compatible)
- **3.0.0**: Major (breaking changes)

---

## 🎯 Distribution Recommendations

### For Enterprise
```bash
# 1. Download binary
# 2. Test thoroughly
# 3. Package with MDM
# 4. Deploy to fleet
# 5. Schedule regular updates
```

### For Individual Users
```bash
# 1. Download latest release
# 2. Extract binary
# 3. Copy to /usr/local/bin (optional)
# 4. Run when needed
# 5. Check for updates quarterly
```

### For Developers
```bash
# 1. Clone repository
# 2. Review source code
# 3. Compile locally if needed
# 4. Integrate into workflows
# 5. Contribute improvements
```

---

## 📞 Support

- **Releases**: https://github.com/hdrapin/macOSSecurityChecker/releases
- **Issues**: https://github.com/hdrapin/macOSSecurityChecker/issues
- **Documentation**: README_DETAILED.md

---

**Last Updated:** May 2024  
**Status:** Distribution Ready  
**Primary Distribution:** GitHub Releases
