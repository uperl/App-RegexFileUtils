use strict;
use warnings;
use Test::More;
BEGIN { plan skip_all => 'only test on MSWin32' if $^O ne 'MSWin32' }
use App::RegexFileUtils;
use App::RegexFileUtils::MSWin32;
plan tests => 4;

my $dir = App::RegexFileUtils->share_dir;
ok -d $dir, "dir = $dir";

foreach my $cmd (qw( cp rm touch ))
{
  ok -e "$dir/ppt/$cmd.pl", "$dir/ppt/$cmd.pl";
}
