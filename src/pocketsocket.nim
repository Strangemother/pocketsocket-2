# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.
let doc = """
pocketsocket run

Usage:
  pocketsocket --run
  pocketsocket --run --broadcast
  pocketsocket --run --print
  pocketsocket (-h | --help)
  pocketsocket --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --run         Run the server.
  --broadcast   Auto broadcast mode
  --print       Echo connect updates to the stdout
"""

# import strutils
import docopt
import pocketsocketpkg/service

let args = docopt(doc, version = "PocketSocket 0.1")

if args["--broadcast"]:
    echo "Applying broadcast mode"
    service.set_broadcast_mode(true)

if args["--print"]:
    echo "Applying print mode"
    service.set_print_mode(true)

if args["--run"]:
  echo "Run"
  service.poke_wake_time()
  service.run_blocking_server()