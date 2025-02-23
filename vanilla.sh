#!/bin/bash

# Update and upgrade system
apt update && apt upgrade -y

# Install necessary packages
apt install sudo mc net-tools nano zip jq wget -y

# Clean package lists
apt update && apt-get clean

# Install build-essential and Java dependencies
apt-get install -y build-essential software-properties-common
add-apt-repository -y ppa:openjdk-r/ppa
apt update && apt install -y openjdk-21-jdk

# Clear screen
clear

# Create and enter the Minecraft server directory
mkdir -p mc
cd mc/

# Download PaperMC server jar
wget https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar

# Create start script
cat <<EOF > start.sh
#!/bin/bash

java -Xms3072M -Xmx3072M --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -jar server.jar --nogui
EOF

# Give execution permission to start script
chmod +x start.sh

# Accept EULA automatically
echo "eula=true" > eula.txt

# Notify user
echo "Minecraft Server is set up! Run it by typing ./start.sh"
