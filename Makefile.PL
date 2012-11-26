use strict;
use warnings;
use ExtUtils::MakeMaker ##{ $eumm_version ##};
use File::Spec;

##{ $share_dir_code{preamble} || '' ##}
 
my ##{ 
  my $write_makefile_args = $plugin->write_makefile_args;
  delete $write_makefile_args->{MIN_PERL_VERSION};
   my $makefile_args_dumper = Data::Dumper->new(
     [ $write_makefile_args ],
     [ '*WriteMakefileArgs' ],
   );
   $makefile_args_dumper->Sortkeys( 1 );
   $makefile_args_dumper->Indent( 1 );
   $makefile_args_dumper->Useqq( 1 );
   $makefile_args_dumper->Dump;
##}

my $sep = $^O eq 'MSWin32' ? ';' : ':';
my $ext = $^O =~ /^(MSWin32|cygwin)$/ ? '.exe' : '';
my %found;
foreach my $path (split $sep, $ENV{PATH})
{
  foreach my $program (qw( mv cp rm ))
  {
    my $exe = File::Spec->catfile($path, "$program$ext");
    if(-x $exe)
    {
      $found{$program} = 1;
    }
  }
}

foreach my $program (qw( mv cp rm ))
{
  warn "not found: $program" unless $found{$program};
}

unless($found{mv} && $found{cp} && $found{rm})
{
  warn "this distribution requires GNU Coreutils (mv, cp, rm and ln), or equivalent";
  if($^O eq 'MSWin32')
  {
    warn "can be downloaded from the GnuWin32 project: http://gnuwin32.sourceforge.net/";
  }
  exit 2;
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}
 
delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };
 
WriteMakefile(%WriteMakefileArgs);
 
##{ $share_dir_code{postamble} || '' ##}

