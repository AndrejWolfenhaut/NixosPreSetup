This is my repo where I keep init and setup scripts for my NixOS systems.

# Install Process
- Basic, minimal NixOS isntallation from USB medium (or similar)
  - Re-create partition table
  - Create partitions
  - Format partitions
  - Mount root an dboot partitions
  - Generate default NixOS config
  - Install NixOS nixos-isntall
  - Automated by script init\<hostname\>.sh in the NixosPreSetup repo
- Pre-setup
  - Modify default configuration
    - Install git as system package
    - Create user with desired username that matches the one defined in globals.nix (must have sudo access)
  - Set password with passwd
  - Generate an ssh key pair \<hostname\> + \<hostname\>.pub and register it on GitHub
  - Configure ssh to use the generated key for host github.com
  - Clone the Nixos repo into the user's home directory
  - Checkout the desired setup branch
  - Automated by script preSetup.sh in the NixosPreSetup repo