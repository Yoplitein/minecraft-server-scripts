#!/bin/bash
#Generates a patch of config/ against config-original/ for files whitelisted in patched-config.txt

files=(`cat patched-config.txt`)
out=out.patch

truncate -s 0 $out

for index in `seq 0 $((${#files[@]} - 1))`; do
    if [ $index -gt 0 ]; then
        echo `head -c 25 /dev/zero | tr '\0' '-/'`
    fi
    
    file="${files[$index]}"
    bits=(config{-original,}/$file)
    old="${bits[0]}"
    new="${bits[1]}"
    
    if [ ! -e $old ]; then
        old=/dev/null
    fi
    
    if [ ! -e $new ]; then
        echo "Error: file $new does not exist"
        exit 1
    fi

    ls -lh $old $new
    git diff --no-index $old $new >> out.patch
done

sed -i 's/config-original/config/g' $out
