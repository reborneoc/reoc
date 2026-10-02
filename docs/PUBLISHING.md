# Publishing REOC updates

1. Prepare a cumulative `payload` folder containing the complete set of files managed by REOC.
2. Run `tools/Build-REOCUpdate.ps1 -PayloadPath <path> -Version X.Y.Z -OutputPath <path>`.
3. Run `tools/Verify-REOCUpdate.ps1 -PackagePath <zip>`.
4. Create a GitHub Release tagged `vX.Y.Z`.
5. Upload `REOC_UPDATE_X.Y.Z.zip` as a release asset.
6. Confirm the release asset URL works.
7. Only then copy the generated `latest.generated.json` to repository root as `latest.json` and commit it.

Never publish an active `latest.json` that points to a missing or unverified release asset.
