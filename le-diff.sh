#!/bin/sh

# Skript pro projekt 1 predmetu IOS, 2013
# Autor: Josef Karasek, xkaras27
# Nazev skriptu: le-diff.sh
# Posledni uprava: 21. 3. 2013

arg()
{    
    for f in "$@"
    do
        to_diff=`echo "$f" | grep -v "^[\.]" | grep -E -v -f .ignore_list`
        if [ "$to_diff" == "" ];then
            continue
        fi
        FINAL_PATH="$PROJDIR/$to_diff"

#             Hledani souboru v aktualnim adresari => EXPCOPY
            if [ -f "$f" ]; then
                # Hledani souboru v projdir
                if [ -f "$FINAL_PATH" ];then
                    # EXISTUJE V OBOU
                    DIFF=`diff -u "$FINAL_PATH" "$f"`
                    if [ "$DIFF" != "" ];then 
                        diff -u "$FINAL_PATH" "$f" 2> /dev/null
                    else
                        echo ".: $f"
                    fi
                else
                    # EXISTUJE POUZE V EXPCOPY
                    echo "D: $f"
                fi
            else
                if [ -f "$FINAL_PATH" ];then
                    # EXISTUJE POZE V PROJDIR
                    echo "C: $f"
                else
                    echo "Soubor '$f' nebyl nalezen" >&2
                fi
            fi
    done
}


no_arg()
{
    ls -l | grep "^[-]" | sed -n 's/^.*:[0-9][0-9] //p' > .LOCAL
    ls -l "$PROJDIR" | grep "^[-]" | sed -n 's/^.*:[0-9][0-9] //p' > .DISTANCE
    grep -v -f .LOCAL .DISTANCE | grep -E -v -f .ignore_list | while read f
    do
        echo "C: $f"
    done
    grep -v -f .DISTANCE .LOCAL | grep -E -v -f .ignore_list | while read f
    do
        echo "D: $f"
    done
    grep -f .DISTANCE .LOCAL | grep -E -v -f .ignore_list > .AUX
    grep -f .AUX .DISTANCE > .MATCH
    rm .DISTANCE 2> /dev/null
    rm .LOCAL 2> /dev/null
    rm .AUX 2> /dev/null
    
    cat .MATCH | while read i
    do
        FINAL_PATH=`echo "$PROJDIR/$i"`
        testovaci=`diff -u "$FINAL_PATH" "$i"`
        if [ -z $testovaci ];then
            echo ".: $i"
        else
            diff -u "$FINAL_PATH" "$i"
        fi
    done
    rm .MATCH 2> /dev/null
}

if [ -f ./.le/.config ] && [ -r ./.le/.config ]; then
    PROJDIR=`sed -n "s/^projdir //p" ./.le/.config`
    if [ -d "$PROJDIR" ];then
        sed -n "s/^ignore //p" ./.le/.config  > .ignore_list
            
        ########################################          
        # Volani funkci
        if [ $# -eq 0 ];then
            no_arg
        else
            arg "$@"
        fi
        ########################################
        rm .ignore_list 2> /dev/null
    else
        echo "Cesta k projdir je neplatna" >&2
    fi
else
    echo "Nemuzu najit cestu k projdir" >&2
fi    