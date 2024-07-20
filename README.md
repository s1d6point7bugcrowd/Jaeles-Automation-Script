# Jaeles Automation Script

## Overview

This script automates the process of discovering subdomains, validating live URLs, and scanning them using Jaeles. It includes options for user inputs such as the target domain, out-of-scope patterns, Jaeles severity level, subdomains file, bug bounty program name, and the path to Jaeles signatures.

## Prerequisites

Ensure you have the following tools installed:
- [Subfinder](https://github.com/projectdiscovery/subfinder)
- [httpx](https://github.com/projectdiscovery/httpx)
- [Jaeles](https://github.com/jaeles-project/jaeles)
- [anew](https://github.com/tomnomnom/anew)

## Installation

To install the required tools, follow these steps:

1. **Install Subfinder:**
    ```sh
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    ```

2. **Install httpx:**
    ```sh
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    ```

3. **Install Jaeles:**
    ```sh
    go install github.com/jaeles-project/jaeles@latest
    ```

4. **Install anew:**
    ```sh
    go install github.com/tomnomnom/anew@latest
    ```

## Usage

1. **Make the script executable:**
    ```sh
    chmod +x scan.sh
    ```

2. **Run the script:**
    ```sh
    ./scan.sh
    ```

3. **Follow the prompts:**
    - Enter the target domain.
    - Enter comma-separated out-of-scope patterns.
    - Enter Jaeles severity level (e.g., 1, 2, 3, ...).
    - Enter the path to the subdomains file (leave empty to use subfinder and dnsx).
    - Enter the bug bounty program name.
    - Enter the path to Jaeles signatures (leave empty to use default: `/home/kali/jaeles-signatures`).

## Script Details

The script performs the following steps:

1. **Subdomain Discovery:**
    - If a subdomains file is provided, it uses the file. Otherwise, it runs subfinder to discover subdomains.

2. **Live URL Validation:**
    - Uses httpx to validate the discovered subdomains and filter live URLs.

3. **Jaeles Scanning:**
    - Scans the live URLs using Jaeles with the provided severity level and custom header.

4. **Report Generation:**
    - Generates a detailed report of the scan results.

## Example Output

```sh
Enter the target domain: example.com
Enter comma-separated OOS patterns: out.of.scope.com,another.out.of.scope.com
Enter Jaeles severity level (e.g., 1, 2, 3, ...): 2
Enter the path to the subdomains file (leave empty to use subfinder and dnsx): 
Enter the bug bounty program name: bugcrowd
Enter the path to Jaeles signatures (leave empty to use default: /home/kali/jaeles-signatures): /path/to/custom/signatures

Running subfinder to discover subdomains...
Subdomains discovered:
sub1.example.com
sub2.example.com

Validating live URLs using httpx...
Live URLs validated:
https://sub1.example.com
https://sub2.example.com

Running Jaeles scans on live URLs...
Running: jaeles scan -L 2 -c 20 -s /path/to/custom/signatures/* -u https://sub1.example.com -H "X-Bug-bounty: insert-username-here" -o example.com_jaeles_results.txt
Running: jaeles scan -L 2 -c 20 -s /path/to/custom/signatures/* -u https://sub2.example.com -H "X-Bug-bounty:  insert-username-here" -o example.com_jaeles_results.txt

Generating the Jaeles report...
Scanning completed. Results saved to example.com_jaeles_results.txt and report generated at /home/kali/scanned/out.
