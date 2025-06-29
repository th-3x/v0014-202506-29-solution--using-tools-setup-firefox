#!/bin/bash
#==============================================================================
# Firefox One-Click Installer for KDE + noVNC Environment
# Compatible with the KDE Desktop + noVNC One-Click Installer system
# Version: 1.0
#==============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}🦊 Firefox One-Click Installer${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "\n${BLUE}🔧 $1${NC}"
}

# Configuration file path
CONFIG_FILE="firefox-config.conf"

# Default configuration
DEFAULT_INSTALL_FOR_ALL="true"
DEFAULT_CREATE_SHORTCUTS="true"
DEFAULT_OPTIMIZE_VNC="true"
DEFAULT_INSTALL_EXTENSIONS="false"
DEFAULT_SET_DEFAULT_BROWSER="false"

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        print_info "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        print_info "Using default configuration"
        INSTALL_FOR_ALL="$DEFAULT_INSTALL_FOR_ALL"
        CREATE_SHORTCUTS="$DEFAULT_CREATE_SHORTCUTS"
        OPTIMIZE_VNC="$DEFAULT_OPTIMIZE_VNC"
        INSTALL_EXTENSIONS="$DEFAULT_INSTALL_EXTENSIONS"
        SET_DEFAULT_BROWSER="$DEFAULT_SET_DEFAULT_BROWSER"
    fi
}

# Generate configuration file
generate_config() {
    print_step "Generating configuration file: $CONFIG_FILE"
    
    cat > "$CONFIG_FILE" << EOF
#==============================================================================
# Firefox Installer Configuration
#==============================================================================

# Install Firefox system-wide for all users (true/false)
INSTALL_FOR_ALL="$DEFAULT_INSTALL_FOR_ALL"

# Create desktop shortcuts for users (true/false)
CREATE_SHORTCUTS="$DEFAULT_CREATE_SHORTCUTS"

# Apply VNC optimizations (true/false)
OPTIMIZE_VNC="$DEFAULT_OPTIMIZE_VNC"

# Install useful extensions (true/false)
INSTALL_EXTENSIONS="$DEFAULT_INSTALL_EXTENSIONS"

# Set Firefox as default browser (true/false)
SET_DEFAULT_BROWSER="$DEFAULT_SET_DEFAULT_BROWSER"

# Specific users to setup (leave empty for all VNC users)
# Format: "user1 user2 user3" or leave empty
TARGET_USERS=""

#==============================================================================
# Advanced Settings
#==============================================================================

# Firefox profile optimizations for VNC
VNC_OPTIMIZATIONS=(
    "gfx.xrender.enabled=false"
    "layers.acceleration.disabled=true"
    "browser.tabs.animate=false"
    "browser.fullscreen.animate=false"
    "toolkit.cosmeticAnimations.enabled=false"
)

# Useful extensions for VNC environment
EXTENSIONS=(
    "ublock-origin"
    "privacy-badger"
)
EOF

    print_success "Configuration file created: $CONFIG_FILE"
    print_info "Edit this file to customize your installation, then run:"
    print_info "./firefox-installer.sh"
}

# Check system requirements
check_requirements() {
    print_step "Checking system requirements"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "Don't run this script as root. It will use sudo when needed."
        exit 1
    fi
    
    # Check sudo access
    if ! sudo -n true 2>/dev/null; then
        print_info "This script requires sudo access for system installation"
        sudo -v || {
            print_error "Failed to get sudo access"
            exit 1
        }
    fi
    
    # Check internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        print_warning "No internet connection detected. Installation may fail."
    fi
    
    print_success "System requirements check passed"
}

# Install Firefox system-wide
install_firefox() {
    print_step "Installing Firefox system-wide"
    
    # Check if Firefox is already installed
    if command -v firefox &> /dev/null; then
        print_warning "Firefox is already installed"
        firefox --version
        return 0
    fi
    
    # Update package list
    print_info "Updating package repositories..."
    sudo apt update -qq
    
    # Install Firefox
    print_info "Installing Firefox..."
    if sudo apt install firefox -y; then
        print_success "Firefox installed successfully"
        firefox --version
    else
        print_error "Failed to install Firefox"
        return 1
    fi
}

# Get VNC users
get_vnc_users() {
    local users=()
    
    if [[ -n "$TARGET_USERS" ]]; then
        # Use specified users
        read -ra users <<< "$TARGET_USERS"
    else
        # Auto-detect VNC users (users with home directories and VNC configs)
        while IFS= read -r user; do
            if [[ -d "/home/$user" ]] && id "$user" &>/dev/null; then
                users+=("$user")
            fi
        done < <(ls /home 2>/dev/null | grep -E '^x[0-9]+$|^vnc|^desktop')
        
        # If no VNC-specific users found, get all regular users
        if [[ ${#users[@]} -eq 0 ]]; then
            while IFS= read -r user; do
                if [[ -d "/home/$user" ]] && id "$user" &>/dev/null; then
                    local uid=$(id -u "$user")
                    if [[ $uid -ge 1000 && $uid -lt 65534 ]]; then
                        users+=("$user")
                    fi
                fi
            done < <(ls /home 2>/dev/null)
        fi
    fi
    
    echo "${users[@]}"
}

# Create desktop shortcuts
create_desktop_shortcuts() {
    local user="$1"
    print_info "Creating desktop shortcuts for user: $user"
    
    # Create Desktop directory if it doesn't exist
    sudo -u "$user" mkdir -p "/home/$user/Desktop"
    
    # Copy Firefox desktop file
    local firefox_desktop="/var/lib/snapd/desktop/applications/firefox_firefox.desktop"
    if [[ -f "$firefox_desktop" ]]; then
        sudo -u "$user" cp "$firefox_desktop" "/home/$user/Desktop/" 2>/dev/null
        sudo -u "$user" chmod +x "/home/$user/Desktop/firefox_firefox.desktop" 2>/dev/null
    else
        # Create custom desktop file
        sudo -u "$user" tee "/home/$user/Desktop/Firefox.desktop" > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Comment=Web Browser
Exec=firefox %u
Icon=firefox
Terminal=false
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF
        sudo -u "$user" chmod +x "/home/$user/Desktop/Firefox.desktop"
    fi
    
    print_success "Desktop shortcut created for $user"
}

# Apply VNC optimizations
apply_vnc_optimizations() {
    local user="$1"
    print_info "Applying VNC optimizations for user: $user"
    
    # Create Firefox profile directory
    sudo -u "$user" mkdir -p "/home/$user/.mozilla/firefox"
    
    # Create user.js with VNC optimizations
    local user_js="/home/$user/.mozilla/firefox/user.js"
    sudo -u "$user" tee "$user_js" > /dev/null << 'EOF'
// VNC Optimizations for Firefox
// Disable hardware acceleration
user_pref("gfx.xrender.enabled", false);
user_pref("layers.acceleration.disabled", true);
user_pref("gfx.direct2d.disabled", true);

// Disable animations
user_pref("browser.tabs.animate", false);
user_pref("browser.fullscreen.animate", false);
user_pref("toolkit.cosmeticAnimations.enabled", false);

// Performance optimizations
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);
user_pref("network.http.pipelining", true);
user_pref("network.http.pipelining.maxrequests", 8);

// Reduce memory usage
user_pref("browser.sessionhistory.max_total_viewers", 2);
user_pref("browser.tabs.unloadOnLowMemory", true);
EOF
    
    print_success "VNC optimizations applied for $user"
}

# Set Firefox as default browser
set_default_browser() {
    local user="$1"
    print_info "Setting Firefox as default browser for user: $user"
    
    sudo -u "$user" xdg-settings set default-web-browser firefox.desktop 2>/dev/null || {
        print_warning "Could not set Firefox as default browser for $user"
    }
}

# Create connection info
create_connection_info() {
    print_step "Creating connection information"
    
    local info_file="FIREFOX_ACCESS_INFO.txt"
    cat > "$info_file" << EOF
#==============================================================================
# Firefox Access Information
# Generated: $(date)
#==============================================================================

Firefox has been successfully installed and configured for your KDE + noVNC environment.

## Access Methods

### 1. Web Browser Access (noVNC)
For each user, access their desktop via web browser:

$(get_vnc_users | while read -r user; do
    if [[ -n "$user" ]]; then
        # Try to determine ports (common patterns)
        local display_num=$(echo "$user" | grep -o '[0-9]\+' | head -1)
        if [[ -n "$display_num" ]]; then
            local vnc_port=$((5900 + display_num))
            local novnc_port=$((6080 + display_num - 1))
            echo "User: $user"
            echo "  - noVNC URL: http://localhost:$novnc_port/vnc.html"
            echo "  - VNC Port: $vnc_port"
            echo ""
        else
            echo "User: $user"
            echo "  - Check your VNC configuration for ports"
            echo ""
        fi
    fi
done)

### 2. Launch Firefox
Once connected to the desktop:
- Click Applications Menu → Internet → Firefox
- Double-click Firefox icon on Desktop
- Open terminal and type: firefox

### 3. SSH Tunnel (for remote access)
ssh -L 6080:localhost:6080 -L 6081:localhost:6081 user@server-ip

## Firefox Features Configured

✅ System-wide installation
✅ VNC performance optimizations
✅ Desktop shortcuts created
✅ Memory usage optimizations
✅ Animation disabled for smooth VNC experience

## Troubleshooting

### Firefox won't start
- Check VNC logs: tail -f ~/.vnc/*.log
- Restart VNC session
- Try: killall firefox && firefox

### Performance issues
- VNC optimizations are already applied
- Consider reducing screen resolution
- Close unused tabs

### Connection issues
- Verify VNC services are running: sudo systemctl status vncserver@*
- Check noVNC services: sudo systemctl status novnc*
- Verify ports are open: sudo netstat -tlnp | grep -E ':(590[0-9]|608[0-9])'

## Support
For issues with this Firefox installation, check:
1. Firefox logs: ~/.mozilla/firefox/*/console-errors.txt
2. VNC logs: ~/.vnc/*.log
3. System logs: journalctl -u firefox*

Generated by Firefox One-Click Installer
EOF

    print_success "Connection information saved to: $info_file"
}

# Main installation process
main_install() {
    print_header
    
    # Load configuration
    load_config
    
    # Check requirements
    check_requirements
    
    # Install Firefox system-wide
    if [[ "$INSTALL_FOR_ALL" == "true" ]]; then
        install_firefox || exit 1
    fi
    
    # Get users to configure
    local users=($(get_vnc_users))
    
    if [[ ${#users[@]} -eq 0 ]]; then
        print_warning "No users found to configure"
        print_info "Firefox is installed system-wide and available to all users"
    else
        print_info "Configuring Firefox for users: ${users[*]}"
        
        for user in "${users[@]}"; do
            print_step "Configuring Firefox for user: $user"
            
            # Create desktop shortcuts
            if [[ "$CREATE_SHORTCUTS" == "true" ]]; then
                create_desktop_shortcuts "$user"
            fi
            
            # Apply VNC optimizations
            if [[ "$OPTIMIZE_VNC" == "true" ]]; then
                apply_vnc_optimizations "$user"
            fi
            
            # Set as default browser
            if [[ "$SET_DEFAULT_BROWSER" == "true" ]]; then
                set_default_browser "$user"
            fi
            
            print_success "Firefox configured for user: $user"
        done
    fi
    
    # Create connection info
    create_connection_info
    
    print_success "Firefox installation and configuration completed!"
    print_info "Check FIREFOX_ACCESS_INFO.txt for access details"
}

# Command line argument handling
case "${1:-}" in
    --config)
        generate_config
        exit 0
        ;;
    --help|-h)
        print_header
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --config    Generate configuration file"
        echo "  --help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 --config    # Generate config file"
        echo "  $0             # Run installation"
        exit 0
        ;;
    "")
        main_install
        ;;
    *)
        print_error "Unknown option: $1"
        print_info "Use --help for usage information"
        exit 1
        ;;
esac
