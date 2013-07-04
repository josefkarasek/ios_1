#!/bin/sh

# Skript pro projekt 1 predmetu IOS, 2013
# Autor: Josef Karasek, xkaras27
# Nazev skriptu: le-checkout.sh
# Posledni uprava: 21. 3. 2013


if [ $# -eq 0 ]; then
    printf "Nebyl zadan argument\nPriklad spusteni: le-checkout.sh /path/to/shared_dir\n" >&2
    exit 1
fi

if ! [ -d "$1" ]; then
    printf "Zadana cesta '$1' je neplatna\n" >&2
    exit 1
fi

touch .ignore_list

if [ -d ./.le ]; then
    if [ -f ./.le/.config ] && [ -r ./.le/.config ] ;then
        sed -n "s/^ignore //p" ./.le/.config  > .ignore_list 
    fi
    # ...smazou se vechny viditelne soubory v adresari .le
    
    find ./.le -maxdepth 1 ! -iname '.*' -type f | while read f
    do
        to_remove=`echo "$f" | grep -E -v -f .ignore_list`
        rm "$to_remove" 2> /dev/null
    done
else
    mkdir .le
fi

if [ -d "$1" ]; then
     find "${1}" -maxdepth 1 ! -iname '.*' -type f | while read f
     do
         to_copy=`echo "$f" | grep -E -v -f .ignore_list`
         cp "$to_copy" . 2> /dev/null
         cp "$to_copy" ./.le 2> /dev/null
     done
else
    echo "Zadana cesta '$1' je neplatna." >&2
fi
rm .ignore_list 2> /dev/null

# Pridani cesty projdir do .config
if [ -f ./.le/.config ]; then
    if [ -w ./.le/.config ]; then
        testovaci=`grep "^projdir" ./.le/.config`
        if [ -n "$testovaci" ]; then
            sed -i'' -e "/^projdir.*/d" ./.le/.config
            echo "projdir $1" >> ./.le/.config
        else
            echo "projdir $1" >> ./.le/.config
        fi
    else
        printf "Nemam prava zapisovat do .config\n" >&2
    fi
else
    echo "projdir $1" > ./.le/.config
fi
true