# Package
version       = "0.1.0"
author        = "Jay Jagpal"
description   = "websocket server"
license       = "MIT"
srcDir        = "src"
binDir        = "dist"
installExt    = @["nim"]
bin           = @["pocketsocket"]

# Dependencies

requires "nim >= 2.0.2"
requires "nimpy"
requires "ws"
requires "mummy"
requires "docopt"
requires "zippy >= 0.10.9"
requires "webby >= 0.2.1"
requires "crunchy >= 0.1.11"
