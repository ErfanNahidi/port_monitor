# 🔍 Network Port Inspector

A lightweight, interactive Bash tool for monitoring active network ports and their connections with a beautiful terminal UI.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/bash-5.0%2B-orange.svg)

## ✨ Features

- 🌐 **Port Scanning** - Automatically detects all active TCP and UDP listening ports
- 🔗 **Connection Monitoring** - Shows all established connections for each port
- 📊 **Service Detection** - Identifies common services running on ports (SSH, HTTP, etc.)
- 🎨 **Beautiful UI** - Clean, interactive terminal interface using whiptail
- ⚡ **Fast & Lightweight** - Pure Bash script with minimal dependencies
- 🔄 **Real-time Updates** - Scan multiple ports without returning to main menu
- 🎯 **User-Friendly** - Easy navigation with arrow keys and intuitive menus

## 📸 Screenshots

```
┌─────────────────────────────────────────────────┐
│        🔍 Network Port Inspector                │
│                                                  │
│  Choose an action:                              │
│                                                  │
│  1  Scan and inspect ports                      │
│  2  About this tool                             │
│  3  Exit                                        │
│                                                  │
└─────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Linux-based operating system
- Bash 4.0 or higher
- Required packages:
  - `iproute2` (provides `ss` command)
  - `gawk` (GNU awk)
  - `whiptail` (for TUI dialogs)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/network-port-inspector.git
cd network-port-inspector
```

2. **Make the script executable**
```bash
chmod +x port_inspector.sh
```

3. **Install dependencies** (if not already installed)

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install iproute2 gawk whiptail
```

**RHEL/CentOS/Fedora:**
```bash
sudo yum install iproute gawk newt
```

**Arch Linux:**
```bash
sudo pacman -S iproute2 gawk libnewt
```

### Usage

**Basic usage:**
```bash
./port_inspector.sh
```

**For complete network visibility (recommended):**
```bash
sudo ./port_inspector.sh
```

> **Note:** Running with `sudo` provides access to all network connections and processes. Without elevated privileges, you may see limited information.

## 📖 How It Works

1. **Launch the tool** - Start the script to see the main menu
2. **Scan ports** - Select "Scan and inspect ports" to discover active ports
3. **Choose a port** - Navigate through the list of detected ports using arrow keys
4. **View connections** - See all active IP addresses connected to the selected port
5. **Repeat or exit** - Check another port or press ESC to return to the main menu

## 🛠️ Technical Details

### What the tool does:

- Uses `ss` command to query socket statistics
- Parses network data with `awk` for efficient processing
- Displays interactive menus using `whiptail`
- Shows only **ESTABLISHED** connections (active connections)
- Filters out listening-only states that don't have remote IPs

### Supported Protocols:

- ✅ TCP (Transmission Control Protocol)
- ✅ UDP (User Datagram Protocol)

### Output Information:

- Port number
- Protocol type (TCP/UDP)
- Service name (if recognized)
- List of connected remote IP addresses
- Connection count

## 📋 Examples

### Example 1: Checking SSH connections
```
Port: 22 | Protocol: TCP | Service: ssh
Active Connections: 3

  1. 192.168.1.100
  2. 10.0.0.50
  3. 172.16.0.25
```

### Example 2: Monitoring web server
```
Port: 80 | Protocol: TCP | Service: http
Active Connections: 15

  1. 203.0.113.42
  2. 198.51.100.88
  3. 192.0.2.156
  ...
```

## ⚠️ Important Notes

- **Listening vs. Established**: This tool shows only ESTABLISHED connections. A port in LISTEN state without active connections will show "No active connections found."
- **Permissions**: Some network information requires root privileges. Run with `sudo` for complete visibility.
- **IPv6 Support**: The tool supports both IPv4 and IPv6 addresses.

## 🐛 Troubleshooting

### No ports found
- Make sure services are actually running on your system
- Try running with `sudo` for full network visibility
- Check that `ss` command is available: `which ss`

### No connections shown for a port
- This is normal if the port is only listening without active connections
- Only ESTABLISHED connections display remote IP addresses
- Try accessing the service from another machine to create a connection

### Missing dependencies error
```bash
# Install missing packages
sudo apt-get install iproute2 gawk whiptail
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Ideas for contributions:
- Add export functionality (CSV, JSON)
- Implement filtering options
- Add connection history tracking
- Create a daemon mode for continuous monitoring
- Add geolocation for IP addresses

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Erfan Nahidi**

- GitHub: [@erfannahidi](https://github.com/erfannahidi)
- Email: your.email@example.com

## 🌟 Acknowledgments

- Built with Bash scripting
- Uses `ss` from the iproute2 package
- Terminal UI powered by whiptail
- Inspired by the need for simple network monitoring tools

## 📊 Roadmap

- [ ] Add logging functionality
- [ ] Implement connection duration tracking
- [ ] Add bandwidth usage statistics
- [ ] Create configuration file support
- [ ] Add email alerts for suspicious connections
- [ ] Develop web-based dashboard

## 💬 Support

If you have any questions or need help:

1. Check the [Issues](https://github.com/yourusername/network-port-inspector/issues) page
2. Create a new issue if your problem isn't already listed
3. Star ⭐ the project if you find it useful!

---

**Made with ❤️ by Erfan Nahidi**

*If this tool helped you, consider giving it a star ⭐*
