@echo off
del loser.com
tasm /m3 main.asm
tlink /3 /t /x main.obj
del main.obj
post main.com
ren main.com loser.com
