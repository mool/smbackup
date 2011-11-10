#!/bin/bash

## Script de backup de recursos compartidos SAMBA
#
# Uso: backup.sh <archivo.conf>
#

BACKUPDIR="/var/backups/pcs"
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

		BACKUP_HOST=$(echo $1 | awk -F / '{ print $3 }')
		BACKUP_SRC=$(echo $1 | awk -F / '{ print $4 }')

		if [ ! -d $BACKUPDIR/$FECHA ]; then
			echo Creando el directorio para la FECHA $FECHA
			mkdir $BACKUPDIR/$FECHA
		fi
		if [ ! -d $BACKUPDIR/$FECHA/$BACKUP_HOST ]; then
			echo Creando el directorio para el Host $BACKUP_HOST
			mkdir $BACKUPDIR/$FECHA/$BACKUP_HOST
		fi

		echo Haciendo el backup de $BACKUP_HOST - $BACKUP_SRC...

		if [ $2 ]; then
			if [ $3 ]; then
				$SMBCLIENT -U $2 $1 $3 -c "tarmode full" -Tcq $BACKUPDIR/$FECHA/$BACKUP_HOST/$BACKUP_SRC.tar
			else
				$SMBCLIENT -U $2 $1 -c "tarmode full" -Tcq $BACKUPDIR/$FECHA/$BACKUP_HOST/$BACKUP_SRC.tar
			fi
		else
			$SMBCLIENT $1 -N -c "tarmode full" -Tcq $BACKUPDIR/$FECHA/$BACKUP_HOST/$BACKUP_SRC.tar
		fi
	done < $CONFIG_FILE
else
	echo "Uso: ./backup.sh <archivo.conf>"
fi
