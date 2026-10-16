# CachyOS Migration Guide (EndeavourOS → CachyOS)

> Tailored to **this machine** (analyzed on the current system):
> - **Current OS:** EndeavourOS (Arch-based, rolling), kernel `linux` 7.2.9
> - **Machine:** ASUSTeK TUF Dash F15 FX517ZM (12th Gen Intel i7-12650H, hybrid Intel UHD + NVIDIA RTX 3060 Mobile / Max-Q)
> - **Boot:** UEFI, GRUB, ESP = `/dev/nvme0n1p1` (260M FAT32, mounted `/boot/efi`), root = `/dev/nvme0n1p7` (ext4, mounted `/`)
> - **Swap:** `/swapfile` (8G), no swap partition
> - **Packages:** 360 explicit pacman, 49 foreign (AUR), 4 Flatpak apps
> - **Shell:** zsh via `ZDOTDIR=~/.config/zsh`, prompt Starship, managed by **GNU Stow**
> - **Dotfiles:** git repo `git@github.com:AlyNokrashy/my-dotfiles.git` → `~/dotfiles`
> - **Login:** `greetd` + `noctalia-greeter`; **keyd** remaps CapsLock/Esc
> - **Old external disk:** 2TB Seagate (USB) — **retired** (SMART: 120 pending + 120 uncorrectable sectors, failed self-test). Not used in this plan; do not back up onto it.
> - **New backup drive:** 2TB Seagate Backup Plus (`/dev/sdb1`, NTFS, label `Seagate Backup Plus Drive`) — healthy, ~1.4 TB free. **This is the backup target.**
>
> **Target filesystem for the new install: Btrfs** (CachyOS default). This guide assumes Btrfs throughout — see the Btrfs notes in Phases E, F and J.

Because both distros are Arch-based, this is fundamentally a **"save everything, fresh-install CachyOS, restore"** job. Package names, `stow old`, and most configs transfer almost directly — the main work is careful backup + a handful of machine-specific rebuilds.

> **⚠️ Two shell traps on this machine — read before pasting any command:**
>
> 1. **Inline `#` comments aren't comments.** Interactive **zsh here doesn't treat `#` as a comment** (`INTERACTIVE_COMMENTS` is off), so a pasted line like `cp -a src dst   # note` feeds `#`, `note` to the command as *extra arguments* and fails (e.g. `cp: target 'lists': No such file or directory`). Fix it permanently by adding `setopt interactivecomments` to your zsh config (`~/.config/zsh/.zshrc`, since `ZDOTDIR` is set). Until then, paste one line at a time and drop the trailing comments.
> 2. **`grep` is aliased to `rg`.** `~/.config/zsh/aliases.zsh` line 32 has `alias grep='rg --color=auto'`, so `grep -E`, `grep -vE`, `grep -iE` **fail** (`rg: … unknown encoding: …`) and the output file ends up empty. The guide's commands therefore call **`command grep …`**, which bypasses the alias and uses the real `/usr/bin/grep`. If you type your own `grep …` interactively, prefix it with `command ` (or use `rg` regex syntax directly).

---

## Table of contents

1. [Choose a strategy](#1-choose-a-strategy)
2. [Pre-flight: do these first](#2-pre-flight-do-these-first)
3. [Phase A — Back up all data off the machine](#phase-a--back-up-all-data-off-the-machine)
4. [Phase B — Capture package inventory](#phase-b--capture-package-inventory)
5. [Phase C — Capture system configs & secrets](#phase-c--capture-system-configs--secrets)
6. [Phase D — Make the CachyOS USB installer](#phase-d--make-the-cachyos-usb-installer)
7. [Phase E — Install CachyOS (partitioning decisions)](#phase-e--install-cachyos-partitioning-decisions)
8. [Phase F — First boot: base system](#phase-f--first-boot-base-system)
9. [Phase G — Reinstall packages](#phase-g--reinstall-packages)
10. [Phase H — Restore dotfiles](#phase-h--restore-dotfiles)
11. [Phase I — Restore app data & secrets](#phase-i--restore-app-data--secrets)
12. [Phase J — Restore `/etc`, services & machine-specific bits](#phase-j--restore-etc-services--machine-specific-bits)
13. [Phase K — Verify](#phase-k--verify)
14. [Gotchas specific to your setup](#gotchas-specific-to-your-setup)
15. [Rollback / safety net](#rollback--safety-net)
16. [Appendix: package lists & configs](#appendix-package-lists--configs)

---

## 1. Choose a strategy

| Strategy | What it means | Verdict |
|---|---|---|
| **A. Fresh install + restore** (this guide) | Back up everything, wipe `/`, install CachyOS, restore | ✅ **Recommended.** True clean CachyOS, optimized repos/kernels, no EndeavourOS leftovers |
| **B. In-place repo conversion** | Keep the running install, add CachyOS repos + kernels on top of EndeavourOS | ⚠️ Not a real "distro switch"; EndeavourOS packages/branding remain; can leave a franken-system. Use only if downtime must be near-zero |
| **C. Install CachyOS to a spare/test disk** | Full trial CachyOS, keep EndeavourOS untouched | 👍 Good as a *rehearsal* / fallback, but needs a spare healthy disk (the old 2TB is not usable) |

This guide follows **A**, with **C** offered as an optional rehearsal. You can literally run through Phases A–C once, boot a CachyOS live USB, mount your backup, and confirm the restore works before committing.

**Time budget:** a full afternoon/evening. Most of it is waiting on the big copy (your home is tens of GB) and package downloads.

---

## 2. Pre-flight: do these first

Run on the **current EndeavourOS system**:

```bash
# 1. Be fully up to date and know where you are
sudo pacman -Syu
cat /etc/os-release | head -2
uname -r

# 2. Pick a working + backup directory (on the machine, small)
mkdir -p ~/migration

# 3. Free some easy space first (optional but recommended)
#     ~/.local/share/Trash is ~4.7G, ~/.cache is ~7.5G on your box
du -sh ~/.local/share/Trash ~/.cache 2>/dev/null
# (Only empty Trash once you're sure — see Phase A.)
```

**Target filesystem = Btrfs** (chosen; CachyOS default). It gives you native snapshots for rollback (you already install `timeshift` + `timeshift-autosnap`), transparent compression, and subvolumes. This guide now assumes Btrfs throughout.

Three Btrfs facts that shape the steps below (all handled later):
- **Subvolumes**: CachyOS lays out `@`, `@home`, `@log`, `@cache`, `@tmp`, `@snapshots`. Timeshift's Btrfs mode depends on this exact scheme.
- **Swap**: a Btrfs swapfile must live on a dedicated **no-COW** subvolume and **cannot hibernate**. (Or just use CachyOS's default **zram**.)
- **/boot on Btrfs**: GRUB can read kernels from Btrfs; keep the `/boot` subvolume compatible with your GRUB (CachyOS's does — don't hand-tune compression there).

---

## Phase A — Back up all data off the machine

Everything you can't re-download. Do **not** write the backup to the same `/` partition you're about to wipe.

### A.1 Prepare the backup destination

The old 2TB Seagate is **retired** (see Gotchas). This plan uses the **new 2TB Seagate Backup Plus** drive — `/dev/sdb1`, NTFS, label `Seagate Backup Plus Drive`, ~1.4 TB free. Mount it at a space-free path (`/mnt/backup`) so the scripts below work cleanly:

```bash
# It auto-mounts under /run/media with spaces in the name — remount it at /mnt/backup
sudo mkdir -p /mnt/backup
sudo umount "/run/media/aly/Seagate Backup Plus Drive" 2>/dev/null
sudo mount -t ntfs3 -o uid=1000,gid=1000,umask=022 /dev/sdb1 /mnt/backup

# Confirm it's mounted and writable
findmnt /mnt/backup
mkdir -p /mnt/backup/cachy-backup       # NOTE: no sudo — the ntfs3 mount maps to your uid
df -h /mnt/backup                       # ~1.4 TB free — plenty
touch /mnt/backup/cachy-backup/.rwtest && echo "WRITABLE OK" && rm /mnt/backup/cachy-backup/.rwtest
```

> **Don't create `cachy-backup` with `sudo`.** On the `ntfs3` mount (`uid=1000`) a root-created dir ends up root-owned and you can't write into it (`touch: Permission denied`). Create it as your normal user. If you already hit this, fix it with no root needed:
> ```bash
> rmdir /mnt/backup/cachy-backup        # works because /mnt/backup is world-writable and the dir is empty
> mkdir -p /mnt/backup/cachy-backup
> ```
> (If the dir isn't empty: `sudo rm -rf /mnt/backup/cachy-backup && mkdir -p /mnt/backup/cachy-backup`.)

> **Filesystem caveat:** if the destination is **NTFS/exFAT** (typical on pre-formatted USB disks), it cannot store Linux permissions, ownership, or symlinks — so **don't `rsync` your home onto it**, or you'd lose your whole `~/.config/<app> → ~/dotfiles/...` symlink setup and file modes. **Use the `tar` archives below** — a `.tar.zst` is just a byte-stream, so NTFS/exFAT is fine as a container and everything is preserved on extract.
>
> If the destination is **ext4/Btrfs**, both the `tar` method and `rsync -aHAX` work (see A.4).

> **Note:** this drive already holds old data (~413 GB of `___Monthly Backup` etc.) — fine, just less free space; don't delete it unless you're sure. To mount it at `/mnt/backup` automatically, add to `/etc/fstab`:
> `UUID=FAE20EDDE20E9E4F /mnt/backup ntfs3 uid=1000,gid=1000,umask=022,nofail 0 0`

### A.2 Back up your home directory

Run as root so ownership/xattrs are captured. Adjust excludes as you like.

```bash
cd /home
sudo tar --zstd --acls --xattrs --numeric-owner -cpf \
  /mnt/backup/cachy-backup/home-$(date +%F).tar.zst \
  --exclude='aly/.cache' \
  --exclude='aly/.local/share/Trash' \
  --exclude='aly/.local/share/Steam/steamapps' \
  --exclude='aly/.local/share/lutris' \
  aly
```

Notes:
- `--numeric-owner` records your **numeric ids — here `uid 1000, gid 1001`** (gid 1000 is the `autologin` group on this box). A fresh CachyOS install usually gives user **aly** gid **1000**, so restored home files would carry gid 1001. Harmless for a single-user home, and the restore step runs `sudo chown -R aly:aly /home/aly` to normalize it.
- Excluded `Steam/steamapps` and `lutris` (games) to save hours — reinstall/redownload, or back them up separately if you have fast internet budget (see A.5).
- Your home root dirs (`Grad-Project`, `Films`, `Audiobooks`, `Pictures`, `Manga`, `Books`, `Documents`, `Courses`, `GitHub`, etc.) and all the dotfiles are included.
- Measured on this machine: home is **80 GB** total → **~50 GB** actually archived after the excludes above → zstd packs it to **~31 GB** (the real run produced a 30.2 GiB `home-2026-10-16.tar.zst`). Verify free space on the destination first (`df -h`).
- **`tar: ...: socket ignored` warnings are expected and harmless.** Unix sockets (e.g. `~/.ssh/agent/s.*`) can't be stored in a tar; they're recreated when the app runs. Only a non-zero exit code matters. (A `file changed as we read it` warning is also normally fine.)

> Don't try to rescue/keep the retired 2TB Seagate — anything still only on it should be copied to the **new** drive as part of this step.

### A.3 Back up `/etc` and other system bits

```bash
sudo tar --zstd --acls --xattrs -cpf \
  /mnt/backup/cachy-backup/etc-$(date +%F).tar.zst -C / etc

# Everything under /usr/local — custom binaries, the noctalia-drive-health
# libexec scripts, and the Hyprland session file (A.3 originally only took bin):
sudo tar --zstd --acls --xattrs --numeric-owner -cpf \
  /mnt/backup/cachy-backup/usr-local-$(date +%F).tar.zst -C /usr local
```

Then verify the archives are non-truncated before you trust them (see A.6).

### A.4 Alternative: rsync (only to an ext4/Btrfs target)

If your backup target is a real Linux filesystem at e.g. `/mnt/backup`:

```bash
sudo rsync -aHAX --info=progress2 --delete \
  --exclude='.cache/' \
  --exclude='.local/share/Trash/' \
  --exclude='.local/share/Steam/steamapps/' \
  --exclude='.local/share/lutris/' \
  /home/aly/ /mnt/backup/aly/
```

### A.5 Gaming data (optional)

If you want to keep Steam/Lutris saves and games:

```bash
# Steam: config/saves are small; the game data (steamapps) is the big part
du -sh ~/.local/share/Steam/steamapps ~/.steam 2>/dev/null
sudo tar --zstd -cpf /mnt/backup/cachy-backup/steam-$(date +%F).tar.zst \
  -C /home/aly/.local/share/Steam steamapps
```

Otherwise redownload after install (fastest to just reinstall the games).

### A.6 Verify the backups

```bash
ls -lh /mnt/backup/cachy-backup/
# Test-list each archive (must print a file listing without errors):
for f in /mnt/backup/cachy-backup/*.tar.zst; do
  echo "== $f =="
  tar -tf "$f" >/dev/null && echo "OK" || echo "CORRUPT"
done
```

> Tip: if you can, keep **two** copies (e.g. external disk + cloud/another drive). The external disk is your single point of failure during the wipe.

### A.7 System-level data that is NOT in your home

The home archive covers `~/` **only**. Three things on this machine live outside it and would otherwise be lost:

1. **Docker** — you run ~8 containers (`bookorbit-app`, `bookorbit-db`, `power-teams-db`, `audiobookshelf`, `portainer`, …) with 4 named volumes (incl. `portainer_data`). Images/containers/volumes live in the root-owned `/var/lib/docker`.
2. **`/opt/audiobookshelf`** — root-owned app data (`config/`, `metadata/`, and its own `docker-compose.yml`).
3. **`/srv/tftp`** — your TFTP server files (`zImage`, `*.dtb`).

Your compose files and `.env` (in `~/bookorbit`, `~/GitHub/AttendanceSystem`) are already inside the home backup.

> **Flatpak (`/var/lib/flatpak`, ~4.6 GB):** deliberately **not** archived — it's all reinstallable. The app list is in `flatpaks.txt` (Phase B) and reinstalled in **G.4**; the apps' own data lives in `~/.var`, which *is* in the home archive. No action needed.

```bash
# Record the docker state for reference
sudo docker ps -a --format '{{.Names}}\t{{.Image}}' > ~/migration/docker-containers.txt
sudo docker images --format '{{.Repository}}:{{.Tag}}'       > ~/migration/docker-images.txt
sudo docker volume ls                                        > ~/migration/docker-volumes.txt

# Stop containers so volume data is consistent, then archive the volumes
sudo docker compose -f ~/bookorbit/docker-compose.yml down 2>/dev/null || true
sudo docker compose -f /opt/audiobookshelf/docker-compose.yml down 2>/dev/null || true
sudo systemctl stop docker docker.socket
sudo tar --zstd -cpf /mnt/backup/cachy-backup/docker-volumes-$(date +%F).tar.zst -C /var/lib/docker volumes
sudo systemctl start docker

# /opt and /srv data
sudo tar --zstd -cpf /mnt/backup/cachy-backup/opt-$(date +%F).tar.zst -C / opt/audiobookshelf
sudo tar --zstd -cpf /mnt/backup/cachy-backup/srv-$(date +%F).tar.zst -C / srv
# include the new lists (keep the comment on its own line — see the zsh note at the top)
cp -a ~/migration /mnt/backup/cachy-backup/
```

> You do **not** need to copy `/var/lib/docker/overlay2` (the images). The **volume archive + your compose files are enough**: on the new system `docker compose up -d` re-pulls images and reattaches the restored volumes. Only copy images if your internet is slow.
>
> Add `docker-volumes-*.tar.zst`, `opt-*.tar.zst`, `srv-*.tar.zst`, and `secrets-*.tar.zst` to the verify loop in A.6.

---

## Phase B — Capture package inventory

Save these three lists into `~/migration/` (they'll be inside the home backup too, but keep them handy separately).

```bash
mkdir -p ~/migration

# Native/explicit packages (the 360 you installed on purpose)
pacman -Qqe  > ~/migration/pkglist-explicit.txt

# AUR / foreign packages (the 49)
pacman -Qqm  > ~/migration/pkglist-aur.txt

# Flatpak apps
flatpak list --app --columns=application > ~/migration/flatpaks.txt

# (Nice-to-have) full versioned list for reference
pacman -Q > ~/migration/pkglist-full.txt

wc -l ~/migration/*.txt
```

### B.1 Strip EndeavourOS-only packages

These won't exist in CachyOS repos and must be removed from the install list to avoid failures. Edit `~/migration/pkglist-explicit.txt` and delete lines matching the EndeavourOS tooling:

```
endeavouros-branding
endeavouros-keyring
endeavouros-mirrorlist
eos-dracut
eos-hooks
eos-log-tool
eos-packagelist
eos-qogir-icons
eos-rankmirrors
arc-gtk-theme-eos
yay            # CachyOS ships paru instead
hwdetect       # EOS helper; may not exist upstream
reflector-simple
```

You can automate the removal:

```bash
cd ~/migration
command grep -vE '^(endeavouros-|eos-|arc-gtk-theme-eos|yay|hwdetect|reflector-simple)$' \
  pkglist-explicit.txt > pkglist-explicit.cachyos.txt
diff pkglist-explicit.txt pkglist-explicit.cachyos.txt
```

In `~/migration/pkglist-aur.txt`, remove the CachyOS packages that are **native on CachyOS** (they're only "foreign" right now because you added the repo):

```bash
command grep -vE '^(cachyos-keyring|cachyos-mirrorlist|cachyos-v3-mirrorlist|cachyos-v4-mirrorlist)$' \
  pkglist-aur.txt > pkglist-aur.cachyos.txt
```

---

## Phase C — Capture system configs & secrets

### C.1 Secrets and identity (most important to not lose)

```bash
ls -la ~/.ssh                 # id_ed25519, otw, known_hosts, agent/
ls -la ~/.gnupg
ls -la ~/.gitconfig
ls -la ~/.config/gh ~/.config/syncthing 2>/dev/null
```

These are all **already inside `home-*.tar.zst`**, but a small dedicated archive is worth having — it lets you pull in your SSH key *before* the full 31 GB restore (e.g. to `git clone` the dotfiles repo right after install):

```bash
cd /home/aly
tar --zstd --acls --xattrs --numeric-owner -cpf \
  /mnt/backup/cachy-backup/secrets-$(date +%F).tar.zst \
  .ssh .gnupg .gitconfig .config/gh
# restore later:  tar -xpf /mnt/backup/cachy-backup/secrets-*.tar.zst -C /home/aly
```

- **⚠️ Don't `cp` these onto the NTFS drive.** NTFS can't store Unix permissions (the mount applies `umask 022`), so `id_ed25519` / `otw` (600) and `~/.config/gh/hosts.yml` (the OAuth token, 600) would land **world-readable (644)** — and `ssh` would then refuse the key until you `chmod 600`. The `tar` above preserves modes; extract it as **your user**, not root.
- `~/.ssh` (your ed25519 keys + `otw`) — **included in the home backup**, but if you use those keys to `git clone` your dotfiles repo during setup, you'll want them *before* the full restore. Consider copying just `~/.ssh` to the external disk now, or temporarily add a new deploy key on GitHub.
- `~/.gnupg` — included in home backup.
- **Warning:** the home backup contains browser cookies/passwords (Zen/Firefox/LibreWolf), GitHub CLI tokens, Syncthing device identity, Bitwarden data. Keep the external disk safe; don't leave the archive lying around unencrypted.

### C.2 Key system config files to re-create by hand

Save copies of these (they're in `etc-*.tar.zst` too, but note them explicitly because you'll re-apply them deliberately):

| File | Why it matters |
|---|---|
| `/etc/keyd/default.conf` | CapsLock→overload(ctrl,esc), Esc→capslock |
| `/etc/greetd/config.toml` | Runs `noctalia-greeter-session` on VT1 |
| `/etc/environment` | `BROWSER=firefox`, `EDITOR=nvim`, `__GLX_VENDOR_LIBRARY_NAME=nvidia` |
| `/etc/locale.conf` | `LANG=en_GB.UTF-8` + `ar_EG.UTF-8` for LC_NAME/ADDRESS/TELEPHONE/IDENTIFICATION |
| `/etc/zsh/zshenv` | Sets `ZDOTDIR=$XDG_CONFIG_HOME/zsh` for you |
| `/etc/fstab` | old: NTFS mount, `/tmp` tmpfs, `/swapfile` (new install uses Btrfs subvolumes — see J.3) |
| `/etc/pacman.conf` | `Color`, `ILoveCandy`, `ParallelDownloads=5`, `VerbosePkgLists` |
| `/etc/default/grub` + `/etc/grub.d/` | If you keep GRUB and customize it |
| `/etc/pam.d/` (greetd, hyprlock, system-login) | Login stack tweaks |

Print them for reference right now:

```bash
for f in /etc/keyd/default.conf /etc/greetd/config.toml /etc/environment \
         /etc/locale.conf /etc/zsh/zshenv /etc/fstab /etc/pacman.conf \
         /etc/default/grub /etc/pam.d/greetd /etc/pam.d/hyprlock /etc/pam.d/system-login; do
  echo "===== $f ====="; cat "$f" 2>/dev/null || echo "(missing)"; echo
done | tee ~/migration/system-configs.txt
```

### C.3 Record enabled services (system + user)

```bash
systemctl list-unit-files --state=enabled --no-pager \
  | command grep -vE 'systemd-|dbus|getty|man-db|fstrim' > ~/migration/services-system.txt
systemctl --user list-unit-files --state=enabled --no-pager \
  > ~/migration/services-user.txt
cat ~/migration/services-system.txt ~/migration/services-user.txt
```

You'll re-enable these in Phase J. Recorded on your current system:

**System:** `auto-cpufreq`, `avahi-daemon(.socket)`, `bluetooth`, `docker`, `firewalld`, `greetd`, `keyd`, `NetworkManager`(+dispatcher/wait-online), `nvidia-persistenced`, `rpcbind`, `supergfxd`, `switcheroo-control`, `tftpd.socket`, `noctalia-drive-health.timer`, `paccache.timer`

**User:** `elephant`, `mpd`, `mpd-mpris`, `mpdscribble`, `pipewire`(+pulse/socket), `syncthing`, `wireplumber`, `xdg-user-dirs`, `gnome-keyring-daemon.socket`, `p11-kit-server.socket`

### C.4 Copy lists + `/etc` tarball to the external disk

```bash
mkdir -p /mnt/backup/cachy-backup/migration
# contents only (trailing /.), so re-running doesn't nest migration/migration
cp -a ~/migration/. /mnt/backup/cachy-backup/migration/
sync
```

---

## Phase D — Make the CachyOS USB installer

1. Download the ISO from **https://cachyos.org/download/** (choose the **Desktop** edition).
2. Verify it (download `sha256sum` / `.sig` alongside; CachyOS publishes them):
   ```bash
   sha256sum -c cachyos-*.iso.sha256   # or compare manually
   gpg --verify cachyos-*.iso.sig      # if a signature is provided
   ```
3. Write to a USB stick (**⚠️ double-check the device name — `dd` is destructive**):
   ```bash
   lsblk                       # identify your USB, e.g. /dev/sdc
   sudo dd if=cachyos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
   sync
   ```
   (Ventoy or balenaEtcher also work.)

4. **Verify the stick is actually bootable — don't skip this:**
   ```bash
   lsblk -f                          # expect: iso9660 <LABEL> + a small FAT ESP (ARCHISO_EFI) — NOT a lone empty FAT32
   command ls /run/media/$USER/*/    # `command` bypasses your `ls`→eza alias; expect arch/, boot/, EFI/, shellx64.efi
   # strongest check — the ISO ships a checksum of its own root filesystem:
   ( cd /run/media/$USER/*/arch/x86_64 && sha512sum -c airootfs.sha512 )   # must print: airootfs.sfs: OK
   ```
   ⚠️ A USB that shows up as a **single, empty FAT32 partition** (even if labeled `CACHYOS`) is **not** a working installer — the write failed or wasn't done. Re-write it before relying on it.

5. Reboot into BIOS (hold **F2** on ASUS) and:
   - Ensure **UEFI** boot, Secure Boot **disabled** (it's already off on your system).
   - Set the USB first in boot order.

> **Optional rehearsal:** boot the live ISO, pick "CachyOS" and explore its installer/partitioning UI, then exit without installing. Confirms drivers (Wi‑Fi, NVIDIA) work.

---

## Phase E — Install CachyOS (partitioning decisions)

Boot the USB → launch **CachyOS Installer** (Calamares-based).

1. **Language/timezone/keyboard:** set keyboard to **English (UK)** to match your `VC Keymap=uk` / `X11 Layout=gb`.
2. **Partitioning → choose "Manual partitioning":**

   Your disk is a single NVMe:
   ```
   nvme0n1p1  260M  vfat   → ESP (currently /boot/efi)
   nvme0n1p7  476G ext4    → / (currently ext4 → re-format as Btrfs)
   ```

   **Recommended layout (Btrfs root + GRUB + reuse the ESP):**
   | Partition | Mount | Format | Notes |
   |---|---|---|---|
   | `nvme0n1p1` | `/boot/efi` | **keep FAT32 — do NOT format** | 260M is small; keep **GRUB** so kernels live in `/boot` on the Btrfs root, not on the ESP |
   | `nvme0n1p7` | `/` | **Btrfs** | wipe and reinstall (this is the OS wipe) |

   **“Do I wipe everything or keep the boot partition?”**
   - **Format `/` (`nvme0n1p7`) as Btrfs → yes, this wipes the OS.** That's the whole point of the fresh install.
   - **Keep the ESP (`nvme0n1p1`) — do NOT format it.** It's a tiny FAT32 boot partition. The CachyOS installer writes GRUB's EFI binary into it and updates the UEFI boot entry. Keeping it is safer (preserves the existing EFI entry as a fallback) and you lose nothing: your disk is single-boot, so there's no other OS in the ESP to protect, but there's also nothing to gain by erasing it.
   - You do **not** need to repartition or create a new partition table — just reformat `p7` as Btrfs and leave `p1` alone.
   - Only if you deliberately want a spotless ESP: format it too, but then make sure the installer also **(re)creates the GRUB EFI file and a UEFI boot entry** — otherwise the machine won't boot.
   - **This is how you "delete EndeavourOS":** formatting `p7` erases its whole root filesystem (every `eos-*`/`endeavouros-*` package, config, and kernel). You don't uninstall anything — the fresh install simply replaces it.
   - *Optional tidy-up (after first boot):* because you kept the ESP, a stale `EndeavourOS` UEFI entry may linger in the boot menu. Remove it with `sudo efibootmgr -v` (find the `endeavouros`/`EndeavourOS` entry and its `BootXXXX` number) then `sudo efibootmgr -b XXXX -B`.

   **Btrfs subvolumes (let the installer create them):** CachyOS sets up the standard set automatically:
   ```
   @          → /
   @home      → /home
   @log       → /var/log
   @cache     → /var/cache
   @tmp       → /var/tmp
   @snapshots → /.snapshots    (used by Timeshift/snapper)
   ```
   If you ever set them up by hand, use exactly this scheme so Timeshift's Btrfs mode works out of the box.

   **Swap on Btrfs:** either let the installer make a swapfile (it must be on a **no-COW** subvolume — see Phase F.1) or skip it and use CachyOS's default **zram**. Btrfs swapfiles **cannot** be used for hibernation.

   > **⚠️ ESP size:** 260 MB is tight. Keep **GRUB** (kernels on the Btrfs root, ESP only holds GRUB). If the installer defaults to **systemd-boot** (kernels on the ESP), switch to GRUB — multiple CachyOS kernels + fallback images can overflow 260M.

   > **⚠️ GRUB + Btrfs compression:** GRUB reads Btrfs, but the kernel/initramfs must be readable at boot. CachyOS's GRUB supports zstd and its installer uses a compatible layout. If you hand-tune, don't put `/boot` on a subvolume with a compression mode GRUB can't read.

3. **Bootloader:** choose **GRUB** (to `/dev/nvme0n1`), matching your current setup.
4. **User account:** create user **`aly`** with **uid 1000** (default) so the restored files' ownership matches. Set your password.
5. **Hostname:** set the same hostname you use now (check `hostnamectl` before wiping if it matters to you).
6. **Kernel selection:** CachyOS offers several. Pick:
   - `linux-cachyos` (or **`linux-cachyos-bore`/`-lts`** if you want alternatives) — CachyOS kernels.
   - Tick the **NVIDIA** option for your RTX 3060 (**open** driver, `nvidia-open-dkms`, is correct for Ampere/RTX 30-series). CachyOS's installer "CachyOS Hello" handles hybrid graphics well.
7. **Filesystem/repo options:** the installer sets up CachyOS repos. You already have `cachyos-v3-mirrorlist` — **x86-64-v3** is the correct level for your i7-12650H (v4 needs AVX-512, which Alder Lake's P-cores lack). Let the installer choose v3 automatically.
8. **Desktop environment:** choose whatever you want installed (e.g. a minimal base). Your real Hyprland/Noctalia config comes back via dotfiles in Phase H, so you can install a minimal set and skip a full DE.
9. Reboot, remove the USB.

> **Wi-Fi note (Intel):** CachyOS live media and install include `iwlwifi`/`iwd`; your hardware is well supported. If networking fails, plug in Ethernet or tether via USB.

---

## Phase F — First boot: base system

Log in (or through `greetd`/TTY). Then:

```bash
# 1. Update everything
sudo pacman -Syu

# 2. Confirm CachyOS identity + kernel
cat /etc/os-release | head -2
uname -r
paru --version        # CachyOS ships paru

# 3. Install the tools you need for the restore pipeline
sudo pacman -S --needed git stow zstd rsync base-devel

# 4. Make your data directories exist
mkdir -p ~/Applications ~/bin ~/scripts ~/.local/bin ~/Pictures/Wallpapers
xdg-user-dirs-update
```

### F.1 Swap on Btrfs (pick one)

**Option 1 — zram (simplest; CachyOS enables it by default):**

```bash
swapon --show          # if a zram device shows up, you're done — no swapfile needed
zramctl
```

**Option 2 — 8G Btrfs swapfile** (like your old `/swapfile`, but Btrfs rules apply):

```bash
# A Btrfs swapfile must be on a dedicated NO-COW (-C) subvolume and must not be compressed.
sudo btrfs subvolume create /swap
sudo chattr +C /swap
sudo fallocate -l 8G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile

# Persist it:
echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
free -h
```

> ⚠️ Btrfs swapfiles **cannot hibernate**, and the `chattr +C` (no-COW) is mandatory — without it Btrfs refuses to activate the swapfile. The installer may already have created a swapfile during partitioning; check `/etc/fstab` first and don't add a duplicate. If unsure, just use zram (Option 1).

### F.2 NVIDIA / hybrid graphics

If you ticked NVIDIA in the installer, the open driver + DKMS should already be there. Verify:

```bash
pacman -Qs nvidia | head
# expect Intel UHD + GeForce RTX 3060
lspci | command grep -iE 'vga|3d'
nvidia-smi                          # must show the 3060
```

If not installed, use **CachyOS Hello → NVIDIA** (recommended for laptops), or manually install the open DKMS driver matching your kernel headers:

```bash
sudo pacman -S --needed nvidia-open-dkms nvidia-utils nvidia-prime \
  lib32-nvidia-utils nvidia-settings
# keep the DKMS module in sync with the CachyOS kernel:
sudo pacman -S --needed linux-cachyos-headers
sudo mkinitcpio -P
```

Add the env you had before to `/etc/environment` (Phase J).

### F.3 ASUS laptop controls

```bash
sudo pacman -S --needed asusctl supergfxctl rog-control-center
sudo systemctl enable --now supergfxd
```

---

## Phase G — Reinstall packages

### G.1 Mount the backup and get the lists

```bash
# Mount the new backup drive at /mnt/backup if it isn't already:
mountpoint -q /mnt/backup || sudo mount -t ntfs3 -o uid=1000,gid=1000,umask=022 /dev/sdb1 /mnt/backup
ls /mnt/backup/cachy-backup/migration/
cp -a /mnt/backup/cachy-backup/migration ~/migration
cd ~/migration
```

### G.2 Native packages

```bash
# pkglist-explicit.cachyos.txt = your 360 minus EndeavourOS-only tools
sudo pacman -S --needed - < pkglist-explicit.cachyos.txt
```

- `--needed` skips anything already present.
- If a name fails because CachyOS names it differently, note it and continue; rerun the list after fixing.
- CachyOS also provides its own optimized variants (e.g. `-cachyos` suffixes for some libs) via its repos — the installer already added those repos.

### G.3 AUR packages

```bash
# pkglist-aur.cachyos.txt = your 49 foreign minus cachyos-* (native now)
paru -S --needed - < pkglist-aur.cachyos.txt
```

Watch for AUR builds that break (see [Gotchas](#gotchas-specific-to-your-setup)). Big/slow ones on your list: `zen-browser-bin`, `onlyoffice-bin`, `waybar-git`, `rmpc-git`, `ryujinx-canary`, `millennium`, `walker`, `opencode-beta`.

### G.4 Flatpaks

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# installs: Flatseal, Stremio, YACReader, KCC
xargs -a flatpaks.txt -r flatpak install -y flathub
```

### G.5 Fonts & icons

Your explicit list already includes them (`ttf-*-nerd`, `maplemono-*`, `noto-fonts*`, `ttf-ms-fonts`, `maplemono-nf-unhinted`). Also restore your user fonts in Phase I (`~/.local/share/fonts`, ~227M) and refresh the cache:

```bash
fc-cache -f && fc-list | wc -l
```

---

## Phase H — Restore dotfiles

Your dotfiles are a git repo managed by **GNU Stow**. This is the easiest part.

### H.1 Set up SSH so you can clone

The repo remote is `git@github.com:AlyNokrashy/my-dotfiles.git`. You need your key first:

```bash
# Option 1: restore just the SSH key from the backup now
sudo mkdir -p ~/.ssh && sudo chown aly:aly ~/.ssh
# (quickest) extract the .ssh dir from the home archive:
sudo tar --zstd -xf /mnt/backup/cachy-backup/home-*.tar.zst \
  -C /home aly/.ssh aly/.gitconfig
sudo chown -R aly:aly ~/.ssh ~/.gitconfig
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519 ~/.ssh/otw
# Option 2: temporarily add a deploy key in GitHub settings
ssh -T git@github.com   # should greet you by username
```

### H.2 Clone and stow

```bash
git clone git@github.com:AlyNokrashy/my-dotfiles.git ~/dotfiles
cd ~/dotfiles
stow btop fastfetch hypr kitty leaf mpd noctalia nvim rmpc swaync wal walker waybar yazi zen zsh
```

This symlinks each package's `.config/<app>` into `~/.config/<app>` (e.g. `~/.config/zsh → ~/dotfiles/zsh/.config/zsh`).

### H.3 Machine-specific steps from your README

- **Monitors:** edit `hypr/.config/hypr/modules/monitor.lua` — it assumes `eDP-1` + `HDMI-A-1`.
- **Wallpapers:** `~/Pictures/Wallpapers` (created in Phase F; restore/or point Noctalia at it).
- **External scripts not in the repo** (re-create from the backup):
  - `~/.local/bin/{setwal,waybar-reload,powermenu,eject-storage.sh}`
  - `~/scripts/pywal16`
  - (`~/.local/bin` also had `lyrics-fetch.sh`, `mpd-refresh.sh`, plus symlinks to AppImages you must restore — see Phase I.)
- **Zen Browser profile:** the `zen` stow package targets `~/.config/zen/1gai9kpi.Default (release)/chrome`. If you restore your old `~/.config/zen` verbatim (Phase I), the profile dir name is preserved and stow still matches. If the name changes, re-point the package (it's just a directory name).
- **Hyprland plugins:** re-run `hyprpm` per `hypr/.config/hypr/modules/plugins.lua`.
- **Zsh plugins:** auto-cloned on first shell start (gitignored) — nothing to do.
- **Noctalia theming:** regenerated at login. Force it once with `noctalia msg templates-apply` if colors look off.

---

## Phase I — Restore app data & secrets

Now extract the rest of your home over the freshly-stowed config. **Do it carefully** so you don't clobber the stow symlinks with real dirs from the archive.

**Best order:**
1. Restore the whole home archive **first**, then re-run `stow -R` (restow) so the symlinks win.

Cleanest approach:

```bash
# 1. Extract your entire home (nothing stowed yet, or accept overwrite then restow)
cd /home
sudo tar --zstd --acls --xattrs --numeric-owner -xpf \
  /mnt/backup/cachy-backup/home-*.tar.zst
sudo chown -R aly:aly /home/aly

# 2. Re-apply stow so the symlinks replace any plain dirs that came out of the archive
cd ~/dotfiles
stow -R btop fastfetch hypr kitty leaf mpd noctalia nvim rmpc swaync wal walker waybar yazi zen zsh
```

> `stow -R` (restow) is important: it removes and re-creates the symlinks, fixing any conflict where the tar extraction wrote a real directory over a link target.

Then verify the important data landed:

```bash
# Browsers, app data, toolchains, projects
du -sh ~/.config/zen ~/.mozilla ~/.librewolf ~/.var ~/.local/share/Steam 2>/dev/null
ls ~/GitHub ~/Grad-Project ~/Documents ~/Pictures 2>/dev/null | head
ls -la ~/.ssh ~/.gnupg ~/.gitconfig ~/.config/gh 2>/dev/null

# AppImages + the ~/.local/bin symlinks that point at them
ls -la ~/Applications ~/.local/bin
# (re-create any broken symlinks, e.g. iloader -> ~/Applications/iloader.AppImage)
```

Flatpak app data (Stremio, YACReader, KCC settings) lives in `~/.var` — restored above. If you skipped `~/.var` in the backup, re-configure those apps.

### I.1 Dev toolchains

Your home carries `~/.cargo`, `~/.bun`, `~/.dotnet`, `~/.eclipse`, `~/go`, `~/.local/share/pnpm`, `~/.local/share/uv`, etc. They're restored by the archive. Enough to keep working; if any is broken due to a version jump, reinstall that toolchain:

```bash
# examples
curl -sSf https://sh.rustup.rs | sh    # for ~/.cargo (if needed)
# Go, Node/pnpm, .NET, Bun, Python/uv — reinstall via your preferred method if broken
```

### I.2 Restore Docker, `/opt` and `/srv` (from A.7)

```bash
# Docker: enable the daemon (installed via your package list) and restore volumes
sudo systemctl enable --now docker
sudo tar --zstd -xpf /mnt/backup/cachy-backup/docker-volumes-*.tar.zst -C /var/lib/docker
sudo systemctl restart docker

# /opt and /srv
sudo tar --zstd -xpf /mnt/backup/cachy-backup/opt-*.tar.zst -C /
sudo tar --zstd -xpf /mnt/backup/cachy-backup/srv-*.tar.zst -C /

# Bring the compose projects back up (re-pulls images, reattaches volumes)
sudo docker compose -f /opt/audiobookshelf/docker-compose.yml up -d
cd ~/bookorbit && sudo docker compose up -d
cd ~/GitHub/AttendanceSystem && sudo docker compose up -d
```

> Check `~/migration/docker-containers.txt` / `docker-volumes.txt` to confirm every container and volume came back. Volumes restore with their original names, so the compose files reattach them automatically.

---

## Phase J — Restore `/etc`, services & machine-specific bits

### J.1 Re-apply the key `/etc` files

Extract the etc tarball to a scratch dir and copy back **only what you want** (don't blindly overwrite CachyOS's tuned defaults):

```bash
sudo mkdir -p /tmp/etc-old
sudo tar --zstd -xf /mnt/backup/cachy-backup/etc-*.tar.zst -C /tmp/etc-old
ls /tmp/etc-old/etc
```

Then apply individually:

```bash
# keyd remap (CapsLock = overload(ctrl, esc), Esc = capslock)
sudo cp /tmp/etc-old/etc/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd

# greetd → noctalia-greeter
sudo cp /tmp/etc-old/etc/greetd/config.toml /etc/greetd/config.toml
# (noctalia-greeter package installs the session binary; enable greetd)
sudo systemctl enable --now greetd

# environment
sudo cp /tmp/etc-old/etc/environment /etc/environment
#   ensures: BROWSER=firefox, EDITOR=nvim, __GLX_VENDOR_LIBRARY_NAME=nvidia

# locale (en_GB.UTF-8 + ar_EG.UTF-8 for LC_*)
sudo cp /tmp/etc-old/etc/locale.conf /etc/locale.conf
sudo locale-gen                     # if applicable on CachyOS
localectl set-keymap uk
localectl set-x11-keymap gb

# zsh ZDOTDIR hook
sudo cp /tmp/etc-old/etc/zsh/zshenv /etc/zsh/zshenv

# pacman.conf cosmetics/options (merge Color, ILoveCandy, ParallelDownloads=5,
#   VerbosePkgLists — but KEEP CachyOS's repos). Diff first:
sudo diff -u /etc/pacman.conf /tmp/etc-old/etc/pacman.conf

# fstab: /tmp tmpfs + Btrfs subvolumes + swap (see J.3)
```

### J.2 Re-enable services

System services:

```bash
sudo systemctl enable --now \
  auto-cpufreq avahi-daemon avahi-daemon.socket bluetooth docker firewalld \
  greetd keyd NetworkManager NetworkManager-dispatcher NetworkManager-wait-online \
  nvidia-persistenced rpcbind supergfxd switcheroo-control tftpd.socket \
  noctalia-drive-health.timer paccache.timer
```

User services (run as `aly`, or `systemctl --user` when logged in):

```bash
systemctl --user enable --now \
  elephant mpd mpd-mpris mpdscribble pipewire pipewire-pulse \
  pipewire.socket pipewire-pulse.socket syncthing wireplumber xdg-user-dirs \
  gnome-keyring-daemon.socket p11-kit-server.socket
```

> `systemctl --user enable` for a service that isn't installed yet will fail — install the owning package first (Phase G does this). Re-run after packages are in.

### J.3 `/etc/fstab` (Btrfs) and extras

The CachyOS installer writes the Btrfs subvolume mounts for you. Verify them against `blkid`, and make sure `/tmp` and swap match what you set up. It should look like this:

```ini
# Btrfs root subvolumes (UUID = your Btrfs partition; ssd+discard for NVMe)
UUID=<BTRFS-UUID>  /           btrfs  subvol=@,compress=zstd:3,ssd,discard=async,noatime          0 0
UUID=<BTRFS-UUID>  /home       btrfs  subvol=@home,compress=zstd:3,ssd,discard=async,noatime      0 0
UUID=<BTRFS-UUID>  /var/log    btrfs  subvol=@log,compress=zstd:3,ssd,discard=async,noatime       0 0
UUID=<BTRFS-UUID>  /var/cache  btrfs  subvol=@cache,compress=zstd:3,ssd,discard=async,noatime     0 0
UUID=<BTRFS-UUID>  /var/tmp    btrfs  subvol=@tmp,compress=zstd:3,ssd,discard=async,noatime       0 0
UUID=<BTRFS-UUID>  /.snapshots btrfs  subvol=@snapshots,compress=zstd:3,ssd,discard=async,noatime 0 0

# ESP
UUID=<ESP-UUID>    /boot/efi   vfat   fmask=0137,dmask=0027  0 2

# /tmp on tmpfs (as before)
tmpfs              /tmp        tmpfs  defaults,noatime,mode=1777  0 0

# swap — only if you chose Option 2 in F.1; omit if you're using zram
/swap/swapfile     none        swap   defaults  0 0
```

> Your old 2TB NTFS disk is retired — don't re-add its entry here.

Reload: `sudo systemctl daemon-reload && sudo mount -a`.

### J.4 Custom `/usr/local/bin` binaries

You had hand-placed tools there: `advcp`, `advmv` (advanced copy/move), `awww`/`awww-daemon`, `network_manager`, `sine`, `start-hyprland-logged` (wrapper that logs `start-hyprland` to `~/hyprland-start.log`).

```bash
sudo tar --zstd -xpf /mnt/backup/cachy-backup/usr-local-bin-*.tar.zst -C /usr/local
sudo chmod +x /usr/local/bin/*
```

> These were compiled locally. If any misbehaves on CachyOS (different libc/lib versions, or built against an older ABI), rebuild it from source rather than copying the binary. `start-hyprland-logged` and `network_manager` are plain scripts/wrappers and are safe to copy.

### J.5 GRUB (if you customized it)

```bash
sudo cp -a /tmp/etc-old/etc/default/grub /etc/default/grub
ls /tmp/etc-old/etc/grub.d/         # copy any custom scripts you added
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## Phase K — Verify

Work through this checklist before you consider the migration done:

```bash
# OS + kernel + repos
cat /etc/os-release | head -2
uname -r
pacman -Qq | wc -l
pacman -Qqm | wc -l                    # AUR count (expect ~ your old 49 minus cachyos-*)

# Graphics / hybrid
nvidia-smi
# may need mesa-utils (in your list)
glxinfo -B 2>/dev/null | command grep -iE 'renderer|version'
supergfxctl -g                          # current GPU mode

# Login stack
systemctl status greetd --no-pager | head
systemctl status keyd   --no-pager | head
# confirm CapsLock behaves as Ctrl and Esc

# Audio / network / bluetooth
pactl info | head
nmcli device status
bluetoothctl show | head

# Dotfiles are stowed (symlinks, not copies)
ls -la ~/.config/zsh ~/.config/hypr ~/.config/kitty | command grep '\->'

# Fonts, theming
fc-list | command grep -i "Maple Mono NF" | head
# launch a Hyprland session → Noctalia should theme everything

# Services all green
systemctl --failed
systemctl --user --failed

# Btrfs health
sudo btrfs subvolume list /                 # should list @, @home, @log, @cache, @tmp, @snapshots
sudo btrfs filesystem usage /               # allocation, not "df full" illusion
sudo btrfs scrub start -Bd /                # verify checksums on the whole fs (runs a while)
findmnt -no SOURCE,OPTIONS /                # confirm subvol=@ and compress=zstd
swapon --show; zramctl                      # confirm your chosen swap setup

# Data present
ls ~/GitHub ~/Grad-Project ~/Pictures/Wallpapers
flatpak list --app
```

Then a **reboot test** (login greeter → Hyprland → Wi-Fi → audio → NVIDIA app like Steam or a game).

---

## Gotchas specific to your setup

- **EndeavourOS-only packages** must be dropped from the install list or `pacman -S` will 404 (`endeavouros-*`, `eos-*`, `arc-gtk-theme-eos`, `yay`, `hwdetect`, `reflector-simple`). Handled in Phase B.1.
- **`cachyos-keyring`/`cachyos-mirrorlist`/`cachyos-v3-mirrorlist` are "AUR" now** but become native on CachyOS — remove them from the AUR list (Phase B.1) or `paru` will try to build packages that now exist in the repos.
- **Toolchain/ABI mismatches after copying binaries:** `/usr/local/bin` custom binaries and any self-built AUR packages may need rebuilding. Prefer rebuild over copy for compiled ELF binaries.
- **AUR builds that commonly break:** `waybar-git`, `rmpc-git`, `ryujinx-canary`, `millennium`, `zen-browser-bin`. If one fails, build it manually with `paru -S <pkg>` and read the PKGBUILD; check the AUR page for a newer commit/fix.
- **ESP is only 260 MB.** Keep **GRUB** (kernels on `/`) or enlarge the ESP. CachyOS's systemd-boot default + multiple kernels can overflow a 260M ESP.
- **Btrfs specifics:** mount options and subvolumes matter — verify `/etc/fstab` uses `subvol=@`, `@home`, `@log`, `@cache`, `@tmp`, `@snapshots` (Phase J.3). Restoring home is just copying files back onto the mounted `@home`. A Btrfs swapfile needs a **no-COW** subvolume and **cannot hibernate**.
- **NVIDIA + DKMS:** the open driver must rebuild against the CachyOS kernel. Keep `linux-cachyos-headers` installed and run `sudo mkinitcpio -P` after kernel updates. `nvidia-open` is correct for your Ampere RTX 3060.
- **ASUS controls:** `asusctl`, `supergfxctl`, `rog-control-center`, and the `supergfxd` service are needed for your TUF's fan/GPU-mode controls. Don't skip Phase F.3.
- **`__GLX_VENDOR_LIBRARY_NAME=nvidia`** in `/etc/environment` can cause issues on a hybrid setup; keep it only if you rely on it (it forces the NVIDIA GLX vendor). Test both ways.
- **The old 2TB Seagate (USB) is retired:** SMART shows 120 pending + 120 uncorrectable sectors, reallocated = 0, and a **failed self-test (read failure)** — a failing drive. Don't mount it, don't back up to it. Use a new disk.
- **Secrets in the backup:** the archive contains SSH/GPG keys, browser sessions, and possibly Bitwarden data. Keep the backup disk physically secure and **encrypt the archive** (`tar ... | age -p > file.tar.age` or GPG).
- **Timeshift on Btrfs:** install `timeshift` + `timeshift-autosnap`, then select **BTRFS** as the snapshot type (not rsync-mode). It snapshots `@`/`@home` into `@snapshots`. For snapshot entries in the boot menu, also add `grub-btrfs`. Snapshots are on the same disk, so they are **not** a substitute for the off-machine backup.
- **Zen profile dir is machine-specific** (`1gai9kpi.Default (release)`). Restoring `~/.config/zen` wholesale preserves it; otherwise re-point the `zen` stow package.

---

## Rollback / safety net

- **Don't wipe until verified:** keep the `home-*.tar.zst` and `etc-*.tar.zst` on the external disk, and ideally copy them to a second location.
- **Rehearse (optional):** boot the CachyOS live ISO and test-mount/verify your backup archives with `tar -tf` before installing.
- **Test on a spare disk:** if you have a healthy spare disk, you *can* install CachyOS to it (Btrfs) as a full trial while EndeavourOS stays intact. Don't use the retired 2TB Seagate for this.
- **Keep the old boot entries:** since `/boot/efi` is shared, if something goes wrong you can still boot a live USB and re-extract your backup.
- **Worst case:** reinstall EndeavourOS and restore the same archives — the guide is distro-agnostic for the *restore* half.

---

## Appendix: package lists & configs

### A. Your explicit package list (360) — save to `~/migration/pkglist-explicit.txt`

Generated with `pacman -Qqe`. In the migration flow, this is filtered to `pkglist-explicit.cachyos.txt` (see Phase B.1).

```
accountservice adw-gtk-theme adwaita-icon-theme alsa-firmware alsa-plugins alsa-utils arc-gtk-theme-eos aria2 aspell asusctl auto-cpufreq base base-devel bash-completion bat bat-extras bc bear bitwarden bitwarden-cli blueman bluetui bluez bluez-utils borg brightnessctl btop btrfs-progs cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist calibre cantarell-fonts catppuccin-gtk-theme-mocha cava chafa cliphist cmake cowsay cryptsetup dbeaver dconf-editor device-mapper dialog diffutils discord dmidecode dmraid dnsmasq docker docker-buildx docker-compose dosfstools downgrade dracut dragon duf dysk e2fsprogs easytag efibootmgr efitools elephant-bin elephant-bitwarden-bin elephant-calc-bin elephant-clipboard-bin elephant-desktopapplications-bin elephant-files-bin elephant-menus-bin elephant-providerlist-bin elephant-runner-bin elephant-websearch-bin elephant-windows-bin endeavouros-branding endeavouros-keyring endeavouros-mirrorlist eos-dracut eos-hooks eos-log-tool eos-packagelist eos-qogir-icons eos-rankmirrors ethtool evince evtest ex-vi-compat exfatprogs eza f2fs-tools fastfetch ffmpegthumbnailer file-roller firewall-applet firewalld fish flatpak gamemode gazelle-tui gdu ghgrab-bin git github-cli gnome-calculator gnome-disk-utility gnome-keyring gnome-themes-extra go gparted grub gst-libav gst-plugin-pipewire gst-plugins-bad gst-plugins-ugly gtk-engine-murrine gvfs gvfs-afc gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb hdparm help2man hwdetect hwinfo hyprland hyprlock hyprmoncfg hyprpicker hyprpm hyprshot ifuse inetutils inkscape intel-media-driver intel-ucode inxi iptables iwd jfsutils jupyterlab keyd kitty lazygit leaf-markdown-viewer-bin less lib32-mangohud lib32-nvidia-utils lib32-opencl-nvidia lib32-vulkan-intel libdvdcss libgsf libopenraw libreoffice-still librewolf linux linux-firmware linux-headers linuxconsole localsend logrotate loupe lrcget-bin lsb-release lsscsi lutris lvm2 lxappearance ly man-db man-pages mangohud maplemono-nf-unhinted maplemono-ttf mdadm mediainfo meld mesa-utils meson millennium mingw-w64-gcc modemmanager mousepad mpc mpd mpd-mpris mpdscribble mpv mtools nano nano-syntax-highlighting nautilus ncdu neovim network-manager-applet networkmanager networkmanager-openconnect networkmanager-openvpn nfs-utils nilfs-utils nm-connection-editor noctalia noctalia-greeter noto-fonts noto-fonts-cjk noto-fonts-emoji npm nss-mdns nsxiv ntfs-3g ntfsprogs nvidia-open-dkms nvidia-prime nvidia-settings nvidia-utils nvtop nwg-look obs-studio obsidian onlyoffice-bin openbsd-netcat opencl-nvidia opencode-beta openmp openssh optipng os-prober overskride-bin pacman-contrib pamixer papirus-icon-theme paru pavucontrol pdfarranger perl pipewire-alsa pipewire-jack pipewire-pulse pkgfile plocate polkit-gnome polycat poppler-glib powertop protonup-qt python python-adblock python-defusedxml python-jinja python-packaging python-pip python-pipx python-pygame python-tldextract qbittorrent qt6-wayland qt6ct-kde readest rebuild-detector reflector reflector-simple resvg rmpc-git rofi rog-control-center rose-pine-cursor rsync rtkit ryujinx-canary s-nail sassc sg3_utils shader-slang shell-color-scripts-git showtime smartmontools sof-firmware squashfs-tools starship steam stow stress sudo superfile supergfxctl sushi swaync swi-prolog swig switcheroo-control syncthing sysfsutils sysstat systemd-sysvcompat tcpdump tealdeer telegram-desktop texinfo tftp-hpa timeshift timeshift-autosnap tree tree-sitter-cli ttf-amiri ttf-bitstream-vera ttf-dejavu ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-liberation ttf-ms-fonts ttf-nerd-fonts-symbols ttf-opensans tumbler udiskie unrar unzip upower usb_modeswitch usbutils vlc vorta vulkan-intel vulkan-tools walker waybar-git wget which whois wine-mono wine-staging winetricks wireless-regdb wireplumber wl-clip-persist wlctl-bin woff2-font-awesome wpa_supplicant xdg-desktop-portal xdg-desktop-portal-hyprland xdg-user-dirs xdg-user-dirs-gtk xdg-utils xf86-input-libinput xfsprogs xl2tpd xorg-server xorg-xdpyinfo xorg-xinit xorg-xinput xorg-xkill xorg-xrandr xreader yay yazi yt-dlp zathura zathura-pdf-poppler zen-browser-bin zip zoxide zsh
```

> Note: `accountservice` above should be `accountsservice` — double-check the exact name when re-running, or rely on `pacman -S --needed` and let it correct you.

### B. Your AUR/foreign list (49) — save to `~/migration/pkglist-aur.txt`

```
auto-cpufreq cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist catppuccin-gtk-theme-mocha elephant-bin elephant-bitwarden-bin elephant-calc-bin elephant-clipboard-bin elephant-desktopapplications-bin elephant-files-bin elephant-menus-bin elephant-providerlist-bin elephant-runner-bin elephant-websearch-bin elephant-windows-bin gazelle-tui ghgrab-bin gtk-engine-murrine gtk2 hyprmoncfg leaf-markdown-viewer-bin localsend lrcget-bin maplemono-nf-unhinted maplemono-ttf millennium noctalia-greeter onlyoffice-bin opencode-beta overskride-bin polycat protonup-qt python-gevent-eventemitter python-inputs python-steam qt6ct-kde rmpc-git rose-pine-cursor ryujinx-canary shell-color-scripts-git supergfxctl timeshift-autosnap ttf-amiri ttf-ms-fonts walker waybar-git wlctl-bin zen-browser-bin
```

Remove the `cachyos-*` four before running `paru` on CachyOS (they're native there).

### C. Flatpaks (4)

```
com.github.tchx84.Flatseal
com.stremio.Stremio
com.yacreader.YACReader
io.github.ciromattia.kcc
```

### D. Dotfiles stow packages

```
btop fastfetch hypr kitty leaf mpd noctalia nvim rmpc swaync wal walker waybar yazi zen zsh
```

Clone: `git clone git@github.com:AlyNokrashy/my-dotfiles.git ~/dotfiles`

### E. Quick copy-paste: full restore skeleton

```bash
# --- after CachyOS is installed and you're logged in as aly (uid 1000) ---
sudo pacman -Syu
sudo pacman -S --needed git stow zstd rsync base-devel paru
mountpoint -q /mnt/backup || sudo mount -t ntfs3 -o uid=1000,gid=1000,umask=022 /dev/sdb1 /mnt/backup
sudo mkdir -p ~/Applications ~/.local/bin ~/scripts ~/Pictures/Wallpapers
xdg-user-dirs-update

# packages
cp -a /mnt/backup/cachy-backup/migration ~/migration && cd ~/migration
sudo pacman -S --needed - < pkglist-explicit.cachyos.txt
paru    -S --needed - < pkglist-aur.cachyos.txt

# dotfiles
git clone git@github.com:AlyNokrashy/my-dotfiles.git ~/dotfiles
cd ~/dotfiles && stow btop fastfetch hypr kitty leaf mpd noctalia nvim rmpc swaync wal walker waybar yazi zen zsh

# home data
cd /home && sudo tar --zstd --acls --xattrs --numeric-owner -xpf /mnt/backup/cachy-backup/home-*.tar.zst
sudo chown -R aly:aly /home/aly
cd ~/dotfiles && stow -R btop fastfetch hypr kitty leaf mpd noctalia nvim rmpc swaync wal walker waybar yazi zen zsh

# /etc restore (selective) + services + fstab + linux-cachyos
# ... see Phases J.1–J.5 ...
```
