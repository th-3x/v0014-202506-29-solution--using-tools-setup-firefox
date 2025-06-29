# Firefox One-Click Installer for KDE + noVNC

A comprehensive, automated Firefox installation tool designed specifically for the KDE Desktop + noVNC environment. This tool provides seamless Firefox setup with VNC optimizations for all users.

## 🚀 Quick Start

```bash
# Navigate to the tools directory
cd tools-setup-firefox

# One-click installation
./firefox-installer.sh
```

## 📋 Features

- ✅ **One-Click Installation**: Automated Firefox setup for all VNC users
- ✅ **VNC Optimized**: Performance tweaks for remote desktop access
- ✅ **Multi-User Support**: Configures Firefox for all VNC users automatically
- ✅ **Desktop Shortcuts**: Creates desktop icons for easy access
- ✅ **Smart Detection**: Auto-detects VNC users (x2, x3, x4, etc.)
- ✅ **Configurable**: Customizable installation options
- ✅ **Connection Info**: Generates access documentation

## 🏗️ File Structure

```
tools-setup-firefox/
├── firefox-installer.sh      # Main installation script
├── firefox-config.conf       # Configuration file (auto-generated)
├── README.md                 # This documentation
└── FIREFOX_ACCESS_INFO.txt   # Generated access information
```

## ⚙️ Configuration

### Generate Configuration File

```bash
./firefox-installer.sh --config
```

This creates `firefox-config.conf` with customizable options:

| Setting | Default | Description |
|---------|---------|-------------|
| INSTALL_FOR_ALL | true | Install Firefox system-wide |
| CREATE_SHORTCUTS | true | Create desktop shortcuts |
| OPTIMIZE_VNC | true | Apply VNC performance optimizations |
| INSTALL_EXTENSIONS | false | Install useful browser extensions |
| SET_DEFAULT_BROWSER | false | Set Firefox as default browser |
| TARGET_USERS | "" | Specific users (empty = auto-detect) |

### Example Configuration

```bash
# Edit the configuration
nano firefox-config.conf

# Example custom settings
INSTALL_FOR_ALL="true"
CREATE_SHORTCUTS="true"
OPTIMIZE_VNC="true"
TARGET_USERS="x2 x3 x4"  # Specific users only
```

## 🔧 Installation Process

### Automatic Process

1. **System Check**: Validates requirements and sudo access
2. **Firefox Installation**: Installs Firefox system-wide via apt/snap
3. **User Detection**: Auto-detects VNC users (x2, x3, x4, etc.)
4. **Desktop Shortcuts**: Creates Firefox icons on each user's desktop
5. **VNC Optimization**: Applies performance tweaks for remote access
6. **Configuration**: Sets up user-specific Firefox profiles
7. **Documentation**: Generates connection and access information

### Manual User Specification

```bash
# Edit config to target specific users
echo 'TARGET_USERS="x2 x3 x5"' >> firefox-config.conf
./firefox-installer.sh
```

## 🌐 Access Methods

### For Each VNC User

After installation, users can access Firefox through their VNC sessions:

#### Web Browser Access (noVNC)
```
User x2: http://localhost:6080/vnc.html
User x3: http://localhost:6081/vnc.html
User x4: http://localhost:6082/vnc.html
```

#### Within VNC Desktop
- **Applications Menu** → Internet → Firefox
- **Desktop Shortcut** → Double-click Firefox icon
- **Terminal** → Type `firefox` and press Enter

#### Direct VNC Client
```
User x2: localhost:5901
User x3: localhost:5902
User x4: localhost:5903
```

## 🎯 VNC Optimizations Applied

The installer automatically applies these optimizations for smooth VNC performance:

### Performance Tweaks
- Disabled hardware acceleration (`gfx.xrender.enabled=false`)
- Disabled GPU layers (`layers.acceleration.disabled=true`)
- Disabled animations (`browser.tabs.animate=false`)
- Optimized memory usage
- Enhanced network pipelining

### User Profile Settings
Each user gets a customized `~/.mozilla/firefox/user.js` with:
```javascript
// VNC Performance Optimizations
user_pref("gfx.xrender.enabled", false);
user_pref("layers.acceleration.disabled", true);
user_pref("browser.tabs.animate", false);
user_pref("toolkit.cosmeticAnimations.enabled", false);
```

## 🛠️ Usage Examples

### Basic Installation
```bash
# Simple one-click setup
./firefox-installer.sh
```

### Custom Configuration
```bash
# Generate and edit config
./firefox-installer.sh --config
nano firefox-config.conf

# Run with custom settings
./firefox-installer.sh
```

### Specific Users Only
```bash
# Edit config for specific users
echo 'TARGET_USERS="x3 x4"' >> firefox-config.conf
./firefox-installer.sh
```

### Help and Options
```bash
# Show help
./firefox-installer.sh --help

# Available options:
#   --config    Generate configuration file
#   --help      Show help message
```

## 🔍 Troubleshooting

### Common Issues

#### Firefox Won't Start
```bash
# Check VNC logs
tail -f ~/.vnc/*.log

# Kill and restart Firefox
killall firefox
firefox &
```

#### Performance Issues
- VNC optimizations are automatically applied
- Consider reducing VNC resolution if still slow
- Close unused browser tabs

#### Connection Problems
```bash
# Check VNC services
sudo systemctl status vncserver@*

# Check noVNC services  
sudo systemctl status novnc*

# Verify ports
sudo netstat -tlnp | grep -E ':(590[0-9]|608[0-9])'
```

#### Desktop Shortcut Missing
```bash
# Manually create shortcut for user x3
sudo -u x3 cp /var/lib/snapd/desktop/applications/firefox_firefox.desktop /home/x3/Desktop/
sudo -u x3 chmod +x /home/x3/Desktop/firefox_firefox.desktop
```

### Log Locations
- **Firefox Logs**: `~/.mozilla/firefox/*/console-errors.txt`
- **VNC Logs**: `~/.vnc/*.log`
- **Installation Logs**: Check terminal output during installation

## 🔒 Security Considerations

### Network Security
- Firefox traffic uses standard HTTPS encryption
- VNC connections should use SSH tunneling for remote access
- Consider VPN for production environments

### User Isolation
- Each user gets their own Firefox profile
- Bookmarks and settings are user-specific
- No shared browsing data between users

### Recommended SSH Tunnel
```bash
# For remote access to multiple users
ssh -L 6080:localhost:6080 -L 6081:localhost:6081 -L 6082:localhost:6082 \
    -L 5901:localhost:5901 -L 5902:localhost:5902 -L 5903:localhost:5903 \
    user@server-ip
```

## 🔧 Advanced Configuration

### Custom VNC Optimizations
Edit the installer script to add custom Firefox preferences:

```bash
# Add to VNC_OPTIMIZATIONS array in firefox-config.conf
VNC_OPTIMIZATIONS=(
    "gfx.xrender.enabled=false"
    "layers.acceleration.disabled=true"
    "browser.tabs.animate=false"
    "your.custom.preference=value"
)
```

### Extension Installation
Enable automatic extension installation:

```bash
# In firefox-config.conf
INSTALL_EXTENSIONS="true"
EXTENSIONS=(
    "ublock-origin"
    "privacy-badger"
)
```

### Integration with Main KDE Installer
This tool is designed to work alongside the main KDE + noVNC installer:

```bash
# After running the main KDE installer
cd tools-setup-firefox
./firefox-installer.sh
```

## 📊 Compatibility

### Supported Systems
- **OS**: Ubuntu 20.04+ (Debian-based distributions)
- **Desktop**: KDE Plasma (installed via main installer)
- **VNC**: TigerVNC, TightVNC, or similar
- **noVNC**: Web-based VNC client

### User Requirements
- Users must exist in the system
- Users should have home directories
- VNC sessions should be configured
- noVNC services should be running

### Port Requirements
- **VNC Ports**: 5901, 5902, 5903, etc.
- **noVNC Ports**: 6080, 6081, 6082, etc.
- **HTTP**: Port 80/443 for web access (if remote)

## 🤝 Integration Examples

### With Main KDE Installer
```bash
# Run main KDE + noVNC installer first
./kde-vnc-installer.sh

# Then add Firefox
cd tools-setup-firefox
./firefox-installer.sh
```

### With Multiple Users
```bash
# Set up users x2, x3, x4 with main installer
# Then configure Firefox for all
./firefox-installer.sh

# Or target specific users
echo 'TARGET_USERS="x2 x4"' >> firefox-config.conf
./firefox-installer.sh
```

### Automated Deployment
```bash
#!/bin/bash
# Complete setup script
git clone <kde-vnc-installer-repo>
cd kde-vnc-installer

# Main KDE setup
./kde-vnc-installer.sh

# Firefox setup
cd tools-setup-firefox
./firefox-installer.sh --config
# Edit firefox-config.conf as needed
./firefox-installer.sh
```

## 📝 Generated Files

After installation, you'll find:

### Configuration Files
- `firefox-config.conf` - Installation settings
- `FIREFOX_ACCESS_INFO.txt` - Connection details and troubleshooting

### User Files (per user)
- `~/Desktop/Firefox.desktop` - Desktop shortcut
- `~/.mozilla/firefox/user.js` - VNC optimizations
- `~/.mozilla/firefox/profiles.ini` - Profile configuration

### System Files
- `/usr/bin/firefox` - Firefox executable
- `/var/lib/snapd/desktop/applications/firefox_firefox.desktop` - System desktop file

## 🆘 Support

### Getting Help
1. **Check generated documentation**: `FIREFOX_ACCESS_INFO.txt`
2. **Review logs**: Terminal output during installation
3. **Test basic functionality**: Can you launch Firefox in VNC?
4. **Verify services**: Are VNC and noVNC running?

### Common Solutions
```bash
# Reinstall Firefox for specific user
sudo -u x3 rm -rf ~/.mozilla/firefox
./firefox-installer.sh

# Reset VNC optimizations
sudo -u x3 rm ~/.mozilla/firefox/user.js
./firefox-installer.sh

# Recreate desktop shortcuts
sudo -u x3 rm ~/Desktop/Firefox*
./firefox-installer.sh
```

### Reporting Issues
When reporting problems, include:
- System information (`uname -a`)
- Firefox version (`firefox --version`)
- VNC configuration details
- Error messages from installation
- Contents of `FIREFOX_ACCESS_INFO.txt`

## 📄 License

This tool is part of the KDE Desktop + noVNC One-Click Installer system and follows the same open-source license.

## 🔄 Updates

### Updating Firefox
```bash
# System updates will handle Firefox updates
sudo apt update && sudo apt upgrade

# Or update snap packages
sudo snap refresh firefox
```

### Updating the Installer
```bash
# Re-download the latest version
git pull origin main

# Re-run if needed
./firefox-installer.sh
```

---

**Generated by Firefox One-Click Installer**  
**Compatible with KDE Desktop + noVNC One-Click Installer**  
**Version: 1.0**  
**Last Updated: $(date)**
