#!/bin/bash

# Check for -verbose flag
VERBOSE=false
for arg in "$@"; do
    if [ "$arg" == "-verbose" ]; then
        VERBOSE=true
        break
    fi
done

# Function to run commands with optional verbosity
run_cmd() {
    if [ "$VERBOSE" == "true" ]; then
        eval "$1"
    else
        echo -e "[🔧] $2..."
        eval "$1" &>/dev/null
    fi
}

# Display ASCII banner
clear
echo "=================================================================================================================================="
echo "    __  ____                            ______     _____                              ____           __        ____         "
echo "   /  |/  (_)___  ___  ______________ _/ __/ /_   / ___/___  ______   _____  _____   /  _/___  _____/ /_____ _/ / /__  _____"
echo "  / /|_/ / / __ \/ _ \/ ___/ ___/ __ \`/ /_/ __/   \__ \/ _ \/ ___/ | / / _ \/ ___/   / // __ \/ ___/ __/ __ \`/ / / _ \/ ___/"
echo " / /  / / / / / /  __/ /__/ /  / /_/ / __/ /_    ___/ /  __/ /   | |/ /  __/ /     _/ // / / (__  ) /_/ /_/ / / /  __/ /    "
echo "/_/  /_/_/_/ /_/\___/\___/_/   \__,_/_/  \__/   /____/\___/_/    |___/\___/_/     /___/_/ /_/____/\__/\__,_/_/_/\___/_/     "
echo "=================================================================================================================================="
echo "Minecraft Server Installer"
echo "By: Luca-rickrolled-himself"
echo "(https://github.com/LucaBarbaLata/Minecraft-Server-Installer-Android)"
echo "==================================================================="

# Countdown before execution
echo ""
echo "The script will run in 3 seconds..."
sleep 3

# Update and upgrade system
run_cmd "apt update && apt upgrade -y" "Updating OS"

# Install necessary packages
run_cmd "apt install sudo mc net-tools nano zip jq wget -y" "Installing required packages"

# Clean package lists
run_cmd "apt update && apt-get clean" "Cleaning package lists"

# Install build-essential and Java dependencies
run_cmd "apt-get install -y build-essential software-properties-common" "Installing build tools"
run_cmd "add-apt-repository -y ppa:openjdk-r/ppa" "Adding OpenJDK repository"
run_cmd "apt update && apt install -y openjdk-21-jdk" "Installing OpenJDK 21"

# Clear screen
clear

# Create and enter the Minecraft server directory
run_cmd "mkdir -p mc && cd mc" "Creating Minecraft server directory"

# Download PaperMC server jar
run_cmd "wget https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar" "Downloading Minecraft server"

# Create start script
cat <<EOF > mc/start.sh
#!/bin/bash

java -Xms3072M -Xmx3072M --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -jar server.jar --nogui
EOF

# Give execution permission to start script
run_cmd "chmod +x mc/start.sh" "Making start script executable"

# Accept EULA automatically
echo "eula=true" > mc/eula.txt

clear

# Notify user
echo "==================================================================="
echo "Minecraft Server is set up! 🎉"
echo "To start the server, use the following commands:"
echo ""
echo "cd mc/"
echo "./start.sh"
echo ""
echo "Enjoy your game! 🚀"
echo "==================================================================="
