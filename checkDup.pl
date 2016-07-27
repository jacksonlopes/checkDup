#!/usr/bin/env perl

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Jackson Lopes <jacksonlopes@gmail.com>

use Digest::MD5;
use Getopt::Std;
use File::Find;
#use diagnostics;
#use Data::Dumper;

# receive parameters...
use vars qw/ %opt /;

# store infor hash files...
# key   => path + filename
# value => md5
my %hashFileMD5 = ();
my %hashFileDup = ();
my @listFilesErrorOpen = ();
my %options = ();
my $fileOut = "/tmp/checkDupScript.sh";
my $totalSizeFileDup = 0;


# check parameters
sub checkParameters() {  
  getopts("d:e:ghv", \%options ) or infoUsage();
  $tamHash = keys %options;
  infoUsage() if $options{'h'} or $tamHash == 0 or !$options{'d'};
}

sub infoUsage() {
  
  print "Using this program...\n";
  print "usage: $0 [-hvd] [-f file]\n\n";
  
  print "-d        : directory\n";
  print "-e        : excluse directory search\n";
  print "-g        : write script\n";
  print "-h        : show help\n";
  
  exit;
}

# Inicio
sub main() {
  checkParameters();
  if($options{'d'}) {
    checkMD5dir();
    getListFilesDup();
    showListFilesDup();
  } 
  print "* Size of duplicate files: " . getScaleSizeFile($totalSizeFileDup);
  print "\n* END\n";
}

# Get scale of file
sub getScaleSizeFile() {
    my( $size, $n ) =( shift, 0 );
    ++$n and $size /= 1024 until $size < 1024;
    return sprintf "%.2f %s",$size, ( qw[ bytes KB MB GB ] )[ $n ];
}


# Check all files in directory (recursive)
sub checkMD5dir() {  
  $sourceDir = $options{'d'};
  print "\n* Search duplicates in $sourceDir ...\n";
  find(\&getMD5, $sourceDir);
}

# get hash files
sub getMD5() {
  my $fileName = $File::Find::name if -f;  
  # If file and not null
  if( length($fileName) > 0 ) {
    # If filename contains directory.. not search.. return
    if( $options{'e'} and $options{'e'} eq substr($fileName,0,length($options{'e'})) ) {
      return;
    }
    if(open(my $fh,'<',$fileName)) {
      binmode($fh);
      $hashFileMD5{$fileName} = Digest::MD5->new->addfile($fh)->hexdigest;
      print "*** Check $fileName ...\n";
      close($fh);
    } else {      
      push(@listFilesErrorOpen,$fileName);
    }
  }
}

# Show list files and signature...
sub showHashFiles() {  
  while ( my ($key, $value) = each(%hashFileMD5) ) {
    print "FILE: $key ==> MD5: $value\n";    
  }
}

# Show list files and signature...
sub showListFilesDup() {
  #print Dumper(\%hashFileDup);
  my @stat = ();
  $sizeHashDup = keys %hashFileDup;
  if($sizeHashDup) {
    print "\n============== Duplicate files ============== \n";
    open(my $fh, '>', $fileOut) if $options{'g'};
    print $fh "#!/bin/bash \n\n" if $options{'g'};
    for $key ( keys %hashFileDup ) {
      print "* $key:\n";
      for $i ( 0 .. $#{ $hashFileDup{$key} } ) {
        # Sum duplicate size file... a file is.. so don't sum your size...
        @stat = stat $hashFileDup{$key}[$i] if $i > 0;
        $totalSizeFileDup += $stat[7] if $i > 0;
        print "(Preserved file: $hashFileDup{$key}[$i])\n" if $options{'g'} and $i == 0;
        print "====> $hashFileDup{$key}[$i]\n";
        print $fh "echo Removing \"$hashFileDup{$key}[$i]\" ...\n" if $options{'g'} and $i > 0;
        print $fh "/usr/bin/rm -f \"$hashFileDup{$key}[$i]\"\n" if $options{'g'} and $i > 0;
      }
    }
    print $fh "echo END\n" if $options{'g'};
    close $fh if $options{'g'};
    print "\n==> Generated script: $fileOut\n" if $options{'g'};
  } else {
    print "\n***** There were no duplicate files *****\n"; 
  }
}

# Get duplicates files by signature
# The logic is reversed...
# md5 --> key
# Example:
# d41d8cd98f00b204e9800998ecf8427e => ["file01","file02"]
sub getListFilesDup() {
  while( my ($key, $value) = each(%hashFileMD5) ) {
    my @arrayFiles = ();
    if(exists $hashFileDup{$value}) {
      # [] does copy array.. 
      @arrayFiles = @{$hashFileDup{$value}};
      push(@arrayFiles,$key);
      $hashFileDup{$value} = [(@arrayFiles)];
    } else {
      $hashFileDup{$value} = [$key];
    }
  }
  # remove that are not duplicated
  # if size 1.. nothing..
  for $key ( keys %hashFileDup ) {
    if(@{$hashFileDup{$key}} == 1) {
      delete($hashFileDup{$key});
    }
  }
}

#----------------------------------------
main();
