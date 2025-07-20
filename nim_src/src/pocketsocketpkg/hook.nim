import std/hashes

import mummy
import nimpy
import nimpy/py_lib as lib

var
  pyHook: PyObject

proc call_py_hook*(
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


proc hook*(p: PyObject): void =
  #[
    The exposed hook proc accepts a python _callable_, called upon
    message events.
  ]#
  # Keep the function as the callable.
  pyHook = p
