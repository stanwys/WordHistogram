#!/bin/bash
function licze(){
zmienna=$(cat $1|tr '[:punct:]' ' '|tr -s ' '|
tr '[a-ząćęóśłńżź]' '[A-ZĄĆĘÓŚŁŃŻŹ]'|tr ' ' '\n'|tr -s '\n'|sort)
echo -e "$3\n" >> $2
echo "$zmienna"|uniq -c|sort -n >> $2

#echo ${list[@]}|tr ' ' '\n'
# comment tr -cd [A-Za-z0-9ąćęóśłńżź]' '
}

sciezka_pliku="brak";rozszerzenie=".txt"

if [[ -z "$1" ]];then	#nie ma zadnego parametru- musze sam wpisac tekst
	read i;touch wyn
	echo "$i" >> temp.txt;wynik=$(licze temp.txt wyn brak_parametrow)
	cat wyn;rm temp.txt wyn
else
	if [[ "$1" == "-h" ]];then
		#wypisz pomoc
		echo "poprawna kolejnosc zapisu to:"
		echo "nazwa_katalogu rozszerzenie_pliku_wyjsciowego plik1 plik2 ..."
		shift
	fi
	if [[ -d "$1" ]];then  #jezeli istnieje dany katalog
		sciezka_pliku=$1;shift
	elif [[ "$1" == */* ]];then 
		mkdir -p $1;sciezka_pliku=$1;shift
	fi
	if [[ "$1" == "csv" ]];then 	#podaje rozszerzenie pliku, do ktorego chce 
		rozszerzenie=".csv";shift	#wpisac wyniki
	elif [[ "$1" == "txt" ]];then
		rozszerzenie=".txt";shift
	fi
	plik="stats$rozszerzenie"
	if [[ -a $plik ]];then 	#jezeli istnieje juz plik o takiej nazwie, to chce
		rm $plik 			#nowe statystyki
	fi
	while [[ ! -z $1 ]];do

	if [[ "$1" == *.pdf ]];then
		pdftotext $1 temp.txt;arg="temp.txt"
	elif [[ "$1" == *.ps ]];then
		ps2pdf $1 temp.pdf;pdftotext temp.pdf temp.txt;arg="temp.txt"
	else
		arg=$1
	fi
	wynik=$(licze $arg $plik $1)
	shift

	if [[ "$arg" == "temp.txt" ]];then #jezeli utworzono plik tymczasowy
		rm $arg 
		if [[ -a  temp.pdf ]];then
			rm temp.pdf
		fi
	fi
	done

	echo koniec
	if [[ $sciezka_pliku == "brak" ]];then	#nie podano sciezki, wypisuje na wyjscie
		cat "$plik"
		rm "$plik" 							#usuwam plik
	elif [[ ! -a "$sciezka_pliku/$plik" ]];then
		mv $plik "$sciezka_pliku"			#przenosze m do danego katalogu, bo
	fi										#zostal utworzony w tym samym katalogu
											#co skrypt, lecz jesli ma on byc w tym
fi											#samym to zostawiam
