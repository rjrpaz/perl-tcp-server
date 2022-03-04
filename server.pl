#!/usr/bin/perl

use strict;
use Socket;

# Subrutina que genera los mensaje formateado en pantalla
# al estilo de un log.
sub logmsg
{
	print scalar localtime, ": @_ \n";
}

# En el caso del server, necesita saber en que puerto tcp
# debe escuchar para esperar los requerimientos que lleguen
# del cliente. En principio, esperara que lleguen 
# requirimientos desde todas las interfaces que posee.
my $server_port = 2345;
my $proto = getprotobyname('tcp');

# Arma el socket con el cual esperara los requerimientos.
socket(SERVER, PF_INET, SOCK_STREAM, $proto) or die "No se pudo crear socket: $!";
setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, pack("l", 1)) or die "setsockopt: $!";

# Relacione al socket con las interfaces.
bind(SERVER, sockaddr_in($server_port, INADDR_ANY)) or die "Error en bind $!";

# Comienza a escuchar en todas las interfaces.
listen(SERVER,SOMAXCONN) or die "Error en listen $!";

logmsg "El server arranco escuchando en el puerto $server_port";

# Se crea un bucle infinito, ya que los servidores TCP
# son servicios que deben estar escuchando todo el tiempo
# a no ser que se los termine explicitamente.
for ( ; my $paddr = accept(CLIENT,SERVER); close CLIENT)
{
	# Cuando llega un requerimiento, arma el socket
	# con el cliente.
	my($port,$iaddr) = sockaddr_in($paddr);
	# Trata de obtener el nombre del cliente, a los
	# solos efectos de dejar registrada la conexion
	# en el log.
	my $name = gethostbyaddr($iaddr,AF_INET);
	logmsg "Conexion establecida desde $name [", inet_ntoa($iaddr), "] puerto $port";

	# Envia informacion al cliente.
	print CLIENT "Hola $name, la hora en el servidor es ", scalar localtime, "\n";
}

