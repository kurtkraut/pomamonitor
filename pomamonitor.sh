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
notify-send --icon=notification-network-ethernet-disconnected "Poor's Man Monitor" "Monitor ativado"
delay="$normaldelay"
while [ 1 ]
do
echo "Aguardando $delay segundos para efetuar testes."
sleep $delay
 echo Efetuando testes neste exato momento.
 temporary=$(mktemp)
 fping -dAeu $targets > $temporary
 if test $? -eq 1
 then
  delay="$briefdelay"
  echo "Pausa entre uma checagem e outra modificada para $delay segundos."
  output=$(cat $temporary)
  cat $temporary
  notify-send --urgency=critical --icon=notification-network-ethernet-disconnected "Host fora do ar" "$output"
 else
 rm $temporary
 fi
 echo Teste concluído.
done
