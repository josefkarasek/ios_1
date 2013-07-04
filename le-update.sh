#!/bin/sh

# Skript pro projekt 1 predmetu IOS, 2013
# Autor: Josef Karasek, xkaras27
# Nazev skriptu: le-update.sh
# Posledni uprava: 21. 3. 2013

arg()
{
    for i in "$@"
    do
        ignore=`echo "$i" | grep -v "^[\.]" | grep -E -v -f .ignore_list`
        if [ "$ignore" == "" ];then
            continue
        fi

        exp_le=false
        
        LE=`echo "./.le/$i"`
        PROJ=`echo "$PROJDIR/$i"`
    
        
        # EXISTUJE V EXP_COPY
        if [ -f "$i" ];then
            # EXISTUJE V .le
            if [ -f "$LE" ];then
                if diff "$i" "$LE" > /dev/null ;then
                    exp_le=true
#                     echo "Experimentalni a .le se NElisi." 1>&2
#                 else
#                     echo "Experimentalni a .le se lisi." 1>&2
                fi
                # EXISTUJE V PROJDIR
                if [ -f "$PROJ" ];then
                    if diff "$i" "$PROJ" > /dev/null ;then
                        if [ $exp_le == true ];then
                            echo ".: $i"                                                    # 1
                        else
#                             echo "Experimentalni a PROJDIR jsou shodne, ale .le neni." 1>&2
                            echo "UM: $i"                                                   # 3
                        fi
                    else
#                         echo "Experimentalni a PROJDIR se lisi" 1>&2
                        if diff "$PROJ" "$LE" > /dev/null ;then
                            echo "M: $i"                                                    # 2
                        else
                            if [ $exp_le == false ];then
#                                 echo "EXP != PROJDIR != .le"  1>&2                                   # 5

                                diff -u "./.le/$i" "$PROJ" > x.diff
                                patch "$i" < x.diff > /dev/null 2>&1
                                if [ $? -eq 0 ];then
#                                     patch "$i" < x.diff > /dev/null 2>&1
                                    echo "M+: $i" 
                                    cp "$PROJ" ./.le/ 2> /dev/null
                                else
                                    echo "M!: $i conflict!"
                                fi
                                rm x.diff 2> /dev/null
                                rm "$i.rej" 2> /dev/null
                                rm "$i.orig" 2> /dev/null
                            else
                                echo "U: $i"                                                    # 4
                                cp "$PROJ" . 2> /dev/null
                                cp "$PROJ" ./.le 2> /dev/null
                            fi
                        fi
                    fi
#                 else
#                     echo "Hledany soubor '$i' v PROJDIR neni." 1>&2
                fi  
#             else
#                 echo "Hledany soubor '$i' v .le neni." 1>&2
            fi
         else
#             echo "Hledany soubor '$i' v Experimentalni neni." 1>&2
            if [ -a "$PROJ" ];then
                echo "C: $i"                                                                # 6
                cp "$PROJ" . 2> /dev/null
                cp "$PROJ" ./.le 2> /dev/null
            fi
        fi
        
        if [ -f "$LE" ];then
            if ! [ -f "$PROJ" ]; then
#                 echo "Je v .le a neni v PROJDIR" 1>&2                                        # 7
                echo "D: $i"
                rm "$LE" 2> /dev/null
                if [ -f "$i" ];then
                    rm "$i" 2> /dev/null
                fi
            fi
        fi
        
    done
}

no_arg()
{
    ls -l | grep "^[-]" | grep -v "~$" | sed -n 's/^.*:[0-9][0-9] //p' > .LOCAL
    ls -l ./.le | grep "^[-]" | grep -v "~$" | sed -n 's/^.*:[0-9][0-9] //p' > .REF
    ls -l "$PROJDIR" | grep "^[-]" | grep -v "~$" | sed -n 's/^.*:[0-9][0-9] //p' > .SHARED
    
    grep -f .LOCAL .REF > .AUX
    grep -v -f .LOCAL .REF >> .AUX
    grep -v -f .REF .LOCAL >> .AUX
    
    grep -f .SHARED .AUX > .CONTENT
    grep -v -f .SHARED .AUX >> .CONTENT
    grep -v -f .AUX .SHARED >> .CONTENT
    cat .CONTENT | grep -E -v -f .ignore_list > .FINAL
#     grep -v -f .ignore_list .CONTENT > .FINAL
    
    rm .LOCAL 2> /dev/null
    rm .REF 2> /dev/null
    rm .SHARED 2> /dev/null
    rm .AUX 2> /dev/null
    rm .CONTENT 2> /dev/null
    
    while read i
    do
        ignore=`echo "$i" | grep -v "^[\.]"`
        if [ "$ignore" == "" ];then
            continue
        else
            arg "$i"
        fi
    done < .FINAL
    rm .FINAL 2> /dev/null
}

# Nalezeni cesty ke sdilenemu adresari
if [ -f ./.le/.config ] && [ -r ./.le/.config ];then
    PROJDIR=`sed -n "s/^projdir //p" ./.le/.config`
    # Nalezeni sdileneho adresare
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
        echo "Cesta k projdir je neplatna" 1>&2
    fi
else
    echo "Nemuzu najit cestu k projdir" 1>&2
fi