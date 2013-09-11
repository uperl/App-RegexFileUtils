use strict;
use warnings;
use Test::More tests => 4;
use File::Temp qw( tempdir );

my @cmds;
my $error;
BEGIN {
  *CORE::GLOBAL::system = sub {
    push @cmds, \@_;
    note "% @_";
    CORE::system(@_);
    $error = $?;
  };
}

use App::RegexFileUtils;
use File::Spec;

my $dir = tempdir( CLEANUP => 1);
chdir($dir) || die;

ok -d $dir, "dir = $dir";

foreach my $fn (qw( foo.txt bar.txt baz ))
{
  open my $fh, '>', $fn;
  close $fh;
}

App::RegexFileUtils->main('touch', '/\\.txt$/');

ok 'didn\'t die';

# commands could come in any order
@cmds = sort { $a->[1] cmp $b->[1] } @cmds;

is_deeply \@cmds,
  [ [ 'touch', 'bar.txt' ], [ 'touch', 'foo.txt' ] ],
  "touch bar.txt ; touch foo.txt ";

is $error, 0, '$? == 0';

chdir(File::Spec->updir) || die;
