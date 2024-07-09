#!/bin/bash
#BY KHERE
cartellavecchia='FOTO-VECCHIE-LIGHTECH'  #folder where are stored images that you need to modify
cartellanuova='FOTO-NUOVE-LIGHTECH' #folder where the modifed images will be copied
numerofoto=$(ls $cartellavecchia | wc -l) #number of images
for i in $(seq 1 $numerofoto); 
do
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1) #image that will be modify
grandezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null)
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed 's/x.*//')
altezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed -n -e 's/^.*x//p')
controllo1=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,0}]" info:-)
controllo2=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{0,$altezza}]" info:-)
controllo3=$(convert $cartellavecchia/$fotomodifica -format '%[pixel:p{0,0}]' info:-)
controllo4=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,$altezza}]" info:-)
#Check for adding white border
if [[ $controllo1 == "white" ]] &&[[ $controllo2 == "white" ]] &&[[ $controllo3 == "white" ]] && [[ $controllo4 == "white" ]]
then
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf pad=width=iw+100:height=ih+100:x=50:y=50:color=white $cartellavecchia/$fotomodifica #add white border
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
fi
#CHECK PROPORITION
if [[ $larghezza -gt $altezza ]] #WEIGHT > HEIGHT
then
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed -n -e 's/^.*x//p')
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed 's/x.*//')
altezzagiusta=$(echo "scale=2; $altezza/$larghezza" | bc)
altezzagiusta=$(echo "0"$altezzagiusta | sed 's/0./0,/')
altezzagiusta=$((($altezzagiusta *1200)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=1200:$altezzagiusta $cartellavecchia/$fotomodifica
numeropixelvecchio=$((1200-$altezzagiusta))
numeropixel=$(($numeropixelvecchio /2 ))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf pad=height=ih+$numeropixelvecchio:x=$numeropixel:y=$numeropixel:color=white $cartellanuova/$fotomodifica
fi
if [[ $altezza -gt $larghezza ]] #HEIGHT > WEIGHT
then
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed -n -e 's/^.*x//p')
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null | sed 's/x.*//')
larghezzagiusta=$(echo "scale=2; $larghezza/$altezza" | bc)
larghezzagiusta=$(echo "0"$larghezzagiusta | sed 's/0./0,/')
larghezzagiusta=$((($larghezzagiusta *1200)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=$larghezzagiusta:1200 $cartellavecchia/$fotomodifica
numeropixellarghezza=$((1200-$larghezzagiusta))
numeropixelgiusto=$(($numeropixellarghezza /2 ))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf pad=width=iw+$numeropixellarghezza:x=$numeropixelgiusto:y=$numeropixelgiusto:color=white $cartellanuova/$fotomodifica
fi
#IF BOTH ARE EQUAL IT ONLY DOES RESIZE 1200X1200
if [[ $altezza -eq $larghezza ]]
then
echo "Valori uguali"
ffmpeg -i $cartellavecchia/$fotomodifica -vf scale=1200:1200 $cartellanuova/$fotomodifica
fi
done
