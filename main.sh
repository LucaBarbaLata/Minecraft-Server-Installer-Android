#!/bin/bash

# Function to update and clean the package lists
update_clean() {
    sudo apt update
    sudo apt-get clean
}

# Function to install essential build tools
install_build_essential() {
    sudo apt-get install -y build-essential
}

# Function to install software-properties-common
install_software_properties_common() {
    sudo apt-get install -y software-properties-common
}

# Function to add the OpenJDK PPA repository
add_openjdk_ppa() {
    sudo add-apt-repository -y ppa:openjdk-r/ppa
    sudo apt update
}

# Function to download the Minecraft server jar based on user selection
download_server_jar() {
    case $server_software in
        1)
            echo "Downloading Vanilla server..."
            wget -O server.jar "https://s3.amazonaws.com/Minecraft.Download/versions/$version/minecraft_server.$version.jar"
            ;;
        2)
            echo "Downloading Paper server..."
            wget -O server.jar "https://api.papermc.io/v2/projects/paper/versions/$version/builds/137/downloads/paper-$version-137.jar"
            ;;
        3)
            echo "Downloading Ketting server..."
            # Replace with the actual URL for Ketting server
            wget -O server.jar "https://example.com/ketting-server-$version.jar"
            ;;
        4)
            echo "Downloading Magma server..."
            # Replace with the actual URL for Magma server
            wget -O server.jar "https://example.com/magma-server-$version.jar"
            ;;
        *)
            echo "Invalid server software selected."
            exit 1
            ;;
    esac
}

# Function to install OpenJDK
install_openjdk() {
    sudo apt install -y openjdk-21-jdk
}

# Function to install nano text editor
install_nano() {
    sudo apt install -y nano
}

# Function to install zip
install_zip() {
    sudo apt install -y zip
}

# Function to run the Minecraft server
run_server() {
    java -Xmx${ram}M -Xms${ram}M -jar server.jar nogui
}

# Main script
clear

# Print ASCII art
cat << "EOF"
 __  __ ____   _____ _______  _______   ____  _____   ___  _  _______ _______ 
|  \/  |  _ \ / ____|__   __|/ ____\ \ / /  \/  |  _ \ / _ \| |/ / ____|__   __|
| \  / | |_) | (___    | |  | (___  \ V /| \  / | |_) | | | | ' / (___    | |   
| |\/| |  _ < \___ \   | |   \___ \  > < | |\/| |  _ <| | | |  < \___ \   | |   
| |  | | |_) |____) |  | |   ____) |/ . \| |  | | |_) | |_| | . \____) |  | |   
|_|  |_|____/|_____/   |_|  |_____//_/ \_\_|  |_|____/ \___/|_|\_\_____/   |_|   
                                                                                
EOF

echo ""
echo "Welcome to the Minecraft Server Setup Script!"
echo ""

# Ask user for server software
echo "What server software do you want to use?"
echo "[1] Vanilla"
echo "[2] Paper"
echo "[3] Ketting"
echo "[4] Magma"
read -p "Select an option [1-4]: " server_software

# Ask user for Minecraft version
echo "What version should we install?"
echo "[1] 1.20.1"
read -p "Select an option [1-1]: " version

# Ask user for RAM allocation
read -p "How much RAM should we allocate to the Minecraft server? In MB: " ram

# Run setup steps
update_clean
install_build_essential
install_software_properties_common
add_openjdk_ppa
install_openjdk
install_nano
install_zip
download_server_jar

# Print final message
clear
echo "Server Installed! You can run the server with the following command:"
echo "java -Xmx${ram}M -Xms${ram}M -jar server.jar nogui"
echo ""
ip=$(hostname -I | awk '{print $1}')
echo "The server IP is: ${ip}"
