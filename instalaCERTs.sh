#!/bin/bash

## ARCHIVO: /usr/local/sbin/instalaCERTs.sh
##              
## USO: instalaCERTs.sh
##
## GitHub Project:
## https://github.com/leomartinez/Install-RootCA-AR.git
##

#############################
## DEFINICIÓN DE VARIABLES ##
#############################

# Directorios
CERTDIR="/usr/local/share/ca-certificates"
ACARDIR="AR_acraiz"
TEMPDIR="/tmp"

# Archivos
ACROOT2007DESC="Certificado de la AC Raíz de la República Argentina 2007"
ACROOT2007URL="http://acraiz.gov.ar/ca.crt"
ACROOT2016DESC="Certificado de la AC Raíz de la República Argentina 2016"
ACROOT2016URL="http://acraiz.gov.ar/acraizra.crt"
ACONTI2020DESC="NUEVO Certificado de la AC ONTI 2020"
ACONTI2020URL="https://www.acraiz.gob.ar/Content/Archivos/certificados/licenciados/10.crt"
ACONTIDESC="Certificado de la AC ONTI"
ACONTIURL="https://www.acraiz.gob.ar/Content/Archivos/certificados/licenciados/03.crt"
ACPFDRDESC="Certificado de la AC MODERNIZACIÓN-PFDR"
ACPFDRURL="https://www.acraiz.gob.ar/Content/Archivos/certificados/licenciados_acraiz2016/01.crt"

# Comandos
WGET=`which wget`
UPDATECA=`which update-ca-certificates`
CP=`which cp`
MV=`which mv`
RM=`which rm`
CHMOD=`which chmod`
MKDIR=`which mkdir`

# Variables locales
USO="instalaCERTs.sh"

# Parámetros para wget. Ajustar según necesidades (ej: proxy)
# WGETPARAM="-e http_proxy=<proxy-server>:<proxy-port> -e https_proxy=<proxy-server>:<proxy-port>"
WGETPARAM=""

# Variables de representación en pantalla

linea="==============================================================================="
reset_terminal="tput sgr0"
negrita_ini="\033[1m"
negrita_fin="\033[0m"
negro="\E[30m"
negro_bg="\E[40m"
rojo="\E[31m"
rojo_bg="\E[41m"
verde="\E[32m"
verde_bg="\E[42m"
amarillo="\E[33m"
amarillo_bg="\E[43m"
azul="\E[34m"
azul_bg="\E[44m"n
magenta="\E[35m"
magenta_bg="\E[45m"
cyan="\E[36m"
cyan_bg="\E[46m"
blanco="\E[37m"
blanco_bg="\E[47m"


#############################
## DEFINICIÓN DE FUNCIONES ##
#############################

verifica_args() {
#
# Verifica que la cantidad de argumentos sea la correcta
#
# Ejemplo:
# verifica_args 2 $#
#

EXPECTED_ARGS=$1
ARGS=$2
E_BADARGS=65
if [ $ARGS -ne $EXPECTED_ARGS ]; then
    clear
    echo -ne "\n${negrita_ini}${rojo}${linea}\n\n${amarillo}La cantidad de argumentos no corresponde. ARGS: ${ARGS}\n\nUso: ${blanco}${USO}\n\n${rojo}${linea}\n\n"; $reset_terminal
    exit $E_BADARGS
else
    return 0
fi
}

presione_enter () {
    echo ""
    echo -ne "${negrita_ini}${amarillo}Presione Enter para continuar${negrita_fin}"; $reset_terminal
    read
}

usuario_correcto() {
    echo -ne "\n${negrita_ini}Verificando que el usuario tiene permisos... ${negrita_fin}"; $reset_terminal
    if [ $USER != root ]; then
        echo -ne "${negrita_ini}${rojo}ERROR.\n\n${negrita_fin}"; $reset_terminal
	    echo -ne "${negrita_ini}${amarillo}El script debe ejecutarse con el usuario ${rojo}root${amarillo} o con un permisos ${negrita_ini}${rojo}sudo${amarillo}.\n\nTerminando la ejecución.\n\n${negrita_fin}" 1>&2
	    exit 1;
    fi
    echo -ne "${negrita_ini}${verde}OK.\n\n${negrita_fin}"; $reset_terminal
}


bajacert() {
    verifica_args 2 $#
    URL=$1
    DESC=$2
    echo -ne "\n\n${amarillo}Descargando el ${negrita_ini}$DESC${negrita_fin}.\n\n"; $reset_terminal
    $WGET $WGETPARAM $URL
    if [ $? -eq 0 ]; then
        echo -ne "${verde}Descarga correcto.\n\n"; $reset_terminal
    fi
}

#############################
##    SECCIÓN PRINCIPAL    ##
#############################

# verificar que el usuario tenga permisos
usuario_correcto

# Verificar que el script fue llamado sin parámetros
verifica_args 0 $#

# Descargar CRTs

cd $TEMPDIR

## Certificado de la AC Raíz de la República Argentina 2007
bajacert $ACROOT2007URL "$ACROOT2007DESC"

## Certificado de la AC Raíz de la República Argentina 2016
bajacert $ACROOT2016URL "$ACROOT2016DESC"

## NUEVO Certificado de la AC ONTI 2020
bajacert $ACONTI2020URL "$ACONTI2020DESC"

## Certificado de la AC ONTI
bajacert $ACONTIURL "$ACONTIDESC"

## Certificado de la AC MODERNIZACIÓN-PFDR
bajacert $ACPFDRURL "$ACPFDRDESC"

# Crear Directorio de certificados con permisos adecuados

echo -ne "\n\n${amarillo}Creando el directorio ${negrita_ini}$CERTDIR/$ACARDIR${negrita_fin}...  "; $reset_terminal

$MKDIR -p $CERTDIR/$ACARDIR
$CHMOD 755 $CERTDIR/$ACARDIR

echo -ne "${negrita_ini}${verde}OK.\n\n${negrita_fin}"; $reset_terminal

# Mover CRTs y acomdar permisos

echo -ne "\n\n${amarillo}Ubicando certificados ...  "; $reset_terminal

$MV $TEMPDIR/*.crt $CERTDIR/$ACARDIR
$CHMOD 644 $CERTDIR/$ACARDIR/*

# Atcualizar base de certificados
$UPDATECA


#############################
##    FINAL DEL SCRIPT     ##
#############################