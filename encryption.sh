#!/bin/bash
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
		echo "Архив $input_file успешно дешифрован."
		rm "$input_file"
		if [[ "$output_file" == *.*.zip ]]; then
			unzip "$output_file"
		else
			unzip -j "$output_file" -d "${output_file%.zip}"
		fi
		if [ $? -eq 0 ]; then
			echo "Файл $output_file успешно разархивирован."
			rm "$output_file"
		else
			echo "Ошибка при разархивировании файла $output_file.zip."
			exit 1
		fi
	else
		echo "Ошибка при дешифровании архива $input_file."
		exit 1
	fi
else
	echo "Файл $input_file не имеет расширение .data, создание архива ZIP и шифрование..."
	output_file="${input_file}.zip"
	zip -r "$output_file" "$input_file"
	if [ $? -eq 0 ]; then
		echo "Архив $input_file.zip успешно создан."
		rm -rf "$input_file" 
		openssl enc -aes-256-cbc -in "$output_file" -out "${output_file}.data"
		if [ $? -eq 0 ]; then
			echo "Архив $input_file.zip успешно зашифрован и сохранен как ${output_file}.data"
			rm "$output_file" 
		else
			echo "Ошибка при шифровании архива $input_file.zip."
			exit 1
		fi
	else
		echo "Ошибка при создании архива $input_file.zip."
		exit 1
	fi
fi
exit 0
