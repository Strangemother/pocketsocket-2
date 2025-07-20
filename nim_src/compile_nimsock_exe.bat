nimble c --app:console ^
    --out:dist/pocketsocket-cli.exe ^
    --threads:on ^
    --tlsEmulation:off ^
    -d:release ^
    --opt:size -d:lto -d:strip ^
    --mm:arc ^
    -d:useMalloc ^
    --passL:-static src/pocketsocket_cli.nim
