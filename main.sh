#!/bin/bash

# Check if the verbose flag is passed
verbose=""
if [[ "$1" == "-verbose" ]]; then
    verbose="-verbose"
fi

# Display the menu
echo "Choose Minecraft Server Software:"
echo "1. Vanilla"
echo "2. PaperMC"
echo "3. Ketting"

# Read user choice
read -p "Enter your choice [1-3]: " choice

# Download and run the corresponding installer script based on the user's choice
case $choice in
    1)
        echo "Downloading and installing Vanilla server..."
        curl -sSL https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/installers/vanilla.sh -o /tmp/vanilla.sh && bash /tmp/vanilla.sh $verbose
        ;;
    2)
        echo "Downloading and installing PaperMC server..."
        curl -sSL https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/installers/paper.sh -o /tmp/paper.sh && bash /tmp/paper.sh $verbose
        ;;
    3)
        echo "Downloading and installing Ketting server..."
        curl -sSL https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/installers/ketting.sh -o /tmp/ketting.sh && bash /tmp/ketting.sh $verbose
        ;;
    *)
        echo "Invalid choice. Please select 1, 2, or 3."
        ;;
esac
