package App::RegexFileUtils::MSWin32;

package
  App::RegexFileUtils;

use strict;
use warnings;
use File::ShareDir qw( dist_dir );
use File::Basename qw( dirname );
use File::Spec;

# ABSTRACT: MSWin32 specific code for App::RegexFileUtils
# VERSION

warn "only needed on MSWin32" unless $^O eq 'MSWin32';

my $path;

sub share_dir
{
  unless(defined $path)
  {
    if(defined $App::RegexFileUtils::MSWin32::VERSION && $INC{'App/RegexFileUtils/MSWin32.pm'} =~ /blib/)
    {
      $path = File::Spec->catdir(
        dirname(__FILE__), 
        File::Spec->updir,
        File::Spec->updir,
        File::Spec->updir,
        File::Spec->updir,
        'share',
      );
      undef $path unless $path && -d "$path/ppt";
    }
    
    eval {
      if(defined $App::RegexFileUtils::MSWin32::VERSION)
      {
        $path = dist_dir('App-RegexFileUtils');
      }
      undef $path unless $path && -d "$path/ppt";
    };
    
    unless(defined $path)
    {
      $path = File::Spec->catdir(
        dirname(__FILE__),
        File::Spec->updir,
        File::Spec->updir,
        File::Spec->updir,
        'share',
      );
    }
    
    die 'can not find share directory' unless $path && -d "$path/ppt";    
  }
  
  $path;
}

sub fix_path
{
  my($class, $cmd) = @_;

  foreach my $path (split /;/, $ENV{PATH})
  {
    return if -x File::Spec->catfile($path, $cmd->[0] . '.exe');
  }

  $cmd->[0] = File::Spec->catfile(
    App::RegexFileUtils->share_dir,
    'ppt', $cmd->[0] . '.pl',
  );
  unshift @$cmd, $^X;
}

1;
