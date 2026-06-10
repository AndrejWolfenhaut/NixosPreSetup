#! /usr/bin/env bash



throwMessage() {
    echo "$1"
    exit
}

printMessage() {
    local notification="$1"

    local notificationWidth=${#notification}
    local leftRightSpacesWidth=5
    local totalWidth=$(( $notificationWidth + 2*$leftRightSpacesWidth + 2 ))
    local topBottomSpacesWidth=$(( $totalWidth-2 ))

    local topBottomBar=""
    for i in $(seq 1 "$totalWidth"); do topBottomBar="$topBottomBar""#"; done

    local leftRightSpaces=""
    for i in $(seq 1 "$leftRightSpacesWidth"); do leftRightSpaces="$leftRightSpaces"" "; done

    local topBottomSpaces=""
    for i in $(seq 1 "$topBottomSpacesWidth"); do topBottomSpaces="$topBottomSpaces"" "; done

    echo
    echo "$topBottomBar"
    echo "#""$topBottomSpaces""#"
    echo "#""$leftRightSpaces""$notification""$leftRightSpaces""#"
    echo "#""$topBottomSpaces""#"
    echo "$topBottomBar"
    echo
}

getPreSetupPhase() {
    if [ -f ./.preSetupPhase ]; then
        cat ./.preSetupPhase
    else
        echo "1"
    fi
}

setPreSetupPhase() {
    echo "$1" > ./.preSetupPhase
}

resetPreSetupPhase() {
    rm -f ./.preSetupPhase
}



if [ "$#" != "2" ]; then
    throwMessage "Usage: ./preSetup.sh <username> <hostname>"
fi



username="$1"
hostname="$2"



case "$(getPreSetupPhase)" in
    "1")
        # Phase 1:
        # Modify the default configuration to install git and create the user
        # Executed by root from /tmp
        printMessage "Phase 1: Installing git and creating the normal user..."
        
        # Check that we are in /tmp and are executing the script as ./preSetup.sh...
        if [ "$(pwd)" != "/tmp" ]; then
            throwMessage "Phase 1 of the pre-setup must be executed from /tmp as the working directory with the command ./preSetup.sh!"
        fi
        if [ "$0" != "./preSetup.sh" ]; then
            throwMessage "Phase 1 of the pre-setup must be executed from /tmp as the working directory with the command ./preSetup.sh!"
        fi

        configuration="$(cat /etc/nixos/configuration.nix)"

        # Install git as system-level package
        configuration="$configuration"' // { environment.systemPackages = [ pkgs.git ]; }'
        # Create normal user with desired username
        configuration="$configuration"' // { users.users.'"$username"' = { isNormalUser = true; extraGroups = [ "wheel" ]; }; }'

        echo "$configuration" | sudo tee /etc/nixos/configuration.nix > /dev/null

        sudo nixos-rebuild switch

        # Set a password for the created user
        passwd "$username"
        
        setPreSetupPhase 2

        # Copy the script to the newly created home directory (it will be cleaned up from /tmp automatically on reboot...)
        cp "$0" "/home/$username"
        cp "./.preSetupPhase" "/home/$username"

        # Inform user how to proceed
        echo
        echo "Git has been installed and the normal user \"$username\" has been created."
        echo "To continue with the pre-setup, please re-login as the normal user and execute this script again,"
        echo "this time from the home directory /home/$username with the command ./preSetup.sh."
        echo
        ;;
    "2")
        # Phase 2:
        # SSH configuration and cloning of setup branch
        printMessage "Phase 2: Configuring SSH and cloning setup branch..."

        # Check that we are in /home/<username> and are executing the script as ./preSetup.sh...
        if [ "$(pwd)" != "/home/$username" ]; then
            throwMessage "Phase 2 of pre-setup must be executed from the home directory /home/$username as the working directory with the command ./preSetup.sh!"
        fi
        if [ "$0" != "./preSetup.sh" ]; then
            throwMessage "Phase 2 of pre-setup must be executed from the home directory /home/$username as the working directory with the command ./preSetup.sh!"
        fi

        # Generate an SSH key pair to access GitHub
        printMessage "Phase 2.1: Configuring SSH..."

        sshKeyFile="/home/$username/.ssh/$hostname"
        sshConfigFile="/home/$username/.ssh/config"

        ssh-keygen -f "/home/$username/.ssh/$hostname"

        printf "Host github.com\n"                                > "$sshConfigFile"
        printf "\tidentitiesOnly yes\n"                          >> "$sshConfigFile"
        printf "\tidentityFile /home/$username/.ssh/$hostname\n" >> "$sshConfigFile"

        # Inform user how to proceed
        echo
        echo "SSH is configured, but requires manual intervention."
        echo "Please register the public SSH key"
        echo
        echo "$(cat /home/$username/.ssh/$hostname.pub)"
        echo
        echo "in GitHub so that the setup branch can be cloned."
        echo "There seems to not be an easy way around this :("
        echo "Press ENTER to proceed when the key is registered."
        echo

        read -p "Press ENTER to proceed..."

        # Clone the setup branch
        printMessage "Phase 2.2: Cloning setup branch..."

        git clone -b "$hostname/setup" --single-branch git@github.com:AndrejWolfenhaut/Nixos.git

        # Inform user how to proceed
        echo
        echo "Everything is ready for the actual setup."
        echo "To proceed with setup, cd to ~/Nixos, execute ./setup.sh and follow the directions."
        echo "This script will be yeeted now as it is no longer needed."
        echo

        # Clean up
        resetPreSetupPhase
        rm -f -- "$0"
        ;;
    *)
        throwMessage "Invalid pre-setup phase: $(setupPhase)!"
        ;;
esac
