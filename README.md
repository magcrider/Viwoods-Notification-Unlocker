
---

# 📬 Viwoods Notification Unlocker

**Magisk module to enable notifications for all apps on the Viwoods Reader**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![Magisk](https://img.shields.io/badge/Magisk-Compatible-00B39B.svg)](https://github.com/topjohnwu/Magisk)

> Unlock system-blocked notifications on the Viwoods Reader.
> This module removes the hardcoded notification whitelist present in **Viwoods firmware**, allowing **all apps** to post notifications normally.

---

## 💖 Support the Project

If this module saved you time or frustration, consider supporting development:

<p align="center">
  <a href="https://buymeacoffee.com/ScreenSensitive" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="50">
  </a>
</p>

---

## 📱 Compatibility

### ✅ Tested

* **Device:** Viwoods Reader
* **Firmware:** Viwoods software **1.1.0**

### ⚠️ Untested

* Other Viwoods devices
* Other firmware versions

> **Important:** This module is verified **only on Viwoods firmware 1.1.0**.
> Other versions may have different code paths or offsets.

---

## 🔍 Background

The Viwoods Reader blocks notifications using a **hardcoded application whitelist** inside the system services code.
The check lives in `services.jar` (specifically `classes2.dex`) and drops notifications from non-whitelisted apps before they are posted, even when notification permissions are enabled.

### Technical Context

* **File:** `/system/framework/services.jar`
* **DEX:** `classes2.dex`
* **Class:** `com.android.server.notification.NotificationManagerService`
* **Method:** `enqueueNotificationInternal()`

---

## ✅ What This Module Does

This Magisk module **patches `classes2.dex` inside `services.jar` systemlessly** to disable the notification whitelist check.

### Patch Summary

* Disables the notification whitelist check
* Allows all applications to post notifications
* Applied systemlessly via Magisk
* Fully reversible by removing the module

---

## 📦 Installation

### Requirements

* **Unlocked bootloader**
* **Root access via Magisk**

  * Root **requires patching `init_boot.img`** using the Magisk app
* Viwoods firmware **1.1.0**

### Steps

1. Download the module `.zip` from **Releases**
2. Open **Magisk → Modules**
3. Select **Install from storage**
4. Choose the downloaded `.zip`
5. Reboot

---

## ⚡ Recommended [![Download inkOS](https://img.shields.io/badge/Download-inkOS-brightgreen?style=flat\&logo=android)](https://github.com/gezimos/inkOS/releases/latest)

Since the Viwoods Reader **lacks a native pull-down notification tray**, it is **recommended to use [inkOS](https://github.com/gezimos/inkOS)** — a minimalist, **eink‑friendly Android launcher with notification tray support**.
*Provides a gesture assignable notification tray while native pop-ups continue to work without it.*

---

## 🗑️ Uninstallation

1. Open **Magisk**
2. Navigate to **Modules**
3. Remove **Viwoods Notification Unlocker**
4. Reboot

---

## ⚠️ Warnings & Notes

* Designed specifically for the **Viwoods Reader firmware 1.1.0**
* OTA updates may overwrite or invalidate the patch
* Low-level system service modification — proceed at your own risk

---

## 🔧 Technical Notes

* Systemless patch of `services.jar` (`classes2.dex`)
* SELinux enforcing compatible
* No permanent system partition changes
* Safe to remove at any time

---

## ⚖️ Disclaimer

This module is provided **"AS IS"**.
By installing it, you acknowledge that you are responsible for any consequences, including but not limited to:

* Bricked devices
* Bootloops
* Loss of data
* Voided warranties

The author is **not responsible** for any damage resulting from the use of this module. Use at your own risk.

---

## 📄 License

MIT License — free to use, modify, and redistribute.

---

## ⭐ Support & Feedback

If this module helped you:

* ⭐ Star the repository
* 🐞 Open an issue for firmware changes or breakage
* ☕ Support development via Buy Me a Coffee

---
