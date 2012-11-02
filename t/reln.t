use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use App::RegexFileUtils;
use File::Spec;

my $dir = tempdir( CLEANUP => 1);

chdir($dir) || die;

do {
  open(my $fh, '>', 'foo');
  close $fh;
  eval { symlink 'foo', 'bar' };
  if($@)
  { chdir(File::Spec->updir); plan skip_all => 'Test requires symlink' }
  else
  { plan tests => 9 }
};

ok -d $dir, "dir = $dir";

my @orig = qw( libfoo.so.1.2.3 libbar.so.1.2 );
for (@orig)
{ open my $fh, '>', $_; close $fh }

ok -e $_ && !-l $_, "orig $_" for @orig;

App::RegexFileUtils->main('ln', -s => '/\\.so\\..*$/.so/');

ok -e $_ && !-l $_, "still $_" for @orig;
ok -l 'libfoo.so', 'is symlink libfoo.so';
ok -l 'libbar.so', 'is symlink libbar.so';
is readlink('libfoo.so'), 'libfoo.so.1.2.3', 'libfoo.so => libfoo.so.1.2.3';
is readlink('libbar.so'), 'libbar.so.1.2',   'libbar.so => libbar.so.1.2';

chdir(File::Spec->updir) || die;