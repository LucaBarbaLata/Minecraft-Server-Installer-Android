#!/bin/bash

# Enable colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

echo -e "${YELLOW}Welcome to the Minecraft Server Installer!${NC}"
echo -e "This script is open-source and licensed under the MIT License."
echo -e "GitHub Repository: ${BLUE}https://github.com/LucaBarbaLata/Minecraft-Server-Installer-Android${NC}\n"

while true; do
    read -p "Do you agree to continue? (yes/no): " consent
    case "$consent" in
        yes) break ;;
        no) echo -e "${RED}You did not accept the terms. Exiting...${NC}"; exit 1 ;;
        *) echo -e "${RED}Invalid input. Please type 'yes' or 'no'.${NC}"; sleep 2 ;;
    esac
done

while true; do
    clear
    echo -e "${GREEN}Choose your server software:${NC}"
    echo "[1] Paper"
    echo "[2] Vanilla"
    read -p "Enter the option (1 or 2): " server_software

    case "$server_software" in
        1) software="Paper"; version="1.20.1"; break ;;
        2) software="Vanilla"; version="1.20.1"; break ;;
        *) echo -e "${RED}Invalid selection. Please choose again.${NC}"; sleep 2 ;;
    esac
done

while true; do
    clear
    echo -e "${YELLOW}==============================${NC}"
    echo -e "${YELLOW}BUILD CONFIGURATION${NC}"
    echo -e "${YELLOW}==============================${NC}"
    echo -e "💻 Software: ${GREEN}$software${NC}"
    echo -e "📅 Version: ${GREEN}$version${NC}"
    echo -e "---------------------------------------------------"
    echo -e "Is this information correct?"
    echo -e "${YELLOW}|| Yes ||                  || No ||${NC}"
    read -p "Confirm (yes/no): " confirm

    case "$confirm" in
        yes) break ;;
        no) continue ;;
        *) echo -e "${RED}Invalid input, please type 'yes' or 'no'.${NC}"; sleep 2 ;;
    esac
done

clear
echo -e "${BLUE}Updating system and installing dependencies...${NC}"
apt update && apt upgrade -y
apt install sudo mc net-tools nano zip jq -y
apt update && apt-get clean
apt-get install -y build-essential software-properties-common
add-apt-repository -y ppa:openjdk-r/ppa
apt update && apt install -y openjdk-21-jdk

clear
echo -e "${BLUE}Setting up Minecraft Server...${NC}"
mkdir -p ~/minecraft && cd ~/minecraft || exit

echo -e "${YELLOW}Downloading server file...${NC}"
if [[ "$software" == "Paper" ]]; then
    wget -O server.jar "https://api.papermc.io/v2/projects/paper/versions/$version/builds/latest/downloads/paper-$version-latest.jar"
elif [[ "$software" == "Vanilla" ]]; then
    url=$(wget -qO- https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r --arg version "$version" '.versions[] | select(.id==$version) | .url' | xargs wget -qO- | jq -r '.downloads.server.url')
    wget -O server.jar "$url"
fi

echo -e "${BLUE}Creating start.sh script...${NC}"
cat <<EOL > start.sh
#!/bin/bash
java -Xms4096M -Xmx4096M --add-modules=jdk.incubator.vector \
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
    -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -jar server.jar --nogui
EOL

chmod +x start.sh

echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "Run your server with: ${YELLOW}./start.sh${NC}"
echo -e "Listing server directory contents:"
ls -la
