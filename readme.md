# Readme

## Dev Notes


### Memory Leak for incoming sockets

All sockets leak for ingress. With `-d:useMalloc` the leak is 4KB. Without the switch, the leak is near `~40KB`.

#### Issue:

    https://github.com/nim-lang/Nim/issues/24693
    https://github.com/nim-lang/Nim/pull/24701
    https://github.com/nim-lang/Nim/issues/22510

#### Solution

Partial fix until Nim 2.0 is changed will reduce the overhead:

        --mm:arc
        -d:useMalloc