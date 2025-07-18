nimble c --app:lib ^
    --out:dist/pocketsocket.pyd ^
    --threads:on ^
    --tlsEmulation:off ^
    --mm:orc ^
    --skipdeps ^
    --passL:-static src/pocketsocket.nim
rem -d:release ^ -d:useMalloc ^
REM --opt:speed -d:lto -d:strip ^
