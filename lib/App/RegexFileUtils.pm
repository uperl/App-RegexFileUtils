package App::RegexFileUtils;

use strict;
use warnings;

# ABSTRACT: use regexes with file utils like rm, cp, mv, ln
# VERSION

sub main {
  my $class = shift;
  my $mode = shift;
  my $appname = $mode;
  $mode =~ s!^.*/!!;
  my @args = @_;
  
  my @options = ();
  my $verbose = 0;
  my $do_hidden = 0;
  my $re;
  my $sub;
  my $regulations;
  my $tr;
  
  while(defined($args[0]) && $args[0] =~ /^-/) {
    my $arg = shift @args;
  
    if($arg =~ /^--recmd$/) {
      $mode = shift @args;
      $mode =~ s!^.*/!!;
    } elsif($arg =~ /^--reverbose$/) {
      $verbose = 1;
    } elsif($arg =~ /^--reall$/) {
      $do_hidden = 1;
    } else {
      push @options, $arg;
    }
  }
  
  my $dest = pop @args;
  
  unless(defined $dest) {
    print STDERR "usage: $appname [options] [source files] /pattern/[substitution/]\n";
    print STDERR "\n";
    print STDERR "--recmd [command]      change the behavior of the tool\n";
    print STDERR "--verbose              print commands before they are executed\n";
    print STDERR "--reall                include hidden (so called `dot') files\n";
    print STDERR "\n";
    print STDERR "all other arguments are passed to the system tool\n";
    exit;
  }
  
  my $orig_mode = $mode;
  $mode =~ s/^re//;
  
  my %modes = (
    'mv'    => 'mv',
    'move'    => 'mv',
    'rename'  => 'mv',
    'cp'    => 'cp',
    'copy'    => 'cp',
    'ln'    => 'ln',
    'link'    => 'ln',
    'symlink'  => 'ln',
    'rm'    => 'rm',
    'remove'  => 'rm',
    'unlink'  => 'rm',
    'touch'    => 'touch',
  );
  
  unshift @options, '-s' if $mode eq 'symlink';
  
  $mode = $modes{$mode};
  unless(defined $mode) {
    print STDERR "unknown mode $orig_mode\n";
    exit;
  }
  
  my $no_dest = 0;
  if($mode eq 'touch' || $mode eq 'rm') {
    $no_dest = 1;
  }
  
  my @files = @args;
  
  if(@files ==0) {
    opendir(DIR, '.') || die "unable to opendir `.' $!";
    @files = readdir(DIR);
    closedir DIR;
  }
  
  if($dest =~ m!^(s|)/(.*)/(.*)/([ig]*)$!) {
    $re = $2;
    $sub = $3;
    $regulations = $4;
  
    if($no_dest) {
      print STDERR "substitution `$mode' doesn't make sense\n";
      exit;
    }
  
  }
  
  elsif($dest =~ m!tr/(.*)/(.*)/$!) {
    $tr = $1;
    $sub = $2;
  
    if($no_dest) {
      print STDERR "translation `$mode' doesn't make sense\n";
    }
  }
  
  elsif($dest =~ m!^(m|)/(.*)/([i]*)$!) {
    $re = $2;
    $regulations = $3;
  }
  
  else {
    die "$dest did not match\n";
  }
  
  for(@files) {
    next if /^\./ && !$do_hidden;
    next unless /$re/ || defined $tr;
    my $old = $_;
    my $new = $old;
  
    if(defined $tr) {
      eval "\$new =~ tr/$tr/$sub/"
    } elsif(defined $sub) {
      eval "\$new =~ s/$re/$sub/$regulations"
    } else {
      if($no_dest) {
        $new = '';
      } else {
        $new = '.';
      }
    }
  
    my $cmd = "$mode @options \"$old\" \"$new\"";
    print "% $cmd\n" if $verbose;
  
    my $pid;
    if(($pid = fork()) == 0) {
      exec($cmd);
    }
  
    unless(defined $pid) {
      print STDERR "error in fork() $!";
    }
  
    wait;
  }
}

1;
