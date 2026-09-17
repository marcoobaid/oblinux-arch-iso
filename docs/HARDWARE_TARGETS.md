# Hardware targets and compatibility notes

OBLinux does not claim a broad hardware support matrix. This index records
hardware that has received project-specific testing and links to detailed notes
where a limitation or workaround was observed. Results apply to the documented
test environment unless stated otherwise.

| Hardware | Tested area | Status and notes |
|---|---|---|
| Lenovo ThinkPad T14s Gen 6 AMD | MediaTek MT7925 (`14c3:7925`), `mt7925e` Wi-Fi | 6 GHz association showed instability and severe upload degradation in the tested Wi-Fi 7 environment. A 5 GHz BSSID workaround was validated; the underlying cause remains undetermined. See [Wi-Fi compatibility details](HARDWARE_T14S_GEN6_WIFI.md). |

Historical BIOS/UEFI, live-boot, and installation test results remain in
[`TESTING.md`](TESTING.md).
