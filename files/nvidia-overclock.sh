#!/usr/bin/env bash

#
# nvidia-overclock.sh
# Author: Nils Knieling - https://github.com/Cyclenerd/ethereum_nvidia_miner
#
# Overclocking with nvidia-settings
#

# Load global settings settings.conf
if ! source ~/settings.conf; then
	echo "FAILURE: Can not load global settings 'settings.conf'"
	exit 9
fi

export DISPLAY=:0

# returns the performance level of the specified device
function getPerfLevel () {
	local lineCount=0
	local deviceNo=$1
	nvidia-smi --format=csv,noheader --query-gpu=name | while read line
	do
		if (( lineCount == deviceNo )); then
			if [[ $line == *"1050"* ]]; then
				return 2
			else
				return 3
			fi
		fi
		(( lineCount++ ))
	done
	return 3 #default - should never be reached
} # end function getPerfLevel

# Graphics card 1 to 6
for MY_DEVICE in {0..5}
do
	# Check if card exists
	if nvidia-smi -i $MY_DEVICE >> /dev/null 2>&1; then
		#detect the erformance level
		getPerfLevel $MY_DEVICE
		perfLevel=$?
		# Put card into highest perfomance state
		nvidia-settings -a "[gpu:$MY_DEVICE]/GPUPowerMizerMode=1"
		# Fan speed
		nvidia-settings -a "[gpu:$MY_DEVICE]/GPUFanControlState=1"
		nvidia-settings -a "[fan:$MY_DEVICE]/GPUTargetFanSpeed=$MY_FAN"
		# Graphics clock
		nvidia-settings -a "[gpu:$MY_DEVICE]/GPUGraphicsClockOffset[$perfLevel]=$MY_CLOCK"
		# Memory clock
		nvidia-settings -a "[gpu:$MY_DEVICE]/GPUMemoryTransferRateOffset[$perfLevel]=$MY_MEM"
		# Set watt/powerlimit. This is also set in miner.sh at autostart.
		sudo nvidia-smi -i "$MY_DEVICE" -pl "$MY_WATT"
	fi
done

echo
echo "Done"
echo
