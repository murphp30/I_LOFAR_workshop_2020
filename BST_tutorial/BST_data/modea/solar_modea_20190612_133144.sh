#!/bin/bash

#variables
rcumode=3
bits=8
duration=1200 #300 #21600 # observation duration in seconds as firts input
observation="solar_mode3"

today="`date +"%Y.%m.%d"`"
start_time="`date +"%H%M%S"`"

#check below exists
#write data datapath on LCU
datapath=/data/home/user1/data/$today/$observation/$start_time/
echo "*** Statistics being saved to $datapath"
#swlevel 3 to allow beamforming
echo "*** Going to swlevel 3"
swlevel 3 
#allow lots of time to reach swlevel 3
#sleep 180 #come back to this

#create the data directory & copy this script to it as a record of what we've done.
mkdir -p $datapath
cp $0 $datapath

band="10_90" # assume mode 3
antennaset="LBA_INNER"
if [ $bits -eq 8 ]; then
	subbands="7:494" #"51:450" #Freq. range = 10.0-88.0MHz
	beamlets="0:487" #"0:399"
else
	subbands="203:446" #Freq. range = 40-87MHz
	freq_range="40-87MHz"
	beamlets="0:243" #automate this!
fi

#Setup the pointings
#CRAB="1.459672668,0.384225508,J2000"
theSUN="0,0,SUN"
echo "*** Observing in bitmode $bits with $antennaset in subbands $subbands, frequency range $freq_range"
#set up beams to point at sun 
if [ $bits -eq 8 ]; then
	# Setup 8-bit mode, otherwise assume 16(12) bit mode
	rspctl --bitmode=8
	sleep 10 
	echo "*** Setting beam to point at $theSUN" 
	beamctl --antennaset=$antennaset --rcus=0:191 --band=$band --subbands=$subbands --beamlets=$beamlets --anadir=$theSUN --digdir=$theSUN > $datapath/beamctl.log 2>&1 &
else
	rspctl --bitmode=16
	echo "*** Setting beam to point at $theSUN" 
	beamctl --antennaset=$antennaset --rcus=0:191 --band=$band --subbands=$subbands --beamlets=$beamlets --anadir=$theSUN --digdir=$theSUN > $datapath/beamctl.log 2>&1 &
fi
#actually record statistic files (bst) nohup is forced execution
nohup rspctl --statistics=beamlet --duration=$duration --integration=1 --directory=$datapath > $datapath/rspctl_beamlet.log 2>&1 & 

echo " "
echo "*** Recording started at: " $(date)
echo "*** Recording beamlet statistics for "$duration" seconds...."
sleep $duration


echo "*** Observation finished, killing the beam"

killall beamctl # kill any existing beams
#echo "*** Going back to swlevel 0"
#swlevel 0
