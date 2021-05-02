#!/bin/bash

function quick() {
	local list=("$@")
	local listLen="${#list[@]}"
	local position=0
	if (( listLen == 2 ))
	then
		if (( list[0] > list[1] ))
		then
			read -r -a list <<<"${list[1]} ${list[0]}"

		fi
	elif (( listLen > 2 ))
	then
		for (( i=1; i < listLen; i++ ))
		do
			if (( list[i] <= list[0] ))
			then
				(( position++ ))
				temp=${list[${i}]}
				list[${i}]=${list[${position}]}
				list[${position}]=${temp}
			fi
		done
		temp=${list[0]}
		list[0]=${list[${position}]}
		list[${position}]=${temp}
		read -r -a list <<<"$( quick "${list[@]:0:((position))}") ${list[${position}]} $(quick "${list[@]:((position + 1)):((listLen - position))}")"
	fi
	echo "${list[@]}"
}

if [[ $# -eq 0 ]]
then
	echo -n "Enter list of numbers: "
	read -r -a array
else
	array=("$@")
fi

printf "%s sorted is %s\n" "${array[*]}" "$(quick "${array[@]}")"
