# Malicious_scan.pl
crawls the network its deployed on scanning for other devices and attempts to install a backdoor on wach device found.
Malicious Scan

This Perl script is a network scanner that looks for vulnerable machines on the same network and tries to infect them with a backdoor.
Installation

This script requires the following Perl modules to be installed:

    Net::Ping
    Net::Nmap::Scan
    Net::FTP
    File::Copy
    File::Basename
    File::Spec
    threads
    Term::ANSIColor
    Log::Log4perl

You can install them using CPAN or your package manager.
Usage

To run the script, simply execute it using Perl:

perl malicious_scan.pl

The script will start scanning for machines on the same network with port 22 (SSH) open. Once it finds vulnerable machines, it will try to connect to them using a list of common SSH passwords and upload a backdoor.
Configuration

You can configure the script by editing the following variables at the top of the script:

    $gateway: The IP address of the default gateway.
    $port: The port number to scan for vulnerable machines.
    $wordlist: The path to the file containing the list of common SSH passwords.
    $sleep: The number of seconds to sleep between scans.

Disclaimer

This script is intended for educational purposes only. Use it at your own risk and do not use it to harm others. The author is not responsible for any damage caused by this script.
