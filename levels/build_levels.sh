#!/bin/bash
printf "levels:\n" >levels.asm
for file in raw/*
do
base=`basename $file`
zx7b $file $base.zx7
echo "   incbin \"$base.zx7\"" >>levels.asm
echo "$base = $ - 1" >>levels.asm
done
