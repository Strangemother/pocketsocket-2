# This is just an example to get you started. Users of your hybrid library will
# import this file by writing ``import nimsockpkg/submodule``. Feel free to rename or
# remove this file altogether. You may create additional modules alongside
# this file as required.

import dynlib
import std/files
import std/paths
import os

# Make a function prototype
type
  updateProc = proc () {.nimcall.}

var
  dll: LibHandle      # Library that's loaded
  update: updateProc  # Function to call, and reload
  loaded_template_str: string


proc getWelcomeMessage*(): string =
    let filepath_str = "banner.txt"
    let base_dir = os.getCurrentDir()
    # let base_dir = getAppDir()
    let filepath = Path(base_dir) / Path(filepath_str)

    if loaded_template_str != nil:
      return loaded_template_str
    else:
      echo "Template String is nil: ", loaded_template_str ,". Discovering: ", cast[string](filepath)
      if fileExists(filepath):
          result = readFile(cast[string](filepath))
          # result = readAll(filepath_str)
      else:
          result = "Hello, World!"


proc getLocalFileContents*(filepath_str:string, base_dir=os.getCurrentDir()): string =
    # let filepath_str = "banner.txt"
    # let base_dir = os.getCurrentDir()

    let filepath = Path(base_dir) / Path(filepath_str)
    echo "Discovering: ", cast[string](filepath)
    if fileExists(filepath):
        return readFile(cast[string](filepath))
        # result = readAll(filepath_str)
    let default_template_value: string = """<body onload="ws=new WebSocket('ws://'+location.host).onmessage=e=>document.body.innerHTML=e.data" style="background:#111;color:#ccc"></body>"""
    return default_template_value


proc getCachedLocalFileContents*(filepath_str:string, base_dir=os.getCurrentDir()): string =

  #https://forum.nim-lang.org/t/9379
  {.cast(gcsafe).}:
    if loaded_template_str != nil:
      return loaded_template_str
    else:
      echo "Template String is nil: ", loaded_template_str ,". Discovering: ", filepath_str
      return getLocalFileContents(filepath_str, base_dir)


proc setLoadedTemplate*(filepath_str:string): void =
  loaded_template_str = getLocalFileContents(filepath_str)
  echo "Template Set. Length: ", $loaded_template_str.len


proc load_lib*() =
    let base_dir = os.getCurrentDir()
    # let base_dir = getAppDir()
    let filepath = Path(base_dir) / Path("lib/imp.dll")
    let func_name: string = "greet"
    echo "Load ", cast[string](filepath)
    dll = loadLib(cast[string](filepath))   # Change this for your OS
    if dll != nil:
      # Get the address where the `update()` proc is stored
      let updateAddr = dll.symAddr(cstring(func_name))
      if updateAddr != nil:
        update = cast[updateProc](updateAddr)
    # Run it
    if update != nil:
      update()
    else:
      echo "Wasn't able to load ", func_name ,"() from DLL."