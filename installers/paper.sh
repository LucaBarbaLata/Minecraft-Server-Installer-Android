#!/bin/bash

# ══════════════════════════════════════════════════════════════════════════════
# Colors & helpers
# ══════════════════════════════════════════════════════════════════════════════
RESET="\033[0m";   RED="\033[31m";   GREEN="\033[32m"; YELLOW="\033[33m"
BLUE="\033[34m";   CYAN="\033[36m";  MAGENTA="\033[35m"; WHITE="\033[37m"
BOLD="\033[1m"

VERBOSE=false
for arg in "$@"; do [ "$arg" == "-verbose" ] && VERBOSE=true; done

run_command() {
    if [ "$VERBOSE" == true ]; then eval "$1"; else eval "$1" &>/dev/null; fi
}

log() { echo -e "$1"; }

check_success() {
    if [ $? -ne 0 ]; then
        log "${RED}[❌] $1 failed. Exiting.${RESET}"; exit 1
    fi
}

# confirm "Question?" [default: Y or N]  →  returns 0 (yes) or 1 (no)
confirm() {
    local question=$1 default=${2:-Y} prompt answer
    [[ "$default" =~ ^[Yy]$ ]] && prompt="[Y/n]" || prompt="[y/N]"
    read -p "$(echo -e "   ${WHITE}$question $prompt: ${RESET}")" answer
    answer=${answer:-$default}
    [[ "$answer" =~ ^[Yy]$ ]]
}

SERVER_DIR="$HOME/mc"

# ══════════════════════════════════════════════════════════════════════════════
# Update checker  (triggered by -update flag)
# ══════════════════════════════════════════════════════════════════════════════
check_for_updates() {
    local info_file="$SERVER_DIR/.server_info"
    if [ ! -f "$info_file" ]; then
        log "${RED}[❌] No server info found. Run the installer first.${RESET}"; exit 1
    fi
    # shellcheck source=/dev/null
    source "$info_file"

    log ""
    log "${CYAN}[🔍] Checking for PaperMC updates...${RESET}"
    log "   Current version : ${YELLOW}$SAVED_MC_VERSION${RESET}"
    log "   Current build   : ${YELLOW}$SAVED_BUILD${RESET}"

    local latest_build
    latest_build=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$SAVED_MC_VERSION/builds" \
        | jq -r '.builds[-1].build // empty')

    if [ -z "$latest_build" ]; then
        log "${RED}[❌] Could not reach PaperMC API. Check your connection.${RESET}"; exit 1
    fi

    if [ "$latest_build" -gt "$SAVED_BUILD" ]; then
        log "${YELLOW}[⬆️]  New build available: $latest_build  (you have $SAVED_BUILD)${RESET}"
        if confirm "Download and install update?" Y; then
            cd "$SERVER_DIR" || exit 1
            local jar_url="https://api.papermc.io/v2/projects/paper/versions/$SAVED_MC_VERSION/builds/$latest_build/downloads/paper-$SAVED_MC_VERSION-$latest_build.jar"
            log "${CYAN}[⬇️]  Downloading build $latest_build...${RESET}"
            wget --show-progress "$jar_url" -O server.jar
            if [ $? -eq 0 ]; then
                sed -i "s/SAVED_BUILD=.*/SAVED_BUILD=$latest_build/" "$info_file"
                log "${GREEN}[✅] Updated to build $latest_build! Restart your server to apply.${RESET}"
            else
                log "${RED}[❌] Download failed.${RESET}"
            fi
        fi
    else
        log "${GREEN}[✅] Already on the latest build ($SAVED_BUILD). No update needed.${RESET}"
    fi
    exit 0
}

for arg in "$@"; do [ "$arg" == "-update" ] && check_for_updates; done

# ══════════════════════════════════════════════════════════════════════════════
# Banner
# ══════════════════════════════════════════════════════════════════════════════
clear
log "${CYAN}${BOLD}=================================================================================================================================="
log "    __  ____                            ______     _____                              ____           __        ____         "
log "   /  |/  (_)___  ___  ______________ _/ __/ /_   / ___/___  ______   _____  _____   /  _/___  _____/ /_____ _/ / /__  _____"
log "  / /|_/ / / __ \/ _ \/ ___/ ___/ __ \`/ /_/ __/   \__ \/ _ \/ ___/ | / / _ \/ ___/   / // __ \/ ___/ __/ __ \`/ / / _ \/ ___/"
log " / /  / / / / / /  __/ /__/ /  / /_/ / __/ /_    ___/ /  __/ /   | |/ /  __/ /     _/ // / / (__  ) /_/ /_/ / / /  __/ /    "
log "/_/  /_/_/_/ /_/\___/\___/_/   \__,_/_/  \__/   /____/\___/_/    |___/\___/_/     /___/_/ /_/____/\__/\__,_/_/_/\___/_/     "
log "==================================================================================================================================${RESET}"
log "${MAGENTA}${BOLD}Minecraft Server Installer (PaperMC)${RESET}"
log "By: Luca-rickrolled-himself"
log "(https://github.com/LucaBarbaLata/Minecraft-Server-Installer-Android)"
log "${YELLOW}WARNING: This Script Will Consume Approx. 3 GB of Data!${RESET}"
log ""
log "${WHITE}Tip: ${CYAN}-verbose${WHITE} to see full install output  |  ${CYAN}-update${WHITE} to check for PaperMC updates${RESET}"
log ""
read -p "$(echo -e "${YELLOW}Press [Enter] to continue or Ctrl+C to cancel...${RESET}")"

# ══════════════════════════════════════════════════════════════════════════════
# Prerequisites  (curl + jq needed for API calls, installed early)
# ══════════════════════════════════════════════════════════════════════════════
log ""
log "${BLUE}[🔧] Installing prerequisites (curl, jq, wget)...${RESET}"
run_command "apt-get update -y"
run_command "apt-get install -y curl jq wget"
check_success "Installing prerequisites"

# ══════════════════════════════════════════════════════════════════════════════
# Minecraft version  +  auto-fetch latest build
# ══════════════════════════════════════════════════════════════════════════════
log ""
while true; do
    read -p "$(echo -e "${WHITE}Enter Minecraft version (default: 1.21.1): ${RESET}")" MC_VERSION
    MC_VERSION=${MC_VERSION:-1.21.1}
    if [[ "$MC_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then break
    else log "${RED}   Invalid format. Use e.g. 1.21.1${RESET}"; fi
done

log "${CYAN}[🔍] Fetching latest build for $MC_VERSION...${RESET}"
BUILD_NUMBER=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$MC_VERSION/builds" \
    | jq -r '.builds[-1].build // empty')

if [ -z "$BUILD_NUMBER" ]; then
    log "${YELLOW}[⚠️]  Could not fetch build automatically. Please enter it manually.${RESET}"
    log "   Browse builds at: ${CYAN}https://papermc.io/downloads/paper${RESET}"
    while true; do
        read -p "$(echo -e "   Build number: ")" BUILD_NUMBER
        [[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]] && break
        log "${RED}   Must be a positive number.${RESET}"
    done
else
    log "${GREEN}[✅] Latest build: $BUILD_NUMBER${RESET}"
fi

# ══════════════════════════════════════════════════════════════════════════════
# RAM
# ══════════════════════════════════════════════════════════════════════════════
log ""
while true; do
    read -p "$(echo -e "${WHITE}RAM to allocate in GB (default: 3): ${RESET}")" RAM_GB
    RAM_GB=${RAM_GB:-3}
    if [[ "$RAM_GB" =~ ^[1-9][0-9]*$ ]]; then break
    else log "${RED}   Must be a positive whole number (e.g. 2, 3, 4).${RESET}"; fi
done
RAM_MB=$((RAM_GB * 1024))

# ══════════════════════════════════════════════════════════════════════════════
# System dependencies  +  Java
# ══════════════════════════════════════════════════════════════════════════════
log ""
log "${BLUE}[🔧] Updating Ubuntu and installing dependencies...${RESET}"
run_command "apt-get upgrade -y"
run_command "apt-get install -y sudo mc net-tools nano zip build-essential software-properties-common"
check_success "Installing base packages"
run_command "apt-get install -y openjdk-21-jdk"
check_success "Installing Java"

if ! command -v java &>/dev/null; then
    log "${RED}[❌] Java not found in PATH after installation. Exiting.${RESET}"; exit 1
fi
log "${GREEN}[✅] $(java -version 2>&1 | head -1)${RESET}"

# ══════════════════════════════════════════════════════════════════════════════
# Server directory  (with optional backup)
# ══════════════════════════════════════════════════════════════════════════════
log ""
log "${BLUE}[📁] Setting up server directory at $SERVER_DIR...${RESET}"

if [ -d "$SERVER_DIR" ]; then
    log "${YELLOW}[⚠️]  $SERVER_DIR already exists.${RESET}"
    if confirm "Back up existing server before continuing?" Y; then
        BACKUP_NAME="$HOME/mc_backup_$(date +%Y%m%d_%H%M%S).zip"
        log "${CYAN}[📦] Creating backup at $BACKUP_NAME...${RESET}"
        zip -rq "$BACKUP_NAME" "$SERVER_DIR"
        log "${GREEN}[✅] Backup saved to $BACKUP_NAME${RESET}"
    fi
fi

mkdir -p "$SERVER_DIR/plugins"
cd "$SERVER_DIR" || { log "${RED}[❌] Could not enter $SERVER_DIR. Exiting.${RESET}"; exit 1; }

# ══════════════════════════════════════════════════════════════════════════════
# Download PaperMC
# ══════════════════════════════════════════════════════════════════════════════
JAR_URL="https://api.papermc.io/v2/projects/paper/versions/$MC_VERSION/builds/$BUILD_NUMBER/downloads/paper-$MC_VERSION-$BUILD_NUMBER.jar"
log ""
log "${CYAN}[🌐] Downloading PaperMC $MC_VERSION build $BUILD_NUMBER...${RESET}"
wget --show-progress "$JAR_URL" -O server.jar
if [ $? -ne 0 ]; then
    log "${RED}[❌] Download failed. Check version/build at https://papermc.io/downloads/paper${RESET}"
    exit 1
fi
log "${GREEN}[✅] PaperMC downloaded.${RESET}"

# ══════════════════════════════════════════════════════════════════════════════
# server.properties configurator
# ══════════════════════════════════════════════════════════════════════════════
configure_server_properties() {
    log ""
    log "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗"
    log "║        ⚙️   Server Properties Configurator       ║"
    log "╚══════════════════════════════════════════════════╝${RESET}"
    log "   ${WHITE}Press Enter to accept the default shown in [brackets].${RESET}"
    log ""

    # MOTD
    read -p "$(echo -e "   ${WHITE}Server description / MOTD [A Minecraft Server]: ${RESET}")" MOTD
    MOTD=${MOTD:-A Minecraft Server}

    # Port
    log ""
    while true; do
        read -p "$(echo -e "   ${WHITE}Server port [25565]: ${RESET}")" PORT
        PORT=${PORT:-25565}
        if [[ "$PORT" =~ ^[0-9]+$ ]] && [ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ]; then break
        else log "   ${RED}Invalid. Must be between 1024 and 65535.${RESET}"; fi
    done

    # Max players
    log ""
    while true; do
        read -p "$(echo -e "   ${WHITE}Max players [20]: ${RESET}")" MAX_PLAYERS
        MAX_PLAYERS=${MAX_PLAYERS:-20}
        if [[ "$MAX_PLAYERS" =~ ^[1-9][0-9]*$ ]]; then break
        else log "   ${RED}Must be a positive number.${RESET}"; fi
    done

    # Gamemode
    log ""
    log "   ${WHITE}Default gamemode:${RESET}"
    log "     [1] Survival   [2] Creative   [3] Adventure   [4] Spectator"
    while true; do
        read -p "$(echo -e "   Choose [1]: ")" GM
        GM=${GM:-1}
        case $GM in
            1) GAMEMODE="survival";   break ;;
            2) GAMEMODE="creative";   break ;;
            3) GAMEMODE="adventure";  break ;;
            4) GAMEMODE="spectator";  break ;;
            *) log "   ${RED}Enter 1, 2, 3, or 4.${RESET}" ;;
        esac
    done

    # Difficulty
    log ""
    log "   ${WHITE}Difficulty:${RESET}"
    log "     [1] Peaceful   [2] Easy   [3] Normal   [4] Hard"
    while true; do
        read -p "$(echo -e "   Choose [3]: ")" DF
        DF=${DF:-3}
        case $DF in
            1) DIFFICULTY="peaceful"; break ;;
            2) DIFFICULTY="easy";     break ;;
            3) DIFFICULTY="normal";   break ;;
            4) DIFFICULTY="hard";     break ;;
            *) log "   ${RED}Enter 1, 2, 3, or 4.${RESET}" ;;
        esac
    done

    # Online mode
    log ""
    if confirm "Enable online mode? (disable for cracked/offline servers)" Y; then
        ONLINE_MODE="true"
    else
        ONLINE_MODE="false"
        log "   ${YELLOW}Tip: Install SkinsRestorer to allow custom skins in offline mode.${RESET}"
    fi

    # PVP
    log ""
    if confirm "Enable PVP?" Y; then PVP="true"; else PVP="false"; fi

    # View distance
    log ""
    while true; do
        read -p "$(echo -e "   ${WHITE}View distance in chunks (2-32) [10]: ${RESET}")" VIEW_DIST
        VIEW_DIST=${VIEW_DIST:-10}
        if [[ "$VIEW_DIST" =~ ^[0-9]+$ ]] && [ "$VIEW_DIST" -ge 2 ] && [ "$VIEW_DIST" -le 32 ]; then break
        else log "   ${RED}Must be between 2 and 32.${RESET}"; fi
    done

    # Simulation distance
    log ""
    while true; do
        read -p "$(echo -e "   ${WHITE}Simulation distance in chunks (2-32) [10]: ${RESET}")" SIM_DIST
        SIM_DIST=${SIM_DIST:-10}
        if [[ "$SIM_DIST" =~ ^[0-9]+$ ]] && [ "$SIM_DIST" -ge 2 ] && [ "$SIM_DIST" -le 32 ]; then break
        else log "   ${RED}Must be between 2 and 32.${RESET}"; fi
    done

    # World seed
    log ""
    read -p "$(echo -e "   ${WHITE}World seed (leave blank for random): ${RESET}")" LEVEL_SEED

    # Level name
    read -p "$(echo -e "   ${WHITE}World folder name [world]: ${RESET}")" LEVEL_NAME
    LEVEL_NAME=${LEVEL_NAME:-world}

    # Whitelist
    log ""
    if confirm "Enable whitelist?" N; then WHITELIST="true"; else WHITELIST="false"; fi

    # Allow flight
    if confirm "Allow flight? (prevents kick when flying with elytra or plugins)" N; then
        ALLOW_FLIGHT="true"
    else
        ALLOW_FLIGHT="false"
    fi

    # Spawn protection
    log ""
    while true; do
        read -p "$(echo -e "   ${WHITE}Spawn protection radius (0 to disable) [16]: ${RESET}")" SPAWN_PROT
        SPAWN_PROT=${SPAWN_PROT:-16}
        if [[ "$SPAWN_PROT" =~ ^[0-9]+$ ]]; then break
        else log "   ${RED}Must be 0 or a positive number.${RESET}"; fi
    done

    # Command blocks
    log ""
    if confirm "Enable command blocks?" N; then CMD_BLOCKS="true"; else CMD_BLOCKS="false"; fi

    # Force gamemode
    if confirm "Force gamemode on join? (all players always use the default gamemode)" N; then
        FORCE_GM="true"
    else
        FORCE_GM="false"
    fi

    # Write server.properties
    cat <<EOF > "$SERVER_DIR/server.properties"
#Minecraft server properties
#Generated by Minecraft Server Installer
motd=$MOTD
server-port=$PORT
max-players=$MAX_PLAYERS
gamemode=$GAMEMODE
force-gamemode=$FORCE_GM
difficulty=$DIFFICULTY
online-mode=$ONLINE_MODE
pvp=$PVP
view-distance=$VIEW_DIST
simulation-distance=$SIM_DIST
level-seed=$LEVEL_SEED
level-name=$LEVEL_NAME
white-list=$WHITELIST
allow-flight=$ALLOW_FLIGHT
spawn-protection=$SPAWN_PROT
enable-command-block=$CMD_BLOCKS
hardcore=false
max-world-size=29999984
network-compression-threshold=256
prevent-proxy-connections=false
use-native-transport=true
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
allow-nether=true
generate-structures=true
EOF
    log ""
    log "${GREEN}[✅] server.properties configured and saved.${RESET}"
}

configure_server_properties

# ══════════════════════════════════════════════════════════════════════════════
# Plugin installer
# ══════════════════════════════════════════════════════════════════════════════

# Download from Modrinth by project slug
download_modrinth() {
    local slug=$1 name=$2
    log "${CYAN}   [⬇️]  $name (Modrinth)...${RESET}"
    local api_url="https://api.modrinth.com/v2/project/$slug/version?loaders=%5B%22paper%22%5D&game_versions=%5B%22$MC_VERSION%22%5D"
    local url
    url=$(curl -s "$api_url" | jq -r '.[0].files[0].url // empty')

    # Fallback: try without version filter (gets latest regardless of MC version)
    if [ -z "$url" ]; then
        log "   ${YELLOW}No exact version match, trying latest release...${RESET}"
        url=$(curl -s "https://api.modrinth.com/v2/project/$slug/version" \
            | jq -r '.[0].files[0].url // empty')
    fi

    if [ -z "$url" ]; then
        log "   ${RED}[❌] Could not find $name on Modrinth. Skipping.${RESET}"; return 1
    fi
    wget -q --show-progress "$url" -P "$SERVER_DIR/plugins/"
    if [ $? -eq 0 ]; then log "${GREEN}   [✅] $name installed.${RESET}"
    else log "${RED}   [❌] $name download failed.${RESET}"; fi
}

# Download from GitHub releases by repo + filename regex pattern
download_github() {
    local repo=$1 name=$2 pattern=$3
    log "${CYAN}   [⬇️]  $name (GitHub)...${RESET}"
    local url
    url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | jq -r ".assets[] | select(.name | test(\"$pattern\")) | .browser_download_url" | head -1)

    if [ -z "$url" ]; then
        log "   ${RED}[❌] Could not find $name on GitHub. Skipping.${RESET}"; return 1
    fi
    wget -q --show-progress "$url" -P "$SERVER_DIR/plugins/"
    if [ $? -eq 0 ]; then log "${GREEN}   [✅] $name installed.${RESET}"
    else log "${RED}   [❌] $name download failed.${RESET}"; fi
}

install_plugins() {
    log ""
    log "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════╗"
    log "║                      🔌  Plugin Installer                        ║"
    log "╠══════════════════════════════════════════════════════════════════╣"
    log "║  [1] EssentialsX     - Core commands, economy, /home, /warp     ║"
    log "║  [2] LuckPerms       - Ranks & permissions management           ║"
    log "║  [3] VeinMiner       - Mine entire ore veins at once            ║"
    log "║  [4] ViaVersion      - Let newer clients connect to your server ║"
    log "║  [5] ViaBackwards    - Let older clients connect too            ║"
    log "║  [6] AuraSkills      - RPG skill progression system             ║"
    log "║  [7] WorldEdit       - Powerful in-game world editor            ║"
    log "║  [8] SkinsRestorer   - Custom player skins for offline mode     ║"
    log "║  [9] TAB             - Custom tab list, nametags & scoreboards  ║"
    log "║                                                                  ║"
    log "║  [A] Install all plugins      [N] Skip plugin installation      ║"
    log "╚══════════════════════════════════════════════════════════════════╝${RESET}"
    log ""
    read -p "$(echo -e "${WHITE}Enter numbers separated by spaces (e.g. 1 2 4 5), or A/N: ${RESET}")" PLUGIN_INPUT
    PLUGIN_INPUT=${PLUGIN_INPUT:-N}

    declare -A SELECTED
    if [[ "$PLUGIN_INPUT" =~ ^[Aa]$ ]]; then
        for i in 1 2 3 4 5 6 7 8 9; do SELECTED[$i]=1; done
    elif [[ "$PLUGIN_INPUT" =~ ^[Nn]$ ]]; then
        log "${YELLOW}[⏭️]  Skipping plugin installation.${RESET}"; return
    else
        for num in $PLUGIN_INPUT; do
            [[ "$num" =~ ^[1-9]$ ]] && SELECTED[$num]=1
        done
    fi

    log ""
    log "${CYAN}[🔌] Installing selected plugins into $SERVER_DIR/plugins/...${RESET}"
    log ""

    # EssentialsX — GitHub (not on Modrinth, only main jar needed)
    [ "${SELECTED[1]}" == "1" ] && \
        download_github "EssentialsX/Essentials" "EssentialsX" "^EssentialsX-[0-9].*\.jar$"

    # LuckPerms — Modrinth
    [ "${SELECTED[2]}" == "1" ] && \
        download_modrinth "luckperms" "LuckPerms"

    # VeinMiner — Modrinth
    [ "${SELECTED[3]}" == "1" ] && \
        download_modrinth "veinminer" "VeinMiner"

    # ViaVersion — Modrinth
    [ "${SELECTED[4]}" == "1" ] && \
        download_modrinth "viaversion" "ViaVersion"

    # ViaBackwards — Modrinth
    [ "${SELECTED[5]}" == "1" ] && \
        download_modrinth "viabackwards" "ViaBackwards"

    # AuraSkills — Modrinth
    [ "${SELECTED[6]}" == "1" ] && \
        download_modrinth "auraskills" "AuraSkills"

    # WorldEdit — Modrinth
    [ "${SELECTED[7]}" == "1" ] && \
        download_modrinth "worldedit" "WorldEdit"

    # SkinsRestorer — Modrinth
    [ "${SELECTED[8]}" == "1" ] && \
        download_modrinth "skinsrestorer" "SkinsRestorer"

    # TAB — GitHub (NEZNAMY/TAB, exclude API jar)
    [ "${SELECTED[9]}" == "1" ] && \
        download_github "NEZNAMY/TAB" "TAB" "^TAB-[0-9].*\.jar$"

    log ""
    log "${GREEN}[✅] Plugin installation complete. Plugins saved to $SERVER_DIR/plugins/${RESET}"
}

install_plugins

# ══════════════════════════════════════════════════════════════════════════════
# Auto-restart
# ══════════════════════════════════════════════════════════════════════════════
log ""
log "${YELLOW}${BOLD}[🔄] Auto-Restart${RESET}"
log "   ${WHITE}Note: systemd is unavailable in proot Ubuntu on Termux."
log "   This feature uses a bash loop in the server run script instead.${RESET}"
log ""
AUTORESTART=false
if confirm "Enable auto-restart on crash or /stop?" N; then AUTORESTART=true; fi

# ══════════════════════════════════════════════════════════════════════════════
# Screen / tmux
# ══════════════════════════════════════════════════════════════════════════════
log ""
log "${YELLOW}${BOLD}[📺] Session Manager${RESET}"
log "   ${WHITE}Running inside screen or tmux keeps your server alive"
log "   after closing the Termux window.${RESET}"
log ""
log "   [1] screen  —  Classic terminal multiplexer"
log "   [2] tmux    —  Modern terminal multiplexer"
log "   [3] None    —  Run directly in the terminal"
log ""
while true; do
    read -p "$(echo -e "   Choose [3]: ")" SESSION_CHOICE
    SESSION_CHOICE=${SESSION_CHOICE:-3}
    case $SESSION_CHOICE in
        1) SESSION_MANAGER="screen"; break ;;
        2) SESSION_MANAGER="tmux";   break ;;
        3) SESSION_MANAGER="none";   break ;;
        *) log "   ${RED}Enter 1, 2, or 3.${RESET}" ;;
    esac
done

if [ "$SESSION_MANAGER" != "none" ]; then
    log "${CYAN}[📦] Installing $SESSION_MANAGER...${RESET}"
    run_command "apt-get install -y $SESSION_MANAGER"
    check_success "Installing $SESSION_MANAGER"
    log "${GREEN}[✅] $SESSION_MANAGER installed.${RESET}"
fi

# ══════════════════════════════════════════════════════════════════════════════
# Build server_run.sh  (core Java command, with or without auto-restart loop)
# start.sh wraps server_run.sh with the chosen session manager
# ══════════════════════════════════════════════════════════════════════════════
log ""
log "${CYAN}[✍️]  Generating server scripts...${RESET}"

SERVER_RUN="$SERVER_DIR/server_run.sh"

# Write the core run script
{
    echo '#!/bin/bash'
    echo "cd \"$SERVER_DIR\""
    echo ""
    if [ "$AUTORESTART" == true ]; then
        echo 'while true; do'
        echo "    java -Xms${RAM_MB}M -Xmx${RAM_MB}M \\"
        echo "      --add-modules=jdk.incubator.vector \\"
        echo "      -XX:+UseG1GC \\"
        echo "      -XX:+ParallelRefProcEnabled \\"
        echo "      -XX:MaxGCPauseMillis=200 \\"
        echo "      -XX:+UnlockExperimentalVMOptions \\"
        echo "      -XX:+DisableExplicitGC \\"
        echo "      -XX:+AlwaysPreTouch \\"
        echo "      -XX:G1HeapWastePercent=5 \\"
        echo "      -XX:G1MixedGCCountTarget=4 \\"
        echo "      -XX:InitiatingHeapOccupancyPercent=15 \\"
        echo "      -XX:G1MixedGCLiveThresholdPercent=90 \\"
        echo "      -XX:G1RSetUpdatingPauseTimePercent=5 \\"
        echo "      -XX:SurvivorRatio=32 \\"
        echo "      -XX:+PerfDisableSharedMem \\"
        echo "      -XX:MaxTenuringThreshold=1 \\"
        echo "      -Dusing.aikars.flags=https://mcflags.emc.gs \\"
        echo "      -Daikars.new.flags=true \\"
        echo "      -XX:G1NewSizePercent=30 \\"
        echo "      -XX:G1MaxNewSizePercent=40 \\"
        echo "      -XX:G1HeapRegionSize=8M \\"
        echo "      -XX:G1ReservePercent=20 \\"
        echo "      -jar server.jar --nogui"
        echo '    echo ""'
        echo '    echo "[🔄] Server stopped. Restarting in 5 seconds... (Ctrl+C to cancel)"'
        echo '    sleep 5'
        echo 'done'
    else
        echo "java -Xms${RAM_MB}M -Xmx${RAM_MB}M \\"
        echo "  --add-modules=jdk.incubator.vector \\"
        echo "  -XX:+UseG1GC \\"
        echo "  -XX:+ParallelRefProcEnabled \\"
        echo "  -XX:MaxGCPauseMillis=200 \\"
        echo "  -XX:+UnlockExperimentalVMOptions \\"
        echo "  -XX:+DisableExplicitGC \\"
        echo "  -XX:+AlwaysPreTouch \\"
        echo "  -XX:G1HeapWastePercent=5 \\"
        echo "  -XX:G1MixedGCCountTarget=4 \\"
        echo "  -XX:InitiatingHeapOccupancyPercent=15 \\"
        echo "  -XX:G1MixedGCLiveThresholdPercent=90 \\"
        echo "  -XX:G1RSetUpdatingPauseTimePercent=5 \\"
        echo "  -XX:SurvivorRatio=32 \\"
        echo "  -XX:+PerfDisableSharedMem \\"
        echo "  -XX:MaxTenuringThreshold=1 \\"
        echo "  -Dusing.aikars.flags=https://mcflags.emc.gs \\"
        echo "  -Daikars.new.flags=true \\"
        echo "  -XX:G1NewSizePercent=30 \\"
        echo "  -XX:G1MaxNewSizePercent=40 \\"
        echo "  -XX:G1HeapRegionSize=8M \\"
        echo "  -XX:G1ReservePercent=20 \\"
        echo "  -jar server.jar --nogui"
    fi
} > "$SERVER_RUN"
chmod +x "$SERVER_RUN"

# Write start.sh — wraps server_run.sh in the chosen session manager
case $SESSION_MANAGER in
    screen)
        cat > "$SERVER_DIR/start.sh" <<'STARTEOF'
#!/bin/bash
SESSION="mcserver"
if screen -list | grep -q "$SESSION"; then
    echo "[⚠️]  Server is already running!"
    echo "      Attach to it with: screen -r $SESSION"
    exit 1
fi
echo "[🚀] Starting server in screen session '$SESSION'..."
screen -S "$SESSION" "$HOME/mc/server_run.sh"
STARTEOF
        cat > "$SERVER_DIR/attach.sh" <<'ATTACHEOF'
#!/bin/bash
screen -r mcserver
ATTACHEOF
        chmod +x "$SERVER_DIR/attach.sh"
        log "${GREEN}   attach.sh created — use it to re-attach to the console.${RESET}"
        ;;
    tmux)
        cat > "$SERVER_DIR/start.sh" <<'STARTEOF'
#!/bin/bash
SESSION="mcserver"
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "[⚠️]  Server is already running!"
    echo "      Attach to it with: tmux attach -t $SESSION"
    exit 1
fi
echo "[🚀] Starting server in tmux session '$SESSION'..."
tmux new-session -d -s "$SESSION" "$HOME/mc/server_run.sh"
echo "[✅] Server started. Attach with: tmux attach -t $SESSION"
STARTEOF
        cat > "$SERVER_DIR/attach.sh" <<'ATTACHEOF'
#!/bin/bash
tmux attach -t mcserver
ATTACHEOF
        chmod +x "$SERVER_DIR/attach.sh"
        log "${GREEN}   attach.sh created — use it to re-attach to the console.${RESET}"
        ;;
    none)
        cat > "$SERVER_DIR/start.sh" <<STARTEOF
#!/bin/bash
exec "$SERVER_DIR/server_run.sh"
STARTEOF
        ;;
esac
chmod +x "$SERVER_DIR/start.sh"
log "${GREEN}[✅] start.sh and server_run.sh created.${RESET}"

# ══════════════════════════════════════════════════════════════════════════════
# EULA
# ══════════════════════════════════════════════════════════════════════════════
echo "eula=true" > "$SERVER_DIR/eula.txt"

# ══════════════════════════════════════════════════════════════════════════════
# Save server info  (used by -update flag)
# ══════════════════════════════════════════════════════════════════════════════
cat <<EOF > "$SERVER_DIR/.server_info"
SAVED_MC_VERSION=$MC_VERSION
SAVED_BUILD=$BUILD_NUMBER
EOF

# ══════════════════════════════════════════════════════════════════════════════
# Done
# ══════════════════════════════════════════════════════════════════════════════
clear
log "${CYAN}${BOLD}=========================================================="
log "${GREEN}[✅] Minecraft Server ($MC_VERSION build $BUILD_NUMBER) is ready! 🎉${RESET}"
log ""
log "   ${WHITE}RAM allocated  : ${YELLOW}${RAM_GB}GB (${RAM_MB}MB)${RESET}"
log "   ${WHITE}Server folder  : ${YELLOW}$SERVER_DIR${RESET}"
log "   ${WHITE}Session manager: ${YELLOW}$SESSION_MANAGER${RESET}"
log "   ${WHITE}Auto-restart   : ${YELLOW}$AUTORESTART${RESET}"
log ""
log "${WHITE}Start the server:${RESET}"
log "   ${YELLOW}cd ~/mc && ./start.sh${RESET}"
if [ "$SESSION_MANAGER" != "none" ]; then
log ""
log "${WHITE}Re-attach to server console:${RESET}"
log "   ${YELLOW}cd ~/mc && ./attach.sh${RESET}"
fi
log ""
log "${WHITE}Check for PaperMC updates later:${RESET}"
log "   ${YELLOW}bash install_mc.sh -update${RESET}"
log ""
log "${WHITE}Browse plugins : ${CYAN}https://modrinth.com/plugins${RESET}"
log "${WHITE}Browse builds  : ${CYAN}https://papermc.io/downloads/paper${RESET}"
log ""
log "${GREEN}Enjoy your server! 🚀${RESET}"
log "${CYAN}${BOLD}==========================================================${RESET}"
