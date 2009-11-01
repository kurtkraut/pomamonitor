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
#Adiciona um timestamp ao echo. Forma padrão de stdout.
time=$(date +%X)
echo "($time) $*"
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
#Definindo arquivo de configuração e checando se há permissão para leitura.
config_file=~/.pomamonitor/pomamonitor.conf
if test -r $config_file
then
 clioutput "Using the configuration file $config_file"
else
 clioutput "Configuration file not found. Exiting. Place it on $config_file"
 exit 1
fi
#Coletando variáveis a partir do $config_file
targets=$(grep -G "^targets=" $config_file -m 1 | cut -f 2 -d"=")
normal_delay=$(grep -G "^normal_delay=" $config_file -m 1 | cut -f 2 -d"=")
brief_delay=$(grep -G "^brief_delay=" $config_file -m 1 | cut -f 2 -d"=")
#Primeira checagem é feita com 5 segundos.
delay=5
#Avisa ao usuário que o monitor está ativado.
clioutput "Poor's Man Monitor - Monitor activated"
clioutput "If you need further details on how to use this software, please type $0 --help"
#Utiliza hosts indicados na sintaxe (quando oferecidos) e os exibe p/ o usuário
if test -z $1
then
 clioutput "Monitoring the default list of hosts: $targets"
else
 targets="$*"
 clioutput "Monitoring this list of hosts: $targets"
 fi
#Loop de checagem dos hosts
while [ 1 ]
do
 counter=$(expr $counter + 1)
 clioutput "Waiting $delay seconds to perform the test nº $counter."
 sleep $delay
 clioutput "Making tests right now."
 temporary=$(mktemp)
 fping -dAeu $targets > $temporary
 if test $? -eq 1
 then
#Se houver pelo menos um host offline:
  delay="$brief_delay"
  clioutput "The pause between each test was temporarily changed to $delay seconds."
  results=$(cat $temporary)
  clioutput "Collected data:"
  cat $temporary
  notify-send --urgency=critical --icon=notification-network-ethernet-disconnected "Offline hosts on check nº $counter" "$results"
 else
#Se todos os hosts online:
  rm $temporary
  delay="$normal_delay"
  clioutput "No offline hosts were detected."
#Se for o primeiro teste, avisar via notify-send que está todos hosts estão online.
  if test $counter -eq 1
  then
   if test -z $1
   then
    notify-send --urgency=low --icon=notification-network-ethernet-connected "Poor's Man Monitor" "All default hosts are online and responding. New checks will be done on every $delay seconds."
   else
    notify-send --urgency=low --icon=notification-network-ethernet-connected "Poor's Man Monitor" "All hosts are online and responding. New checks will be done on every $delay seconds on: $targets"
   fi
  fi
 fi
 clioutput "Current test finished."
done
