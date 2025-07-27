# Package
version       = "2.0.4"
author        = "Strangemother"
description   = "websocket server"
license       = "MIT"
srcDir        = "src"
binDir        = "dist"
installExt    = @["nim"]
namedBin      = {"pocketsocket": "pocketsocket-cli"}.toTable

# Dependencies

requires "nim >= 2.0.2"
requires "nimpy"
requires "ws"
requires "mummy"
requires "docopt"
requires "zippy >= 0.10.9"
requires "webby >= 0.2.1"
requires "crunchy >= 0.1.11"

import std/[os, strutils]

task buildPyd, "build python extension module":
  var (extSuffix, exitCode) = gorgeEx("python3", """
import sysconfig
print(sysconfig.get_config_var("EXT_SUFFIX"))
""")
  stripLineEnd(extSuffix)

  if exitCode != 0:
    raise newException(OSError, "Could not get python native extension suffix")

  switch("out", "python" / "pocketsocket" / "pocketsocket_server" & extSuffix)
  setCommand "c", srcDir / "pocketsocketpkg" / "pocketsocket_server.nim"

task buildCliCI, "build pocketsocket-cli for CI":
  # For simpler logic in CI, tag binary name with target OS and CPU
  switch("out", toExe(binDir / "pocketsocket-cli-" & hostOS & "_" & hostCPU))
  setCommand "c", srcDir / "pocketsocket.nim"
