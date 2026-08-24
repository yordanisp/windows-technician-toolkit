# Windows Technician Toolkit

A Windows command-line toolkit for authorized IT support, system diagnostics, network troubleshooting, SCCM client checks, reporting, and hardware inventory.

## Important Notice

Use this toolkit only on computers and networks that you own or are authorized to administer.

Some actions require local Administrator privileges and may change system configuration, services, network settings, user accounts, Windows Update, SCCM, or installed drivers. Review each action before running it and follow your organization's IT and security policies.

Do not publish reports, logs, backups, serial numbers, usernames, domain names, IP addresses, or other organizational information in a public repository.

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or later
- Local Administrator privileges for administrative actions
- SCCM / Configuration Manager client for SCCM-specific features
- Windows Management Instrumentation (WMI/CIM) enabled for remote diagnostics
- Firewall and permissions configured for authorized remote monitoring

No third-party software is required for the core toolkit.

## Versions

| Version | Description |
| --- | --- |
| v1.0 | Original system, network, storage, repair, security, and technician tools. |
| v1.1 | Organized menus, SCCM tools, reporting, asset exports, and printer diagnostics. |
| v1.2 | Safe temporary-file and Windows component cleanup. |
| v1.3 | System health checks, centralized reports, improved SCCM diagnostics, and cleanup preview. |
| v1.4 | Nine organized main categories with the health check under System information. |
| v1.5 | Network discovery, remote monitoring, DNS diagnostics, port tests, and bandwidth tools. |
| v1.6 | Driver inventory, device problem detection, printer and monitor information, firmware details, and driver backup. |

## Main Features

### System Information

- Computer manufacturer, model, serial number, and domain
- Windows version and build
- Logged-on user and uptime
- System health check
- Driver and firmware diagnostics

### Performance and Storage

- Memory and CPU information
- Top processes
- Disk space and physical disk health
- CHKDSK scan
- Disk Cleanup
- Temporary-file cleanup with confirmation and cleanup preview

### Network Diagnostics

- Full network configuration
- Gateway, DNS, and Internet tests
- DNS and domain lookup
- CIDR subnet ping sweep
- Common TCP port tests
- Route and ARP table
- Traceroute
- Local and remote bandwidth counters
- Authorized remote computer monitoring

### SCCM / Configuration Manager

- Client service and version
- Client health summary
- Machine policy cycle
- Hardware and software inventory cycles
- Software update scan
- CCMCache information
- SCCM logs
- SCCM client repair

### Drivers and Firmware

- Installed driver inventory
- Devices with missing or problem drivers
- Driver signature check
- Printer driver information
- Monitor information
- BIOS and disk firmware information
- Windows Update driver scan
- Installed driver backup with `pnputil`
- CSV driver report

### Reports and Exports

Reports are saved in the local `Reports` folder and may contain sensitive system information.

- Text system report
- HTML system report
- Hardware asset CSV
- Installed software CSV
- Driver CSV
- Printer diagnostics
- Driver backup folder

## Running the Toolkit

Right-click the desired `.bat` file and select **Run as administrator** when required.

Recommended current version:

```text
SystemResources v1.6.bat
```

Use the numbered menus and press `0` to return to the previous menu or main menu, depending on the selected screen.

## Remote Monitoring Notes

Remote monitoring depends on network connectivity, firewall rules, WMI/CIM permissions, and Remote Registry or performance-counter access. A computer may respond to ping while refusing WMI or performance-counter queries.

The toolkit does not bypass security controls. Configure remote access through approved Windows and organizational policies.

## Repository Hygiene

Do not commit the following files or folders when they contain real organizational data:

```text
Reports/
*.log
DriverBackup_*/
```

Before sharing the repository, search for:

- Passwords and tokens
- Internal server names
- Private IP addresses
- Domain names
- Usernames
- Computer names
- Serial numbers
- SCCM site information
- Customer or employee information

## Limitations

- Firmware updates are not installed automatically. Manufacturers use different tools and packages.
- Windows Update is opened for driver-update review; installation remains subject to Windows policy and user confirmation.
- Remote WMI and performance counters must already be permitted by the environment.
- Network discovery and port testing should be performed only on authorized networks.

## License

Add the license required by your organization before redistributing this toolkit.
