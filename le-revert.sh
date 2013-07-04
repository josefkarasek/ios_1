#!/bin/sh

# Skript pro projekt 1 predmetu IOS, 2013
# Autor: Josef Karasek, xkaras27
# Nazev skriptu: le-revert.sh
# Posledni uprava: 21. 3. 2013

no_arg()
{
    find ./.le -maxdepth 1 ! -iname '.*' -type f | grep -v "~$" | while read f
    do
        if [ -f "$f" ] ;then
            to_copy=`echo "$f" | grep -E -v -f ignore_list`
            cp "$to_copy" . 2> /dev/null
        fi
    done
}

arg()
{
    for i in "$@"
    do
        ignore=`echo "$i" | grep -v "^[\.]"`
        if [ "$ignore" == "" ];then
            continue
        fi
        if [ -f "./.le/$i" ] ;then
            to_copy=`echo "$i" | grep -v "^[\.]" | grep -E -v -f ignore_list | awk '{print "'./.le'/"$0}'`
            cp "$to_copy" . 2> /dev/null;true
        else
            echo "Soubor '$i' se v adresari nenachazi" >&2
        fi
    done
}

# Rizeni programu:
#    Pokud slozka .le existuje...
if [ -d ./.le ];then
    # ...provede se pokus o nacteni ignore udaju
    if [ -f ./.le/.config ] && [ -r ./.le/.config ];then
        sed -n "s/^ignore //p" ./.le/.config  > ignore_list 
    else
        touch ignore_list
    fi
    # ...rozdeleni toku programu:
    if [ $# -eq 0 ] ;then
        no_arg
    else
        arg "$@"
    fi
    rm ignore_list 2> /dev/null
else
    echo 'Adresar .le nebyl nalezen' >&2
fi