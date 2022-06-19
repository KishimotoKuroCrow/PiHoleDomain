Adds list of domains to PiHole
----------------------------------------

sudo ./AddDomain.pl file
sudo ./AddDomain.pl file1 file2
sudo ./AddDomain.pl *.txt
sudo ./AddDomain.pl *.txt anotherfile


Note:
-------
The current lists are from https://github.com/sjhgvr/oisd.git
I won't update them here unless I update my PERL script. You should:

- Clone that repository (git clone https://github.com/sjhgvr/oisd.git)
- Use my script with the dbl_*.txt that you want
- Update that repository every now and then and re-add the domains wtih my script (git pull)
