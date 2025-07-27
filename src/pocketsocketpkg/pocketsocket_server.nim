#[
  The primary interface for the pocketsocket app, connecting to the ingress
  and service.
]#

# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import nimpy
import nimpy/py_lib as lib
import service
import hook
import mummy


proc hook*(p: PyObject): int {.exportpy.} =
  # Keep the function as the callable.
  hook.hook(p)


proc send_all*(etype: MessageKind, data: string, origin_uuid: PyObject): int {.exportpy.} =
  #[ send data:String of type:Message, originating from the uuid ]#
  echo "-- nim - Send all: ", type(origin_uuid), ", ", $origin_uuid
  var uuid: uint64 = 0
  if cast[pointer](origin_uuid) != cast[pointer](lib.pyLib.Py_None):
    # We have a uuid.
    uuid = origin_uuid.to(uint64)
  return service.send_all(etype, data, uuid)


proc send*(uuid: PyObject, etype: MessageKind, data: string): int {.exportpy.} =
  # Keep the function as the callable.
  # case kind:
  # of TextMessage:
  #   encodedFrame.buffer1 = encodeFrameHeader(0x1, data.len)
  # of BinaryMessage:
  #   encodedFrame.buffer1 = encodeFrameHeader(0x2, data.len)
  # of Ping:
  #   encodedFrame.buffer1 = encodeFrameHeader(0x9, data.len)
  # of Pong:
  #   encodedFrame.buffer1 = encodeFrameHeader(0xA, data.len)
  echo "-- nim - Send to: ", type(uuid), ", ", $uuid
  return service.send(uuid.to(uint64), etype, data)


proc run_blocking_server*(address: string = "127.0.0.1", port: int = 8090): void {.exportpy.} =
  service.run_blocking_server(address, port)


proc shutdown_server*(): void {.exportpy.} =
  service.shutdown_server()
