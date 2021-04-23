# ALL-in-ONE-nknnode
NKN network miners need a blockchain database to operate, where every new miner synchronizes the ChainDB directly from other miners, but that takes up to several days. BUT, if you already have a fully synchronized miner, there's a way to compress the data into an archive, copy it and use it to "fast deploy" miners very fast.

# Script features:
- NO donation & NO spyware etc.
- Beginner mode: download/host ChainDB and install first NKN node
- Download ChainDB from NKN org and host it on THIS server
- Download ChainDB from known custom URL and host it on THIS server
- Create ChainDB from own node and host on the SAME server
- Create ChainDB from own node and host it on ANOTHER server
- Update old ChainDB file (only for chaindb hosts that also have a node installed)
- Custom URL for ChainDB node deploy (fast)
- no ChainDB deploy (starts syncing from 0, takes up to 5 days)

This script was tested on Ubuntu 20.04 server.
If you come across any bugs please let me know. Thank you!

# VPS FIREWALLS:
AWS (Amazon), Google Cloud, Azure
Pictures of how to set these services:
https://forum.nkn.org/t/deploy-miners-faster-fast-deploy-ubuntu-custom-all-in-one-script-your-own-chaindb-no-donation/2753

# PREPARATION:
**VPS server size:**
To deploy a ChainDB and node: 35+ GB min

To deploy ChainDB only: 25 GB min

To deploy NKN nodes: 25 GB min

**Operating system:** Ubuntu 20.04+

**Private IP check (Linode)**

**Be sure to "disable" VPS provider firewalls!**

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
