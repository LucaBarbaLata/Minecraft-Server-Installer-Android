# Minecraft-Server-Installer-Android-Termux

Automates Minecraft server setup on Android via Termux + Ubuntu proot. Supports Vanilla, PaperMC, and KettingLauncher.

---

## Prerequisites

Before running the script, you need Ubuntu installed inside Termux.

👉 **[How to install Ubuntu in Termux](https://github.com/LucaBarbaLata/Minecraft-Server-Installer-Android/wiki/How-to-install-Ubuntu-in-Termux)**

**Requirements:**
- Termux with Ubuntu proot running
- `curl` installed (`apt install curl`)
- ~3 GB of free storage
- ~2–4 GB of RAM recommended

---

## Quick Start

Run this inside your Ubuntu terminal in Termux:

```bash
curl -sSL https://raw.githubusercontent.com/LucaBarbaLata/Minecraft-Server-Installer-Android/main/main.sh -o main.sh && chmod +x main.sh && ./main.sh
```

---

## Server Types

| Feature | Vanilla | PaperMC | KettingLauncher |
|---|---|---|---|
| Official Mojang server | ✅ | ❌ | ❌ |
| Performance patches | ❌ | ✅ | ✅ |
| Plugin support (Bukkit/Spigot) | ❌ | ✅ | ✅ |
| Forge mod support | ❌ | ❌ | ✅ |
| Auto-fetch latest version | ✅ | ✅ | ✅ |
| Server config wizard | ❌ | ✅ | ❌ |
| Built-in plugin installer | ❌ | ✅ | ❌ |
| Update checker (`-update`) | ❌ | ✅ | ❌ |

---

## Flags

| Flag | Description |
|---|---|
| `-verbose` | Show full output from install commands instead of running silently |
| `-update` | (PaperMC only) Check for and install the latest PaperMC build |

Example:
```bash
./main.sh -verbose
```

---

## PaperMC Plugin Installer

When installing PaperMC, you can optionally install these plugins automatically:

- **EssentialsX** — Core commands, economy, `/home`, `/warp`
- **LuckPerms** — Ranks and permissions management
- **VeinMiner** — Mine entire ore veins at once
- **ViaVersion** — Let newer clients connect
- **ViaBackwards** — Let older clients connect too
- **AuraSkills** — RPG skill progression system
- **WorldEdit** — Powerful in-game world editor
- **SkinsRestorer** — Custom skins for offline-mode servers
- **TAB** — Custom tab list, nametags, and scoreboards

---

## Starting Your Server

After installation, the server is placed in `~/mc/`. To start it:

```bash
cd ~/mc
./start.sh
```

---

## Troubleshooting

**Script fails immediately**
- Make sure you are running inside Ubuntu proot, not bare Termux
- Ensure `curl` is installed: `apt install curl`

**Java not found after install**
- Try closing and reopening your Ubuntu session, then run `java -version`

**Download failed**
- Check your internet connection
- For PaperMC, verify the version exists at [papermc.io/downloads](https://papermc.io/downloads/paper)

**Not enough storage**
- The server requires ~3 GB. Free up space and try again.

---

## License

MIT — see [LICENSE](LICENSE)
