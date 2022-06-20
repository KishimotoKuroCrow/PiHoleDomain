#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw/strftime/;
use Getopt::Long;

$SIG{"INT"} = \&CleanExit;
my $ScriptName = $0;
my $__DEBUG__  = 0;
my $__MAX_PER_LINE__ = 200;
my $__PIHOLE_CMD__ = "pihole -b -nr -q"; # Blacklist domain, don't reload, quiet

# =========================
#  Function Prototypes
sub SysCmdToPush( $ );
sub RunSysCmd( $ );
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
#  Returns the array of system commands to execute
sub SysCmdToPush( $ )
{
   my( $File ) = @_;
   my @SysCmd  = ();

   # Get the file and get the full list
   my $fileline   = "";
   my $cmdline    = "";
   my $CntDomain  = 0;
   my $DomainList = "";
   my $CmdIteration = 0;

   # Make sure the file exists and is not empty
   if( !(-s $File ) )
   {
      print STDOUT "$ScriptName: \"$File\" does not exist or is empty.\n";
      return @SysCmd;
   }

   # Open the file and start processing.
   open( INPUTF, "<$File" );
   while( $fileline = <INPUTF> )
   {
      chomp( $fileline );
      if( $__DEBUG__ eq 1 )
      {
         print STDOUT "$ScriptName: - $File, line: \"$fileline\".\n";
      }

      # Go through the list of sites for sql.
      if(not (($fileline =~ /^#/) or ($fileline =~ /^ *$/)) )
      {
         $DomainList .= " $fileline";
         $CntDomain++;
         if( $CntDomain eq $__MAX_PER_LINE__ )
         {
            $cmdline = "$__PIHOLE_CMD__ $DomainList";
            push @SysCmd, $cmdline;
            $CmdIteration++;
            $DomainList = "";
            $CntDomain  = 0;
         }
      }
   }
   if( $CntDomain gt 0 )
   {
      $cmdline = "$__PIHOLE_CMD__ $DomainList";
      push @SysCmd, $cmdline;

      $CntDomain += $CmdIteration * $__MAX_PER_LINE__;
      $CmdIteration++;
   }
   else
   {
      $CntDomain = $CmdIteration * $__MAX_PER_LINE__;
   }
   print STDOUT "$ScriptName: $File ($CntDomain domains) divided into $CmdIteration cmds.\n";

   # Not necessary, just a precaution.
   $CmdIteration = 0;
   $DomainList = "";
   $CntDomain  = 0;
   close( INPUTF );

   return @SysCmd;
}


# =========================================
#  Function to run the system commands
sub RunSysCmd( $ )
{
   my( $InCmdArray ) = @_;
   my @AllCmd = @{$InCmdArray};

   # "One condition -> loop" rather than extra
   # conditional verification at every iteration:
   if( $__DEBUG__ eq 1 )
   {
      # Uncomment below to see the command that will be
      # executed when not in debug mode
      # -----------------------------------------
      foreach my $ThisCmd( @AllCmd )
      {
         print STDOUT "system( \"$ThisCmd\" )\n";
      }
   }
   else
   {
      foreach my $ThisCmd( @AllCmd )
      {
         system( "$ThisCmd" );
      }
   }
}


# =========================================
#  Main Function
sub main()
{
   # Parse through the files
   my @AllCmdToExec = ();
   my @AllCmdSplit  = ();
   my @CmdArray = ();
   foreach my $TmpFile( @ARGV )
   {
      @CmdArray = ();
      @CmdArray = SysCmdToPush( $TmpFile );
      push @AllCmdToExec, @CmdArray;
   }

   # Split the array into 10 sub-array of commands
   # to indicate the complete percentage on terminal.
   # Array division in the following manner to avoid adding
   # PERL libraries by the user.
   # The following code is taken from "https://www.perlmonks.org/?node_id=1023151"
   #---------------------------------------------------------
   my $TotalNumArrays = 10;
   if( scalar @AllCmdToExec < 10 )
   {
      $TotalNumArrays = scalar @AllCmdToExec;
   }
   while( @AllCmdToExec )
   {
      foreach( 0..$TotalNumArrays-1 )
      {
         if( @AllCmdToExec )
         {
            push @{$AllCmdSplit[$_]}, shift @AllCmdToExec;
         }
      }
   }

   # Push Pihole RestartDNS (reloads FTL) at the end
   push @{$AllCmdSplit[$TotalNumArrays-1]}, "pihole restartdns";

   if( $__DEBUG__ eq 1 )
   {
      foreach( 0..$TotalNumArrays-1 )
      {
         my $temp = scalar @{$AllCmdSplit[$_]};
         print STDOUT "$ScriptName: - Array$_ has $temp elements.\n";
      }
   }

   # Execute and indicate the percentage completed.
   print STDOUT "-- Completion rate: 0%... ";
   foreach( 0..$TotalNumArrays-1 )
   {
      RunSysCmd( \@{$AllCmdSplit[$_]} );
      if( $_ != $TotalNumArrays-1 )
      {
         my $PCT = ($_ + 1) * 10;
         print STDOUT "$PCT%... ";
      }
      else
      {
         print STDOUT "100% complete.\n";
      }
   }

   CleanExit();
}

main();
