# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

# import os
import std/hashes, std/locks, std/tables, std/times, std/monotimes
import asyncdispatch
import nimpy
#import terminal
# import nimpy/py_lib as lib
import mummy, mummy/routers
import submodule

import websocket_dispatch

from broadcast import websocketHandler_broadcast
import broadcast
import ingress


var
  lock: Lock # The lock for global memory
  router: Router
  server: Server
  receiveThread: Thread[void]
  pyHook: PyObject
  wake_time: MonoTime = getMonoTime()
  clientSheet: Table[uint64, WebSocket]


# Remember to initialize the lock.
initLock(lock)


proc send_all*(message_kind: MessageKind, message_data: string, exclude_uuid: uint64): int =
  #[ Send a message to _all_ clients. Provide an exclude for ignoring the
    receiver]#
  return websocket_dispatch.send_all(
      clientSheet,
      message_kind,
      message_data,
      exclude_uuid
    )


proc send*(uuid: uint64, message_kind: MessageKind, message_data: string): int =
  #[ Send a message to the target UUID websocket, with the _kind_ being the
     message type, such as 0 for text.

     return int for success - 0 being ok, any other integer representing a
     error code (typically 1)
  ]#
  return websocket_dispatch.send(
      clientSheet,
      uuid,
      message_kind,
      message_data,
  )


proc close_remove_client*(uuid: uint64): void =
  {.gcsafe.}:
    withLock lock:
      let websocket = clientSheet[uuid]
      websocket.close()
      clientSheet.del(cast[uint64](websocket.hash()))
      # echo "Client Sheet Size: ", $clientSheet.len


proc ctrlc() {.noconv.} =
  echo "Ctrl+C fired!"
  server.close()


proc shutdown_server*(): void =
  echo "nim::shutdown_server"
  server.close()


proc poke_wake_time*(): void =
  wake_time = getMonoTime()


proc set_broadcast_mode*(mode:bool): void =
  broadcast.set_broadcast_mode(mode)


proc set_print_mode*(mode:bool = false): void =
  broadcast.set_print_mode(mode)


proc run_blocking_server*(address: string = "127.0.0.1", port: int = 8090): void =
  # if isatty(stdout):
  #   run_blocking_server()
  when isMainModule:
    echo(getWelcomeMessage())
  # load_lib()
  submodule.setLoadedTemplate("./templates/index.html")
  server = newServer(ingress.router, broadcast.websocketHandler_broadcast)
  # server = newServer(router, websocketHandler)
  echo "Serving on http://", address, ":", port
  setControlCHook(ctrlc)
  let total_time: Duration = getMonoTime() - wake_time
  echo "TTL: ", $total_time
  server.serve(Port(port), address)
  echo "Serve complete"
