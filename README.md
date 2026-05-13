
---

# 📬 Viwoods Notification Unlocker

**Magisk module to restore notifications on the Viwoods AiPaper**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![Magisk](https://img.shields.io/badge/Magisk-Compatible-00B39B.svg)](https://github.com/topjohnwu/Magisk)

---

## ⚠️ DISCLAIMER — READ BEFORE ANYTHING ELSE

**By using this module you accept full responsibility for anything that happens to your device.**

This includes but is not limited to:

- **Bootloops or soft bricks**
- **Complete loss of data**
- **Voided warranty**
- **Device becoming unusable**

The author is **not responsible** for any damage resulting from following this guide. If you are not comfortable recovering a device using `mtkclient` or `fastboot`, **do not proceed**.

---

## ⛔ GOOGLE / FRP WARNING — READ THIS BEFORE UNLOCKING

If you previously enabled Google Play Services on your Viwoods AiPaper, take these steps **before** unlocking the bootloader:

1. Sign out of the Google Play Store
2. Remove all Google accounts from Android Settings (not just the Viwoods UI)
3. Disable the Google Play Services toggle in Viwoods Settings

**Why:** Unlocking the bootloader wipes the device. The Viwoods AiPaper does **not** have a proper Android FRP recovery screen. If a Google account is still linked when you wipe, you may end up FRP-locked with no easy way out.

> **Learned the hard way:** If you do hit FRP after unlocking — enable Google Play Services once, sign into the Play Store, sign back out, remove all Google accounts in Settings, disable Google Play Services again, then factory reset. After that, setup completes normally.

*If you never enabled Google Play Services, you can ignore this.*

---

## 💖 Support the Project

<p align="center">
  <a href="https://ko-fi.com/eymagic" target="_blank">
    <img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Support on Ko-fi" height="50">
  </a>
</p>

---

## 📱 Compatibility

| Firmware | Status |
|----------|--------|
| 1.4.0 | ✅ Tested |
| 1.3.8 | ✅ Tested |
| 1.1.0, 1.2.3 | See [upstream repo](#-attribution) |

> Each firmware version patches different code locations. Use the release matching your firmware exactly.

---

## 🔍 Background

Viwoods firmware silently blocks notifications from most apps using a hardcoded whitelist buried inside the Android system. Apps not on that list are rejected before the notification ever reaches your screen — even if you have granted permissions in Settings.

This module removes that restriction. **Many apps** will work after installing it. Some Google apps (Gmail, GMS-specific flows) still have limitations — see [Known Limitations](#-known-limitations).

For the full technical breakdown: [Technical Analysis](context/ANALYSIS.md) · [Project Context](context/CONTEXT.md)

---

## ✅ What This Module Does

- Removes Viwoods' custom notification blocking from the system
- Lets most third-party apps (WhatsApp, Telegram, etc.) post notifications
- Prevents Viwoods' aggressive background process killer from stopping apps before notifications arrive
- Applied without permanently modifying the system partition (Magisk systemless)
- Fully reversible — remove the module to restore original behavior

---

## 📦 Installation

### 🔒 STEP 0 — FULL BACKUP (MANDATORY)

**Do not skip this.** A full backup is your only reliable recovery method if something goes wrong.

Use [mtkclient](https://github.com/bkerler/mtkclient):

```sh
# Power off device → hold Volume Down → connect USB (BROM mode)
python mtk.py rl backup_folder/ --skip userdata
```

> **BROM mode tip:** Power off completely, then hold **Volume Down** and connect the USB cable. Keep holding until mtkclient shows a connection in the terminal — then release the button (usually 2–3 seconds after connecting). Releasing too early or too late means it won't detect the device.

- Back up **all partitions**
- Store the backup somewhere safe on your PC
- **If you skip this and something breaks, you may lose everything**

---

### 🔓 STEP 1 — Root Your Device

This module requires an unlocked bootloader and Magisk root. If you haven't done this yet, you need to complete that first.

The full rooting process for Viwoods AiPaper is documented by the community — search XDA Forums for the Viwoods Magisk rooting guide. Key requirements:

- **MediaTek drivers** installed on your PC
- **ADB & Fastboot** installed
- **mtkclient** for partition-level operations
- **Magisk** latest stable

> ⚠️ **Enable Google Services BEFORE rooting** — see the FRP warning at the top of this page.

---

### 📲 STEP 2 — Install the Module

1. Download the `.zip` from **[Releases](https://github.com/magcrider/Viwoods-Notification-Unlocker/releases)** — use the version matching your firmware
2. Transfer the ZIP to your device via USB (File Transfer / MTP mode)
3. Open **Magisk → Modules → Install from storage**
4. Select the downloaded ZIP
5. Reboot when prompted

---

### ✔️ STEP 3 — Verify It's Working

After rebooting, send yourself a WhatsApp or Telegram message from another device and confirm the notification appears.

To confirm the patch is active:
```sh
adb logcat | grep "eink"
```
If the module is working, this returns **no output**. If you still see `"eink project,Blocked notification from package:"` lines, the patch is not loading — check the [Installation Guide](context/INSTALLATION.md) for troubleshooting steps.

---

## ⚠️ Known Limitations

- **Google apps (Gmail, GMS):** Some Google notification flows go through a separate code path not yet covered by this patch. Work in progress — tracked in [Project Context](context/CONTEXT.md#outstanding-items)
- **Gmail specifically:** Open Gmail → Menu → Settings → [account] → Notifications → set to **"All new mail"** — this must be done manually regardless of the module
- **Newly installed apps:** Apps installed after the last reboot may need another reboot before the battery optimization bypass takes effect
- **OTA firmware updates:** A Viwoods update will overwrite `services.jar` and disable the patch. Re-install the module after any firmware update

---

## 🗑️ Uninstall

1. Open **Magisk → Modules**
2. Remove **Viwoods Notification Unlocker**
3. Reboot — the original notification whitelist is fully restored

---

## 🙏 Attribution

This module is based on the original work by **ScreenSensitive**:

👉 [ScreenSensitive/Viwoods-Notification-Unlocker](https://github.com/ScreenSensitive/Viwoods-Notification-Unlocker)

The original module supported firmware 1.1.0 and 1.2.3. This fork extends support to 1.3.8 and 1.4.0, adds battery optimization fixes, and documents the additional filter points introduced in newer firmware.

---

## 📄 License

MIT — free to use, modify, and redistribute with attribution.

---
