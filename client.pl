#!/usr/bin/perl

use strict;
use Socket;
my ($remote, $port, $iaddr, $paddr, $proto, $line);

if ($#ARGV != 1)
{
	print <<EOF;

Forma de Uso:

	$0 <host> <port>

Ejemplo:
	$0 localhost 2345

EOF
	exit 0;
}

my $server_address = $ARGV[0];
my $server_port = $ARGV[1];

# Chequea que el puerto TCP sea numerico. Si no lo es,
# busca en el listado de servicios '/etc/services', para
# ver si puede determinar el numero de puerto.

if ($server_port =~ /\D/)
{
	$server_port = getservbyname($port, 'tcp')
}
die "No se pudo determinar el numero de puerto" unless $server_port;

# De la misma manera que obtiene el numero de puerto TCP
# del server, trata de obtener la direccion IP del server
# a partir del nombre del mismo. Esto se hace buscando
# primero en el archivo '/etc/hosts', y luego utilizando
# el servicio de DNS.
my $ip = inet_aton($server_address) or die "No se pudo determinar la direccion IP para el host $server_address";

# Arma la direccion que se utilizara para contactar al server.
# Esta direccion esta formada por el par 'direccion ip' y 'puerto'.
$paddr = sockaddr_in($server_port, $ip);

# Obtiene el valor del protocolo 'tcp', el cual debe ser provisto
# a 'ip' para armar el socket.
$proto = getprotobyname('tcp');
# Arma el socket efectivamente.
socket(SOCK, PF_INET, SOCK_STREAM, $proto) or die "No se pudo crear socket: $!";

# Establece la conexion con el server.
connect(SOCK, $paddr) or die "No se pudo realizar conexion con el server: $!";

# A medida que recibe "lineas" de texto desde el server, las va
# escribiendo en la pantalla.
while ($line = <SOCK>)
{
	print $line;
}

# Cierra el socket y termina el programa.
close (SOCK) or die "close: $!";
exit;
