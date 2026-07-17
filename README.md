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

When installing PaperMC, the installer fetches the **most popular Paper plugins from
[Modrinth](https://modrinth.com)** that are compatible with the Minecraft version you
chose, and shows them in an interactive menu. Pick the ones you want by number (e.g.
`1 3 5`), enter `A` to install all, or `N` to skip.

Each selected plugin is downloaded straight from Modrinth — the newest build that
targets your version (falling back to the same `1.x` family, then the latest release).
If Modrinth can't be reached, the installer falls back to a curated built-in list
(EssentialsX, LuckPerms, ViaVersion, WorldEdit, SkinsRestorer, TAB, and more).

---

## Java Version

The Vanilla and PaperMC installers pick the right Java runtime automatically based on
the Minecraft version you install:

| Minecraft version | Java |
|---|---|
| ≤ 1.16 | 8 |
| 1.17 – 1.20.4 | 17 |
| 1.20.5 – 1.21.x | 21 |
| 26.1+ (calendar versions) | 25 |

If your distro doesn't ship the required Java, the installer pulls it from the
[Eclipse Temurin](https://adoptium.net) apt repository (which has arm64 builds).

---

## Starting Your Server

After installation, the server is placed in `~/mc/`. To start it:

```bash
cd ~/mc
./start.sh
```

For PaperMC you can later check for newer server builds with:

```bash
./main.sh -update
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
