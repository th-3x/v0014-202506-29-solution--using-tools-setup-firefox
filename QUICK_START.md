# 🦊 Firefox Quick Start Guide

## One-Click Installation

```bash
cd tools-setup-firefox
./firefox-installer.sh
```

That's it! Firefox will be installed and configured for all your VNC users.

## What It Does

✅ Installs Firefox system-wide  
✅ Creates desktop shortcuts for all VNC users  
✅ Applies VNC performance optimizations  
✅ Generates connection documentation  

## Access Firefox

### For User x2
- **Web**: http://localhost:6080/vnc.html
- **VNC**: localhost:5901

### For User x3  
- **Web**: http://localhost:6081/vnc.html
- **VNC**: localhost:5902

### For User x4
- **Web**: http://localhost:6082/vnc.html  
- **VNC**: localhost:5903

## Launch Firefox
Once connected to VNC desktop:
- Double-click Firefox icon on desktop
- Applications Menu → Internet → Firefox  
- Terminal: `firefox`

## Custom Setup

```bash
# Generate config file first
./firefox-installer.sh --config

# Edit settings
nano firefox-config.conf

# Run installation
./firefox-installer.sh
```

## Need Help?

```bash
./firefox-installer.sh --help
```

Check `FIREFOX_ACCESS_INFO.txt` after installation for detailed access information.
