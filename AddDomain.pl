#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw/strftime/;
use Getopt::Long;

$SIG{"INT"} = \&CleanExit;
my $ScriptName = $0;
my $__DEBUG__ = 1;

# =========================
#  Function Prototypes
sub PathDirectory( $ );
sub GetDateTime();
sub CleanExit();
sub main();


# =========================================
#  Get Date and Time formatted as _YYYYMMDD_HHMM
sub GetDateTime()
{
   my $DateString = "";
   $DateString = strftime "_%Y%m%d_%H%M", localtime;
   
   return $DateString;
}


# =========================================
#  Check and return the directory name
sub PathDirectory( $ )
{
   my( $Path ) = @_;
   my @DirSegment = split( '/', $Path );
   my $DirPath = "./";
   my $NumElements = scalar @DirSegment;
   if( $NumElements gt 1 )
   {
      # Remove the last element and recombine
      if( $__DEBUG__ eq 1 )
      {
         print STDOUT "@DirSegment\n";
      }
      @DirSegment = splice( @DirSegment, 0, $NumElements - 1);
      $DirPath = join( '/', @DirSegment );
   }
   if( $__DEBUG__ eq 1 )
   {
      print STDOUT "$ScriptName :- PathDirectory = \"$DirPath\" for \"$Path\"\n";
   }

   # Return the directory path
   return $DirPath;
}


# =========================================
#  Clean Exit
sub CleanExit()
{
   print STDOUT "\n-- $ScriptName: Exiting Program --\n";
   exit 0;
}


# =========================================
#  Main Function
sub main()
{
   # Get the options and validate
   my %options;
   GetOptions(
      "l=s" => \$options{'l'}, # List of remote domains/sites to block
   );

   if( not defined $options{'l'} )
   {
      die "Error: option '-l' not defined\n";
   }

   # Get the file and get the full list
   my $fileline   = "";
   my $cmdline    = "";
   my $CntDomain  = 0;
   my $DomainList = "";
   open( INPUTF, "<$options{'l'}" );
   while( $fileline = <INPUTF> )
   {
      chomp( $fileline );
      if( $__DEBUG__ eq 1 )
      {
         print STDOUT "$ScriptName: - File line: \"$fileline\"\n";
      }

      # Go through the list of sites for sql.
      if(not (($fileline =~ /^#/) or ($fileline =~ /^ *$/)) )
      {
         $DomainList .= " $fileline";
         $CntDomain++;
         if( $CntDomain eq 20 )
         {
            $cmdline = "pihole -b -nr $DomainList";
            print STDOUT "Executing \"$cmdline\"\n";
            if( $__DEBUG__ eq 0 ) 
            {
               system( "$cmdline" );
            } 
            $DomainList = "";
            $CntDomain  = 0;
         }
      }
   }
   if( $CntDomain gt 0 )
   {
      $cmdline = "pihole -b $DomainList";
      print STDOUT "Executing \"$cmdline\"\n";
      if( $__DEBUG__ eq 0 ) 
      {
         system( "$cmdline" );
      } 
   }
   else
   {
      $cmdline = "pihole -g";
      print STDOUT "Executing \"$cmdline\"\n";
      if( $__DEBUG__ eq 0 ) 
      {
         system( "$cmdline" );
      } 
   }
   close( INPUTF );

   CleanExit();
}

main();
