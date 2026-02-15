#!/bin/bash

VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ "$1" == "-v" || "$1" == "--version" ]]; then
    echo "Encryption Tool v${VERSION}"
    exit 0
fi
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: encryption [OPTIONS] <file>"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show help"
    echo "  -v, --version    Show version"
    exit 0
fi
if [ $# -eq 0 ]; then
	echo "Использование: $0 <filename>"
	exit 1
fi
input_file="$1"
output_file=""
if [[ "$input_file" == *.data ]]; then
	echo "Файл $input_file имеет расширение .data, дешифрование и разархивирование..."
	output_file="${input_file%.data}"
	openssl enc -d -aes-256-cbc -in "$input_file" -out "$output_file"
	if [ $? -eq 0 ]; then
		echo -e "${GREEN}Архив $input_file успешно дешифрован.${NC}"
		rm "$input_file"
		if [[ "$output_file" == *.*.zip ]]; then
			unzip "$output_file"
		else
			unzip -j "$output_file" -d "${output_file%.zip}"
		fi
		if [ $? -eq 0 ]; then
			echo -e "${GREEN}Файл $output_file успешно разархивирован.${NC}"
			rm "$output_file"
		else
			echo -e "${RED}Ошибка при разархивировании файла $output_file.zip.${NC}"
			exit 1
		fi
	else
		echo -e "${RED}Ошибка при дешифровании архива $input_file.${NC}"
		exit 1
	fi
else
	echo "Файл $input_file не имеет расширение .data, создание архива ZIP и шифрование..."
	output_file="${input_file}.zip"
	zip -r "$output_file" "$input_file"
	if [ $? -eq 0 ]; then
		echo -e "${GREEN}Архив $input_file.zip успешно создан.${NC}"
		rm -rf "$input_file" 
		openssl enc -aes-256-cbc -in "$output_file" -out "${output_file}.data"
		if [ $? -eq 0 ]; then
			echo -e "${GREEN}Архив $input_file.zip успешно зашифрован и сохранен как ${output_file}.data${NC}"
			rm "$output_file" 
		else
			echo -e "${RED}Ошибка при шифровании архива $input_file.zip.${NC}"
			exit 1
		fi
	else
		echo -e "${RED}Ошибка при создании архива $input_file.zip.${NC}"
		exit 1
	fi
fi
exit 0
