#!/bin/bash

echo ""
echo ""
echo "#######################"
echo "#                     #"
echo "#  IMEI COLLECTOR v2  #"
echo "#                     #"
echo "#######################"
echo ""
echo ""
bold=$(tput bold)
normal=$(tput sgr0)

echo "Please type a name for the .csv file ${bold}(NO SPACES)${normal}"
read chosenname
nameextension=$(date +%F)
file="$HOME/Desktop/IMEI-${nameextension}-${chosenname}.csv"
echo "IMEI,Model" >> $file

echo "Now collecting IMEIs in ${file}"
echo "To stop collecting and exit, press CTRL+C"
echo ""
echo ""
ABSPATH="$(cd "$(dirname "$0")" && pwd)"
cd "$ABSPATH"

i=1

while true
do
	pair=$(idevicepair pair)

	if [[ $pair == *"trust dialog"* ]]; then
		echo "Please accept trust dialog."
	elif [[ $pair == *"Paired with device"* ]]; then
		# Query for device info
		info=$(ideviceinfo)

		# Getting the IMEI
		imei=$(echo "$info" | grep "InternationalMobileEquipmentIdentity: " | sed -n -e 's/^.*InternationalMobileEquipmentIdentity: //p')
		lookup=$(cat $file | grep "$imei")

		if [[ ! -z $imei && -z $lookup ]]; then
			# Getting the model number
			modelnumber=$(echo "$info" | grep "ModelNumber: " | sed -n -e 's/^.*ModelNumber: //p' | sed 's/^.//')
			# Figuring out model from model number
			name=$(cat appledevices.txt | grep "$modelnumber" | awk '{$NF="";sub(/[ \t]+$/,"")}1')

			# Saving Model Number if name is missing
			if [[ -z $name ]]; then
				name=$modelnumber
			fi

			# Output to CSV
			echo "$imei,$name" >> $file
			echo "$i : $imei : $name"
			afplay /System/Library/Sounds/Tink.aiff

			i=$((i+1))
			idevicepair unpair > /dev/null

		elif [[ ! -n $imei ]]; then
			echo "empty IMEI, program will retry" > /dev/null
		else
			#echo "IMEI already acquired, change phone"
			idevicepair unpair > /dev/null
		fi
	else
		echo "Other error, please troubleshoot" > /dev/null
		idevicepair unpair > /dev/null
	fi
	sleep 1
done
