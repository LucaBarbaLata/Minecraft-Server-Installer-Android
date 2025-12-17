#!/bin/bash

set -e

WORKDIR="$HOME/.mc-installer"
mkdir -p "$WORKDIR"

# Check if the verbose flag is passed
verbose=""
if [[ "$1" == "-verbose" ]]; then
    verbose="-verbose"
fi

echo "Choose Minecraft Server Software:"
echo "1. Vanilla"
echo "2. PaperMC"
echo "3. Ketting"

read -p "Enter your choice [1-3]: " choice

download_and_run() {
    local name="$1"
    local url="$2"
    local script="$WORKDIR/$name.sh"

    echo "Downloading $name installer..."
    curl -fL "$url" -o "$script"

    chmod +x "$script"
    bash "$script" $verbose
}

case $choice in
    1)
        download_and_run "vanilla" \
        "https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/installers/vanilla.sh"
        ;;
    2)
        download_and_run "paper" \
        "https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/installers/paper.sh"
        ;;
    3)
        download_and_run "ketting" \
        "https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/installers/ketting.sh"
        ;;
    *)
        echo "Invalid choice. Please select 1, 2, or 3."
        exit 1
        ;;
esac
