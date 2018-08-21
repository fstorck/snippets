#!/usr/bin/perl
# Perl Script for IPCop to calc DSL Dialup stats 
# Florian Storck


use Time::localtime;
use File::stat;

&calc_dialupstats();

sub calc_dialupstats
{

@logs = </var/log/messages*>;
# @logs = <messages*>;
@logs = reverse(@logs);

@month = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");

%midx  = ("Jan", 1,
          "Feb", 2,
          "Mar", 3,
          "Apr", 4,
          "May", 5,
          "Jun", 6,
          "Jul", 7,
          "Aug", 8,
          "Sep", 9,
          "Oct",10,
          "Nov",11,
          "Dec",12);

%mdays = ("Jan", 0,
          "Feb", 31,
          "Mar", 59,
          "Apr", 89,
          "May",120,
          "Jun",150,
          "Jul",181,
          "Aug",212,
          "Sep",242,
          "Oct",273,
          "Nov",303,
          "Dec",334);


%mdaycnt = ("Jan", 31,
            "Feb", 28,
            "Mar", 31,
            "Apr", 30,
            "May", 31,
            "Jun", 30,
            "Jul", 31,
            "Aug", 31,
            "Sep", 30,
            "Oct", 31,
            "Nov", 30,
            "Dec", 31);

$curday = localtime->mday(); #(localtime())[3];
$curmon = localtime->mon()  +1;
$curyear= localtime->year() +1900;

print (" $curday.$curmon.$curyear <br /><br />\n");

$BytesRx = 0;
$BytesTx = 0;

# DSL 100
$maxhrs   = 100 * 60;
# billing start day
$startday = 8;
$endday   = $startday;

if(localtime->year() % 4 ==  0)
{
  print "Schaltjahr. <br /><br />\n";
  %mdays = ("Jan", 0,
          "Feb", 31,
          "Mar", 60,
          "Apr", 90,
          "May",121,
          "Jun",151,
          "Jul",182,
          "Aug",213,
          "Sep",244,
          "Oct",275,
          "Nov",306,
          "Dec",335);
}
if($startday > $curday)
{
   if( ($curmon-1) == 0)
   { # handling year change
     $curmon = 12;
     $startyear= $curyear -1;
     $filmon  = $month[$curmon];
     $startmon= $curmon;
     $endmon   = 1;
     $endyear  = $curyear;
   }
   else
   {
     $filmon   = $month[$curmon-1];         # period start in last month
     $startmon = $curmon-1;
     $startyear= $curyear;
     $endmon   = $curmon;
     $endyear  = $curyear;
   }
}
else
{
   $startyear= $curyear;
   $filmon   = $month[$curmon];            # period starts in current month
   $startmon = $curmon;
   $endmon   = $curmon +1;
   $endyear  = $curyear;
}

$perdays    = $mdays{$filmon}         + $startday + 365*$startyear;  # days at beginning of period
$actdays    = $mdays{$month[$curmon]} + $curday + 365*$curyear;  # days at beginning
$enddays    = $mdays{$month[$endmon]} + $endday + 365*$endyear;      # days at end of period
$startdate  = 10000*$startyear + 100*$startmon + $startday;  # date coded decimal

# $perdays= $mdays{$filmon}+ $startday;

foreach $logfile (@logs)
{
  $s_date = ctime(stat($logfile)->mtime);

  @log_date = split(' ', $s_date);
  $log_year = @log_date[4];
  @logname  = split('.', $logfile);
  $log_ext  = @logname[1];

  $filedays =  $mdays{@log_date[1]} + @log_date[2] + 365* $log_year;

  #print "filedays : $filedays \n";
  #print "perdays  : $perdays \n";

  if (($perdays - $filedays) < 40)
  {
   if (open (in, $logfile))
   {
    @logfile = <in>;
    close IN;
    chomp @logfile;

    $totaltime = 0;
    %daytimes;

    @pppCon;
    @pppExt;

    print( "Loaded File: $logfile  FileDate: $s_date <br />\n");

    foreach $logline (@logfile)
    {
       @logline = split(' ', $logline);
       #single logline date, calc absolute days
       $logdays = $mdays{@logline[0]} + @logline[1] + 365* $log_year;
       $logdate = 10000*$log_year + 100*$midx{@logline[0]} + @logline[1];

       $logdays = $mdays{@logline[0]} + @logline[1];

       #print "logdays : $logdays \n";
       #print "logdate : $logdate startdate : $startdate\n";

       if($logdate>=$startdate)
       #if($logdays >= $perdays )
       {
           if(($logline =~ /pppd/) && ($logline =~ /Sent/))
           {
              @logline = split(' ', $logline);
              $BytesTx += @logline[6];
              $BytesRx += @logline[9];
           }
           if (($logline =~ /pppoe/) && ($logline =~ /PPP session/))
           {
              #print ("$startdate : $logdate : $logline <br />\n");
              push(@pppCon, $logline);
           }
           if (($logline =~ /pppoe/) && ($logline =~ /Sent PADT/))
           {
              push(@pppExt, $logline);
           }

           if($logline =~ /Connect time/)
           {
             @logline = split(' ', $logline);

             $key = @logline[0] . " " . @logline[1];
             $daytimes {$key} += @logline[7];
             $totaltime += @logline[7];
           }
       } # filter all below startday
       else
       {
          #print ("$logdate : FILTERED :@logline[0] @logline[1] <br />\n");
       }
    }

   }
   else
   {
    print "Couldn't open logfile <br />\n";
    return;
   }
  }
} # ende logfiles

    print "---------------------------------------------------------------<br />\n";
    $cnt = 0;
    $difftime;
    $runsum = 0;
    %daytm;

    foreach $start (@pppCon)
    {
       @start = split(' ', @pppCon[$cnt]);
       @stop  = split(' ', @pppExt[$cnt]);

       #same day
       if( @start[1] == @stop[1])
       {
          @tstart = split(':', @start[2]);
          @tstop  = split(':', @stop[2]);

          $t2 = (@tstop[0]  * 3600 + @tstop[1]  *60 + @tstop[2]);
          $t1 = (@tstart[0] * 3600 + @tstart[1] *60 + @tstart[2]);

          $difftime = ($t2 - $t1) / 60;
       }
       else # split connection
       {
          @tstart = split(':', @start[2]);
          @tstop  = split(':', @stop[2]);

          $t2 = (@tstop[0]  * 3600 + @tstop[1]  *60 + @tstop[2]);
          $t1 = (@tstart[0] * 3600 + @tstart[1] *60 + @tstart[2]);

          $difftime =  86399 - $t1;              # calc diff until 23:59:59
          $difftime = ($difftime + $t2) / 60 ;   # add from 00:00:00

       }
       $runsum += $difftime / 60;

       printf ("%s %2.2i %s %s Connection time: %6.2f mins %6.2f hrs <br />\n", @start[0],
                                                               @start[1],
                                                               @start[2],
                                                               @stop[2],
                                                               $difftime,
                                                               $runsum);
       # generating day keys

       $mykey = sprintf("%2.2i %s", @start[1], @start[0]);
       $key = @start[1] . " " . @start[0];
       #print $mykey;
       $daytm{$mykey} += $difftime;

       $cnt++;
    }

    print "---------------------------------------------------------------<br />\n";

    $totaltime = 0;
    $cnt       = 0;
    foreach $day (sort (keys(%daytm)))
    {
      $totaltime += $daytm{ $day };
      printf ("%s Total %6.2f mins <br />\n", $day, $daytm{ $day });
      $cnt++;
    }

    # $daysleft = $mdaycnt{$month[$curmon]} - ($cnt-1);
    $daysleft = $enddays - $actdays;

    $leftdaily_mins = ($maxhrs - $totaltime) /$daysleft;
    $leftdaily_hrs  = ($maxhrs - $totaltime) /$daysleft / 60;

    print "---------------------------------------------------------------<br />\n";
    printf("Total time online : %07.2f mins %05.2f hrs <br />\n", $totaltime, $totaltime / 60 );
    if ($cnt != 0) { printf("Daily average     : %07.2f mins %05.2f hrs <br />\n", $totaltime / $cnt, $totaltime / $cnt / 60);}
    printf("Days left         : %2.2i  days <br /> <br />\n", $daysleft);
    printf("Time left online  : %07.2f mins %05.2f hrs <br />\n", $maxhrs - $totaltime, ($maxhrs - $totaltime) / 60);
    printf("Time left daily   : %07.2f mins %05.2f hrs <br />\n", $leftdaily_mins, $leftdaily_hrs);
    printf("MB sent           : %6.2f MB <br />\n", $BytesTx/1048576);
    printf("MB received       : %6.2f MB <br />\n", $BytesRx/1048576);
    printf("Total Traffic     : %6.2f MB <br />\n", ($BytesTx+$BytesRx)/1048576);
#    printf("Days left: %2.2i",);
#    print "startdate: $startdate <br />\n";
#    print "startdate: $startdate <br />\n";
    print "---------------------------------------------------------------<br />\n";
    print "</tt></td></tr></table>\n";

} # end cals_dialupstats