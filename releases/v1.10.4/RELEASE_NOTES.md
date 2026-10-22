# REOC v1.10.4 - Release preparation

## Changes included in the final cumulative ZIP

- ReShade 6.8.0 x86 silent build via native Direct3D 9; no dgVoodoo wrapper.
- One REOC Enhanced Graphics toggle; keep `BIFROST_GAMING.ini` preset and no ReShade overlay.
- Eight custom REOC loading screens, including revised 002 and 005.
- MultiSession V2: discover DAoC processes using their executable paths rather than the ProcessName prefilter. Limit mutex modifications to REOC client processes and named DAoCi1/DAoCi2 mutex handles.
- Preserve existing multiple active instances by avoiding in-use graphics DLL replacements.
- No Rancha executables, account data or saved credentials bundled.

## Verification

- Release ZIP: `REOC_UPDATE_1.10.4.zip`
- ZIP size: **30,351,166 bytes**
- ZIP SHA-256: `BE730CF2040A3FFD30B255D00FA39AA2F85D9BBEA9688ED932A50D03B3C129EC`
- Cumulative `manifest.json`: **30 payload files**; all size and SHA-256 entries verified.
- `pregame/splash.mpk` SHA-256: `5D436DCE3CB12CB948687938E90995754DA33E17AEAAD0453DCAA7A114821345`
- `REOC/EnhancedGraphics/ReShade32_Silent.dll` SHA-256: `B1F2D851DC6F0C1D6A3CCF586C8FC8EB4910D910961E31AC8DD4A319C86AD320`
- `REOC/REOC_MultiSession.ps1` SHA-256: `AE17F8DE875A4DFF31158D8FF4189D721B26DBB462C7DEB327ADE1BA70DFB8B9`

## Runtime validation

The user reported the third simultaneous DAoC client launches successfully on Windows after MultiSession V2. This validates the tested configuration, **not** all Windows installations or four-plus simultaneous clients.

## Publication sequence (MANDATORY)

1. Create **GitHub Release v1.10.4**.
2. Upload the **exact** `REOC_UPDATE_1.10.4.zip` whose checksum appears above.
3. Verify that the GitHub release asset exists, downloads successfully and matches the SHA-256.
4. **Only after verification**, update the repository root `latest.json` with `releases/v1.10.4/latest.generated.json`.
5. Test the REOC updater on a test installation.

The root `latest.json` MUST keep pointing to 1.10.3 until step 3 succeeds. Client archives belong in GitHub Release assets, not Git history.
