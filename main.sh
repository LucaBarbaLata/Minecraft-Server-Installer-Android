#!/bin/bash

set -e
set -o pipefail

# ══════════════════════════════════════════════════════════════════════════════
# Colors
# ══════════════════════════════════════════════════════════════════════════════
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
MAGENTA="\033[35m"
WHITE="\033[37m"
BOLD="\033[1m"

log() { echo -e "$1"; }

WORKDIR="$HOME/.mc-installer"
mkdir -p "$WORKDIR"

# ══════════════════════════════════════════════════════════════════════════════
# Argument parsing  (flags can appear in any order)
# ══════════════════════════════════════════════════════════════════════════════
verbose=""
extra_flags=""
for arg in "$@"; do
    case "$arg" in
        -verbose) verbose="-verbose" ;;
        -update)  extra_flags="$extra_flags -update" ;;
    esac
done

# ══════════════════════════════════════════════════════════════════════════════
# Dependency check
# ══════════════════════════════════════════════════════════════════════════════
if ! command -v curl &>/dev/null; then
    log "${RED}[❌] 'curl' is required but not installed. Run: apt-get install curl${RESET}"
    exit 1
fi

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
log "${MAGENTA}${BOLD}Minecraft Server Installer${RESET}"
log "By: Luca-rickrolled-himself"
log "(https://github.com/LucaBarbaLata/Minecraft-Server-Installer-Android)"
log ""
log "${WHITE}Tips: ${CYAN}-verbose${WHITE} for detailed output  |  ${CYAN}-update${WHITE} to check for PaperMC updates${RESET}"
log ""

# ══════════════════════════════════════════════════════════════════════════════
# Server software selection
# ══════════════════════════════════════════════════════════════════════════════
log "${BOLD}Choose Minecraft Server Software:${RESET}"
log "  ${CYAN}[1]${RESET} Vanilla  — Official Mojang server"
log "  ${CYAN}[2]${RESET} PaperMC  — High-performance fork with plugin support"
log "  ${CYAN}[3]${RESET} Ketting  — Forge + Bukkit hybrid server"
log ""

while true; do
    read -p "$(echo -e "${WHITE}Enter your choice [1-3]: ${RESET}")" choice
    case $choice in
        1|2|3) break ;;
        *) log "${RED}   Invalid choice. Please enter 1, 2, or 3.${RESET}" ;;
    esac
done

download_and_run() {
    local name="$1"
    local url="$2"
    local script="$WORKDIR/$name.sh"

    log ""
    log "${CYAN}[⬇️]  Downloading $name installer...${RESET}"
    if ! curl -fL "$url" -o "$script"; then
        log "${RED}[❌] Failed to download the $name installer. Check your connection.${RESET}"
        exit 1
    fi

    chmod +x "$script"
    log "${GREEN}[✅] Launching $name installer...${RESET}"
    log ""
    bash "$script" $verbose $extra_flags
}

BASE_URL="https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/installers"

case $choice in
    1) download_and_run "vanilla" "$BASE_URL/vanilla.sh" ;;
    2) download_and_run "paper"   "$BASE_URL/paper.sh"   ;;
    3) download_and_run "ketting" "$BASE_URL/ketting.sh" ;;
esac
