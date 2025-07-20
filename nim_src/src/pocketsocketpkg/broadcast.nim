import std/locks, std/sets
import std/hashes, std/locks, std/tables
import mummy

import hook
## This example shows a basic chat server over WebSocket.
##
## To try the example, run the server (nim c -r examples/chat.nim)
## then open a few tabs to http://localhost:8080
##
## Each tab can send messages and they'll be received by all tabs.
##
## This file includes the HTML being sent to the client as a string. In a real
## web app, you'd probably have this in a file or served some other way.
## I'm just keeping everything in one file and as simple as possible.

var
  lock: Lock
  clientSheet: Table[uint64, WebSocket]
  clients: HashSet[WebSocket]

initLock(lock)


proc send_all*(message_kind: MessageKind, message_data: string, exclude_uuid: uint64): int =
  #[ Send a message to _all_ clients. Provide an exclude for ignoring the
    receiver]#
  for other_uuid, websocket in clientSheet:
    if other_uuid == exclude_uuid:
      echo "skipping exclude uuid: ", exclude_uuid
      continue
    websocket.send(message_data, message_kind)
  return 0


proc remove_client*(websocket: WebSocket): void =
  {.gcsafe.}:
    withLock lock:
      clientSheet.del(cast[uint64](websocket.hash()))
      # echo "Client Sheet Size: ", $clientSheet.len


var broadcast_mode*:bool = false

proc set_broadcast_mode*(mode:bool = false): void =
  echo "broadcast_mode: ", $mode
  broadcast_mode = mode


proc websocketHandler_broadcast*(
  websocket: WebSocket,
  event: WebSocketEvent,
  message: Message
) =
  var infoInt:int = 0
  case event:
  of OpenEvent:
    # echo websocket, ": connected"
    {.gcsafe.}:
      withLock lock:
        let uuid = cast[uint64](hash(websocket))
        clientSheet[uuid] = websocket
        # echo "Client Sheet Size: ", $clientSheet.len
    discard call_py_hook(websocket, event, message)

  of MessageEvent:
    # let message_data: string = move message.data
    # echo message.kind, ": ", message_data
    # If the python hook returns an int,
    # test the int for force socket closure.
    infoInt = call_py_hook(websocket, event, message)
    {.gcsafe.}:
      withLock lock:
        if broadcast_mode:
          let uuid = cast[uint64](hash(websocket))
          discard send_all(message.kind, message.data, uuid)
    # echo "resp ", type(info), ":", info
    # websocket.send(message_data, message.kind)
  of ErrorEvent:
    echo "Error event occured: ", $event, " : ", $message
    # websocket.close()
    # remove_client(websocket)
    discard call_py_hook(websocket, event, message)

  of CloseEvent:
    echo websocket, ": close"
    # Lock global memory and remove the websocket.
    remove_client(websocket)
    discard call_py_hook(websocket, event, message)

  if infoInt == 1:
    # echo "Drop socket", $websocket
    websocket.close()
    remove_client(websocket)
    discard call_py_hook(websocket, event, message)
