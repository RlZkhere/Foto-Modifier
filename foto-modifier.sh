#!/bin/bash
#BY KHERE
read -rep $'Nome fornitore:\n' fornitore
read -rep $'Inserisci 0 per aggiungere bordi, 1 per non aggiungerli\n' bordoscegli
#read -rep $'Inserisci 0 per dividere le foto, 1 per non dividerle\n' dividifoto
cartellavecchia='FOTO-VECCHIE-'$fornitore
cartellanuova='FOTO-NUOVE-'$fornitore
numerofoto=$(ls $cartellavecchia | wc -l)
for i in $(seq 1 $numerofoto);
do
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
grandezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null)
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed 's/x.*//')
altezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed -n -e 's/^.*x//p')
controllo1=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,0}]" info:-)
controllo2=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{0,$altezza}]" info:-)
controllo3=$(convert $cartellavecchia/$fotomodifica -format '%[pixel:p{0,0}]' info:-)
controllo4=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,$altezza}]" info:-)
controllotrasparenza=$(convert $cartellavecchia/$fotomodifica -format "%[opaque]" info:)
if [[ $controllotrasparenza == 'false' ]]
then
convert -background white -flatten $cartellavecchia/$fotomodifica $cartellavecchia/$fotomodifica
fi
latolungo=$altezza
if [[ $larghezza -gt $altezza ]]
then
latolungo=$larghezza
fi
if [[ $altezza -gt $larghezza ]]
then
latolungo=$altezza
fi
#CHECK IF BORDERS ARE EMPTY
if [[ $controllo1 == "white" ]] &&[[ $controllo2 == "white" ]] &&[[ $controllo3 == "white" ]] && [[ $controllo4 == "white" ]] && [[ $bordoscegli == 0 ]]
then
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf pad=width=iw+100:height=ih+100:x=50:y=50:color=white $cartellavecchia/$fotomodifica
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
fi
#IF WIDTH GREATER THAN HEIGHT
if [[ $larghezza -gt $altezza ]]
then
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed -n -e 's/^.*x//p')
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed 's/x.*//')
altezzagiusta=$(echo "scale=2; $altezza/$larghezza" | bc)
altezzagiusta=$(echo "0"$altezzagiusta | sed 's/0./0,/')
if [[ $latolungo -le 1400 ]] #IF WIDTH <= 1400 THEN THE PHOTO WILL BECOME 1200X1200
then
altezzagiusta=$((($altezzagiusta *1200)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=1200:$altezzagiusta $cartellavecchia/"1_"$fotomodifica
numeropixelvecchio=$((1200-$altezzagiusta))
fi
if [[ $latolungo -gt 1400 ]] #IF WIDTH >= 1400 THEN THE PHOTO WILL BECOME 2400X2400
then
altezzagiusta=$((($altezzagiusta *2400)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=2400:$altezzagiusta $cartellavecchia/"1_"$fotomodifica
numeropixelvecchio=$((2400-$altezzagiusta))
fi
numeropixel=$(($numeropixelvecchio /2 ))
ffmpeg -y -i $cartellavecchia/"1_"$fotomodifica -vf pad=height=ih+$numeropixelvecchio:x=$numeropixel:y=$numeropixel:color=white $cartellanuova/$fotomodifica
rm -r $cartellavecchia/"1_"$fotomodifica
fi
#IF HEIGHT GREATER THAN WIDTH
if [[ $altezza -gt $larghezza ]]
then
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed -n -e 's/^.*x//p')
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed 's/x.*//')
larghezzagiusta=$(echo "scale=2; $larghezza/$altezza" | bc)
larghezzagiusta=$(echo "0"$larghezzagiusta | sed 's/0./0,/')
if [[ $latolungo -le 1400 ]] #IF HEIGHT <= 1400 THEN THE PHOTO WILL BECOME 1200X1200
then
larghezzagiusta=$((($larghezzagiusta *1200)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=$larghezzagiusta:1200 $cartellavecchia/"1_"$fotomodifica
numeropixellarghezza=$((1200-$larghezzagiusta))
fi
if [[ $latolungo -gt 1400 ]] #IF HEIGHT >= 1400 THEN THE PHOTO WILL BECOME 2400X2400
then
larghezzagiusta=$((($larghezzagiusta *2400)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=$larghezzagiusta:2400 $cartellavecchia/"1_"$fotomodifica
numeropixellarghezza=$((2400-$larghezzagiusta))
fi
numeropixelgiusto=$(($numeropixellarghezza /2 ))
ffmpeg -y -i $cartellavecchia/"1_"$fotomodifica -vf pad=width=iw+$numeropixellarghezza:x=$numeropixelgiusto:y=$numeropixelgiusto:color=white $cartellanuova/$fotomodifica
rm -r $cartellavecchia/"1_"$fotomodifica
fi
#IF WEIGHT = HEIGHT
if [[ $altezza -eq $larghezza ]]
then
echo "Valori uguali"
if [[ $latolungo -le 1400 ]] #IF DIMENSIONS ARE UNDER 1400X1400 THE IMAGE BECOME 1200X1200
then
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=1200:1200 $cartellanuova/$fotomodifica
fi
if [[ $latolungo -gt 1400 ]] #IF DIMENSIONS ARE GREATER THAN 1400X1400 THE IMAGE BECOME 2400X2400
then
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=2400:2400 $cartellanuova/$fotomodifica
fi
fi
convert $cartellanuova/$fotomodifica -strip $cartellanuova/$fotomodifica #REMOVE EXTRA DATA
estensionefile=$(sed 's/.*\.//' <<< $fotomodifica) #IF EXTENSION <> jpg THEN CONVERT PHOTO TO JPG 
if [[ $estensionefile != 'jpg' ]]
then
echo "ESTENSIONE DIVERSA"
fotocambiaestensione=$(sed 's/\..*//' <<< $fotomodifica)
ffmpeg -i $cartellanuova/$fotocambiaestensione"."$estensionefile $cartellanuova/$fotocambiaestensione".jpg"
rm -r $cartellanuova/$fotocambiaestensione"."$estensionefile #DELETE WRONG FORMAT FILE
fi
done
