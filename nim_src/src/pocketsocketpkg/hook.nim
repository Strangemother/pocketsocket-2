import os
import std/strutils, std/hashes, std/locks, std/tables

import mummy
import nimpy
import nimpy/py_lib as lib


proc call_py_hook(
  websocket: WebSocket,
  event: WebSocketEvent,
  message: Message
): int =
  result = 0
  if pyHook != nil:
    let info:PyObject = pyHook.callObject(cast[uint64](hash(websocket)), event, message)
    if cast[pointer](info) != cast[pointer](lib.pyLib.Py_None):
      # echo "Given: ", $info
      result = info.to(int)
    discard info
