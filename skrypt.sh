#!/bin/bash

automat=false
dimension=3
next_turn=x
game_state=( . . . . . . . . . )

render() {
    x=0
    echo automat $automat
    echo nastepna tura $next_turn
    for i in $(seq 1 $dimension)
    do
        echo ${game_state[@]:$((dimension*x)):$dimension}
        x=$((x+1))
    done
}

init_game(){
    game_state=( . . . . . . . . . )
    next_turn=x
}

input() {
    echo "od 0 do 8 - stawianie znaku"
    echo "r - reset"
    echo "s - zapis gry"
    echo "l - odczyt gry"
    echo "a - gra z automatem"
    echo "t - gra turowa"
     
    read Input
    
    re='^[0-9]+$'
    if [[ $Input =~ $re ]] ; then
        if [[ $Input -ge 0 ]] && [[ $Input -lt 9 ]]
        then
          put_move $Input  
        fi
    else
        case $Input in
            r) init_game ;;
            s) save ;;
            l) load ;;
            a) init_game
                automat=true;;
            t) init_game
                automat=false;;
        esac
    fi
}

put_move() {
    if [[ ${game_state[$1]} == "." ]]
    then
        game_state["$Input"]=$next_turn
            
        if [ $next_turn == x ]
        then
           next_turn=0
        else
            next_turn=x
        fi
    fi
}

save() {
    echo ${game_state[@]} > save.txt
    echo $next_turn >> save.txt
    echo $automat >> save.txt
}

load(){
    a=0
    while [[ a -eq 0 ]]
    do
        a=1
        read line
        read next_turn
        read automat
    done < save.txt
    
    a=0
    for i in $line
    do
        game_state[$a]=$i
        a=$((a+1))
    done
}

check_row() {
    temp=""
    if [[ ${game_state[$(($1*$dimension))]} == ${game_state[$(($1*$dimension+1))]} ]]
    then
        temp=${game_state[$(($1*$dimension))]}
    else
        echo "."
        return 0
    fi
    if [[ $temp == ${game_state[$(($1*$dimension+2))]} ]]
    then
        echo "$temp"
    else
        echo "."
    fi
}

check_col() {
    temp=""
    if [[ ${game_state[$(($1))]} == ${game_state[$(($dimension+$1))]} ]]
    then
        temp=${game_state[$(($1*$dimension))]}
    else
        echo "."
        return 0
    fi
    if [[ $temp == ${game_state[$((2*$dimension+$1))]} ]]
    then
        echo "$temp"
    else
        echo "."
    fi
}

check_diag() {
    temp=""
    if [[ ${game_state[0]} == ${game_state[4]} ]] && [[ ${game_state[0]} == ${game_state[8]} ]]
    then
        echo ${game_state[0]}
        return 0
    fi
    if [[ ${game_state[2]} == ${game_state[4]} ]] && [[ ${game_state[2]} == ${game_state[6]} ]]
    then
        echo ${game_state[2]}
        return 0
    fi
    
    echo "."
}

check_win() {
    res[0]=$(check_row 0)
    res[1]=$(check_row 1)
    res[2]=$(check_row 2)
    res[3]=$(check_col 0)
    res[4]=$(check_col 1)
    res[5]=$(check_col 2)
    res[6]=$(check_diag)
    
    for i in ${res[@]}
    do
        if [[ $i != "." ]]
        then
            echo $i
            return 0
        fi
    done
    
    echo "."
}

random_move() {
    avail=0
    for i in ${game_state[@]}
    do
        if [ $i == "." ]; then avail=$((avail+1)); fi
    done
    
    if [[ $avail == 0 ]]
    then
        echo No available moves GAME OVER
        read a
        exit
    fi
    
    move=$(($RANDOM % $avail))
    #echo av $avail chosen $move

    
    avail=-1
    current=0
    for i in ${game_state[@]}
    do
        if [[ $i == "." ]] ; then avail=$((avail+1)) ; fi
        if [[ $avail == $move ]] ; then game_state[$current]=0 ; fi
        current=$((current+1))
    done
    
    #read a
}
    
ai() {
    if [[ $next_turn == x ]] ; then return ; fi
    random_move
    next_turn=x
}
    
while [ true ]
do
    render
    input
    
    if [[ $automat == true ]]
    then
        ai
    fi
    
    res=$(check_win)
    clear
    if [[ $res != "." ]]
    then
        render
        echo $res won the game
        echo input to exit
        read a
        exit
    fi
done



