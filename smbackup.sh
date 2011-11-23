#!/bin/bash

## Script de backup de recursos compartidos Windows/SAMBA
#
# Uso: backup.sh <archivo.conf>
#

BACKUPDIR="/var/backups/pcs"
EXCLUDE="*.avi *.mpg *.mpeg *.mov *.mkv *.mp4 *.wma *.wav *.mp3"
SMBCLIENT=$(which smbclient)

if [ $1 ]; then
	CONFIG_FILE=$1
	FECHA=$(date +%F)

	while read line; do
		set -- $line
		# skip comments
		[[ ${line:0:1} == "#" ]] && continue
		# skip empty lines
		[[ -z "$line" ]] && continue
		# configuration
		if [[ ${line:0:9} == "BACKUPDIR" ]]; then
			BACKUPDIR=$(echo $line | awk -F = '{ print $2 }')
			[ ! -d $BACKUPDIR ] && echo -e "Creando el directorio de backups\n" && mkdir $BACKUPDIR
			continue
		fi

		BACKUP_HOST=$(echo $1 | awk -F / '{ print $3 }')
		BACKUP_SRC=$(echo $1 | awk -F / '{ print $4 }')

		[ ! -d $BACKUPDIR/$FECHA ] && echo "Creando el directorio para la FECHA $FECHA" && mkdir $BACKUPDIR/$FECHA
		[ ! -d $BACKUPDIR/$FECHA/$BACKUP_HOST ] && echo -e "\nCreando el directorio para el Host $BACKUP_HOST" && mkdir $BACKUPDIR/$FECHA/$BACKUP_HOST

		echo "Haciendo el backup de $BACKUP_HOST - $BACKUP_SRC..."

		if [ $2 ]; then
			$SMBCLIENT -U $2 $1 $3 -c "tarmode full" -TXrcq - $EXCLUDE | gzip > $BACKUPDIR/$FECHA/$BACKUP_HOST/$BACKUP_SRC.tar.gz
		else
			$SMBCLIENT $1 -N -c "tarmode full" -TXrcq - $EXCLUDE | gzip > $BACKUPDIR/$FECHA/$BACKUP_HOST/$BACKUP_SRC.tar.gz
		fi
	done < $CONFIG_FILE
else
	echo "Uso: ./backup.sh <archivo.conf>"
fi
