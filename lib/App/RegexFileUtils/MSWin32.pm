package App::RegexFileUtils::MSWin32;

use strict;
use warnings;
use File::ShareDir qw( dist_dir );
use File::Basename qw( dirname );

# ABSTRACT: MSWin32 specific code for App::RegexFileUtils
# VERSION

my $path;

sub App::RegexFileUtils::share_dir
{
  unless(defined $path)
  {
    if(defined $App::RegexFileUtils::MSWin32::VERSION && $INC{'App/RegexFileUtils/MSWin32.pm'} =~ /blib/)
    {
      $path = dirname(__FILE__) . "/../../../../share";
      undef $path unless $path && -d "$path/ppt";
    }
    
    eval {
      if(defined $App::RegexFileUtils::MSWin32::VERSION)
      {
        $path = dist_dir('App::RegexFileUtils');
      }
      undef $path unless $path && -d "$path/ppt";
    };
    
    unless(defined $path)
    {
      $path = dirname(__FILE__) . "/../../../share";
    }
    
    die 'can not find share directory' unless $path && -d "$path/ppt";    
  }
  
  $path;
}

1;
