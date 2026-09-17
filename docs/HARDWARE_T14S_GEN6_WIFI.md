# Lenovo ThinkPad T14s Gen 6 AMD Wi-Fi compatibility

This document records a hardware- and network-specific Wi-Fi performance issue
observed under OBLinux Arch and the workaround that was validated in the test
environment. It does not establish the underlying root cause or define an
OBLinux system default.

## Hardware and test environment

| Item | Observed value |
|---|---|
| System | Lenovo ThinkPad T14s Gen 6 AMD |
| Wireless adapter | MediaTek MT7925 802.11be 160 MHz 2x2 PCIe Wireless Network Adapter; MediaTek Filogic 360 |
| PCI ID | `14c3:7925` |
| Lenovo subsystem ID | `17aa:e025` |
| Kernel driver | `mt7925e` |
| Kernel module | `mt7925e` |
| Access point environment | Wi-Fi 7 capable |

## Observed problem

Wi-Fi connectivity was unstable under OBLinux Arch. The laptop was observed
associating on the 6 GHz band; one observed association used 6855 MHz,
channel 181, with signal reported at approximately 75–78.

The primary performance symptom was severely degraded upload throughput
compared with download throughput. Initial measurements included approximately:

- 302.92 Mbps download and 22.99 Mbps upload
- 360 Mbps download and 40 Mbps upload

These results are observations from this specific hardware and access point
environment, not a general MT7925 performance claim.

## Power-management troubleshooting

Identify the wireless interface before substituting it for `<interface>`:

```bash
iw dev | grep Interface
```

Disable Wi-Fi power saving temporarily:

```bash
sudo iw dev <interface> set power_save off
```

Verify the current state:

```bash
iw dev <interface> get power_save
```

Expected result:

```text
Power save: off
```

For the tested `OBNET` NetworkManager profile, the persistent setting was:

```bash
sudo nmcli connection modify "OBNET" 802-11-wireless.powersave 2
```

Disabling power saving alone did not resolve the poor upload performance.

## Validated 5 GHz workaround

The validated workaround was to force the connection to the 5 GHz band and
pin the NetworkManager profile to a known-good 5 GHz access point BSSID:

```bash
sudo nmcli connection modify "OBNET" 802-11-wireless.band a
sudo nmcli connection modify "OBNET" \
  802-11-wireless.bssid 28:94:01:5C:39:6C
```

Reconnect the profile:

```bash
sudo nmcli connection down "OBNET"
sudo nmcli connection up "OBNET"
```

Verify the stored profile settings:

```bash
nmcli connection show "OBNET" | grep -E '802-11-wireless\.(band|bssid|channel)'
```

The observed stored values were:

```text
802-11-wireless.band:                   a
802-11-wireless.channel:                0
802-11-wireless.bssid:                  28:94:01:5C:39:6C
802-11-wireless.channel-width:          0 (auto)
```

The command below continued to display an apparent active 6 GHz entry even
after the workaround was applied:

```bash
nmcli -f IN-USE,SSID,BSSID,FREQ,CHAN,RATE,SIGNAL dev wifi
```

In this Wi-Fi 7/MLO case, that output was misleading for determining the
actual active link. `iw dev` provided the authoritative kernel-level
association details:

```bash
iw dev
```

Observed result:

```text
Interface wlan0
  ssid OBNET
  type managed
  MLD with links:
    - link ID 1
      channel 153 (5765 MHz), width: 80 MHz, center1: 5775 MHz
      txpower 30.00 dBm
```

This confirmed that the active link was 5 GHz, channel 153, at 5765 MHz,
using an 80 MHz channel width and 30 dBm TX power.

## Performance after the workaround

The Ookla Speedtest client reported the following after the connection was
pinned to the known-good 5 GHz BSSID:

- Download: 587.05 Mbps
- Upload: 521.83 Mbps

This was a major improvement over the observed 6 GHz results and validated
the workaround in the test environment.

## Interpretation

Testing strongly isolated the problem to the 6 GHz / Wi-Fi 7 path on this
hardware and network environment, but it did not prove the exact root cause.
This must not be described as a confirmed `mt7925e` driver bug. Possible
contributing components include:

- the `mt7925e` kernel driver;
- MediaTek firmware;
- NetworkManager;
- Wi-Fi 7 / MLO behavior; and
- access point interoperability.

The 5 GHz workaround is therefore considered validated, while the underlying
root cause remains undetermined.

## Scope and safety

The BSSID `28:94:01:5C:39:6C` is specific to the test environment. It must not
be hard-coded into OBLinux defaults or distributed globally. Other users must
identify an appropriate local 5 GHz BSSID before applying a similar workaround.

List nearby candidates with:

```bash
nmcli -f IN-USE,SSID,BSSID,FREQ,CHAN,RATE,SIGNAL dev wifi
```

5 GHz entries normally show frequencies in the 5xxx MHz range. Confirm the
actual active association with `iw dev`, particularly in a Wi-Fi 7/MLO
environment.

Locking a profile to one BSSID disables normal roaming to other access points.
Apply this workaround only when necessary and with a BSSID appropriate to the
local network.

## Rollback

Return the `OBNET` profile to automatic BSSID and band selection:

```bash
sudo nmcli connection modify "OBNET" 802-11-wireless.bssid ""
sudo nmcli connection modify "OBNET" 802-11-wireless.band ""
```

If needed, restore NetworkManager's default Wi-Fi power-save handling:

```bash
sudo nmcli connection modify "OBNET" 802-11-wireless.powersave 0
```

Reconnect the profile:

```bash
sudo nmcli connection down "OBNET"
sudo nmcli connection up "OBNET"
```

## Reference

- [Lenovo ThinkPad T14s (AMD) Gen 6 — ArchWiki](https://wiki.archlinux.org/title/Lenovo_ThinkPad_T14s_(AMD)_Gen_6)

The ArchWiki page is provided as general model-specific context. It does not
document or substantiate the specific MT7925 6 GHz throughput observations
recorded here.
