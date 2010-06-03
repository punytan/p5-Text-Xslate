#!perl -w
use strict;

use Text::Xslate;
use Template;

use Time::HiRes qw(time);
use FindBin qw($Bin);

use Config; printf "Perl/%vd %s\n", $^V, $Config{archname};
foreach my $mod(qw(Text::Xslate Template)){
    print $mod, '/', $mod->VERSION, "\n";
}

my $tt = Template->new(
    INCLUDE_PATH => ["$Bin/template"],
    COMPILE_EXT  => '.out',
);
my $tx = Text::Xslate->new(
    path  => ["$Bin/template"],
    cache => 2
);

my %vars = (
    data => [
        ({ title => 'Programming Perl'}) x 100,
    ]
);
{
    my $out;
    $tt->process('list.tt', \%vars, \$out);
    $tx->render('list.tx', \%vars) eq $out or die $tx->render('list.tx', \%vars), "\n", $out;
}

$| = 1;

print "Template-Toolkit's process() x 1000\n";
my $start = time();
foreach (1 .. 1000) {
    print $_, "\r";
    $tt->process('list.tt', \%vars, \my $out);
}
print "\n";
my $tt_used = time() - $start;
printf "Used: %.03f sec.\n", $tt_used;

print "Text::Xslate's render() x 1000\n";
$start = time();
foreach (1 .. 1000) {
    print $_, "\r";
    my $out = $tx->render('list.tx', \%vars);
}
print "\n";
my $tx_used = time() - $start;
printf "Used: %.03f sec.\n", $tx_used;

printf "In this benchmark, Xslate is about %.01f times faster than Template-Tookit.\n",
    $tt_used / $tx_used;
