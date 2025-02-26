#!/bin/bash

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

# Function to log emoji messages
log() {
    echo -e "$1"
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
log "\n[⏳] The script will run in 3 seconds..."
sleep 3

# Update and upgrade system
log "[🔧] Updating OS..."
run_command "apt update && apt upgrade -y"

# Install necessary packages
log "[📦] Installing necessary packages..."
run_command "apt install sudo mc net-tools nano zip jq wget -y"

# Clean package lists
log "[🧹] Cleaning package lists..."
run_command "apt update && apt-get clean"

# Install build-essential and Java dependencies
log "[⚙️] Installing build-essential and Java dependencies..."
run_command "apt-get install -y build-essential software-properties-common"
run_command "add-apt-repository -y ppa:openjdk-r/ppa"
run_command "apt update && apt install -y openjdk-21-jdk"

# Clear screen
clear

# Create Minecraft server directory
log "[📁] Creating Minecraft server directory..."
run_command "mkdir -p mc"
cd mc || exit 1  # Move into mc directory

# Download PaperMC server jar
log "[🌐] Downloading PaperMC server jar..."
run_command "wget https://api.papermc.io/v2/projects/paper/versions/1.21.4/builds/177/downloads/paper-1.21.4-177.jar"
run_command "mv paper-1.21.4-177.jar server.jar"

# Create start script
log "[✍️] Creating start script..."
cat <<EOF > start.sh
#!/bin/bash

java -Xms3072M -Xmx3072M --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -jar server.jar --nogui
EOF

# Give execution permission to start script
log "[🔑] Setting execution permission for start script..."
chmod +x ./start.sh  # Ensure it's done in the current directory (mc)

# Accept EULA automatically
log "[📜] Accepting Minecraft EULA..."
echo "eula=true" > eula.txt

clear

# Notify user
log "==================================================================="
log "[✅] Minecraft Server is set up! 🎉"
log "To start the server, use the following commands:"
log ""
log "cd mc/"
log "./start.sh"
log ""
log "Enjoy your game! 🚀"
log "==================================================================="
