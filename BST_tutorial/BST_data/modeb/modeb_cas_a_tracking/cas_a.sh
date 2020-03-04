#variables
rcumode=5
bits=16
duration=43200 # observation duration in seconds
observation='cas_a_tracking'

today="`date +"%Y.%m.%d"`"
start_time=`date +"%H%M%S"`
datapath=/data/home/user1/data/$today/$observation/$start_time/
#swlevel 3 to allow beamforming
swlevel 3 
#allow lots of time to reach swlevel 3
sleep 180

#create the data folder & copy this script to it as a record of what we've done.
mkdir -p $datapath
cp ./cas_a.sh $datapath

band='10_90' # assume mode 3
antennaset='LBA_INNER'
if [ $bits -eq 8 ]; then
	subbands='51:450' #Freq. range = 10.0-88.0MHz
	beamlets='0:399'
else
	subbands='153:396' #Freq. range = 30.0-77.4MHz
	beamlets='0:243'
fi
if [ $rcumode -eq 5 ]; then
	antennaset='HBA_JOINED'
	band='110_190'
	if [ $bits -eq 8 ]; then
		subbands='51:460' #Freq. range = 110.0-190.0MHz
		beamlets='0:409'
else
		subbands='102:345' #Freq. range = 120.0-167.5MHz
		beamlets='0:243'
	fi
fi
if [ $rcumode -eq 6 ]; then
	antennaset='HBA_JOINED'
	band='170_230'
	if [ $bits -eq 8 ]; then
		subbands='64:487' #Freq. range = 170-230MHz
		beamlets='0:423'
	else
		subbands='64:307' #Freq. range = 170-208MHz
		beamlets='0:243'
	fi	fi
if [ $rcumode -eq 7 ]; then
	antennaset='HBA_JOINED'
	band='210_270'
	if [ $bits -eq 8 ]; then
		subbands='51:358' # Freq range = 210-271MHz
		beamlets='0:307'
	else
		subbands='51:294' # Freq range 210.0-257.6MHz
		beamlets='0:243'
	fi
fi
#Setup the pointings
CAS_A="6.123774,1.026459,J2000"

# setup some beams in mode 6 (170-230MHz)


if [ $bits -eq 8 ]; then
	# Setup 8-bit mode, otherwise assume 16(12) bit mode
	rspctl --bitmode=8
	sleep 10 
	beamctl --antennaset=$antennaset --rcus=0:191 --band=$band --subbands=$subbands --beamlets=$beamlets --anadir=$CAS_A --digdir=$CAS_A > $datapath/beamctl.log 2>&1 &
else
	rspctl --bitmode=16
	beamctl --antennaset=$antennaset --rcus=0:191 --band=$band --subbands=$subbands --beamlets=$beamlets --anadir=$CAS_A --digdir=$CAS_A > $datapath/beamctl.log 2>&1 &
fi
#record
nohup rspctl --statistics=beamlet --duration=$duration --integration=1 --directory=$datapath > $datapath/rspctl_beamlet.log 2>&1 & 

echo ''
echo 'Recording started at: ' $(date)
echo 'Recording beamlet statistics for '$duration' seconds....'
sleep $duration


echo 'Observation finished, killing the beam'

killall beamctl # kill any existing beams
