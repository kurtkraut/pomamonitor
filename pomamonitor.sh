#!/bin/dash
#
#Preencha abaixo entre as aspas e separado por espaços os hosts que quer monitorar
#
targets="www.terra.com.br www.uol.com.br www.google.com www.opendns.com www.registro.br"
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
#Adiciona um timestamp ao echo
time=$(date +%X)
echo "($time) $*"
}
#Avisa ao usuário que o monitor está ativado.
notify-send --icon=notification-network-ethernet-disconnected "Poor's Man Monitor" "Monitor ativado"
output "Poor's Man Monitor - Monitor ativado"
delay="$normaldelay"
#Loop de checagem
while [ 1 ]
do
 output "Aguardando $delay segundos para efetuar testes."
 sleep $delay
 output Efetuando testes neste exato momento.
 temporary=$(mktemp)
 fping -dAeu $targets > $temporary
 if test $? -eq 1
 then
  delay="$briefdelay"
  output "Pausa entre uma checagem e outra temporariamente modificada para $delay segundos."
  output=$(cat $temporary)
  output "Dados coletados:"
  cat $temporary
  notify-send --urgency=critical --icon=notification-network-ethernet-disconnected "Host fora do ar" "$output"
 else
  rm $temporary
  delay="$normaldelay"
  output Nenhum host detectado como offline.
 fi
 output Teste concluído.
done
