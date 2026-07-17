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
        bash -c "$1"
    else
        bash -c "$1" &>/dev/null
    fi
}

#Install jq
apt install jq -y

# Function to log messages with colors
log() {
    echo -e "$1"
}

# ══════════════════════════════════════════════════════════════════════════════
# Java runtime installer  (picks the right JRE for the Minecraft version)
# ══════════════════════════════════════════════════════════════════════════════

# Minecraft version → required Java major version.
#   ≤1.16 → 8  |  1.17–1.20.4 → 17  |  1.20.5–1.21.x → 21  |  26.1+ (calendar) → 25
mc_java_version() {
    local v="$1" major minor patch
    major=$(echo "$v" | cut -d. -f1)
    minor=$(echo "$v" | cut -d. -f2); minor=${minor:-0}
    patch=$(echo "$v" | cut -d. -f3); patch=${patch:-0}
    if [ "$major" != "1" ]; then echo 25; return; fi
    if   [ "$minor" -le 16 ]; then echo 8
    elif [ "$minor" -le 19 ]; then echo 17
    elif [ "$minor" -eq 20 ]; then
        if [ "$patch" -ge 5 ]; then echo 21; else echo 17; fi
    else echo 21
    fi
}

# Detected Java major version (handles both the old "1.8" and new "21" schemes).
java_major() {
    local ver
    ver=$(java -version 2>&1 | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
    [ -z "$ver" ] && return 1
    local a=${ver%%.*}
    if [ "$a" = "1" ]; then ver=${ver#*.}; echo "${ver%%.*}"; else echo "$a"; fi
}

# Returns 0 if an installed Java runtime is at least major version $1.
java_satisfies() {
    local want="$1" cur
    command -v java &>/dev/null || return 1
    cur=$(java_major) || return 1
    [ "$cur" -ge "$want" ]
}

# Add the Eclipse Temurin (Adoptium) apt repo — provides arm64 builds of newer
# Java releases that Ubuntu's own repos don't ship yet (e.g. Java 25 on 24.04).
setup_adoptium_repo() {
    run_command "apt-get install -y wget apt-transport-https gnupg ca-certificates"
    local codename
    codename=$(. /etc/os-release 2>/dev/null; echo "${VERSION_CODENAME:-noble}")
    case "$codename" in jammy|noble) ;; *) codename="noble" ;; esac
    run_command "mkdir -p /etc/apt/keyrings"
    run_command "wget -qO /tmp/adoptium.gpg.key https://packages.adoptium.net/artifactory/api/gpg/key/public" || return 1
    run_command "gpg --dearmor --yes -o /etc/apt/keyrings/adoptium.gpg /tmp/adoptium.gpg.key" || return 1
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $codename main" \
        > /etc/apt/sources.list.d/adoptium.list
    run_command "apt-get update -y"
}

# install_java <minecraft-version> — installs a JRE that satisfies that version.
install_java() {
    local mc_version="$1" want
    want=$(mc_java_version "$mc_version")

    if java_satisfies "$want"; then
        log "${GREEN}[✅] Java $(java_major) already present ($(java -version 2>&1 | head -1)).${RESET}"
        return 0
    fi

    log "${BLUE}[☕] Minecraft $mc_version needs Java $want — installing openjdk-${want}-jre..."
    run_command "apt-get update -y"
    run_command "apt-get install -y openjdk-${want}-jre"
    if java_satisfies "$want"; then
        log "${GREEN}[✅] $(java -version 2>&1 | head -1)"; return 0
    fi

    log "${YELLOW}[⚠️]  openjdk-${want}-jre not offered by the distro. Trying Eclipse Temurin..."
    if setup_adoptium_repo; then
        run_command "apt-get install -y temurin-${want}-jre"
        if java_satisfies "$want"; then
            log "${GREEN}[✅] $(java -version 2>&1 | head -1)"; return 0
        fi
    fi

    log "${YELLOW}[⚠️]  Couldn't install Java $want. Falling back to the newest JRE available..."
    local pkg
    for pkg in openjdk-21-jre openjdk-17-jre default-jre; do
        run_command "apt-get install -y $pkg"
        if command -v java &>/dev/null; then
            log "${YELLOW}[⚠️]  Installed '$pkg' ($(java -version 2>&1 | head -1)). Minecraft $mc_version may require Java $want; the server could fail to start until Java is upgraded."
            return 0
        fi
    done

    log "${RED}[❌] Could not install any Java runtime. Exiting."
    exit 1
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
log "Minecraft Server Installer (Vanilla)"
log "By: Luca-rickrolled-himself"
log "(https://github.com/LucaBarbaLata/Minecraft-Server-Installer-Android)"
log "WARNING: This Script Will Consume Aprox. 3 GB of Data!"
log "==================================================================="

log "${YELLOW}[⏳] Waiting 3 seconds before starting script"
sleep 3
echo ""
log "${CYAN}[⏳] Fetching Minecraft version manifest..."
VERSION_MANIFEST=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json)
sleep 1
echo -e "${GREEN}[✅] Done!"
sleep 1
# Ask the user for the Minecraft version
while true; do
    read -p "Enter the Minecraft version you want to install (default: 1.21.1): " MC_VERSION
    MC_VERSION=${MC_VERSION:-1.21.1}
    if [[ "$MC_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then break
    else log "${RED}[❌] Invalid format. Use e.g. 1.21.1${RESET}"; fi
done

# Ask the user for RAM allocation
read -p "Enter the amount of RAM to allocate in GB (default: 3): " RAM_GB
RAM_GB=${RAM_GB:-3}
RAM_MB=$((RAM_GB * 1024))
# Find the latest release for the requested major version
LATEST_RELEASE=$(echo "$VERSION_MANIFEST" | jq -r --arg MC_VERSION "$MC_VERSION" '
  .versions[] | select(.id | startswith($MC_VERSION)) | select(.type=="release") | .id' | head -n 1
)

if [[ -z "$LATEST_RELEASE" ]]; then
    echo -e "${RED}[❌] No matching version found for '$MC_VERSION'. Try again."
    exit 1
fi

echo -e "${GREEN}[✅] Version found! Proceeding with the instalation!"
sleep 2
echo ""
echo ""
# Get the JSON URL for the latest release
VERSION_URL=$(echo "$VERSION_MANIFEST" | jq -r --arg LATEST_RELEASE "$LATEST_RELEASE" '
  .versions[] | select(.id == $LATEST_RELEASE) | .url'
)

# Define the download URL
SERVER_URL=$(curl -s "$VERSION_URL" | jq -r '.downloads.server.url')

# Update and install necessary packages
log "${BLUE}[🔧] Updating OS and installing dependencies..."
run_command "apt-get update -y && apt-get upgrade -y"
run_command "apt-get install sudo mc net-tools nano zip wget -y"
run_command "apt-get install -y build-essential software-properties-common"
install_java "$LATEST_RELEASE"

# Create Minecraft server directory
log "${BLUE}[📁] Creating Minecraft server directory..."
mkdir -p mc
cd mc || exit 1

# Download Vanilla server jar
log "${CYAN}[🌐] Downloading Vanilla server jar for version $MC_VERSION..."
wget "$SERVER_URL" -O server.jar
if [ $? -ne 0 ]; then
    log "${RED}[❌] Download failed."
    exit 1
fi

# Create start script
log "${CYAN}[✍️] Creating start script..."

# jdk.incubator.vector isn't bundled in every JRE — only pass the flag if the
# module exists, otherwise the server dies with "Module jdk.incubator.vector not found".
VECTOR_FLAG=""
if java --list-modules 2>/dev/null | grep -q '^jdk.incubator.vector'; then
    VECTOR_FLAG="--add-modules=jdk.incubator.vector "
fi

cat <<EOF > start.sh
#!/bin/bash
java -Xms${RAM_MB}M -Xmx${RAM_MB}M ${VECTOR_FLAG}-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -jar server.jar --nogui
EOF

# Give execution permission to start script
chmod +x start.sh

# Accept EULA automatically
log "${CYAN}[📜] Accepting Minecraft EULA..."
echo "eula=true" > eula.txt

# Notify user
clear
log "==================================================================="
log "${GREEN}[✅] Your Minecraft Server ($MC_VERSION) is set up! 🎉"
log "To start the server, use the following commands:"
log ""
log "cd mc/"
log "./start.sh"
log ""
log "Enjoy your game! 🚀"
log "==================================================================="
