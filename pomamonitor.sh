#!/bin/dash
#    Poor's Man Monitor - a simple host downtime alert for Gnome/KDE desktop
#    Copyright (C) 2009 Kurt Kraut <development@kurtkraut.net>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
#
clioutput ()
{
#Add a timestamp to echo. Default way of stdout.
time=$(date +%X)
echo "($time) $*"
}
#Checking the presence of dependencies
mktemp_path=$(whereis -b mktemp | cut -d" " -f 2)
fping_path=$(whereis -b fping | cut -d" " -f 2)
grep_path=$(whereis -b grep | cut -d" " -f 2)
notify_send_path=$(whereis -b notify-send | cut -d" " -f 2)
host_path=$(whereis -b host | cut -d" " -f 2)
zenity_path=$(whereis -b zenity | cut -d" " -f 2)
if test -x $mktemp_path
then
    clioutput "Binary $mktemp_path will be used."
else
    clioutput "Fatal error: mktemp is not installed or accessible. Poor's Man Monitor needs access to mktemp."
    exit 1
fi
if test -x $fping_path
then
    clioutput "Binary $fping_path will be used."
else
    clioutput "Fatal error: fping is not installed or accessible. Poor's Man Monitor needs access to fping."
    exit 1
fi
if test -x $grep_path
then
    clioutput "Binary echo $grep_path will be used."
else
    clioutput "Fatal error: grep is not installed or accessible. Poor's Man Monitor needs access to grep."
    exit 1
fi
if test -x $notify_send_path
then
    clioutput "Binary $notify_send_path will be used."
else
    clioutput "Fatal error: notify-send is not installed or accessible. Poor's Man Monitor needs access a binary called 'notify-send'."
    exit 1
fi
if test -x $host_path
then
    clioutput "Binary $host_path will be used."
else
    clioutput "Fatal error: host is not installed or accessible. Poor's Man Monitor needs access to a binary called 'host'."
    exit 1
fi
if test -x $zenity_path
then
    clioutput "Binary $zenity_path will be used."
else
    clioutput "Fatal error: host is not installed or accessible. Poor's Man Monitor needs access to zenity."
    exit 1
fi
#Checking if zenity was aborted
zenity_error_check(){
if test $? -eq 1
then
    zenity --error --text="You've cancelled the Poor's Man Monitor first run settings. You need to complete this process in order to use Poor's Man Monitor. You may run this later."
    exit 1
fi
}
#Creating conf file is non-existant
zenity_conf_maker(){
zenity --title="Read before using Poor's Man Monitor" --question --text="This is the first time you run Poor's Man Monitor. In order to make it run, you will need to answer 3 questions:\\
\\
1) All hosts or IPs you want to monitor, separated by space.\\
2) The delay (in minutes) between each check if a host in the item 1 is online or offline.\\
3) If a host is detected as offline, a briefer delay between each check on item 2.\\
\\
Please note that each question will be done in a different window.If you are not ready to answer these questions, you should cancel this window and run Poor's Man Monitor later.\\
\\
If you are ready to answer then just click on OK."
if test $? -eq 1
then
    exit 0
fi
targets=$(zenity --title="Setting targets" --entry --text="Put below the hosts or IP addresses you want to monitor if they are offline,\\
separated by a single space. It is recommended to keep at least 3 reliable\\
hosts in the list that are usually online and responding to pings.\\
Three reliable targets are already filled for you as an example.\\
\\
You may enter up to hundreds of targets." --entry-text="www.google.com www.opendns.com www.registro.br")
zenity_error_check
normal_delay=$(zenity --scale --title="Setting a delay" --text "We call a check when Poor's Man Monitor pings all targets that you have provided\\
in the last question. Here you will set a delay (in minutes) between each check.\\
\\
A delay of 5 minutes is recommended." --min-value=3  --step 1 --value=5 --max-value=120)
zenity_error_check
brief_delay=$(zenity --scale --title="Setting a brief delay" --text "If a target is detected as offline, it is important to make briefer checks to\\
be sure it is truly offline and to be alerted sooner when it is back online. Set\\
below a brief delay in minutes.\\
\\
A brief delay off 1 minute is recommended" --min-value=1  --step 1 --value=1 --max-value=$normal_delay)
zenity_error_check
#Converting minutes to seconds
normal_delay=$(expr $normal_delay \* 60)
brief_delay=$(expr $brief_delay \* 60)
#Writing collected data to $config_file
echo "targets=\"$targets\"" > $config_file
echo "normal_delay=$normal_delay" >> $config_file
echo "brief_delay=$brief_delay" >> $config_file
zenity --question --title="Poor's Man Monitor configuration finished." --text="You have finished configuring Poor's Man Monitor. If you want to change orr review the settings, just edit the file $config_file\\
\\
Now Poor's Man Monitor will be loaded."
}
#Seting up conf file and checking for read permission
config_file=~/.pomamonitor/pomamonitor.conf
if test -r $config_file
then
    clioutput "Using the configuration file $config_file"
else
    zenity_conf_maker
fi
#Alerts to user
default_online_message(){
if test -n "$opendns_failed_hosts"
then
    notify-send --urgency=low --icon=notification-network-ethernet-disconnected "Poor's Man Monitor check nº $counter" "All hosts are online and responding, except: $opendns_failed_hosts"
    clioutput "All hosts are online and responding, except: $opendns_failed_hosts"
else
    notify-send --urgency=low --icon=notification-network-ethernet-connected "Poor's Man Monitor check nº $counter" "All $targets_qty hosts are online and responding. New checks will be done on every $delay seconds."
    clioutput "All $targets_qty hosts are online and responding. New checks will be done on every $delay seconds."
fi
}

nondefault_online_message(){
if test -n "$opendns_failed_hosts"
then
    notify-send --urgency=low --icon=notification-network-ethernet-disconnected "Poor's Man Monitor check nº $counter" "All hosts are online and responding, except: $opendns_failed_hosts"
    clioutput "All hosts are online and responding, except: $opendns_failed_hosts"
else
    notify-send --urgency=low --icon=notification-network-ethernet-connected "Poor's Man Monitor check nº $counter" "All hosts are online and responding. New checks will be done on every $delay seconds on: $targets"
fi
}

opendns_check () {
#Avoiding false-positive alerts in the presence of OpenDNS servers
temporary_opendns=$(mktemp)
unset opendns_failed_hosts
echo $targets | tr " " \\n > $temporary_opendns
while read line
do
    host $line | grep --fixed-strings --silent "208.69.32.13"
    if test $? -eq 0
    then
#The $delay is not changed to $brief_delay because hardly ever the current status will change in such brief time
       opendns_failed_hosts="$line $opendns_failed_hosts"
    fi
done < $temporary_opendns
if test -n "$opendns_failed_hosts"
then
    notify-send --urgency=critical --icon=notification-network-ethernet-disconnected "Poor's Man Monitor" "Aparentely, some hosts does not exist or their DNS servers stopped responding. You have to check this situation manually for: $opendns_failed_hosts"
   clioutput "Aparentely, some hosts does not exist or their DNS servers stopped responding. You have to check this situation manually for: $opendns_failed_hosts"
else
   clioutput "No host from target list seem to be handled by guide.opendns.com"
   fi
rm $temporary_opendns
}

#--help flag
if test "$1" = "--help"
then
    echo "\
    
Usage: $0 [--help|--version|hosts]

--help: Show this usage instructions.
--version: Shows software version.
hosts: Replace \"hosts\" by a list of hosts you want to monitor. If you do not
provide at least one host at run time, a default list of hosts will be used.

Example:

$0 www.google.com www.opendns.com www.kernel.org

"
    exit 0
fi

#--version flag
if test "$1" = "--version"
then
    echo "\

This software is under constant and initial development. A version number
would mean nothing at all. If you're going to distribute it and need to apply
a number to this, we suggest calling it version 0.

"
    exit 0
fi
#Injects the conf_file in this script
. $config_file
#First check is done in $brief_delay seconds
delay="$brief_delay"
targets_qty=$(echo "$targets" | tr " " \\n | wc -l)
clioutput "Poor's Man Monitor - Monitor activated"
echo
clioutput "If you need further details on how to use this software, please type $0 --help"
echo
if test -z $1
then
    clioutput "Monitoring the default list of $targets_qty hosts: $targets"
else
    targets="$*"
    clioutput "Monitoring this list of $targets_qty hosts: $targets"
fi
#Check up infinite loop
while [ 1 ]
do
    counter=$(expr $counter + 1)
    clioutput "Waiting $delay seconds to perform the check nº $counter."
    sleep $delay
    clioutput "Checking if a target is being handled by guide.opendns.com to avoid false-negative."
    opendns_check
    clioutput "Performing check nº $counter"
    temporary=$(mktemp)
    fping -dAmeu -T60 $targets > $temporary 2>&1
    if test $? != 0
    then
#If there is at least one offline host:
        delay="$brief_delay"
        clioutput "At least one host seem to be offline on check nº $counter."
        clioutput "The pause between each check was temporarily changed to $delay seconds."
        results=$(cat $temporary)
        clioutput "Collected data:"
        cat $temporary
        notify-send --urgency=critical --icon=notification-network-ethernet-disconnected "Offline hosts on check nº $counter" "$results"
    else
#If all hosts are online
        rm $temporary
        clioutput "All $targets_qty are online on check nº $counter."
#If this is the first check or at least one host was offline in the previous check ($delay = $brief_delay), alert user that now all hosts are online
        if test $counter -eq 1 -o $delay = $brief_delay -o -n "$opendns_failed_hosts" 
        then
            if test -z $1
            then
                delay="$normal_delay"
                default_online_message
            else
                delay="$normal_delay"
                nondefault_online_message
            fi
        fi
    fi
    clioutput "Check nº $counter finished."
done
