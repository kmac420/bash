#!/usr/bin/bash

# Any live cell with fewer than two live neighbours dies, as if by underpopulation.
# Any live cell with two or three live neighbours lives on to the next generation.
# Any live cell with more than three live neighbours dies, as if by overpopulation.
# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

board=()
debug=0
births=0
deaths=0
borderColor=$(tput setaf 244)
cellColor=$(tput sgr0)

function showUsageAndExit {
	cat << EOF
Usage:	$0 --cols=C|-cC --rows=R|-rR [--help|-h]
    --cols|-c: Number of columns
    --rows|-r: Number of rows
    --weight|-w: Probably of cell starting with life (1-100)
    --help|-h: Display this help information and exit

EOF
	exit
}

function checkNumber {
	local varName=$1
	local varValue=$2
	numReg="^[1-9][0-9]*$"
	if ! [[ ${varValue} =~ ${numReg} ]]
	then
		printf "Error: %s is not a valid number for %s" "${varValue}" "${varName}"
		exit
	fi
}

function generateBoard {
	local numRows=$1
	local numCols=$2
	num=$((numRows * numCols))
	for (( i=0; i<num; i++ ))
	do
		x=$((RANDOM % 100))
		if [[ ${x} -le ${weight} ]]
		then
			board+=(1)
			if [[ ${debug} -eq 1 ]]
			then
				printf "Random number %s is less than or equal to %s\n" "${x}" "${weight}"
			fi
		else
			board+=(0)
			if [[ ${debug} -eq 1 ]]
			then
				printf "Random number %s is greater than %s\n" "${x}" "${weight}"
			fi
		fi
	done
}

function printBoardTopBorder {
	local numCols=$1
	stopper=$((numCols - 1))
	for (( x=0; x<numCols; x++ ))
	do
		if [ "${x}" -eq 0 ]
		then
			printf "${borderColor}\x1b(0\x6c\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
		elif [ "${x}" -eq ${stopper} ]
		then
			printf "${borderColor}\x1b(0\x77\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
			printf "${borderColor}\x1b(0\x6b\x1b(B${cellColor}"
		else
			printf "${borderColor}\x1b(0\x77\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
		fi
	done
	printf "\n"
}

function printBoardBottomBorder {
	local numCols=$1
	stopper=$((numCols - 1))
	for (( x=0; x<numCols; x++ ))
	do
		if [ "${x}" -eq 0 ]
		then
			printf "${borderColor}\x1b(0\x6d\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
		elif [ "${x}" -eq ${stopper} ]
		then
			printf "${borderColor}\x1b(0\x76\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
			printf "${borderColor}\x1b(0\x6a\x1b(B${cellColor}"
		else
			printf "${borderColor}\x1b(0\x76\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
		fi
	done
	printf "\n"
}

function printBoardMiddleBorder {
	local numCols=$1
	stopper=$((numCols - 1))
	for (( x=0; x<numCols; x++ ))
	do
		if [ "${x}" -eq 0 ]
		then
			printf "${borderColor}\x1b(0\x74\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
		elif [ "${x}" -eq ${stopper} ]
		then
			printf "${borderColor}\x1b(0\x6e\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
			printf "${borderColor}\x1b(0\x75\x1b(B${cellColor}"
		else
			printf "${borderColor}\x1b(0\x6e\x1b(B${cellColor}"
			for y in {1..3}
			do
				printf "${borderColor}\x1b(0\x71\x1b(B${cellColor}"
			done
		fi
	done
	printf "\n"
}

function printBoard {
	local numRows=$1
	local numCols=$2
	local iterationCount=$3
	num=$((numRows * numCols))
	rowStopper=$((numRows-1))
	if [[ ${debug} -eq 0 ]]
	then
		clear
	fi
	printf "Iteration number %s: %s deaths, %s births\n" "${iterationCount}" "${deaths}" "${births}"
	printBoardTopBorder "${numCols}"
	for (( i=0; i<numRows; i++ ))
	do
		for (( j=0; j<numCols; j++ ))
		do
			n=$(( ( i * numCols ) + j ))
			local currVal=${board[${n}]}
			if [[ ${j} -eq 0 ]]
			then
				printf "${borderColor}\x1b(0\x78\x1b(B${cellColor}"
			fi
			if [[ ${currVal} -eq 1 ]]
			then
				printf " ${cellColor}\x1b(0\x60\x1b(B "
			else
				printf "   "
			fi
			printf "${borderColor}\x1b(0\x78\x1b(B${cellColor}"
		done
		printf "\n"
		if [ "${i}" -ne ${rowStopper} ]
		then
			printBoardMiddleBorder "${numCols}"
		fi
	done
	printBoardBottomBorder "${numCols}"
	sleep 0.5
}

function iterateBoard {
	local numRows=$1
	local numCols=$2
	local tempBoard=()
	births=0
	deaths=0

	for x in "${!board[@]}"
	do
		rowNum=$((x/numCols))
		colNum=$((x%numCols))
		neighbourCount=0
		if [[ ${rowNum} -gt 0 ]]
		then
			if [[ ${colNum} -gt 0 ]]
			then
				topLeft=$((x-numCols-1))
				neighbourCount=$((neighbourCount+board[topLeft]))
			fi
			top=$((x-numCols))
			neighbourCount=$((neighbourCount+board[top]))
			if [[ ${colNum} -lt $((numCols-1)) ]]
			then
				topRight=$((x-numCols+1))
				neighbourCount=$((neighbourCount+board[topRight]))
			fi
		fi
		if [[ ${colNum} -gt 0 ]]
		then
			left=$((x-1))
			neighbourCount=$((neighbourCount+board[left]))
		fi
		if [[ ${colNum} -lt $((numCols-1)) ]]
		then
			right=$((x+1))
			neighbourCount=$((neighbourCount+board[right]))
		fi
		if [[ ${rowNum} -lt $((numRows-1)) ]]
		then
			if [[ ${colNum} -gt 0 ]]
			then
				bottomLeft=$((x+numCols-1))
				neighbourCount=$((neighbourCount+board[bottomLeft]))
			fi
			bottom=$((x+numCols))
			neighbourCount=$((neighbourCount+board[bottom]))
			if [[ ${colNum} -lt $((numCols-1)) ]]
			then
				bottomRight=$((x+numCols+1))
				neighbourCount=$((neighbourCount+board[bottomRight]))
			fi
		fi
		if [[ ${debug} -eq 1 ]]
		then
			printf "Index: %s, Row: %s, Column: %s, Count: %s\n" "${x}" "${rowNum}" "${colNum}" "${neighbourCount}"
		fi

		# Any live cell with fewer than two live neighbours dies, as if by underpopulation.
		# Any live cell with two or three live neighbours lives on to the next generation.
		# Any live cell with more than three live neighbours dies, as if by overpopulation.
		# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

		currVal=${board[${x}]}
		if [[ ${currVal} -eq 1 ]]
		then
			if [[ ${neighbourCount} -lt 2 ]]
			then
				tempBoard+=(0)
				deaths=$((deaths+1))
				if [[ ${debug} -eq 1 ]]
				then
					printf "Index %s is live but dies\n" "${x}"
				fi
			elif [[ ${neighbourCount} -gt 3 ]]
			then
				tempBoard+=(0)
				deaths=$((deaths+1))
				if [[ ${debug} -eq 1 ]]
				then
					printf "Index %s is live but dies\n" "${x}"
				fi
			else
				tempBoard+=("${currVal}")
				if [[ ${debug} -eq 1 ]]
				then
					printf "Index %s is live and stays the same\n" "${x}"
				fi
			fi
		else
			if [[ ${neighbourCount} -eq 3 ]]
			then
				tempBoard+=(1)
				births=$((births+1))
				if [[ ${debug} -eq 1 ]]
				then
					printf "Index %s is dead but lives\n" "${x}"
				fi
			else
				tempBoard+=("${currVal}")
				if [[ ${debug} -eq 1 ]]
				then
					printf "Index %s is dead and stays the same\n" "${x}"
				fi
			fi
		fi
	done
	board=("${tempBoard[@]}")
}

options=$(getopt --longoptions "help,rows:,cols:,debug,weight:" --options hr:c:dw: -- "$@")

eval set -- "$options"
while true
do
	case $1 in
		--help|-h)
			showUsageAndExit
			break;;
		--rows|-r)
			checkNumber "$1" "$2"
			export rows=$2
			shift
			shift;;
		--cols|-c)
			checkNumber "$1" "$2"
			export cols=$2
			shift
			shift;;
		--weight|-w)
			checkNumber "$1" "$2"
			export weight=$2
			shift
			shift;;
		--debug|-d)
			export debug=1
			shift;;
		--)
			break;;
		*)
			showUsageAndExit
			break;;
	esac
done

if ! [[ -n "${rows}" && -n "${cols}" ]]
then
	showUsageAndExit
fi

printf "Starting life with %s rows and %s columns" "${rows}" "${cols}"
generateBoard "${rows}" "${cols}"
equilibrium=0
count=0
checkBoard=()
printBoard "${rows}" "${cols}" "${count}"
while [[ ${equilibrium} -eq 0 ]]
do
	checkBoard=("${board[@]}")
	iterateBoard "${rows}" "${cols}"
	printBoard "${rows}" "${cols}" "${count}"
	count=$((count+1))
	equilibrium=1
	boardLength="${#board[@]}"
	for (( x=0; x<boardLength; x++))
	do
		if (( board[x] != checkBoard[x] ))
		then
			equilibrium=0
			break
		fi
	done
done
printf "Equilibrium achieved after %s iterations\n" "${count}"