# MultiSession V2 - REOC client integration

This version incorporates the locally tested MultiSession V2 fix from the REOC 1.10.4 package.

### Cause and correction
V1 reported `DAoC processes found in REOC folder: 0` while two sessions were running. Its process-name prefilter excluded DAoC instances. V2 enumerates executable **image paths** using `QueryFullProcessImageName` with `PROCESS_QUERY_LIMITED_INFORMATION`, then checks exact allowed filenames and the exact launcher-selected client directory.

### Multi-session preflight
- Called from `REOC_Launcher.ps1` before each PLAY, with `-ClientRoot`, `-GameDll`, and `-LogPath`.
- Does nothing if fewer than two matching REOC processes exist.
- Enumerates handles only in the matching client processes.
- Checks the `Mutant` object type and specifically the two mutex names `\\BaseNamedObjects\\DAoCi1` and `\\BaseNamedObjects\\DAoCi2`.
- Uses `DuplicateHandle` / `DUPLICATE_CLOSE_SOURCE` only for matching mutex handles.
- Logs detection, found mutexes and released count under `%LOCALAPPDATA%\\REOC\\Logs`.
- `-DryRun` logs discoveries without closing handles.
- Does not patch `game.dll` or copy Rancha binary files.

### Important restrictions
Never run this helper globally against unrelated processes. It must remain scoped to the exact DAoC client directory. Elevated/non-elevated session mismatches, security software, client versions, and four-plus clients require their own runtime checks. The final ZIP contains the actual, SHA-pinned scripts; the Git repository hosts update metadata and release notes, not the ZIP payload.

### Validation record
- V1 logged zero clients on 22 Oct 2026 with two visible DAoC sessions.
- V2 user confirmed: "ça marche" after installing detection fix.
