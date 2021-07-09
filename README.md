# Prototype

## Installing OPAM

```
sudo apt install opam
opam init
eval `opam config env`
opam switch 4.11.2
eval `opam config env`
```

## Installing Cduce

```
sudo apt install m4
```
Refer to http://www.cduce.org/ to build version 0.7.0-rc10


## Building the prototype

```
cd Prototype/src
opam install dune
eval $(opam env)
opam install ppx_deriving menhir pomap
make
```

