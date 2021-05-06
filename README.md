# ALL-in-ONE-nknnode
https://forum.nkn.org/t/allinone-nknnode-script-deploy-nodes-faster-with-your-own-chaindb/2753
NKN network miners need a blockchain database to operate, where every new miner synchronizes the ChainDB directly from other miners, but that takes up to several days. BUT, if you already have a fully synchronized miner, there's a way to compress the data into an archive, copy it and use it to "fast deploy" miners very fast.

# ALLinONE-nknnode 1.4.4 - Script features:
- NO spyware etc.
- Beginner mode: download/host ChainDB and install first NKN node
- Download ChainDB from NKN org and host it on THIS server
- Download ChainDB from known custom URL and host it on THIS server
- Create ChainDB from own node and host on the SAME server
- Create ChainDB from own node and host it on ANOTHER server
- Update old ChainDB file (only for chaindb hosts that also have a node installed)
- Custom URL for ChainDB node deploy (fast)
- no ChainDB deploy (starts syncing from 0, takes up to 5 days)
- Transfer old NODE ID / wallet to a new server
- in-script NKN node & wallet status monitor
- nWatch website NKN node & wallet status monitor

This script was tested on Ubuntu 20.04 server.
If you come across any bugs please let me know. Thank you!

# PREPARATION:
1. DO NOT USE Google Cloud server, AWS (Amazon "Free"), AZURE! They have hidden fees for traffic etc. Many reported high bills. Stick with Servercheap.net, Digital Ocean, Linode, Vultr, UpCloud, Hetzner... Get your free service coupons at https://vpstrial.net/vps/ for free servers for a few months. Create an account at these sites to deploy a VPS server.
 
2. Go to wallet.nkn.org to create a wallet, use a 20 character strong password, you can generate passwords at https://passwordsgenerator.net/ . After creating the wallet, save the secret seed number to a file along with your password and also download the wallet for another way to restore your wallet account. Make backups of it. Copy the NKN address as this will be your beneficiary address where you'll get paid.

3. To fully deploy a NKN node, you have to invest 10 mainnet NKN (not ERC-20 based NKN) PER NODE, or else the server won't start working. Link to get you started https://forum.nkn.org/t/guide-nkn-s-official-mainnet-token-swap-tool/1727

4. Deploying a server on VPS provider: use Ubuntu as operating system and for the very first server choose a server with 35+ GB of storage, so we can create a node and a ChainDB server on it.

VPS server sizes:
To deploy a ChainDB and node: 35+ GB
To deploy ChainDB only: 25 GB
To deploy NKN nodes: 25 GB

**Private IP check (Linode)**
**Be sure to "disable" VPS provider firewalls!**

5. Connect to the VPS server with software like [MobaXterm](https://mobaxterm.mobatek.net/download-home-edition.html),[Terminus](https://github.com/Eugeny/terminus/releases/tag/v1.0.137),[Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html), via the provided IP address and the password you choose or was provided to you by the VPS service website.

## VPS FIREWALLS:

Node server runs it's own firewall, so there's no need for VPS provider firewalls.

# STARTING THE SCRIPT:
1. **Switch to root user if not root yet:**

   `sudo su -`

2. **Start the script in terminal with this command:**

   `wget -O nkndeploy.sh 'https://raw.githubusercontent.com/no112358/ALLinONE-nknnode/main/nkndeploy.sh'; bash nkndeploy.sh `

## Debugging after installation:

Root user:   `sudo su -`

Find NKN miner directory: `cd "$(find / -type d -name "nkn-node" 2>/dev/null)"`

Check node status (same as nStatus.org): `./nknc info -s`

Use command `ls` to look for nkn-node.log or nkn-node.log.1

Open with: `nano nkn-node.log` or `nano nkn-node.log.1`
Exit with CTRL + X move up and down with page up & page down keyboard button

Look at node service: `systemctl status nkn-commercial.service`

Look at system journal: `journalctl -u nkn-commercial.service`