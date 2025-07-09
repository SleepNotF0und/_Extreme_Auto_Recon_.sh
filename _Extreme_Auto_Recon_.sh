#!/bin/bash

# Function to print usage
usage() {
    echo "Usage: $0 -d <domain> | -l <domains_list> [-shodan]"
    exit 1
}


# Initialize variables
TARGET=""
LIST=""
USE_SHODAN=false
MODE=""

# Manual arguments parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d)
            TARGET="$2"
            MODE="single"
            shift 2
            ;;
        -l)
            LIST="$2"
            MODE="list"
            shift 2
            ;;
        -shodan)
            USE_SHODAN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done


# Validate input
if [[ "$MODE" != "single" && "$MODE" != "list" ]]; then
    usage
fi

# Create _Recon_Results_ directory if it doesn't exist
mkdir -p _Recon_Results_


# Single domain enumeration
if [ "$MODE" == "single" ]; then
    OUTPUT_PREFIX="$TARGET"
    echo "[+] Running enumeration for domain: $TARGET"

    ./findomain -t "$TARGET" --no-wildcards -u "./_Recon_Results_/${OUTPUT_PREFIX}-findomain-Subs.txt"
    #./amass enum -active -d "$TARGET" -o "./_Recon_Results_/${OUTPUT_PREFIX}-amass-Subs.txt" -p 80,443,8000,8080,8443
    ./subfinder -d "$TARGET" -recursive -all -o "./_Recon_Results_/${OUTPUT_PREFIX}-subfinder-Subs.txt"
    #./ffuf -u http://FUZZ."$TARGET" -w ./best-dns-wordlist.txt -mc 200,403,404,301,302,500,201,401 -rate 2 -o "./_Recon_Results_/${OUTPUT_PREFIX}-ffuf-brute-Subs.txt"
    ./github-subdomains.sh -d "$TARGET" "" -o "./_Recon_Results_/${OUTPUT_PREFIX}-github-subdomains.txt" -v

    if [ "$USE_SHODAN" == true ]; then
        python SHDN-HUNT.py -d "$TARGET" -o "./_Recon_Results_/${OUTPUT_PREFIX}-shdn-hunt.txt"
    fi

    cat "./_Recon_Results_/${OUTPUT_PREFIX}-findomain-Subs.txt" \
        "./_Recon_Results_/${OUTPUT_PREFIX}-github-subdomains.txt" \
        ${USE_SHODAN:+ "./_Recon_Results_/${OUTPUT_PREFIX}-shdn-hunt.txt"} \
        "./_Recon_Results_/${OUTPUT_PREFIX}-subfinder-Subs.txt" | sort -u > "./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt"

    ./nuclei -l "./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt" -t takeovers/

    # Cleanup
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-findomain-Subs.txt"
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-github-subdomains.txt"
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-subfinder-Subs.txt"
    if [ "$USE_SHODAN" == true ]; then
        rm "./_Recon_Results_/${OUTPUT_PREFIX}-shdn-hunt.txt"
    fi

    echo "[+] Results saved in ./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt"

    ./httpx -l ./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt -title -follow-redirects -status-code -web-server -ports 80,443,8443,8080,8000,8081 -silent -o ./_Recon_Results_/${OUTPUT_PREFIX}-httpx-Final-subs.txt -fc 400
    echo "[+] HTTPX results saved in ./_Recon_Results_/${OUTPUT_PREFIX}-httpx-Final-subs.txt"
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt"





# List of domains enumeration
elif [ "$MODE" == "list" ]; then
    OUTPUT_PREFIX="$LIST"
    echo "[+] Running enumeration for list of domains: $LIST"

    ./findomain -f "$LIST" --no-wildcards -u "./_Recon_Results_/${OUTPUT_PREFIX}-findomain-Subs.txt"
    # ./amass enum -active -df "$LIST" -o "./_Recon_Results_/${OUTPUT_PREFIX}-amass-Subs.txt" -p 80,443,8000,8080,8443
    ./subfinder -dL "$LIST" -recursive -all -o "./_Recon_Results_/${OUTPUT_PREFIX}-subfinder-Subs.txt"
    # ./ffuf -u http://FUZZ."$domain" -w ./best-dns-wordlist.txt -mc 200,403,404,301,302,500,201,401 -rate 2 -o "./_Recon_Results_/${OUTPUT_PREFIX}-ffuf-brute-Subs.txt"
    ./github-subdomains.sh -l "$LIST" "" -o "./_Recon_Results_/${OUTPUT_PREFIX}-github-subdomains.txt" -v

    if [ "$USE_SHODAN" == true ]; then
        python SHDN-HUNT.py -l "$LIST" -o "./_Recon_Results_/${OUTPUT_PREFIX}-shdn-hunt.txt"
    fi

    cat "./_Recon_Results_/${OUTPUT_PREFIX}-findomain-Subs.txt" \
        "./_Recon_Results_/${OUTPUT_PREFIX}-github-subdomains.txt" \
        ${USE_SHODAN:+ "./_Recon_Results_/${OUTPUT_PREFIX}-shdn-hunt.txt"} \
        "./_Recon_Results_/${OUTPUT_PREFIX}-subfinder-Subs.txt" | sort -u > "./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt"

    ./nuclei -l "./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt" -t takeovers/

    # Cleanup
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-findomain-Subs.txt"
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-github-subdomains.txt"
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-subfinder-Subs.txt"
    if [ "$USE_SHODAN" == true ]; then
        rm "./_Recon_Results_/${OUTPUT_PREFIX}-shdn-hunt.txt"
    fi

    echo "[+] Results saved in ./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt"

    ./httpx -l "./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt" -title -follow-redirects -status-code -web-server -ports 80,443,8443,8080,8000,8081 -silent -threads 30 -o "./_Recon_Results_/${OUTPUT_PREFIX}-httpx-Final-subs.txt" -fc 400
    echo "[+] HTTPX results saved in ./_Recon_Results_/${OUTPUT_PREFIX}-httpx-Final-subs.txt"
    rm "./_Recon_Results_/${OUTPUT_PREFIX}-Final-subs.txt"
fi
