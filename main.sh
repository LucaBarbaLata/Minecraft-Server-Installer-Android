#!/bin/bash

update_clean() {
    sudo apt update
    sudo apt-get clean
}

install_build_essential() {
    sudo apt-get install -y build-essential
}

install_software_properties_common() {
    sudo apt-get install -y software-properties-common
}

add_openjdk_ppa() {
    sudo add-apt-repository -y ppa:openjdk-r/ppa
    sudo apt update
}

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

install_openjdk() {
    sudo apt install -y openjdk-21-jdk
}

install_nano() {
    sudo apt install -y nano
}

install_zip() {
    sudo apt install -y zip
}

run_server() {
    java -Xmx${ram}M -Xms${ram}M -jar server.jar nogui
}

clear

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

echo "What server software do you want to use?"
echo "[1] Vanilla"
echo "[2] Paper"
echo "[3] Ketting"
echo "[4] Magma"
read -p "Select an option [1-4]: " server_software

echo "What version should we install?"
echo "[1] 1.20.1"
read -p "Select an option [1-1]: " version

read -p "How much RAM should we allocate to the Minecraft server? In MB: " ram

update_clean
install_build_essential
install_software_properties_common
add_openjdk_ppa
install_openjdk
install_nano
install_zip
download_server_jar

clear
echo "Server Installed! You can run the server with the following command:"
echo "java -Xmx${ram}M -Xms${ram}M -jar server.jar nogui"
echo ""
ip=$(hostname -I | awk '{print $1}')
echo "The server IP is: ${ip}"
