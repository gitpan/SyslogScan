#!/usr/bin/perl

use strict;

print "1..4\n";
print "Running automated test suite for $0:\n\n";

require "dumpvar.pl";

print "ok 1\n\n";

my $testRoot = "znullTest";

my $testDir = "t";
chdir($testDir) || die "could not cd into testdir $testDir";

my $tmpDir = "tmp.$$";
my $testTmp = "$tmpDir/$testRoot.tmp";
my $testRef = "$testRoot.ref";
mkdir($tmpDir,0777) || die "could not create $tmpDir";
open(TEST,">$testTmp") || die "could not open $testTmp for write: $!";

my $goodLog = "good_syslog";
my $prevLog = "prev_syslog";

my $cmd = "cd ..";
my $switch;
foreach $switch (" u  U healthnet.org:NOT:time t/$goodLog",
		 " g  U healthnet.org  T 6.13.96 t/$prevLog t/$goodLog",
		 " m t/$prevLog t/$goodLog",
		 " m  T 834624000..834710400  o t/cache.sto t/$prevLog t/$goodLog",
		 " i t/cache.sto")
{
    $cmd .= " && echo ./read_mail_log.pl  q $switch";
}
$cmd .= " && cat t/SummaryTest.ref t/$goodLog t/SummaryTest.ref";

open(PROG,"$cmd |");

print "ok 2\n";

select(TEST);
while (<PROG>)
{
    print;
}
close(PROG);
($? >> 8) and die "echo returned nonzero status";

close(TEST);

select(STDOUT);

print "ok 3\n";

my $retval =
    system("perl -pi.bak -e 's/(HASH|ARRAY).+/\$1/g' $testTmp") >> 8;

if (! $retval)
{
    $retval = system("diff $testRef $testTmp") >> 8;
}

if (! $retval)
{
    print STDOUT "$0 produces same variable dump as expected.\n";
    unlink("$testTmp.bak");
    unlink("$tmpDir/cache.sto");
    unlink($testTmp);
    rmdir($tmpDir);
    print STDOUT "ok 4\n\n";
}
else
{
    print STDERR "maybe out of disk space?\n";
    print STDOUT "not ok 4\n\n";
}

exit $retval;
