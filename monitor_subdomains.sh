#!/bin/bash

# 🎯 Target domain (Change this)
TARGET_DOMAIN="oppo.com"

# Install subfinder and httpx if not installed
if ! command -v subfinder &> /dev/null; then
    echo "Installing subfinder..."
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
fi

if ! command -v httpx &> /dev/null; then
    echo "Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
fi

# Set Go binaries in path
export PATH=$PATH:$(go env GOPATH)/bin

# Run Subfinder
echo "[*] Running subfinder for $TARGET_DOMAIN..."
subfinder -d $TARGET_DOMAIN -silent | tee subdomains_new.txt

# Check for Live Subdomains using httpx
echo "[*] Checking for live subdomains..."
cat subdomains_new.txt | httpx -silent > live_subdomains.txt

# Compare with previous results
touch subdomains.txt # Ensure the file exists
if ! diff -q subdomains.txt live_subdomains.txt > /dev/null; then
    echo "[!] New subdomains found!"
    cp live_subdomains.txt subdomains.txt
    echo "::set-output name=changed::true"
else
    echo "[✓] No new subdomains detected."
    echo "::set-output name=changed::false"
fi
