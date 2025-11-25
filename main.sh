#!/bin/bash

# Enhanced Network Port Scanner with improved UI/UX and error handling
# Author: Erfan Nahidi
# Version: 1.0.0

set -euo pipefail

# Color codes for better terminal output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Temporary files with safer naming
readonly TEMP_DIR=$(mktemp -d)
readonly PORTS_FILE="${TEMP_DIR}/ports_list"
readonly IP_FILE="${TEMP_DIR}/ip_list"

# Cleanup on exit
cleanup() {
    rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT INT TERM

# Check for required commands
check_dependencies() {
    local missing_deps=()
    
    for cmd in ss awk whiptail; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing required commands: ${missing_deps[*]}${NC}" >&2
        echo "Please install: sudo apt-get install iproute2 gawk whiptail" >&2
        exit 1
    fi
}

# Check if running with sufficient privileges for network inspection
check_privileges() {
    if ! ss -tuln &> /dev/null; then
        echo -e "${YELLOW}Warning: Limited network visibility. Consider running with sudo for complete results.${NC}" >&2
        sleep 2
    fi
}

# Improved loading animation
show_loading() {
    local pid=$1
    local message=${2:-"Processing"}
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 "$pid" 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r${BLUE}${message}... %s${NC}" "${spinstr:$i:1}"
            sleep $delay
        done
    done
    printf "\r%*s\r" $((${#message} + 10)) ""
}

# Fetch active listening ports with protocol information
fetch_active_ports() {
    ss -tuln 2>/dev/null | awk 'NR>1 {
        # Extract protocol (tcp/udp)
        proto = $1
        
        # Extract port from local address
        split($5, addr, ":")
        port = addr[length(addr)]
        
        # Validate port number
        if (port ~ /^[0-9]+$/ && port > 0 && port < 65536) {
            # Store unique proto:port combinations
            key = proto ":" port
            if (!seen[key]++) {
                print key
            }
        }
    }' | sort -t: -k2 -n > "${PORTS_FILE}"
}

# Fetch connections for a specific port with more details
fetch_connections_for_port() {
    local port=$1
    
    ss -tunp 2>/dev/null | awk -v target_port="$port" '
    NR>1 {
        split($5, remote, ":")
        split($4, local, ":")
        
        local_port = local[length(local)]
        remote_addr = remote[1]
        
        # Handle IPv6 addresses
        for(i=1; i<length(remote)-1; i++) {
            if(i>1) remote_addr = remote_addr ":" remote[i]
        }
        
        # Filter for target port and valid remote IPs
        if (local_port == target_port && remote_addr != "*" && remote_addr != "" && remote_addr != "0.0.0.0" && remote_addr != "::") {
            # Remove IPv6 brackets if present
            gsub(/[\[\]]/, "", remote_addr)
            print remote_addr
        }
    }' | sort -u > "${IP_FILE}"
}

# Get service name for port
get_service_name() {
    local port=$1
    local service
    
    service=$(getent services "$port" 2>/dev/null | awk '{print $1}' | head -1)
    
    if [ -n "$service" ]; then
        echo "$service"
    else
        echo "unknown"
    fi
}

# Enhanced port selection with service names
select_port() {
    if [ ! -s "${PORTS_FILE}" ]; then
        whiptail --title "❌ No Active Ports" \
            --msgbox "No active listening ports found.\n\nPossible reasons:\n- No services running\n- Insufficient permissions\n- Network issue\n\nTry running with sudo." 12 60
        return 1
    fi
    
    local port_list=()
    local count=0
    
    while IFS=: read -r proto port; do
        local service=$(get_service_name "$port")
        port_list+=("${proto}:${port}" "${proto^^} | Port ${port} | ${service}")
        ((count++))
    done < "${PORTS_FILE}"
    
    local menu_height=$((count + 8))
    [ $menu_height -gt 20 ] && menu_height=20
    
    local selected_port
    selected_port=$(whiptail --title "🌐 Active Network Ports (${count} found)" \
        --menu "Select a port to inspect active connections:\n\nUse ↑↓ arrows to navigate, Enter to select, Esc to cancel" \
        $menu_height 70 $count \
        "${port_list[@]}" \
        3>&1 1>&2 2>&3)
    
    local exit_code=$?
    
    if [ $exit_code -ne 0 ] || [ -z "$selected_port" ]; then
        return 1
    fi
    
    echo "$selected_port"
}

# Display connections with enhanced formatting
display_connections() {
    local port_info=$1
    local proto="${port_info%%:*}"
    local port="${port_info##*:}"
    
    if [ ! -s "${IP_FILE}" ]; then
        whiptail --title "ℹ️  Port ${port} (${proto^^})" \
            --msgbox "No active connections found on this port.\n\nThis port is listening but has no established connections.\n\nNote: This tool only shows ESTABLISHED connections.\nListening state doesn't show remote IPs." 12 60
        return
    fi
    
    local connection_count=$(wc -l < "${IP_FILE}")
    local service=$(get_service_name "$port")
    
    # Create formatted output
    {
        echo "═══════════════════════════════════════════════════════"
        echo "  Port: ${port} | Protocol: ${proto^^} | Service: ${service}"
        echo "  Active Connections: ${connection_count}"
        echo "═══════════════════════════════════════════════════════"
        echo ""
        
        local idx=1
        while read -r ip; do
            printf "%3d. %s\n" $idx "$ip"
            ((idx++))
        done < "${IP_FILE}"
        
        echo ""
        echo "═══════════════════════════════════════════════════════"
        echo "  Tip: Press 'q' to exit this view"
        echo "═══════════════════════════════════════════════════════"
    } > "${IP_FILE}.formatted"
    
    whiptail --title "🔗 Active Connections - Port ${port}" \
        --scrolltext \
        --textbox "${IP_FILE}.formatted" 24 70
}

# Scan and inspect ports - with loop to return to port list
scan_and_inspect() {
    while true; do
        clear
        echo -e "${BLUE}🔍 Scanning for active network ports...${NC}"
        
        fetch_active_ports &
        show_loading $! "Scanning ports"
        
        local selected_port
        if ! selected_port=$(select_port); then
            # User cancelled or no ports found - return to main menu
            return
        fi
        
        local port="${selected_port##*:}"
        clear
        echo -e "${BLUE}🔍 Analyzing connections on port ${port}...${NC}"
        
        fetch_connections_for_port "$port" &
        show_loading $! "Fetching connections"
        
        display_connections "$selected_port"
        
        # After showing connections, loop back to port selection
        # User can press ESC in port selection to return to main menu
    done
}

# Main menu loop
main_menu() {
    while true; do
        local choice
        choice=$(whiptail --title "🔍 Network Port Inspector" \
            --menu "Choose an action:" 15 60 3 \
            "1" "Scan and inspect ports" \
            "2" "About this tool" \
            "3" "Exit" \
            3>&1 1>&2 2>&3)
        
        case $choice in
            1)
                scan_and_inspect
                ;;
            2)
                show_about
                ;;
            3|"")
                clear
                echo -e "${GREEN}Thank you for using Network Port Inspector!${NC}"
                exit 0
                ;;
        esac
    done
}

# About dialog
show_about() {
    whiptail --title "ℹ️  About Network Port Inspector" --msgbox \
"Network Port Inspector v1.0.0

A tool for monitoring active network ports and their connections.

Author: Erfan Nahidi

Features:
• Scans TCP and UDP listening ports
• Shows active connections per port
• Displays service names
• Clean, user-friendly interface

Requirements:
• ss (iproute2)
• awk (gawk)
• whiptail (libnewt)

For best results, run with sudo privileges.

Note: Only ESTABLISHED connections show remote IPs.
Listening ports without active connections won't display IPs." 22 65
}

# Main execution
main() {
    check_dependencies
    check_privileges
    main_menu
}

main
