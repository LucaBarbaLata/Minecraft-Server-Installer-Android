#!/bin/bash

# Define color codes
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
MAGENTA="\033[35m"
WHITE="\033[37m"

# Check if -verbose flag is present
VERBOSE=false
for arg in "$@"; do
    if [ "$arg" == "-verbose" ]; then
        VERBOSE=true
        break
    fi
done

# Function to execute commands with or without verbosity
run_command() {
    if [ "$VERBOSE" == true ]; then
        $1 # Run with full output
    else
        $1 &>/dev/null # Run silently
    fi
}

# Function to log messages with colors
log() {
    echo -e "$1"
}

# Display ASCII banner with color
clear
log "${CYAN}=================================================================================================================================="
log "    __  ____                            ______     _____                              ____           __        ____         "
log "   /  |/  (_)___  ___  ______________ _/ __/ /_   / ___/___  ______   _____  _____   /  _/___  _____/ /_____ _/ / /__  _____"
log "  / /|_/ / / __ \/ _ \/ ___/ ___/ __ \`/ /_/ __/   \__ \/ _ \/ ___/ | / / _ \/ ___/   / // __ \/ ___/ __/ __ \`/ / / _ \/ ___/"
log " / /  / / / / / /  __/ /__/ /  / /_/ / __/ /_    ___/ /  __/ /   | |/ /  __/ /     _/ // / / (__  ) /_/ /_/ / / /  __/ /    "
log "/_/  /_/_/_/ /_/\___/\___/_/   \__,_/_/  \__/   /____/\___/_/    |___/\___/_/     /___/_/ /_/____/\__/\__,_/_/_/\___/_/     "
log "=================================================================================================================================="
log "Minecraft Server Installer (PaperMC)"
log "By: Luca-rickrolled-himself"
log "(https://github.com/LucaBarbaLata/Minecraft-Server-Installer-Android)"
log "WARNING: This Script Will Consume Aprox. 3 GB of Data!"
log "==================================================================="

log "${YELLOW}[⏳] Waiting 3 seconds before starting script"
sleep 3
# Ask the user for the Minecraft version
read -p "Enter the Minecraft version you want to install (default: 1.21.10): " MC_VERSION
MC_VERSION=${MC_VERSION:-1.21.10}

# Ask the user for the build number
read -p "Enter the build number (default: 117): " BUILD_NUMBER
BUILD_NUMBER=${BUILD_NUMBER:-117}

# Ask the user for RAM allocation
read -p "Enter the amount of RAM to allocate in GB (default: 3): " RAM_GB
RAM_GB=${RAM_GB:-3}
RAM_MB=$((RAM_GB * 1024))

# Define the download URL
JAR_URL="https://api.papermc.io/v2/projects/paper/versions/$MC_VERSION/builds/$BUILD_NUMBER/downloads/paper-$MC_VERSION-$BUILD_NUMBER.jar"

# Update and install necessary packages
log "${BLUE}[🔧] Updating OS and installing dependencies..."
run_command "apt update -y && apt upgrade -y"
run_command "apt-get install sudo mc net-tools nano zip wget -y"
run_command "apt-get install -y build-essential software-properties-common"
run_command "add-apt-repository -y ppa:openjdk-r/ppa"
run_command "apt-get update -y"
run_command "apt-get install -y openjdk-21-jdk"

# Create Minecraft server directory
log "${BLUE}[📁] Creating Minecraft server directory..."
mkdir -p mc
cd mc || exit 1

# Download PaperMC server jar
log "${CYAN}[🌐] Downloading PaperMC server jar for version $MC_VERSION build $BUILD_NUMBER..."
wget "$JAR_URL" -O server.jar
if [ $? -ne 0 ]; then
    log "${RED}[❌] Download failed."
    exit 1
fi

# Create start script
log "${CYAN}[✍️] Creating start script..."
cat <<EOF > start.sh
#!/bin/bash
java -Xms${RAM_MB}M -Xmx${RAM_MB}M --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -jar server.jar --nogui
EOF

# Give execution permission to start script
chmod +x start.sh

# Accept EULA automatically
log "${CYAN}[📜] Accepting Minecraft EULA..."
echo "eula=true" > eula.txt

# Notify user
clear
log "==================================================================="
log "${GREEN}[✅] Your Minecraft Server ($MC_VERSION build $BUILD_NUMBER) is set up! 🎉"
log "To start the server, use the following commands:"
log ""
log "cd mc/"
log "./start.sh"
log ""
log "Enjoy your game! 🚀"
log "==================================================================="
