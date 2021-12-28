## Expected Results
Perl for z/OS is a work in progress. Not everything passes, the quality should continually get better, or at a minimum, get no worse. 
When requesting a Push Request (PR) against blead, do the following first:

### Ensure you have the latest EBCDIC code
On a system that has Perl:
 - `git clone` of blead (or `git pull` if you have previously cloned)
 - `cd perl`
 - `Porting/makerel -e` (this step requires that you have a functioning Perl)
 - Run the tar command printed out, if it fails, from the `blead` directory
 - sftp the tarball to z/OS, e.g. /tmp

On z/OS:
 - `cd /tmp`
 - `gunzip perl*.gz` to unzip the file you uploaded
 - `tar -xvf perl*.tar` to untar into `<perl-directory>`
 - `mv <perl-directory> ${PERL_PORT}/ebcdic/perl5.local`
 - [Optional] remove /tmp/perl-*.tar 

## Building and testing Perl on z/OS

```
cd ${PERL_PORT}
. ./setenv.sh
nohup buildbleadvariants.sh &
grep 'Summary' nohup.out
```
`buildbleadvariants.sh` will perform 8 builds, across the combination of ASCII/EBCDIC, 31-bit/64-bit, Static/Dynamic and will print out a summary report. 

and then update this file with your dated results

## December 24th, 2021 Results: 
```
blead.64.dynamic.ebcdic Summary: Failed 96 tests out of 1949, 95.07% okay.
blead.64.dynamic.ascii Summary: Failed 37 tests out of 2479, 98.51% okay.
blead.64.static.ebcdic Summary: Failed 97 tests out of 1829, 94.70% okay.
blead.64.static.ascii Summary: Failed 47 tests out of 2358, 98.01% okay.
blead.31.dynamic.ebcdic Summary: Failed 97 tests out of 1945, 95.01% okay.
blead.31.dynamic.ascii Summary: Failed 39 tests out of 2475, 98.42% okay.
blead.31.static.ebcdic Summary: Failed 98 tests out of 1825, 94.63% okay.
blead.31.static.ascii Summary: Failed 52 tests out of 2354, 97.79% okay.
```