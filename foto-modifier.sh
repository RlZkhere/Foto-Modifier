#!/bin/bash
#BY KHERE  
read -rep $'Nome fornitore:\n' fornitore
read -rep $'Inserisci 0 per gestione normale, 1 per guanti\n' sceglitipofoto
read -rep $'Inserisci 0 per aggiungere bordi, 1 per non aggiungerli, 2 per aggiungerli a priori, 3 per toglierli a priori (obbligatorio per scelta guanti)\n' bordoscegli
cartellavecchia='FOTO-VECCHIE-'$fornitore
cartellanuova='FOTO-NUOVE-'$fornitore
numerofoto=$(ls $cartellavecchia | wc -l)
if [[ $bordoscegli == 0 ]] || [[ $bordoscegli == 2 ]] || [[ $bordoscegli == 3 ]]
then
read -rep $'Inserisci numero pixel \n' numeropixelbordo
numeropixelmassimo=$(($numeropixelbordo *2 ))
fi
if [[ $sceglitipofoto == 1 ]]
then
read -rep $'Inserisci 0 per pollice verso l interno, 1 per pollice verso l esterno\n' posizionepollice
fi
for i in $(seq 1 $numerofoto);
do
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
controllotrasparenza=$(convert $cartellavecchia/$fotomodifica -format "%[opaque]" info:)
if [[ $controllotrasparenza == 'false' ]] #CHECK IF PHOTO IS TRASPARENT
then
echo "TOLTA TRASPARENZA"
convert -background white -flatten $cartellavecchia/$fotomodifica $cartellavecchia/$fotomodifica
fi
estensionefile=$(sed 's/.*\.//' <<< $fotomodifica)
if [[ $estensionefile != 'jpg' ]] #CHECK IF IMAGE IS NOT JPG
then
echo "ESTENSIONE SBAGLIATA"
fotocambiaestensione=$(sed 's/\.[^.]*$//' <<< $fotomodifica)
ffmpeg -y -i $cartellavecchia/$fotocambiaestensione"."$estensionefile $cartellavecchia/$fotocambiaestensione".jpg" #CONVERT TO JPG
rm -r $cartellavecchia/$fotomodifica
fotomodifica=$fotocambiaestensione".jpg"
fi
grandezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null)
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%w\n" /dev/null)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%h\n" /dev/null)
controllo1=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,0}]" info:-)
controllo2=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{0,$altezza}]" info:-)
controllo3=$(convert $cartellavecchia/$fotomodifica -format '%[pixel:p{0,0}]' info:-)
controllo4=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,$altezza}]" info:-)
latolungo=$altezza
if [[ $larghezza -gt $altezza ]]
then
latolungo=$larghezza
fi
if [[ $altezza -gt $larghezza ]]
then
latolungo=$altezza
fi
#CHECK IF EDGE ARE WHITE
if [[ $controllo1 == "white" ]] &&[[ $controllo2 == "white" ]] &&[[ $controllo3 == "white" ]] && [[ $controllo4 == "white" ]] && [[ $bordoscegli == 0 ]] || [[ $bordoscegli == 2 ]]
then
echo "BORDO AGGIUNTO"
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf pad=width=iw+$numeropixelmassimo:height=ih+$numeropixelmassimo:x=$numeropixelbordo:y=$numeropixelbordo:color=white $cartellavecchia/"1_"$fotomodifica
rm -r $cartellavecchia/$fotomodifica
mv $cartellavecchia/"1_"$fotomodifica $cartellavecchia/$fotomodifica
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
fi
if [[ $bordoscegli == 3 ]] && [[ $sceglitipofoto == 0 ]]
then
echo "BORDO TOLTO"
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf "crop=iw-$numeropixelmassimo:ih:$numeropixelbordo:0" $cartellavecchia/"1_"$fotomodifica
rm -r $cartellavecchia/$fotomodifica
mv $cartellavecchia/"1_"$fotomodifica $cartellavecchia/$fotomodifica
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
grandezza=$(convert $cartellavecchia/$fotomodifica -print "%wx%h\n" /dev/null)
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%w\n" /dev/null)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%h\n" /dev/null)
controllo1=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,0}]" info:-)
controllo2=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{0,$altezza}]" info:-)
controllo3=$(convert $cartellavecchia/$fotomodifica -format '%[pixel:p{0,0}]' info:-)
controllo4=$(convert $cartellavecchia/$fotomodifica -format "%[pixel:p{$larghezza,$altezza}]" info:-)
latolungo=$altezza
if [[ $larghezza -gt $altezza ]]
then
latolungo=$larghezza
fi
if [[ $altezza -gt $larghezza ]]
then
latolungo=$altezza
fi
fi
#IF THE WIDTH IS GREATER THAN THE HEIGHT THEN CALCULATE THE HEIGHT PROPORTIONALLY
if [[ $larghezza -gt $altezza ]] && [[ $sceglitipofoto -eq 0 ]]
then
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%h\n" /dev/null)
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%w\n" /dev/null)
altezzagiusta=$(echo "scale=2; $altezza/$larghezza" | bc)
altezzagiusta=$(echo "0"$altezzagiusta | sed 's/0\./0,/;s/\.0/,0/')
if [[ $latolungo -le 1400 ]] #IF THE LONGEST SIDE IS SMALL THAN 1400 THE IMAGE GOES TO 1200X1200
then
altezzagiusta=$((($altezzagiusta *1200)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=1200:$altezzagiusta $cartellavecchia/"1_"$fotomodifica
numeropixelvecchio=$((1200-$altezzagiusta))
fi
if [[ $latolungo -gt 1400 ]] #IF THE LONGEST SIDE IS GREATER THAN 1400 THE IMAGE GOES TO 2400X2400
then
altezzagiusta=$((($altezzagiusta *2400)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=2400:$altezzagiusta $cartellavecchia/"1_"$fotomodifica
numeropixelvecchio=$((2400-$altezzagiusta))
fi
numeropixel=$(($numeropixelvecchio /2 ))
ffmpeg -y -i $cartellavecchia/"1_"$fotomodifica -vf pad=height=ih+$numeropixelvecchio:x=$numeropixel:y=$numeropixel:color=white $cartellanuova/$fotomodifica
rm -r $cartellavecchia/"1_"$fotomodifica
fi
#IF THE HEIGHT IS GREATER THAN THE WIDTH THEN IT CALCULATES THE WIDTH PROPORTIONALLY
if [[ $altezza -gt $larghezza ]] && [[ $sceglitipofoto -eq 0 ]]
then
fotomodifica=$(ls $cartellavecchia | head -$i | tail -1)
altezza=$(convert $cartellavecchia/$fotomodifica -print "%h\n" /dev/null)
larghezza=$(convert $cartellavecchia/$fotomodifica -print "%w\n" /dev/null)
larghezzagiusta=$(echo "scale=2; $larghezza/$altezza" | bc)
larghezzagiusta=$(echo "0"$larghezzagiusta | sed 's/0\./0,/;s/\.0/,0/')
if [[ $latolungo -le 1400 ]] #IF THE LONGEST SIDE IS SMALL THAN 1400 THE IMAGE GOES TO 1200X1200
then
larghezzagiusta=$((($larghezzagiusta * 1200)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=$larghezzagiusta:1200 $cartellavecchia/"1_"$fotomodifica
numeropixellarghezza=$((1200-$larghezzagiusta))
fi
if [[ $latolungo -gt 1400 ]] #IF THE LONGEST SIDE IS GREATER THAN 1400 THE IMAGE GOES TO 2400X2400
larghezzagiusta=$((($larghezzagiusta * 2400)/100))
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=$larghezzagiusta:2400 $cartellavecchia/"1_"$fotomodifica
numeropixellarghezza=$((2400-$larghezzagiusta))
fi
numeropixelgiusto=$(($numeropixellarghezza /2 ))
ffmpeg -y -i $cartellavecchia/"1_"$fotomodifica -vf pad=width=iw+$numeropixellarghezza:x=$numeropixelgiusto:y=$numeropixelgiusto:color=white $cartellanuova/$fotomodifica
rm -r $cartellavecchia/"1_"$fotomodifica
fi
#IF HEIGTH IS EQUAL TO WIDTH THE IMAGE GOES TO 1200X1200
if [[ $altezza -eq $larghezza ]] && [[ $sceglitipofoto -eq 0 ]]
then
echo "Valori uguali"
if [[ $latolungo -le 1400 ]]
then
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=1200:1200 $cartellanuova/$fotomodifica
fi
if [[ $latolungo -gt 1400 ]]
then
ffmpeg -y -i $cartellavecchia/$fotomodifica -vf scale=2400:2400 $cartellanuova/$fotomodifica
fi
fi
if [[ $sceglitipofoto -eq 1 ]] #GLOVES
then
orientamento_foto=$(python3 <<EOF
from PIL import Image
import numpy as np
image_path = "$cartellavecchia/$fotomodifica"
image = Image.open(image_path)
image_array = np.array(image)
white_color = [255, 255, 255]
non_white_pixels = np.argwhere(np.any(image_array != white_color, axis=-1))
filtered_pixels = [pixel for pixel in non_white_pixels
                   if image_array[tuple(pixel)][0] <= 240]
top_pixel = filtered_pixels[np.argmin([p[0] for p in filtered_pixels])]
bottom_pixel = filtered_pixels[np.argmax([p[0] for p in filtered_pixels])]
left_pixel = filtered_pixels[np.argmin([p[1] for p in filtered_pixels])]
right_pixel = filtered_pixels[np.argmax([p[1] for p in filtered_pixels])]
alto=top_pixel[0]
basso=bottom_pixel[0]
sinistra=left_pixel[1]
destra=right_pixel[1]
lato_tolleranza="$latolungo"
lato_tolleranza=(int(lato_tolleranza)*5)/100
if alto > basso:
 valorey=alto-basso
else:
 valorey=basso-alto
if destra > sinistra:
 valorex=destra-sinistra
else:
 valorex=sinistra-destra
if valorex > valorey or lato_tolleranza >= (valorey - valorex):
 print(1)
if valorey > valorex and lato_tolleranza < (valorey - valorex):
 print(0)
if valorey == valorex:
 print('ERRORE X=Y')
EOF
)
if [[ $orientamento_foto -eq 0 ]]
then
convert $cartellavecchia/$fotomodifica -flop $cartellavecchia/"2_"$fotomodifica
convert -size 1200x1200 xc:white $cartellavecchia/"3_"$fotomodifica
convert $cartellavecchia/$fotomodifica -trim $cartellavecchia/"1_"$fotomodifica
convert $cartellavecchia/"2_"$fotomodifica -trim $cartellavecchia/"2_"$fotomodifica
convert $cartellavecchia/"2_"$fotomodifica -resize 600x1200 $cartellavecchia/"2_"$fotomodifica
convert $cartellavecchia/"1_"$fotomodifica -resize 600x1200 $cartellavecchia/"1_"$fotomodifica
echo "FOTO-VERTICALE"
if [[ $posizionepollice == 0 ]]
then
convert $cartellavecchia/"3_"$fotomodifica \
\( $cartellavecchia/"2_"$fotomodifica -gravity center -geometry -300+0 \) -composite \
\( $cartellavecchia/"1_"$fotomodifica -gravity center -geometry +300+0 \) -composite \
-splice 50x0 $cartellanuova/$fotomodifica
ffmpeg -y -i $cartellanuova/$fotomodifica -vf pad=width=iw+200:height=ih+200:x=100:y=100:color=white $cartellanuova/$fotomodifica
fi
if [[ $posizionepollice == 1 ]]
then
convert $cartellavecchia/"3_"$fotomodifica \
\( $cartellavecchia/"1_"$fotomodifica -gravity center -geometry -300+0 \) -composite \
\( $cartellavecchia/"2_"$fotomodifica -gravity center -geometry +300+0 \) -composite \
-splice 50x0 $cartellanuova/$fotomodifica
ffmpeg -y -i $cartellanuova/$fotomodifica -vf pad=width=iw+200:height=ih+200:x=100:y=100:color=white $cartellanuova/$fotomodifica
fi
fi
if [[ $orientamento_foto -eq 1 ]]
then
echo "FOTO-ORIZZONTALE"
convert $cartellavecchia/$fotomodifica -flop $cartellavecchia/"2_"$fotomodifica
convert $cartellavecchia/$fotomodifica -shave 0x$numeropixelbordo $cartellavecchia/"1_"$fotomodifica && convert $cartellavecchia/"1_"$fotomodifica -shave $numeropixelbordo"x0" $cartellavecchia/"1_"$fotomodifica
convert $cartellavecchia/"2_"$fotomodifica -shave 0x$numeropixelbordo $cartellavecchia/"2_"$fotomodifica && convert $cartellavecchia/"2_"$fotomodifica -shave $numeropixelbordo"x0" $cartellavecchia/"2_"$fotomodifica
convert \
\( $cartellavecchia/"1_"$fotomodifica -resize 1200x600 -gravity center -background white -extent 1200x600 \) \
\( $cartellavecchia/"2_"$fotomodifica -resize 1200x600 -gravity center -background white -extent 1200x600 \) \
-append -gravity northwest -background white -extent 1200x1200 $cartellanuova/$fotomodifica
fi
rm -r $cartellavecchia/"1_"$fotomodifica
rm -r $cartellavecchia/"2_"$fotomodifica
rm -r $cartellavecchia/"3_"$fotomodifica 2>>/dev/null
fi
convert $cartellanuova/$fotomodifica -strip $cartellanuova/$fotomodifica #REMOVE EXTRA-INFO FROM FILE (SMALLER SIZE)
#mv $cartellavecchia/$fotomodifica $cartellavecchia/"PROCESSATA_"$fotomodifica
#rm -r $cartellavecchia/$fotomodifica
done
