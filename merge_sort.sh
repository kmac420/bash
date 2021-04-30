#!/bin/bash

sorted=()

function merge_sort() {
	list=("$@")
	listLen="${#list[@]}"
	if (( listLen == 1 ))
	then
		echo "${list[0]}"
		return
	else
		midPoint=$((listLen / 2))
		left=()
		right=()
		for (( x=0; x<midPoint; x++))
		do
			left+=("${list[${x}]}")
		done
		for (( y=x; y<listLen; y++))
		do
			right+=("${list[${y}]}")
		done
		read -r -a left <<<"$(merge_sort "${left[@]}")"
		read -r -a right <<<"$(merge_sort "${right[@]}")"
	fi

	leftLen="${#left[@]}"
	rightLen="${#right[@]}"

	while (( leftLen > 0 && rightLen > 0 ))
	do
		if (( left[0] <= right[0] ))
		then
			sorted+=("${left[0]}")
			left=("${left[@]:1}")
			leftLen="${#left[@]}"
		else
			sorted+=("${right[0]}")
			right=("${right[@]:1}")
			rightLen="${#right[@]}"
		fi
	done

	while (( leftLen > 0 ))
	do
		sorted+=("${left[0]}")
		left=("${left[@]:1}")
		leftLen="${#left[@]}"
	done
	while (( rightLen > 0 ))
	do
		sorted+=("${right[0]}")
		right=("${right[@]:1}")
		rightLen="${#right[@]}"
	done
	echo "${sorted[@]}"
}

if [[ $# -gt 0 ]]
then
	list=("$@")
else
	echo -n "Enter a list of numbers separated by spaces: "
	read -r -a list
fi
merge_sort "${list[@]}"
echo "${count}"
