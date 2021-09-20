#!/bin/bash
method1(){
clear
cat << "EOF"
================================================================================
Setup: Download ChainDB from NKN.org and host it on THIS server

Hosting your own ChaindDB archive server will make making new NKN nodes faster.

To force exit this script press CTRL+C
================================================================================

EOF
if [[ $mode == "advanced" ]]; then
printf "\033[2A\033[2K"
cat << "EOF"

Requirements:
1. ChainDB HOST ONLY, need 25 GB+ storage space, 1+ cpu, 512+MB ram
2. ChainDB HOST + NKN node, need 40+ GB storage space, 1+ cpu, 1+GB ram
================================================================================

EOF
read -s -r -p "Press Enter to continue!"
printf "\r\033[K"
fi

# Install Apache web server
printf "Installing Apache Web Server............................................ "
apt-get install apache2 -y > /dev/null 2>&1
printf "DONE!\n"

# Configure Firewall and ports
printf "Configuring firewall.................................................... "
ufw allow 80 > /dev/null 2>&1
ufw allow 22 > /dev/null 2>&1
ufw allow 443 > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1
printf "DONE!\n"

# Download the ChainDB archive from nkn.org
websource="https://nkn.org/ChainDB_pruned_latest.tar.gz" # NKN.org ChainDB URL
#websource="http://194.137.17.39/ChainDB.tar.gz" # TEST ChainDB URL
cd /var/www/html/ > /dev/null 2>&1 || exit

printf "Downloading ChainDB archive............................................. \n"

# Check URL
if curl --connect-timeout 5 --output /dev/null --silent --head --fail "$websource"; then
	# URL OK
	wget --quiet --continue --show-progress $websource
	printf "Downloading ChainDB archive............................................. DONE!\n\n"
else
	# URL FAIL / timeout
	printf "URL: %s, does NOT exist. Server down?\n\n" "$websource"
	read -s -r -p "Press Enter to go back to the menu!"
	menu
fi

# cleanup
filename=${websource##*/} # read the URL filename
mv -f "$filename" ChainDB.tar.gz > /dev/null 2>&1 # fix the original filename to ChainDB.tar.gz
rm -f index.html > /dev/null 2>&1 # remove Apache auto generated index.html

# END output
printf "This is your new ChainDB archive URL use it to deploy your new NKN nodes.\n"
printf "Copy paste it somewhere safe!\n\n"
printf "%s" "$red"
printf "URL: http://%s/ChainDB.tar.gz\n\n" "$PUBLIC_IP"
printf "%s" "$normal"

read -s -r -p "Press Enter to continue!"

# "if from beginner menu" also install NKN node
if [[ $mode == "beginner" ]]; then
	websource="http://$PUBLIC_IP/ChainDB.tar.gz" # set to local ChainDB file
	installation="local"
	userdata1
else
	menu
fi
}

method2(){
clear
cat << "EOF"
================================================================================
Setup: Create ChainDB from own existing NKN node and host on the SAME server

To force exit this script press CTRL+C

Requirements:
1. NKN node syncState: "PERSIST_FINISHED"
2. ChainDB HOST + NKN node, need 40+ GB storage space, 1+ cpu, 1+GB ram
================================================================================

EOF
read -s -r -p "Press Enter to continue!"
printf "\r\033[K"

printf "Installing Apache Web Server............................................ "
apt-get install apache2 -y > /dev/null 2>&1
printf "DONE!\n"

printf "Stopping NKN node software.............................................. "
systemctl stop nkn-commercial.service > /dev/null 2>&1
sleep 5
printf "DONE!\n"

# find directory and change dir to it
cd "$(find / -type d -name "nkn-node" 2>/dev/null)" || exit

printf "Pruning ChainDB folder.................................................. "
./nknc pruning --pruning --lowmem > /dev/null 2>&1
printf "DONE!\n"

printf "Creating ChainDB archive................................................ \n"
tar cf - ./ChainDB -P | pv -s "$(du -sb ./ChainDB | awk '{print $1}')" | gzip > /var/www/html/ChainDB.tar.gz
printf "Create ChainDB archive.................................................. DONE!\n"

printf "Starting NKN node software.............................................. "
systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n\n"

rm -f /var/www/html/index.html > /dev/null 2>&1

#printf "\nYou can now start the script on NEW servers you wanna deploy a node on with:\n\n"

#printf "%s" "$red"
#printf "wget -O nkndeploy.sh 'http://107.152.46.244/nkndeploy.sh'; bash nkndeploy.sh\n\n"
#printf "%s" "$normal"

printf "Custom URL to the ChainDB archive. You will need this URL, make a copy of it!\n\n"
printf "%s" "$red"
printf "http://%s/ChainDB.tar.gz\n\n" "$PUBLIC_IP"
printf "%s" "$normal"
read -s -r -p "Press Enter to continue!"
}

method3(){
clear
cat << "EOF"
================================================================================
Setup: Create ChainDB from own node and host it on another server
To force exit this script press CTRL+C
================================================================================

  ________________                         ________________
 |  ____________  |                       |  ____________  |
 | |            | |                       | |            | |
 | |    NKN     | |                       | |    WEB     | |
 | |    NODE    | |                       | |    HOST    | |
 | |   SERVER   | |                       | |   SERVER   | |
 | |____________| |                       | |____________| |
 |________________|                       |________________|
    _|________|_>>>>>>>>>>>>>>>>>>>>>>>>>>>>>_|________|_
   / ********** \                           / ********** \
 /  ************  \                       /  ************  \
--------------------                     --------------------

READ CAREFULLY!

This process will make a ChainDB file on NKN node server and transfer it
to the web host server.

You need to provide a WEB HOST SERVER! Make another VPS server which you will
use to host the ChainDB file, so you can deploy your next NKN nodes faster!
Requirement: web host with 1 core, 512 MB RAM, 25+GB storage minimum.

EOF
read -s -r -p "Press Enter to continue!"
method3host
}

method3host(){
clear
cat << "EOF"
================================================================================
Setup: Create ChainDB and host it on another server.
To force exit this script press CTRL+C
================================================================================

We will now connect to the HOST server and configure it from this script.
After you put in the username and address, you will be asked to confirm the
ECDSA security. Type yes and hit enter. You will be asked for the password
to establish the SSH connection and to install software on the web host server.

Type in WEB HOST SERVER username:
EOF
read -r sshusername

printf "\nType in WEB HOST SERVER IP address:\n"
read -r sship

printf "\nConfiguring Web Host Server............................................. \n"
sudo ssh -t "$sshusername"@"$sship" 'sudo apt-get update -y > /dev/null 2>&1; sudo apt-get install apache2 -y > /dev/null 2>&1; sudo rm -f /var/www/html/index.html > /dev/null 2>&1; exit > /dev/null 2>&1'

method3node
}

method3node(){
printf "Configuring Web Host Server............................................. DONE!\n"

printf "Stopping NKN node software.............................................. "
systemctl stop nkn-commercial.service > /dev/null 2>&1
sleep 5
printf "DONE!\n"

# find directory and change dir to it
cd "$(find / -type d -name "nkn-node" 2>/dev/null)" || exit

printf "Pruning ChainDB folder.................................................. "
./nknc pruning --pruning --lowmem > /dev/null 2>&1
printf "DONE!\n"

printf "\nWe will now connect to the HOST server again and upload the ChainDB file.\n"

printf "You will be asked for the host server user password for the SSH connection\n\n"

tar zcf - ./ChainDB/ -P | pv -s "$(du -sb ./ChainDB | awk '{print $1}')" | ssh "$sshusername"@"$sship" "cat > /var/www/html/ChainDB.tar.gz"
printf "Upload complete......................................................... DONE!\n"

printf "Starting NKN node software.............................................. "
systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n\n"

#printf "You can now start the script on NEW servers you wanna deploy a node on with:\n\n"

#printf "%s" "$red"
#printf "wget -O nkndeploy.sh 'http://107.152.46.244/nkndeploy.sh'; bash nkndeploy.sh\n\n"
#printf "%s" "$normal"

printf "Custom URL to the ChainDB archive. You will need this URL, make a copy of it!\n\n"
printf "%s" "$red"
printf "http://%s/ChainDB.tar.gz\n\n" "$sship"
printf "%s" "$normal"

read -s -r -p "Press Enter to continue!"
menu
}

method4(){
clear
cat << "EOF"
================================================================================
Setup: Update existing ChainDB archive on THIS server

To force exit this script press CTRL+C

Requirement:
1. NKN node syncState: "PERSIST_FINISHED"

Previous ChainDB will be replaced
================================================================================

EOF
read -s -r -p "Press Enter to continue!"
printf "\r\033[K"

printf "Stopping NKN node software.............................................. "
systemctl stop nkn-commercial.service > /dev/null 2>&1
sleep 5
printf "DONE!\n"

printf "Pruning ChainDB folder.................................................. "
cd "$(find / -type d -name "nkn-node" 2>/dev/null)" || exit # find directory and change dir
./nknc pruning --pruning --lowmem > /dev/null 2>&1
printf "DONE!\n"

printf "Deleting OLD ChainDB archive............................................ "
rm -f Chain*.tar.gz > /dev/null 2>&1 # delete old file from previous versions of script
rm -f /var/www/html/Chain*.tar.gz > /dev/null 2>&1
printf "DONE!\n"

printf "Creating NEW ChainDB archive............................................ \n"
tar cf - ./ChainDB -P | pv -s "$(du -sb ./ChainDB | awk '{print $1}')" | gzip > /var/www/html/ChainDB.tar.gz
# bug somehow the tar/gzip process changes ownership of files ?? rechown
chown -R "$username":"$username" ChainDB/ > /dev/null 2>&1
printf "Create NEW ChainDB archive.............................................. DONE!\n"

printf "Starting NKN node software.............................................. "
sudo systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n\n"

printf "The ChainDB.tar.gz archive was updated.\n\n"

printf "Next time you install a node, it will use the updated database.\n\n"

read -s -r -p "Press Enter to continue!"
menu
}

method5(){
clear
cat << "EOF"
================================================================================
Setup: Download ChainDB from custom URL and host it on this server
To force exit this script press CTRL+C

Requirements:
1. Fresh Server only!
2. ChainDB HOST ONLY, need 25+ GB storage space, 1+ cpu, 512+ MB ram
3. ChainDB HOST + NKN node, need 40+ GB storage space, 1+ cpu, 1+ GB ram
================================================================================

EOF
read -s -r -p "Press Enter to continue!"
printf "\r\033[K"

printf "Enter the custom URL address where the ChainDB*.tar.gz is located at:\n"
read -r websource
printf "\n"

# URL CHECK
if curl --output /dev/null --silent --head --fail "$websource"; then
	printf "URL OK: %s\n" "$websource"
	sleep 4
	#continue if URL ok
else
	printf "ERROR URL does NOT exist: %s\n" "$websource"
	sleep 4
	method5
fi

printf "\nInstalling Apache Web Server............................................ "
apt-get install apache2 -y > /dev/null 2>&1
printf "DONE!\n"

# Configure Firewall and ports
printf "Configuring firewall.................................................... "
ufw allow 80 > /dev/null 2>&1
ufw allow 22 > /dev/null 2>&1
ufw allow 443 > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1
printf "DONE!\n"

cd /var/www/html/ > /dev/null 2>&1 || exit

printf "Downloading ChainDB archive............................................. \n"
wget --quiet --continue --show-progress "$websource"
printf "Downloading ChainDB archive............................................. DONE!\n\n"

# cleanup
filename=${websource##*/}
mv -f "$filename" ChainDB.tar.gz > /dev/null 2>&1
rm -f index.html > /dev/null 2>&1

# NEW websource for the install
websource="http://$PUBLIC_IP/ChainDB.tar.gz"

# END output
printf "This is your new ChainDB archive URL use it to deploy your new NKN nodes.\n"
printf "Copy paste it somewhere safe!\n\n"
printf "%s" "$red"
printf "URL: http://%s/ChainDB.tar.gz\n\n" "$PUBLIC_IP"
printf "%s" "$normal"

# Question
read -r -p "Do you also want to install a NKN node on this server ? [y/n] " response
case "$response" in
	[yY][eE][sS]|[yY])
	# correct continue script
	installation="local" ; userdata1 ;;
	*)
	# wrong exit
	menuadvanced ;;
esac
}

function nodeWalletTransfer(){
clear
cat << "EOF"
================================================================================
Setup: Transfer NODE ID / wallet (NOT beneficiary wallet where you get paid)
To force exit this script press CTRL+C
================================================================================

This will copy the wallet files from the REMOTE server to THIS server!
Run this script on the NEW NKN server where you wanna restore the node ID to.

Requirement:
- NKN node installed on this server!

EOF
printf "REMOTE NKN server IP address:\n"
read -r remoteIP

printf "\nREMOTE NKN server username (NKN if installed with this script):\n"
printf "\n"
read -r remoteUsername

printf "\nLOCAL NKN server username (NKN if installed with this script):\n"
read -r localUsername

printf "\nYou will be asked for the REMOTE user password so the connection\n"
printf "can get established.\n\n"

read -s -r -p "Press Enter to continue!"

# check if rsync works or not
if rsync -a -I "$remoteUsername"@"$remoteIP":/home/"$remoteUsername"/nkn-commercial/services/nkn-node/wallet.json :/home/"$remoteUsername"/nkn-commercial/services/nkn-node/wallet.pswd /home/"$localUsername"/nkn-commercial/services/nkn-node/
then
	printf "\nWallet files copied!\n"
	systemctl restart nkn-commercial.service
	printf "Local NKN node restarted!\n"
	printf "Local NKN noded should start with the new ID.\n\n"
else
	printf "\nError while running rsync\n\n"
fi

read -s -r -p "Press Enter to continue!"
menu
}

################################ user input ####################################

function userdata1(){
clear
cat << "EOF"
================================================================================
Setup: necessary data input
To force exit this script press CTRL+C

Enter the MAINNET! NKN address where you want to receive payments.
Example address: NKNFLRkm3uWZBxohoZAAfBgXPfs3Tp9oY4VQ
================================================================================

NKN Wallet address:
EOF
# Input beneficiary wallet adddress
read -r benaddress

# check wallet address lengh
walletlenght=${#benaddress}

if [[ $walletlenght == "36" ]]; then
	# Continues script
	userdata2
else
	# restarts function F1
cat << "EOF"

NKN wallet address you entered is wrong. Use mainnet NKN wallet,
not ERC-20 wallet. NKN mainnet address starts with NKN*

EOF
	read -s -r -p "Press Enter to continue!"
	userdata1
fi
}

function userdata2(){
clear
cat << "EOF"
================================================================================
Setup: necessary data input
To force exit this script press CTRL+C

A new user will be created for security reasons.
Please use a strong password of choice.
================================================================================

Enter password:
EOF
printf "Pre-set Username: %s\n\n" "$username"

printf "Password:\n"
read -r userpassword
userdata3
}

function userdata3(){
if [[ $installtype == "custom" ]]; then
	clear
cat << "EOF"
================================================================================
Setup: necessary data input
To force exit this script press CTRL+C
================================================================================

Enter the custom URL address where the ChainDB*.tar.gz is located at:
EOF
	read -r websource
	printf "\n"

	if curl --output /dev/null --silent --head --fail "$websource"; then
		printf "URL OK: %s\n" "$websource"
		sleep 4
		userdata4
	else
		printf "ERROR URL does NOT exist: %s\n" "$websource"
		sleep 4
		userdata3
	fi
else
	userdata4
fi
}

function userdata4(){
clear
cat << "EOF"
================================================================================
Setup: necessary data input
To force exit this script press CTRL+C
================================================================================

EOF
# Check data if true
printf "Check what you entered:\n\n"

printf "Wallet address: %s\n" "$benaddress"
printf "Username: %s\n" "$username"
printf "Password: %s\n" "$userpassword"
printf "Chain database source: %s\n\n" "$websource"

# Question
read -r -p "Are you sure this data is correct? [y/n] " response
case "$response" in
    [yY][eE][sS]|[yY])
	#correct continue script
	install1 ;;
    *)
	#wrong restarts userdata input
	userdata1 ;;
esac
}

############################# Firewall warning #################################
function firewallwarn(){
clear
# revert all changes
/home/"$username"/nkn-commercial/nkn-commercial uninstall > /dev/null 2>&1
cd / > /dev/null 2>&1
pkill -KILL -u "$username" > /dev/null 2>&1
deluser --remove-home "$username" > /dev/null 2>&1

printf "%s" "$red"
cat << "EOF"
A modem/router or VPS provided firewall is prohobiting access to the internet!

For home modem, configure the ports correctly.
For VPS, disable the VPS provider firewall and allow all internet through.

The system changes were REVERTED, once you fix the firewall settings
restart the server and just run the same script again

For info on how to do that visit:
https://forum.nkn.org/t/allinone-nknnode-script-deploy-nodes-faster-with-your-own-chaindb/2753

EOF
printf "%s" "$normal"

read -s -r -p "Press Enter to continue!"
menu
}

################################### Uninstall######################################
function uninstall(){
clear
# revert all changes
cat << "EOF"
================================================================================
Setup: Uninstall NKN node

To force exit this script press CTRL+C
================================================================================

EOF
read -s -r -p "Press Enter to continue!"
printf "\r\033[K"

# uninstall NKN miner, kill all user processes, remove user and userfolder
/home/"$username"/nkn-commercial/nkn-commercial uninstall > /dev/null 2>&1
cd / > /dev/null 2>&1
pkill -KILL -u "$username" > /dev/null 2>&1
deluser --remove-home "$username" > /dev/null 2>&1

printf "Uninstall complete!\n\n"

read -s -r -p "Press Enter to continue!"
menu
}

################################## Install #####################################

function install1(){
clear
IFS='' read -r -d '' fire <<"EOF"
           (                 ,&&&.
            )                .,.&&
           (  (              \=__/
               )             ,'-'.
         (    (  ,,      _.__|/ /|
          ) /\ -((------((_|___/ |
        (  // | (`'      ((  `'--|
      _ -.;_/ \\--._      \\ \-._/.
     (_;-// | \ \-'.\    <_,\_\`--'|
     ( `.__ _  ___,')      <_,-'__,'
      `'(_ )_)(_)_)'
================================================================================
This will take some time. Please be patient.
To force exit this script press CTRL+C
================================================================================
EOF
printf "%s\n" "$fire"

# disable firewall for the installation
ufw --force disable > /dev/null 2>&1

# Create a new SUDO user
printf "Creating a new Super User account....................................... "
pass=$(perl -e 'print crypt($ARGV[0], "password")' "$userpassword")
useradd -m -p "$pass" -s /bin/bash "$username"
usermod -a -G sudo "$username"
printf "DONE!\n"

# Install NKN node miner software
printf "Downloading NKN node software........................................... "
cd /home/"$username" || exit
wget --quiet --continue "$nknsoftwareURL"
printf "DONE!\n"

printf "Installing NKN node software............................................ "
# extract filename and extension from URL
filename=${nknsoftwareURL##*/}
unzip "$filename" > /dev/null 2>&1
rm -f "$filename"
# remove extension from filename
filename=${filename%.*}
mv "$filename" nkn-commercial

chown -R "$username":"$username" /home/"$username"
chmod -R 755 /home/"$username"

/home/"$username"/nkn-commercial/nkn-commercial -b "$benaddress" -d /home/"$username"/nkn-commercial/ -u "$username" install > /dev/null 2>&1
printf "DONE!\n"

# Wait for ChainDB DIR and wallet creation
DIR="/home/$username/nkn-commercial/services/nkn-node/"

# No ChainDB install
if [[ $database == "no" ]]; then
	# script waits for wallet generation and then skips DB download and continues
	printf "Waiting for NKN node software to start.................................. "
	
	timestart=$(date +%s)
	while [[ $(($(date +%s) - timestart)) -lt 300 ]]; do # 300sec 5 min
		if [[ ! -f "$DIR"wallet.json ]]; then
			# if file doesn't exist wait and repeat check
			sleep 5
		else
			# when wallet.json file is detected
			printf "DONE!\n"
			install3
		fi
	done
	# when timer runs out go to the firewall warning
	firewallwarn

# ChainDB install	
else
	printf "Waiting for NKN node software to start.................................. "

	timestart=$(date +%s)
	while [[ $(($(date +%s) - timestart)) -lt 300 ]]; do # 300sec 5 min
		if [[ ! -d "$DIR"ChainDB ]] && [[ ! -f "$DIR"wallet.json ]]; then
			# if folder and file don't exist yet wait and repeat check
			sleep 5
		else
			# when file is detected
			sleep 5 > /dev/null 2>&1
			systemctl stop nkn-commercial.service > /dev/null 2>&1
			sleep 5 > /dev/null 2>&1
			printf "DONE!\n"
			install2
		fi
	done
	# when timer runs out go to the firewall warning
	firewallwarn
fi
}

function install2(){
printf "Downloading / Extracting NKN Chain database.............................\n"
cd "$DIR" > /dev/null 2>&1 || exit
rm -rf ChainDB/ > /dev/null 2>&1

# extract locally or download from websource
if [[ $installation == "local" ]]; then
	cd /var/www/html/ || exit
	pv ChainDB.tar.gz | tar xzf - -C "$DIR"
else
    # internet download
	wget -O - "$websource" -q --show-progress | tar -xzf -
fi

chown -R "$username":"$username" /home/"$username" > /dev/null 2>&1
chmod -R 755 /home/"$username" > /dev/null 2>&1

printf "Downloading / Extracting NKN Chain database............................. DONE!\n"
install3
}

function install3(){
# Configure Firewall / ports
printf "Configuring firewall.................................................... "
ufw allow 30001:30005/tcp > /dev/null 2>&1 # NKN node
ufw allow 30010/tcp > /dev/null 2>&1 # Tuna exit
ufw allow 30011/udp > /dev/null 2>&1 # Tuna exit
ufw allow 30020/tcp > /dev/null 2>&1 # Tuna reverse entry
ufw allow 30021/udp > /dev/null 2>&1 # Tuna reverse entry
ufw allow 32768:65535 > /dev/null 2>&1 # Tuna reverse entry
ufw allow 22 > /dev/null 2>&1 # SSH
ufw allow 80 > /dev/null 2>&1 # HTTP
ufw allow 443 > /dev/null 2>&1 # HTTPS
ufw --force enable > /dev/null 2>&1

systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n"

# Disable root password, to enable root again:
# sudo passwd root
# sudo passwd -u root
printf "Disabling Root account for security reasons............................. "
passwd --lock root > /dev/null 2>&1
printf "DONE!\n\n"
install4
}

function install4(){
printf "===============================================================================\n"
printf "Congratulations, you deployed a NKN node!\n"
printf "===============================================================================\n\n"

printf "%s" "$red"
printf "Check the status of your new node on www.nstatus.org\n"
printf "Use this server IP address: %s\n\n" "$PUBLIC_IP"

printf "The new NKN server will take some time to sync up, keep checking it\n"
printf "until the site gives you this error: No ID in this account...\n\n"

printf "Then send 10 NKN (mainnet token) to the address it provides, AKA:\n"
nodewallet=$(sed -r 's/^.*Address":"([^"]+)".*/\1/' "$DIR"wallet.json)
printf "%s\n\n" "$nodewallet"

printf "Keep checking on nstatus to see when the server activates.\n\n"
printf "%s" "$normal"

printf "%s" "$blue"
printf "NKN wallet (beneficiary adddress) where you will get paid to:\n"
printf "%s\n\n" "$benaddress"
printf "%s" "$normal"

printf "From now on use these settings to connect to your server:\n"
printf "If you're using AWS, Google Cloud, Azure... use the provided SSH keys to login.\n\n"

printf "Server IP: %s\n" "$PUBLIC_IP"
printf "SSH login: ssh %s@%s\n" "$username" "$PUBLIC_IP"
printf "Server username: %s\n" "$username"
printf "Server password: %s\n\n" "$userpassword"

printf "Thanks for using this script!\n\n"

read -s -r -p "Press enter to continue!"
menu
}

################################# NODE CHECKER #################################

addip(){
clear
printf "Enter NODE IP address to ADD:\n"
read -r addipaddress
printf "%s\n" >> IPs.txt "$addipaddress" # create/write file IPs.txt
}

removeip(){
clear
FILE="IPs.txt"
printf "Enter NODE IP address to REMOVE:\n"
read -r removeipaddress

# remove information from the file IPs.txt
if grep -Fxq "$removeipaddress" "$FILE"
then
    # if found
    sed -i /"$removeipaddress"/d "$FILE"
    printf "\nIP address removed!\n\n"
    read -s -r -p "Press enter to continue!"
else
    # if not found
    printf "\nERROR IP address not found!\n\n"
    read -s -r -p "Press enter to continue!"
fi
}

showips(){
clear
FILE="IPs.txt"

# read file IPs.txt and print it out in terminal
printf "%s server IP addresses found in IPs.txt file.\n\n" "$(grep "" -c IPs.txt)"

printf "*** File - %s contents ***\n\n" "$FILE"
cat $FILE

printf "\n"
read -s -r -p "Press enter to continue!"
}

checknodes(){
clear
input="IPs.txt"
inputwallet="walletaddress.txt"

while :
do
clear
	# check if file exists, if not skip the wallet part
	if [[ ! -f walletaddress.txt ]]; then
		printf "%s servers IP addresses found in IPs.txt file.\n\n" "$(grep "" -c IPs.txt)"
		printf "IP:              Status:           Height:  Version:  Uptime:\n"
	else
		while IFS= read -r file; do # read the NKN wallet address from the walletaddress.txt file
			walletaddress="$file"

			# fetch wallet balance from nkn.org
			getwalletinfo=$(curl -s -X GET \
			-G "https://openapi.nkn.org/api/v1/addresses/$walletaddress" \
			-H "Content-Type: application/json" \
			-H "Accept: application/json")

			walletoutput1=$(printf "%s" "$getwalletinfo" | sed -n -r 's/(^.*address":")([^"]+)".*/\2/p' | sed -e 's/[",]//g')
			walletoutput2=$(printf "%s" "$getwalletinfo" | sed -E 's/(^.*balance":)([^",]+).*/\2/; s/[0-9]{8}$/.&/')
		done < "$inputwallet"

		printf "Wallet address: %s\n" "$walletoutput1"
		printf "Wallet balance: %s NKN\n\n" "$walletoutput2"

		printf "%s servers IP addresses found in IPs.txt file.\n\n" "$(grep "" -c IPs.txt)"
		printf "IP:              Status:           Height:  Version:  Uptime:   NKN mined:\n"
	fi

	# get blockworth from API
	getlatestblock=$(curl -s -X GET \
	-G "https://openapi.nkn.org/api/v1/statistics/counts" \
	-H "Content-Type: application/json" \
	-H "Accept: application/json")

	latestblock=$(printf "%s" "$getlatestblock" | sed -E 's/(^.*blockCount":)([^",]+).*/\2/; s/[0-9]{8}$/.&/')

	getblockworth=$(curl -s -X GET \
	-G "https://openapi.nkn.org/api/v1/blocks/$latestblock" \
	-H "Content-Type: application/json" \
	-H "Accept: application/json")

	blockworth=$(printf "%s" "$getblockworth" | sed -E 's/(^.*reward":)([^",]+).*/\2/; s/[0-9]{8}$/.&/; s/[}]//g')

	# fetch the node data and process it
	while IFS= read -r file; do
			nkncOutput=$(./nknc --ip "$file" info -s)

			if [[ $nkncOutput == *"error"* ]]
			then
					output1=$(printf "%s" "$nkncOutput" | sed -n -r 's/(^.*message": ")([^"]+)".*/\2/p')
					printf "%-17s%s\n" "$file" "$output1"
			else
					output1=$(printf "%s" "$nkncOutput" | sed -n '/syncState/p' | cut -d' ' -f2 | sed -e 's/[",]//g')
					output2=$(printf "%s" "$nkncOutput" | sed -n '/height/p' | cut -d' ' -f2 | sed -e 's/[",]//g')
					output3=$(printf "%s" "$nkncOutput" | sed -n '/version/p' | cut -d' ' -f2 | sed -e 's/[",]//g' | sed 's/[-].*$//')
					# convert seconds into days and hours 
					uptimeSec=$(printf "%s" "$nkncOutput" | sed -n '/uptime/p' | cut -d' ' -f2 | sed -e 's/[",]//g')
					outputDays=$((uptimeSec / 86400))
					outputHours=$(((uptimeSec / 3600) - (outputDays * 24)))
					days="d "
					hours="h"
					output4="$outputDays$days$outputHours$hours"
					# convert proposal blocks to NKN
					howmanyblocks=$(printf "%s" "$nkncOutput" | sed -n '/proposalSubmitted/p' | cut -d' ' -f2 | sed -e 's/[",]//g')
					worth=$(bc <<< "scale=2; $blockworth / 100000000 * $howmanyblocks")
					nkn=" NKN"
					output5="$worth$nkn"

					# print out in colums
					printf "%-17s%-18s%-9s%-10s%-10s%-10s\n" "$file" "$output1" "$output2" "$output3" "$output4" "$output5"
			fi
	done < "$input"

printf "\nRefresh every 2 minutes, press [ENTER] to exit to menu!\n"
read -r -s -N 1 -t 120 key

if [[ $key == $'\x0a' ]]; # exit loop if ENTER is pressed
then
    menunodechecker
fi
done
}

walletbalance(){
clear
printf "Enter beneficiary wallet address:\n"
read -r walletaddress

# check wallet address lengh
walletlenght=${#walletaddress}

if [[ $walletlenght == "36" ]]; then
	# Continues script
	rm -f walletaddress.txt > /dev/null 2>&1
	printf "%s\n" >> walletaddress.txt "$walletaddress" # write wallet address to file
else
	# error wrong lenght of NKN address go back
cat << "EOF"

NKN wallet address you entered is wrong. Use mainnet NKN wallet,
not ERC-20 wallet. NKN mainnet address starts with NKN*

EOF
	read -s -r -p "Press Enter to continue!"
	walletbalance
fi

menunodechecker
}

################################### nWatch ####################################

nWatchInstall(){
clear
cat << "EOF"
================================================================================
Setup: nWatch installaion
Please be patient
To force exit this script press CTRL+C
================================================================================

EOF

if [[ ! -f /var/www/html/nodes-example.txt ]]; then
	printf "Installing necessary software........................................... "
	apt-get install apache2 php php-curl -y > /dev/null 2>&1
	apt-get autoremove -y > /dev/null 2>&1

	# Debian workaround to install locales
	dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen > /dev/null 2>&1
	sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen > /dev/null 2>&1
	printf 'LANG="en_US.UTF-8"'>/etc/default/locale > /dev/null 2>&1
	dpkg-reconfigure --frontend=noninteractive locales > /dev/null 2>&1
	update-locale LANG=en_US.UTF-8 > /dev/null 2>&1
	#
	printf "DONE!\n"

	printf "Downloading files....................................................... "
	cd /var/www/html/ || exit
	wget https://github.com/AL-dot-debug/nWatch/archive/refs/heads/main.zip > /dev/null 2>&1
	printf "DONE!\n"

	printf "Installing nWatch....................................................... "
	rm -rf index.html > /dev/null 2>&1

	unzip -u main.zip > /dev/null 2>&1
	cp -rf nWatch-main/* . > /dev/null 2>&1
	rm -rf nWatch-main/ > /dev/null 2>&1
	rm -f main.zip > /dev/null 2>&1
	find . -type f -name '*.png' -delete

	chown -R www-data:www-data /var/www/html/ > /dev/null 2>&1
	service apache2 restart > /dev/null 2>&1
	printf "DONE!\n\n"

else
	printf "Installing necessary software........................................... "
	apt-get install apache2 php php-curl -y > /dev/null 2>&1
	apt-get autoremove -y > /dev/null 2>&1
	printf "DONE!\n"

	printf "Downloading files....................................................... "
	cd /var/www/html/ || exit
	wget https://github.com/AL-dot-debug/nWatch/archive/refs/heads/main.zip > /dev/null 2>&1
	printf "DONE!\n"

	printf "Updating nWatch......................................................... "
	unzip -u main.zip > /dev/null 2>&1
	cp -rf nWatch-main/* . > /dev/null 2>&1
	rm -rf nWatch-main/ > /dev/null 2>&1
	rm -f main.zip > /dev/null 2>&1
	find . -type f -name '*.png' -delete

	chown -R www-data:www-data /var/www/html/ > /dev/null 2>&1
	service apache2 restart > /dev/null 2>&1
	printf "DONE!\n\n"
fi

printf "Access the nWatch website on this address, where you can set up your\n"
printf "server IP list and monitor all your nodes.\n"
printf "http://%s\n\n" "$PUBLIC_IP"

read -s -r -p "Press enter to continue!"
menunwatch
}

nWatchRemove(){
clear
cat << "EOF"
================================================================================
Setup: nWatch removal
Please be patient
To force exit this script press CTRL+C
================================================================================

EOF

printf "Removing nWatch....................................................... "
cd /var/www/html/ || exit
find . ! -name ChainDB.tar.gz -delete # delete all files except ChainDB.tar.gz
apt-get remove php php-curl -y > /dev/null 2>&1
printf "DONE!\n\n"

read -s -r -p "Press enter to continue!"
menunwatch
}

################################## Menu stuff ##################################

menunwatch() {
until [[ $selection == "0" ]]; do
clear
cat << "EOF"
                  `/ohdmmmmmdhs/.
               `+dms/-`     `./smdo.
             `oNh:    .:. `o-    -sNs`
            .dm:      .hN+-MMo     -dm-
           `dm.     -oyhhy:sNh      `dN.
           +M:      omNMMMNy.-..`    .My
           hN    `:ooo://::+hmNN/     mN
           hM`  `ymmdooy.`hMMMNs`     mm
           /M+   .oy.dMMh.yhs/shh+   :Ms
            yN:  odo/MMMd`hmdy/--`  -md`
            `yNo``` `dMh. ./syo   `+Nh`
         `.. oMMmo-  `-`        .+dd/`
       `/dNNh/+hyshds+:--.--:/sdhy:`
     `+mMMMMMMh`  `.:+syyyyyso/.`
   `omMMMMMMMNo
 .oNMMMMMMMNo.
oNMMMMMMMm+`
+NMMMMMm+`
================================================================================

Install nWatch node monitor website, an external Github project. You'll be able
to monitor your nodes, add / remove server IPs etc.
https://github.com/AL-dot-debug/nWatch

1) Install / Update (don't install on servers with other websites on them)

3) REMOVE nWatch

10) Go back to first menu
0) Exit
EOF

printf "Enter selection: "
read -r selection
printf "\n"
case $selection in
	1 ) nWatchInstall ;;
	3 ) nWatchRemove ;;
	10 ) menu ;;
	0 ) clear ; exit ;;
	* ) read -s -r -p "Wrong selection press enter to continue!" ;;
esac
done
}

menunodechecker() {
cd "$(find / -type d -name "nkn-node" 2>/dev/null)" || exit
until [[ $selection == "0" ]]; do
clear

# ASCII south park
printf "%s\n" "$ascii_sp"
cat << "EOF"
WORKS ONLY ON A SERVER WITH A NKN NODE INSTALLED! Add your NKN node IP addresses
to the IP database and check on your node status. It will show the node status.

1) Add NKN NODE IP address
2) Remove NKN NODE IP address
3) Show stored IP addresess
4) Check node / wallet status

5) Add beneficiary wallet to display current balance

10) Go back to first menu
0) Exit

EOF
printf "Enter selection: "
read -r selection
printf "\n"
case $selection in
	1 ) addip ;;
	2 ) removeip ;;
	3 ) showips ;;
	4 ) checknodes ;;
	5 ) walletbalance ;;
	10 ) menu ;;
	0 ) clear ; exit ;;
	* ) read -s -r -p "Wrong selection press enter to continue!" ;;
esac
done
}

menuadvanced() {
until [[ $selection = "0" ]]; do
clear

# ASCII south park
printf "%s\n" "$ascii_sp"
cat << "EOF"
NKN ChainDB creation:
1) Download ChainDB from NKN.org and host it on THIS server
2) Download ChainDB from a custom URL and host it on THIS server
3) Create ChainDB from own NKN node and host on the SAME server
4) Create ChainDB from own NKN node and host it on ANOTHER server
5) Update existing ChainDB on THIS server

NKN Node server install
6) via custom server (requires URL to ChainDB*.tar.gz)
7) no ChainDB install, sync starts from 0 (takes a long time)

NKN NODE ID / WALLET TRANSFER
8) Transfer NODE ID / wallet

9) Uninstall NKN node and revert changes

10) Go back to first menu
0) Exit

EOF
printf "Enter selection: "
read -r selection
printf "\n"

case $selection in
	1 ) mode="advanced" ; method1 ;;
	2 ) method5 ;;
	3 ) method2 ;;
	4 ) method3 ;;
	5 ) method4 ;;
	6 ) installtype="custom" ; database="yes" ; userdata1 ;;
    7 ) database="no" ; websource="none" ; userdata1 ;;
	8 ) nodeWalletTransfer ;;
	9 ) uninstall ;;
	10 ) menu ;;
	0 ) clear ; exit ;;
	* ) read -s -r -p "Wrong selection press Enter to continue!" ;;
esac
done
}

menubeginner() {
until [[ $selection == "0" ]]; do
clear
printf "%s" "$blue"
cat << "EOF"
STEP 1: I have no NKN nodes / servers:

YOU NEED TO DO THIS STEP ONLY ONCE!

Hosting the ChainDB archive yourself is essential to deploy your
future NKN nodes faster. You only need one ChainDB server.

Server requirements: 1+ CPU, 1+ GB RAM, 40+ GB of storage

Free credits for server providers: https://vpstrial.net/vps/

If THIS server already has enough storage space, continue by
selecting STEP 1. Otherwise exit this script and provision a new
VPS server.

EOF
printf "%s" "$normal"
printf "%s" "$magenta"
cat << "EOF"
STEP 2: Deploy new nodes:

RUN STEP 2 ONLY ON NEW SERVERS, not on the ChainDB server!!!
Make a new 1 core, 1GB RAM, minimum 25+ GB storage ubuntu 20.04+ server
and use the custom URL address provided to you in the first part of the
script to deploy new node servers.

EOF
printf "%s" "$normal"

cat << "EOF"
1) STEP 1: I have no NKN nodes / servers
3) STEP 2: Deploy new nodes

10) Go back to first menu
0) Exit

EOF
printf "Enter selection: "
read -r selection
printf "\n"

case $selection in
	1 ) mode="beginner" ; database="yes" ; method1 ;;
	2 ) read -s -r -p "Put on your glasses and press enter to continue :D" ; menubeginner ;;
	3 ) installtype="custom" ; database="yes" ; userdata1 ;;

	10 ) menu ;;
	0 ) clear ; exit ;;
	* ) read -s -r -p "Wrong selection press enter to continue!" ;;
esac
done
}

menu() {
until [[ $selection == "0" ]]; do
clear
# ASCII south park
printf "%s\n" "$ascii_sp"

printf "Welcome to no112358 script for deploying NKN node servers! Version: %s\n\n" "$version"

printf "READ CAREFULLY!\n\n"

printf "%s" "$blue"
printf "1) BEGINNERS SELECT 1!\n\n"
printf "%s" "$normal"

printf "%s" "$red"
printf "3) ADVANCED USER!\n\n"
printf "%s" "$normal"

printf "NODE STATUS Checker:\n"
printf "5) in-script NKN node monitor (no112358)\n"
printf "6) nWatch website node monitor (AL-dot-debug)\n\n"

cat << "EOF"
Donate to me:
NKN ERC-20: 0x66b328fc3d429031ee98f81ace49b401f53f2afd
NKN MAINNET: NKNFLRkm3uWZBxohoZAAfBgXPfs3Tp9oY4VQ
BCH: 1Hn2wqtxj7paiXWqLwfgbuPoLpvvvFVFnW
EOF

printf "\n0) Exit\n\n"

printf "Enter selection: "
read -r selection
printf "\n"

case $selection in
	1 ) menubeginner ;;
	3 ) menuadvanced ;;
	5 ) menunodechecker ;;
	6 ) menunwatch ;;
	0 ) clear ; exit ;;
	* ) read -s -r -p "Wrong selection press enter to continue!" ;;
esac
done
}

# Flags help text
help(){
printf "\n\nno112358 NKN node deploy script version: %s\n\n" "$version"
cat << "EOF"
If you give all three flags you can install the node directly without
messing with any menus. Any mistakes with the values will lead to a
broken node, which you'll have to reinstall. Enjoy :D

DO NOT REMOVE SINGLE QUOTES FROM FLAG VALUES!!

EXAMPLE:

wget -O nkndeploy.sh 'https://raw.githubusercontent.com/no112358/ALLinONE-nknnode/main/nkndeploy.sh'; bash nkndeploy.sh -p 'password' -b 'beneficiaryaddress' -w 'chaindbURL'

-p , --password       Set password
-b , --benaddress     Set beneficiary address where you get paid
-w , --websource      Set ChainDB URL address

-h , --help           Display help and exit

Donate to me:
NKN ERC-20: 0x66b328fc3d429031ee98f81ace49b401f53f2afd
NKN MAINNET: NKNFLRkm3uWZBxohoZAAfBgXPfs3Tp9oY4VQ
BCH: 1Hn2wqtxj7paiXWqLwfgbuPoLpvvvFVFnW
EOF
}

###################### Start of the script ####################

# Define colors
red=$(tput setaf 1)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
normal=$(tput sgr0)

# ROOT check
if [[ $EUID -gt 0 ]]; then
printf "%s" "$red"
cat << "EOF"
=================================
PLEASE RUN AS ROOT USER! Type in:

sudo su -

and then run the script again.
=================================
EOF
printf "%s" "$normal"
exit
fi

# Update, upgrade, install system software
apt update -y
apt upgrade -y
apt install unzip -y
apt install ufw -y
apt install sed -y
apt install grep -y
apt install pv -y
apt install curl -y
apt install sudo -y
apt install bc -y
apt install vnstat -y
apt autoremove -y

# ASCII for menus
IFS='' read -r -d '' ascii_sp <<"EOF"
         _          __________                              __
     _.-(_)._     ."          ".      .--""--.          _.-{__}-._
   .'________'.   | .--------. |    .'        '.      .:-'`____`'-:.
  [____________] /` |________| `\  /   .'``'.   \    /_.-"`_  _`"-._\
  /  / .\/. \  \|  / / .\/. \ \  ||  .'/.\/.\'.  |  /`   / .\/. \   `\
  |  \__/\__/  |\_/  \__/\__/  \_/|  : |_/\_| ;  |  |    \__/\__/    |
  \            /  \            /   \ '.\    /.' / .-\                /-.
  /'._  --  _.'\  /'._  --  _.'\   /'. `'--'` .'\/   '._-.__--__.-_.'   \
 /_   `""""`   _\/_   `""""`   _\ /_  `-./\.-'  _\'.    `""""""""`    .'`\
(__/    '|    \ _)_|           |_)_/            \__)|        '       |   |
  |_____'|_____|   \__________/   |              |;`_________'________`;-'
   '----------'    '----------'   '--------------'`--------------------`

================================================================================
EOF

# Public IP and script version
PUBLIC_IP=$(wget -q http://ipecho.net/plain -O -)
version="1.6.3"

# Detect architecture and select proper NKN-commercial version/URL
arch=$(uname -m)

# 64bit X86 CPUs
if [[ $arch == "x86_64" ]]; then
	nknsoftwareURL="https://commercial.nkn.org/downloads/nkn-commercial/linux-amd64.zip"

# Raspberry Pi 32bit
elif [[ $arch == "armv6l" ]]; then
	nknsoftwareURL="https://commercial.nkn.org/downloads/nkn-commercial/linux-armv6.zip"

# Raspberry Pi 64bit
elif [[ $arch == "armv7l" ]] || [[ $arch == "aarch64" ]] || [[ $arch == "armv8b" ]] || [[ $arch == "armv8l" ]] || [[ $arch == "aarch64_be" ]]; then
	nknsoftwareURL="https://commercial.nkn.org/downloads/nkn-commercial/linux-armv7.zip"

else
	# Error if unsupported architecture
	printf "Architecture %s is not supported.\n" "$arch"
	exit 1
fi

# Flags logic
while [[ $1 != "" ]]; do
flags="1"
case "$1" in
	--help | -h)
		help
		exit 1
		;;
	--password | -p)
		shift
		# Check if theres a value for this flag
		if [[ $# -gt 0 ]]; then
				export userpassword=$1
				username="nkn"
				database="yes"
		else
				printf "No password specified\n"
				exit 1
		fi
		shift
		;;
	--benaddress | -b)
		shift
		if [[ $# -gt 0 ]]; then
				export benaddress=$1
		else
				printf "No beneficiary address specified\n"
				exit 1
		fi
		shift
		;;
	--websource | -w)
		shift
		if [[ $# -gt 0 ]]; then
				export websource=$1
		else
				printf "No ChainDB URL address specified\n"
				exit 1
		fi
		shift
		;;
	*)
		help
		exit 1
		;;
esac
done

# Check if flags present
if [[ $flags == "1" ]]; then
    if [[ $userpassword == "" ]] || [[ $benaddress == "" ]] || [[ $websource == "" ]]; then
		printf "Provide all three flags: password, benaddress and ChainDB websource!\n";
        exit 1;
    else
		# Flag direct to install start up of the script
        install1
    fi
else
	# Normal menus start of the script
	username="nkn"
	mode="whatever"
	database="whatever"
	installation="whatever"
	menu
fi
