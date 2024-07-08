#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/chrgra/Documenten/kloktijden_pastoriestraat/kloktijden_sync_pastoriestraat
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64       -L. -o /home/chrgra/Documenten/kloktijden_pastoriestraat/kloktijden_sync_pastoriestraat -T /home/chrgra/Documenten/kloktijden_pastoriestraat/link20366.res -e _start
if [ $? != 0 ]; then DoExitLink /home/chrgra/Documenten/kloktijden_pastoriestraat/kloktijden_sync_pastoriestraat; fi
IFS=$OFS
