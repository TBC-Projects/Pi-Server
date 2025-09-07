# Pi Server Documentation
Note: The source for the website that is hosted on the server can be found [here](https://github.com/TBC-Projects/Website).  
## [Click here to visit the website.](https://www.boringclubuw.org)  

## Pi Server Report Out  

### Introduction
This document is intended to provide a comprehensive overview of our project's developments and serve as a reference tool for new members joining our team.  
This report serves two primary functions:
1. **Project Review:** The document provides details on our established objectives, achievements, encountered challenges, key learnings, and prospective future plans. This reflective evaluation allows our team to track progress, make necessary adjustments, and maintain a clear vision moving forward.
2. **New Member Orientation:** The report also serves as a detailed onboarding guide designed to assist new members in understanding the project's context, objectives, and intricacies. We intend this guide to expedite the acclimatization process and equip newcomers with the necessary knowledge to contribute effectively in the forthcoming quarter.

### About the Project
- Project Title: Raspberry Pi Server
- Project Purpose: To familiarize students with Linux, the hardware/software interface, cybersecurity and web development
- Brief Description: Building and operating a server and a website to host on it.
- Report Authors: Sam Mansouri, Adelin Ma, Hudson Wong, Nicolas Berredo

### Accomplishments
- Deliverable: A globally accessible, functional club website hosted on the Raspberry Pi
- Outcome: The website is accessible via any device with access to the World Wide Web, running on the Raspberry Pi, and configurable via git and a deployment script. Memory is periodically dumped and access requests are rate limited to ensure continuous uptime.

### Challenges Faced 
- Could not ssh into the Raspberry Pi without a LAN connection
  - Solution
    - Either configure Wi-Fi connection before formatting the OS on the drive, or bring a keyboard to establish a connection after the Pi is set up.
  - Lesson Learned
    - Always have a way of interfacing directly with the Pi in case SSH has issues
- For the animation on our project page, there was a problem where the images were not scrolling properly. For images that are too wide, the additional part of the image would overflow into the next image, and sometimes the last image would not be displayed entirely. 
  - Solution: 
    - Firstly I took a look at the website and noticed that this problem was occurring in all the project card images, but not the image animation on the cover page. This means that the problem is specific to the .scroll-slides class in the css file.
    - I went into the css file and looked at the @keyframes scroll-slides which is the code controlling the animation and it seems like there were no issues. 
    - I went to the .scroll-slides img and noticed that images cover the box, but there was no line to remove the overhang if the images were not of the same size as the container. 
    - Added in overflow: hidden; line within the .scroll-slides img
  - Lesson Learned
    - Very important to know how to trace the source of your problems and know exactly what components are connected to which to notice any patterns. 
    - Perhaps have better documentation so that someone else who is working on the website could trace it as well. 
- Raspberry Pi would not open after running  sudo apt-get update, sudo apt-get upgrade
  - Solution
    - Running sudo apt-get upgrade was the command that appeared to break the SD card, so we opted to skip that step in favor of running just the update. This seemed to work. 
  - Lesson Learned
    - Keep backups, read command documentation carefully. 
    - To check whether the SD card is being read correctly, open up the Raspberry Pi. If it is running, there will be a red light indicating power and a flashing green light indicating that the SD card is being read. 
    - Do not run sudo apt-get upgrade? Needs some further research as to why this broke the system, since it generally should not affect anything. 
- Domain name is unavailable on Cloudflare
  - Solution
    - Go to your domain provider (in our case Squarespace)
    - Go to DNS, delete the existing domain nameservers, and replace them the ones provided by Cloudflare (found in your Cloudflare account under DNS)
Lesson Learned
    - It can take up to 24 hours for Cloudflare to recognize the nameservers so don’t expect to put a website up immediately after buying a domain.
    - Cloudflared is not finding .json file when building the tunnel
Solution
    - Find the true directory of your .json file. This may include typing whoami to find the name of your user directory. Update it accordingly.
    - Lesson Learned
    - Even if your pwd command shows the correct directory, the user in which you are running it may hide a layer of the file path
- CSS Changes are not updating with new deployment
  - Solution
    - Go to Cloudflare Dashboard, Caching, Configuration, and Purge Everything
    - Purging the cache will force the website to reload the CSS file, applying any changes you make
- Server is crashing every few days (requires reset) but otherwise working fine
  - Solution

``` Cloudflare fixes
sudo nano /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
Restart=always
ExecStart=/usr/local/bin/cloudflared tunnel run <YOUR-TUNNEL-NAME>

[Install]
WantedBy=multi-user.target
sudo systemctl daemon-reexec
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
Apache fixes
sudo nano /etc/apache2/mods-available/mpm_prefork.conf
MaxRequestWorkers 10
ServerLimit 10
StartServers 2
MinSpareServers 2
MaxSpareServers 5
sudo systemctl restart apache2
sudo systemctl enable apache2
sudo systemctl enable cloudflared
```
  - Lesson Learned
    - Even though the server may be running correctly, your work is not over. You still need to perform maintenance or set limitations automatically to protect server performance.
    
### Potential Improvements
- To update the website (current process)
  - A change is made to the main branch of TBC-Projects/Website (Follow the process outlined in TBC-Projects/Website/README.md)
  - Deploy the change
    - Navigate to home directory: ```cd ~/```
    - Run deploy.sh: ```./deploy.sh```
- Future improvement: set up Git auto-update via webhooks to skip the deploy.sh step.

### Relevant Resources
#### Key files, figures, algorithms
  - deploy.sh: Deploys the website update by pulling from Git and sending to Apache
    ``` #!/bin/bash
        
        # Define paths
        REPO_DIR="/home/boringpi/git/Website"   # change this to your actual git repo path
        TARGET_DIR="/var/www/html"
        
        echo ">>> Pulling latest changes from Git..."
        cd "$REPO_DIR" || { echo "❌ Failed to cd into repo directory"; exit 1; }
        
        git pull origin main || { echo "❌ Git pull failed"; exit 1; }
        
        echo ">>> Removing old files from $TARGET_DIR..."
        sudo rm -rf "$TARGET_DIR"/*
        
        echo ">>> Copying updated files to $TARGET_DIR..."
        sudo cp -r "$REPO_DIR"/* "$TARGET_DIR"
        echo ">>> Setting permissions..."
        sudo chown -R www-data:www-data "$TARGET_DIR"
        sudo chmod -R 755 "$TARGET_DIR"
        
        echo ">>> Restarting Apache..."
        sudo systemctl restart apache2
        
        echo "✅ Deployment complete!"
        ```
#### Software/platforms used, and their purpose
- Raspberry Pi Imager: Imaging OS to microSD and formatting drive
- Raspberry Pi OS Lite 64-bit: Operating System for the Raspberry Pi
- We chose the Lite version because it excludes unnecessary features, like GUI, which will save space for files
- Apache Web Server: Local application to host server on the Raspberry Pi
- Cloudflare: Used to create tunnels to open the server to the internet and configure DNS
- Squarespace domains: used to purchase the domain name boringclubuw.org
#### Languages used
- HTML
- CSS
- bash
#### [Perform a tunnel test](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/trycloudflare/)

### Other Information
#### Abbreviations
- SSH \- Secure Shell (connection protocol)
- LAN \- Local Area Network
- OS \- Operating System
- GUI \- Graphical User Interface
- IP \- Internet Protocol
- HTML \- HyperText Markup Language
- CSS \- Cascading Style Sheets
#### Contributors, Team Roles:
- Sam Mansouri, Project Lead and Deployment
- Sean Bubernak, Firmware
- Adelin Ma, Web Development
- Andrew Bechtel, Hardware
- Hudson Wong, Hardware
- Aashish Kumar, Cybersecurity
- Nicholas Berredo, Cybersecurity
  
