Automation bash script which automate my recon methodology in the bug bounty
.  
## Key Features:-  
###  1. Recon for a list of domains or single domain:-  
......using findomain  
......using subfinder  
......using amass  
(Migrate & filter unique subdomain)  
.  
### 2- Recon using shodan API using SHDN-HUNT.py  
### 3- Subdomain DNS fuzzing (!!! If Enabled !!!)  
.......using amass  
.......using ffuf custom dns wirdlist as best-dns-wordlist.txt  
.  
### 4- Recon on github repos using github-subdomains.sh  
### 5- Check for Subdomain Takeover using Nuclei  
### 6- Subdomain probing using httpx with customized rate limit & bandwith balance  
.  
.  
### USAGE:-  
./_Extreme_Auto_Recon_.sh -d <<-DOMAIN->> -shodan  
./_Extreme_Auto_Recon_.sh -l <<-LIST.txt->> -shodan  
./_Extreme_Auto_Recon_.sh -d <<-DOMAIN->>  
.  
.  
### REQUIREMENTS:-  
SHDN-HUNT.py  
findomain bash  
subfinder bash  
amass Bash  
findomain bash  
nuclei bash  
httpx bash  
github-subdomains.sh bash  
ffuf bash  
best-dns-wordlist.txt  
