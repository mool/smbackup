#!/bin/bash

## Script de backup de recursos compartidos SAMBA
#
# Uso: backup.sh <archivo.conf>
#

BACKUPDIR="/home/mool/dev/smbackup/files"
SMBCLIENT=$(which smbclient)

if [ $1 ]; then
  [ ! -d $BACKUPDIR ] && echo "Creando el directorio de backups" && mkdir $BACKUPDIR

	CONFIG_FILE=$1
	FECHA=$(date +%F)

	while read line; do
		set -- $line
		# skip comments
		[[ ${line:0:1} == "#" ]] && continue
		# skip empty lines
		[[ -z "$line" ]] && continue

		BACKUP_HOST=$(echo $1 | awk -F / '{ print $3 }')
		BACKUP_SRC=$(echo $1 | awk -F / '{ print $4 }')

		[ ! -d $BACKUPDIR/$FECHA ] && echo "Creando el directorio para la FECHA $FECHA" && mkdir $BACKUPDIR/$FECHA
		[ ! -d $BACKUPDIR/$FECHA/$BACKUP_HOST ] && echo "Creando el directorio para el Host $BACKUP_HOST" && mkdir $BACKUPDIR/$FECHA/$BACKUP_HOST

		echo "Haciendo el backup de $BACKUP_HOST - $BACKUP_SRC..."

		if [ $2 ]; then
				$SMBCLIENT -U $2 $1 $3 -c "tarmode full" -Tcq - | gzip > $BACKUPDIR/$FECHA/$BACKUP_HOST/$BACKUP_SRC.tar.gz
		else
			$SMBCLIENT $1 -N -c "tarmode full" -Tcq - | gzip > $BACKUPDIR/$FECHA/$BACKUP_HOST/$BACKUP_SRC.tar.gz
		fi
	done < $CONFIG_FILE
else
	echo "Uso: ./backup.sh <archivo.conf>"
fi
