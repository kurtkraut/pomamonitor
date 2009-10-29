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
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#Preencha abaixo entre as aspas e separado por espaços os hosts que quer monitorar
#
targets="www.terra.com.br www.uol.com.br www.google.com www.opendns.com www.registro.br www.alemdonatural.com.br loja.alemdonatural.com.br NS3.EU.EDITDNS.NET NS5.US.EDITDNS.NET NS4.US.EDITDNS.NET remoto.alemdonatural.com.br"
#
#Indique abaixo, entre as aspas, o intervalo em segundos entre uma checagem e outra de todos os hosts supracitados
#
normaldelay="300"
#
#Caso um dos hosts esteja offline, é interessante fazer checagens mais curtas. Nesse caso, elas serão feitas a cada X segundos, especificados abaixo entre aspas
#
briefdelay="60"
#
#Não modifique desta linha em diante
#
#
#
output ()
{
#Adiciona um timestamp ao echo. Forma padrão de stdout.
time=$(date +%X)
echo "($time) $*"
}
#Avisa ao usuário que o monitor está ativado.
notify-send --icon=notification-network-ethernet-disconnected "Poor's Man Monitor" "Monitor ativado"
output "Poor's Man Monitor - Monitor ativado"
#Faz a primeira checagem dentro de 5 segundos:
delay=5
#Utiliza hosts indicados na sintaxe (quando oferecidos)
if test -z $1
then
 output Utilizando listas de host padrão: $targets
else
 targets="$*"
 output Utilizando a lista de hosts: $targets
fi
#Loop de checagem dos hosts
while [ 1 ]
do
 output "Aguardando $delay segundos para efetuar testes."
 sleep $delay
 output Efetuando testes neste exato momento.
 temporary=$(mktemp)
 fping -dAeu $targets > $temporary
 if test $? -eq 1
 then
#Se houver pelo menos um host offline:
  delay="$briefdelay"
  output "Pausa entre uma checagem e outra temporariamente modificada para $delay segundos."
  output=$(cat $temporary)
  output "Dados coletados:"
  cat $temporary
  notify-send --urgency=critical --icon=notification-network-ethernet-disconnected "Host fora do ar" "$output"
 else
#Se todos os hosts online:
  rm $temporary
  delay="$normaldelay"
  output Nenhum host detectado como offline.
 fi
 output Teste concluído.
done
