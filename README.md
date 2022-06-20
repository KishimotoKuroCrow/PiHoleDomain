Adds list of domains to PiHole
-------
sudo ./AddDomain.pl file\
sudo ./AddDomain.pl file1 file2\
sudo ./AddDomain.pl *.txt\
sudo ./AddDomain.pl *.txt anotherfile

Idea behind this script
-------
This script can only be run in Linux (tested under Arch Linux and Raspbian OS).

The script reads a list of files containing domains to blacklist using Pi-Hole. For each file, it concatenates 200 domains per command as follows:
- pihole -b -nr -q domain0 domain1 ... domain199

If the file has 10020 domains, then it generates 51 commands (the last one has 20 commands).

When all the files are processed, the script takes all these commands and splits them into 10 groups to show the completion rate. The last group contains:
- pihole restartdns

Note:
-------
Beware that this method is only suitable for small list. If using a large list of domains like from [OISD](https://github.com/sjhgvr/oisd.git), please set them as a host file and then add them using sqlite3 (as in my other PERL script AddList.pl) because it'll take hours to complete.\
The "MyDomainsToBlock" contains domains I've gathered over the span of a year to block.\
The OISD's dbl_*.txt lists are from [https://github.com/sjhgvr/oisd.git](https://github.com/sjhgvr/oisd.git).\
I won't update them here unless I update my PERL script. You should:

- Clone that repository (git clone https://github.com/sjhgvr/oisd.git)
- Use my script with the dbl_*.txt that you want
- Update that repository every now and then and re-add the domains wtih my script (git pull)
