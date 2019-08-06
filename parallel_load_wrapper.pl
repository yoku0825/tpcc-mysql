#!/usr/bin/perl

########################################################################
# Copyright (C) 2014, 2019  yoku0825
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
########################################################################

use strict;
use warnings;
use Parallel::ForkManager;
use Fcntl;

### TODO: read by getoptions
my $db_name  = "tpcc";
my $user     = "tpcc";
my $password = "test";
my $warehouse= 4;
my $connect_string= "-d $db_name -u $user -p $password -w $warehouse "; ### Add some string if you need.

### Detecting tpcc_load executable.
my $tpcc_load= "";
if (-x "./tpcc_load")
{
  $tpcc_load= "./tpcc_load";
}
elsif ($tpcc_load= `which tpcc_load 2>/dev/null`)
{
  chomp($tpcc_load);
}
else
{
  ### TODO: read from stdin.
  die("tpcc_load executable is not found.");
}

### Detecting how many cores.
my $max_proc= `nproc`;
chomp($max_proc);
$max_proc= int($max_proc / 2);

system($tpcc_load . " $connect_string -m 1 -n 1 -l $warehouse");
my $pm= Parallel::ForkManager->new($max_proc);
foreach (my $n= 1; $n <= $warehouse; $n++)
{
  foreach (2..4)
  {
    $pm->start and next;
    system($tpcc_load . " $connect_string -m $_ -n $n -l $n");
    $pm->finish;
  }
}
$pm->wait_all_children;


exit 0;

