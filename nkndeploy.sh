#!/bin/bash
#v1.1 Added method 5

method1(){
clear
printf "================================================================================\n"
printf "Setup: Download ChainDB from NKN.org  and host it on this server\n"
printf "To force exit this script press CTRL+C.\n"
printf "This will probably take a very long time, be patient!\n"
printf "================================================================================\n\n"

if [ $mode == "advanced" ]; then
printf "To host the file on this server you must have enough storage space.\n"
printf "20GB minimum, IF the server is only going to host the ChainDB and nothing else.\n"
printf "If you also want to run a NKN node on this server you neeed minimum 35GB.\n\n"

read -p "Press enter to continue!"
printf "\033[1A\033[2K"
fi

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

cd /var/www/html/ > /dev/null 2>&1

printf "Downloading ChainDB archive............................................. \n"
websource="https://nkn.org/ChainDB_pruned_latest.tar.gz"
wget --quiet --continue --show-progress $websource
printf "Downloading ChainDB archive............................................. DONE!\n\n"

# cleanup
filename=${websource##*/}
mv -f "$filename" ChainDB.tar.gz > /dev/null 2>&1
rm -f index.html > /dev/null 2>&1

# NEW websource for the install
websource="http://"$PUBLIC_IP"/ChainDB.tar.gz"

printf "You can now start the script on NEW servers you wanna deploy a node on with:\n\n"

printf "${red}"
printf "wget -O nkndeploy.sh 'http://107.152.46.244/nkndeploy.sh'; bash nkndeploy.sh\n\n"
printf "${normal}"

printf "Custom URL to the ChainDB archive. You will need this URL, make a copy of it!\n\n"
printf "${red}"
printf "http://%s/ChainDB.tar.gz\n\n" "$PUBLIC_IP"
printf "${normal}"

# if from beginner menu, then also install a node on this server
if [ $mode == "beginner" ]; then
	# Question
	read -r -p "Do you also want to install a NKN node on this server ? [y/n] " response
	case "$response" in
		[yY][eE][sS]|[yY])
		# correct continue script
		installation="local" ; userdata1 ;;
		*)
		# wrong exit
		menu ;;
	esac
else
    read -p "Press enter to continue!"
	menu
fi
}

method2(){
clear
printf "================================================================================\n"
printf "Setup: Create ChainDB from own node and host on the same server\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

printf "REQ.: Fully synced node (mining). To host the file on this server you must\n"
printf "have enough storage space 35GB.\n\n"

read -p "Press enter to continue!"
printf "\033[1A\033[2K"

printf "Installing Apache Web Server............................................ "
apt-get install apache2 -y > /dev/null 2>&1
printf "DONE!\n"

printf "Stopping NKN node software.............................................. "
systemctl stop nkn-commercial.service > /dev/null 2>&1
sleep 5
printf "DONE!\n"

# find directory and change dir to it
cd "$(find / -type d -name "nkn-node" 2>/dev/null)"

printf "Pruning ChainDB folder.................................................. "
./nknc pruning --pruning --lowmem > /dev/null 2>&1
printf "DONE!\n"

printf "Creating ChainDB archive................................................ \n"
tar cf - ./ChainDB -P | pv -s $(du -sb ./ChainDB | awk '{print $1}') | gzip > /var/www/html/ChainDB.tar.gz
printf "Create ChainDB archive.................................................. DONE!\n"

printf "Starting NKN node software.............................................. "
systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n"

rm -f /var/www/html/index.html > /dev/null 2>&1

printf "\nYou can now start the script on NEW servers you wanna deploy a node on with:\n\n"

printf "${red}"
printf "wget -O nkndeploy.sh 'http://107.152.46.244/nkndeploy.sh'; bash nkndeploy.sh\n\n"
printf "${normal}"

printf "Custom URL to the ChainDB archive. You will need this URL, make a copy of it!\n\n"
printf "${red}"
printf "http://%s/ChainDB.tar.gz\n\n" "$PUBLIC_IP"
printf "${normal}"
read -p "Press enter to continue!"
}

method3(){
clear
printf "================================================================================\n"
printf "Setup: Create ChainDB from own node and host it on another server\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

cat << "EOF"
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
EOF
printf "\nREAD CAREFULLY!\n\n"

printf "This process will make a ChainDB file on NKN node server and transfer it\n"
printf "to the web host server.\n\n"

printf "You need to provide a WEB HOST SERVER! Make another VPS server which you will\n"
printf "use to host the ChainDB file, so you can deploy your next NKN nodes faster!\n"
printf "REQ.: web host: 1 core, 512 MB RAM, 20GB storage minimum.\n\n"

read -p "Press enter to continue!"

method3host
}

method3host(){
clear
printf "================================================================================\n"
printf "Setup: Create ChainDB and host it on another server.\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

printf "We will now connect to the HOST server and configure it from this script.\n"
printf "After you put in the username and address, you will be asked to confirm the\n"
printf "ECDSA security. Type yes and hit enter. You will be asked for the password\n"
printf "to establish the SSH connection and to install software on the web host server.\n\n"

printf "Type in WEB HOST SERVER username:\n"
read sshusername

printf "\nType in WEB HOST SERVER IP address:\n"
read sship

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
cd "$(find / -type d -name "nkn-node" 2>/dev/null)"

printf "Pruning ChainDB folder.................................................. "
./nknc pruning --pruning --lowmem > /dev/null 2>&1
printf "DONE!\n"

printf "\nWe will now connect to the HOST server again and upload the ChainDB file.\n"

printf "You will be asked for the host server user password for the SSH connection\n\n"

tar zcf - ./ChainDB/ -P | pv -s $(du -sb ./ChainDB | awk '{print $1}') | ssh "$sshusername"@"$sship" "cat > /var/www/html/ChainDB.tar.gz"
printf "Upload complete......................................................... DONE!\n"

printf "Starting NKN node software.............................................. "
systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n"

printf "You can now start the script on NEW servers you wanna deploy a node on with:\n\n"

printf "${red}"
printf "wget -O nkndeploy.sh 'http://107.152.46.244/nkndeploy.sh'; bash nkndeploy.sh\n\n"
printf "${normal}"

printf "Custom URL to the ChainDB archive. You will need this URL, make a copy of it!\n\n"
printf "${red}"
printf "http://%s/ChainDB.tar.gz\n\n" "$sship"
printf "${normal}"

read -p "Press enter to continue!"
}

method4(){
clear
printf "================================================================================\n"
printf "Setup: Update existing ChainDB on your ChainDB host server\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

printf "UPDATE ONLY! Run only on previous ChainDB server!\n"
printf "REQ.: Fully synced node (mining). To host the file on this server you must\n"
printf "have enough storage space 35GB.\n\n"

read -p "Press enter to continue!"
printf "\033[1A\033[2K"

printf "Stopping NKN node software.............................................. "
systemctl stop nkn-commercial.service > /dev/null 2>&1
sleep 5
printf "DONE!\n"

# find directory and change dir to it
cd "$(find / -type d -name "nkn-node" 2>/dev/null)"

printf "Pruning ChainDB folder.................................................. "
./nknc pruning --pruning --lowmem > /dev/null 2>&1
printf "DONE!\n"

printf "Deleting OLD ChainDB archive............................................ "
rm -f Chain*.tar.gz > /dev/null 2>&1
rm -f /var/www/html/Chain*.tar.gz > /dev/null 2>&1
printf "DONE!\n"

printf "Creating NEW ChainDB archive............................................ \n"
tar cf - ./ChainDB -P | pv -s $(du -sb ./ChainDB | awk '{print $1}') | gzip > /var/www/html/ChainDB.tar.gz
printf "Create NEW ChainDB archive.............................................. DONE!\n"

printf "Starting NKN node software.............................................. "
sudo systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n\n"

printf "The ChainDB.tar.gz archive was updated.\n\n"

printf "Next time you install a node, it will use the new database.\n\n"

read -p "Press enter to continue!"
menu
}

method5(){
clear
printf "================================================================================\n"
printf "Setup: Download ChainDB from custom URL and host it on this server\n"
printf "To force exit this script press CTRL+C.\n"
printf "This will probably take some time, be patient!\n"
printf "================================================================================\n\n"

printf "FRESH server only! You must have enough storage space on VPS!\n"
printf "25GB minimum IF the server is only going to host the ChainDB and nothing else.\n"
printf "If you also want to run a NKN node on this server you neeed minimum 35GB.\n\n"

read -p "Press enter to continue!"
printf "\033[1A\033[2K"

printf "Enter the custom URL address where the ChainDB*.tar.gz is located at:\n"
read websource
printf "\n"

# URL CHECK
if curl --output /dev/null --silent --head --fail "$websource"; then
	printf "URL OK: %s\n" "$websource"
	read -t 4
	#continue if URL ok
else
	printf "ERROR URL does NOT exist: %s\n" "$websource"
	read -t 4
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

cd /var/www/html/ > /dev/null 2>&1

printf "Downloading ChainDB archive............................................. \n"
wget --quiet --continue --show-progress $websource
printf "Downloading ChainDB archive............................................. DONE!\n\n"

# cleanup
filename=${websource##*/}
mv -f "$filename" ChainDB.tar.gz > /dev/null 2>&1
rm -f index.html > /dev/null 2>&1

# NEW websource for the install
websource="http://"$PUBLIC_IP"/ChainDB.tar.gz"

printf "You can now start the script on NEW servers you wanna deploy a node on with:\n\n"

printf "${red}"
printf "wget -O nkndeploy.sh 'http://107.152.46.244/nkndeploy.sh'; bash nkndeploy.sh\n\n"
printf "${normal}"

printf "Custom URL to the ChainDB archive. You will need this URL, make a copy of it!\n\n"
printf "${red}"
printf "http://%s/ChainDB.tar.gz\n\n" "$PUBLIC_IP"
printf "${normal}"

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

################################ user input ####################################

function userdata1(){
clear
printf "================================================================================\n"
printf "Setup: necessary data input\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

# input NKN wallet address
printf "Enter the MAINNET! NKN address where you want to receive payments.\n"
printf "Example address: NKNFLRkm3uWZBxohoZAAfBgXPfs3Tp9oY4VQ\n\n"

printf "NKN Wallet address:\n"
read benaddress

# check wallet address lengh
walletlenght=`expr length "$benaddress"`

if [ $walletlenght == "36" ]; then
	# Continues script
	userdata2
else
	# restarts function F1
	printf "\nNKN address you entered is wrong.\n"
	printf "Use mainnet NKN wallet, NOT ERC-20.\n"
	printf "Address starts with NKN*\n\n"

	read -p "Press enter to continue!"
	userdata1
fi
}

function userdata2(){
clear
printf "================================================================================\n"
printf "Setup: necessary data input\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

printf "A new user will be created for security reasons. Please input any password.\n\n"

printf "Pre-set Username: %s\n\n" "$username"

printf "Password:\n"
read userpassword
userdata3
}

function userdata3(){
if [ $installtype == "custom" ]; then
	clear
	printf "================================================================================\n"
	printf "Setup: necessary data input\n"
	printf "To force exit this script press CTRL+C.\n"
	printf "================================================================================\n\n"

	printf "Enter the custom URL address where the ChainDB*.tar.gz is located at:\n"
	read websource
	printf "\n"

	if curl --output /dev/null --silent --head --fail "$websource"; then
		printf "URL OK: %s\n" "$websource"
		read -t 4
		userdata4
	else
		printf "ERROR URL does NOT exist: %s\n" "$websource"
		read -t 4
		userdata3
	fi
else
	userdata4
fi
}

function userdata4(){
clear
printf "================================================================================\n"
printf "Setup: necessary data input\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

# Check data if true
printf "Check what you entered:\n\n"

printf "Wallet address: %s\n" "$benaddress"
printf "Username: %s\n" "$username"
printf "Password: %s\n" "$userpassword"
printf "Chain database source: %s\n\n" "$websource"


# if beginner skip web source
#if [ $mode == "beginner" ]; then
#	printf "\n"
#else
#	printf "Chain database source: %s\n\n" "$websource"
#fi



# ASK if the entered data is correct
read -r -p "Are you sure this data is correct? [y/n] " response
case "$response" in
    [yY][eE][sS]|[yY])
	#correct continue script
	install1 ;;
    *)
	#wrong restarts userdata input
	userdata1
	;;
esac
}

############################# Firewall warning #################################
function firewallwarn(){
clear
# revert all changes
/home/$username/nkn-commercial/nkn-commercial uninstall > /dev/null 2>&1
cd / > /dev/null 2>&1
pkill -KILL -u "$username" > /dev/null 2>&1
deluser --remove-home "$username" > /dev/null 2>&1

printf "${red}"
printf "A modem/router or VPS provided firewall is prohobiting access to the internet!\n"
printf "Please disable the firewall and allow all internet through.\n\n"

printf "The system changes were REVERTED, once you fix the firewall settings\n"
printf "restart the server and just run the same script again\n\n"

printf "For info on how to do that visit:\n"
printf "https://forum.nkn.org/t/deploy-miners-faster-fast-deploy-ubuntu-custom-all-in-one-script-your-own-chaindb-no-donation/2753\n\n"
printf "${normal}"

read -p "Press enter to continue!"
exit
}

################################## Install #####################################

function install1(){
clear
cat << "EOF"
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
EOF
printf "\n================================================================================\n"
printf "This will take some time. Please be patient.\n"
printf "To force exit this script press CTRL+C.\n"
printf "================================================================================\n\n"

# disable firewall for the installation
ufw --force disable > /dev/null 2>&1

# Create a new SUDO user
printf "Creating a new Super User account....................................... "
pass=$(perl -e 'print crypt($ARGV[0], "password")' $userpassword) > /dev/null 2>&1
useradd -m -p "$pass" -s /bin/bash "$username" > /dev/null 2>&1
usermod -a -G sudo $username > /dev/null 2>&1
printf "DONE!\n"

# Install NKN node miner software
printf "Downloading NKN node software........................................... "
cd /home/$username > /dev/null 2>&1
wget --quiet --continue https://commercial.nkn.org/downloads/nkn-commercial/linux-amd64.zip > /dev/null 2>&1
printf "DONE!\n"

printf "Installing NKN node software............................................ "
unzip linux-amd64.zip > /dev/null 2>&1
rm -f linux-amd64.zip > /dev/null 2>&1
mv linux-amd64 nkn-commercial > /dev/null 2>&1

chown -R $username:$username /home/$username > /dev/null 2>&1
chmod -R 755 /home/$username > /dev/null 2>&1

/home/$username/nkn-commercial/nkn-commercial -b $benaddress -d /home/$username/nkn-commercial/ -u $username install > /dev/null 2>&1
printf "DONE!\n"

# Wait for DIR and wallet creation
DIR="/home/$username/nkn-commercial/services/nkn-node/"
if [ $database == "no" ]; then
	# script skips DB download and continues
    install3
else
	printf "Waiting for NKN node software to start.................................. "

	timestart=$(date +%s)
	while [[ $(($(date +%s) - $timestart)) -lt 300 ]]; do # 300sec 5 min
		if [ ! -d "$DIR"ChainDB ] && [ ! -f "$DIR"wallet.json ]; then
			# if folder and file don't exist wait and repeat check
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
cd "$DIR" > /dev/null 2>&1
rm -rf ChainDB/ > /dev/null 2>&1

# if from beginner menu, extract locally, if not download from websource
if [ $installation == "local" ]; then
	cd /var/www/html/
	#printf "LOCAL!\n"
	pv ChainDB.tar.gz | tar xzf - -C "$DIR"
else
    # internet download
	wget -O - "$websource" -q --show-progress | tar -xzf -
fi

chown -R $username:$username /home/$username > /dev/null 2>&1
chmod -R 755 /home/$username > /dev/null 2>&1

printf "Downloading / Extracting NKN Chain database............................. DONE!\n"

install3
}

function install3(){
# Configure Firewall and ports
printf "Configuring firewall.................................................... "
ufw allow 30001 > /dev/null 2>&1
ufw allow 30002 > /dev/null 2>&1
ufw allow 30003 > /dev/null 2>&1
ufw allow 30004 > /dev/null 2>&1
ufw allow 30005 > /dev/null 2>&1
ufw allow 30010/tcp > /dev/null 2>&1
ufw allow 30011/udp > /dev/null 2>&1
ufw allow 30020/tcp > /dev/null 2>&1
ufw allow 30021/udp > /dev/null 2>&1
ufw allow 32768:65535/tcp > /dev/null 2>&1
ufw allow 32768:65535/udp > /dev/null 2>&1
ufw allow 22 > /dev/null 2>&1
ufw allow 80 > /dev/null 2>&1
ufw allow 443 > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1

systemctl start nkn-commercial.service > /dev/null 2>&1
printf "DONE!\n"

# Disable root password, to enable root again:
# sudo passwd root
# sudo passwd -u root
printf "Disabling Root account for security reasons............................. "
passwd --lock root > /dev/null 2>&1
printf "DONE!\n"
install4
}

function install4(){
printf "\n===============================================================================\n"
printf "Congratulations, you deployed a NKN node!\n"
printf "===============================================================================\n\n"

printf "NKN wallet address: %s\n\n" "$benaddress"

printf "From now on use these settings to connect to your server:\n"
printf "If you're using AWS, Google Cloud, Azure... use the provided keys to login.\n\n"

printf "Server IP: %s\n" "$PUBLIC_IP"
printf "Server username: %s\n" "$username"
printf "Server password: %s\n" "$userpassword"
printf "SSH login: ssh %s@%s\n\n" "$username" "$PUBLIC_IP"

printf "The server should be visible on nstatus.org in a few minutes.\n"
printf "Enter the Server IP provided here!\n"
printf "The node will take an hour or two do it's thing, so dont' worry.\n\n"

printf "Thanks for using this script!\n\n"

exit
}

################################## Menu stuff ##################################

menuadvanced() {
until [ "$selection" = "0" ]; do
clear
cat << "EOF"
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
EOF
printf "\n================================================================================\n\n"

printf "NKN ChainDB creation:\n"
printf "1) Download ChainDB from NKN.org and host it on THIS server\n"
printf "2) Download ChainDB from a custom URL and host it on THIS server\n"
printf "3) Create ChainDB from own node and host on the SAME server\n"
printf "4) Create ChainDB from own node and host it on ANOTHER server\n"
printf "5) Update existing ChainDB on your ChainDB host server\n\n"


printf "NKN Node server install:\n"
printf "6) via custom server (requires URL to ChainDB*.tar.gz)\n"
printf "7) no ChainDB install, sync starts from 0 (takes a long time)\n\n"

printf "10) Go back to first menu\n"
printf "0) Exit\n\n"
printf "Enter selection: "
read selection
printf "\n"

case $selection in
	1 ) mode="advanced" ; method1 ;;
	2 ) method5 ;;
	3 ) method2 ;;
	4 ) method3 ;;
	5 ) method4 ;;

	6 ) installtype="custom" ; database="yes" ; userdata1 ;;
    7 ) database="no" ; websource="none" ; userdata1 ;;

	10 ) menu ;;
	0 ) clear ; exit ;;
	* ) read -p "Wrong selection press enter to continue!" ;;
esac
done
}

menubeginner() {
until [ "$selection" = "0" ]; do
clear
printf "${blue}"
printf "STEP 1: I have no NKN nodes / servers:\n\n"

printf "YOU NEED TO DO THIS STEP ONLY ONE TIME!\n\n"

printf "Hosting the ChainDB archive yourself is essential to deploy your nodes\n"
printf "fast. Get the cheapest server with 1GB+ RAM and 35+ GB of storage\n"
printf "to store the ChainDB archive and start your first NKN node.\n\n"

printf "Free credits for server providers: https://vpstrial.net/vps/\n\n"

printf "If THIS server already has enough storage space, then you don't\n"
printf "need to create a new one you can just continue by selecting STEP 1.\n\n"
printf "${normal}"

printf "${magenta}"
printf "STEP 2: Deploy new nodes:\n\n"

printf "RUN STEP 2 ONLY ON NEW SERVERS, not on the first one you created!\n\n"
printf "Make a new 1core, 1GB RAM, minium 25GB storage ubuntu 20.04+ server\n"
printf "and use the custom URL address provided to you in the first part of the\n"
printf "script to deploy new node servers.\n\n"
printf "${normal}"

printf "1) STEP 1: I have no NKN nodes / servers\n"
printf "3) STEP 2: Deploy new nodes\n\n"

printf "5) Go back to first menu\n"
printf "0) Exit\n\n"

printf "Enter selection: "
read selection
printf "\n"

case $selection in
	1 ) mode="beginner" ; database="yes" ; method1 ;;
	2 ) read -p "Put on your glasses and press enter to continue :D " ; menubeginner ;;
	3 ) installtype="custom" ; database="yes" ; userdata1 ;;

	5 ) menu ;;
	0 ) clear ; exit ;;
	* ) read -p "Wrong selection press enter to continue!" ;;
esac
done
}

menu() {
until [ "$selection" = "0" ]; do
clear
cat << "EOF"
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
EOF
printf "\n================================================================================\n\n"

printf "Welcome to no112358 script for deploying NKN node servers!\n\n"

printf "READ CAREFULLY!\n\n"

printf "${blue}"
printf "1) BEGINNERS SELECT 1!\n\n"
printf "${normal}"

printf "${red}"
printf "3) ADVANCED USER!\n\n"
printf "${normal}"

printf "0) Exit\n\n"

printf "Enter selection: "
read selection
printf "\n"

case $selection in
        1 ) menubeginner ;;
        3 ) menuadvanced ;;
        0 ) clear ; exit ;;
        * ) read -p "Wrong selection press enter to continue!" ;;
esac
done
}

###################### Start of the script with Root check ####################

# Define colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
normal=$(tput sgr0)
underline=$(tput smul)

if [[ $EUID > 0 ]]; then
printf "${red}"
printf "\n=================================\n"
printf "PLEASE RUN AS ROOT USER! Type in:\n\n"

printf "sudo su -\n\n"

printf "and then run the script again.\n"
printf "=================================\n"
printf "${normal}"
exit
fi




# Start point
apt-get update -y; apt-get upgrade -y
apt-get install unzip glances vnstat ufw pv -y
username="nkn"
mode="whatever"
database="whatever"
installation="whatever"
PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
menu
