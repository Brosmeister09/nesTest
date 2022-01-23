#!/bin/sh
ca65 test.s -o test.o -t nes --debug-info
ld65 test.o -o test.nes -t nes --dbgfile test.dbg
fceux test.nes