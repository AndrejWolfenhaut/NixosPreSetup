This is where I keep init and setup scripts for my NixOS systems.

# Install Process
- Basic, minimal NixOS installation from USB medium (or similar)
  - Re-create partition table
  - Create partitions
  - Format partitions
  - Mount root and boot partitions
  - Generate default NixOS config
  - Install NixOS nixos-install
  - Automated by script init\<hostname\>.sh
- Pre-setup
  - Modify default configuration
    - Install git as system package
    - Create user with desired username that matches the one defined in globals.nix (must have sudo access)
  - Set password with passwd
  - Generate an SSH key pair \<hostname\> + \<hostname\>.pub and register it on GitHub
  - Configure SSH to use the generated key for host github.com
  - Clone the Nixos repo into the user's home directory
  - Checkout the desired setup branch
  - Automated by script preSetup.sh