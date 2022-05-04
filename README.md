Esta es una guia de como se debe instalar arch linux con bspwm y el kernel zen
Comensamos descargando arch de su página oficial y buscando el servidor más
cercano a nuestro lugar de residencia

Posteriormente se puede utilizar rufus si se esta en windows o rosa-image-writer
en linux, o tambien suse-estudio-writer para bootear una usb, y ya que el .iso
pesa aproximadamente 900MB no es necesaria una memoria muy grande. Depende de la
motherboard de la computadora que tecla se ocupe al encender la computadora para
bootear desde la usb.

Al entrar al instalador de linux se tendra por defecto el teclado de USA. Para
cambiarlo se utiliza el comando

$loadkeys la-latin1

en el caso de que el teclado sea el latinoamericano

Posteriormente se debe conectar la computadora a un puerto ethernet para contar
con insternet y poder descargar los archivos del sistema. Aunque también se puede
hacer mediante wifi.


Se debe agregar la actualización del reloj del sistema:
$timedatectl set-ntp true


###############################################################################
#############Particiones#######################################################
###############################################################################

Ahora se revisa el disco duro y sus particiones con
fdisk -l

Posteriormente se procede a hacer el esquema de particiones dependiendo si nuestro
modo de arranque, con boot solo se necesitan dos particiones, una para la swap y
otro para la memoria principal que debe ser booteable

$cfdisk     //para hacer las particiones para boot se selecciona 'dos' como tipo
            //de partición

Se muestra un menu con las particiones y el espacio libre existente, en la parte
inferior nos interesan las opciones [delete] [new] [booteable] [type] [write] 
Alli se borran todas las particiones existentes con la opción [delete] despues
en el espacio libre se selecciona [new] y se ponen de 1 a 2 G para la swap, para
decir que es swap se selecciona [type] y en el menu que aparece se escoje swap/solaris
Se debe hacer una segunda partición para el sistema seleccionando todo el espacio
restante, de esta partición no se debe selecionar el [type] en cambio una vez
creada se debe seleccionar [booteable].

Como resultado de lo anterior se pueden ver las particiones con fdisk -l 
/dev/sda
	/dev/sda1        swap
	/dev/sda2	linux
Estas particiones se deben de formatear, 
mkfs.ext4 /dev/sda2	fromatea la partición principal
mkswap /dev/sda1	formatea la swap
swapon /dev/sda1	enciende la swap

###################################################################################
################################Descargando el sistema#############################
###################################################################################

Lo siguiente es montar el sistema de archivos en la partición root
$mount /dev/sda2 /mnt

Los siguiente es instalar descargar el sistema para poderlo intalar
Anteriormente se debían escoger los servidores que estan en
/etc/pacman.d
para buscar los que se querian utilizar se podian utilizar expreiones
regulares. Pero actualmente el sistema utiliza reflector para generar la lista de 
servidores, y selecciona los que utilizaras dependiendo desde que localidad se este.

Ahora se descargara el sistema en /mnt que es donde se habia montado la partición 
de los /dev/sda2 que era la booteable.

$pacstrap /mnt base linux linux-firmware

Posteriormente se deben crear los ficheros fstab que comunmente se encuentra en /etc
y se encarga del esquema de las particiones y de la información necesaria para montar
las particiones
$genfstab -U /mnt >> /etc/mnt/fstab

Lo siguiente es camiar lla ubicación del directorio ráiz de los procesos que estan sucediendo
$arch-chroot /mnt           ->se cambia el entorno raiz a la partición donde se instalo el 
                            ->sistema en el que se moto /dev/sda2


########################################################################################
######################Configuración de zona horaria#####################################
########################################################################################

--> Zona Horario

Para establecer la zona horaia se debe crear un enlace simbólico del lugar donde se
encuentra la información, se puede listar el continente con el siguiente comando:

$ls /usr/share/zoneinfo

Se selecciona 'America' o el continente que se desee

$ls /usr/share/zoneinfo/America/Mexico_City

Y se hace el enlace simboolíco

$ln -sf /usr/share/zoneinfo/America/Mexico_City /mnt/localtime

Depués se corre hwclock para generar el archivo /etc/adjtime

$hwclock --systohc

--> Localización

Se debe editar el archivo /etc/locale.gen para seleccionar los caracteres que se utilizaran
Para hacer esto simplenete se descomenta la linea de la región, pero primero se debe
descargar nano o algún editor de texto, ya que al cambiar con arch-chroot ya no se tiene 
nada instalado, nisiquiera se puede acceder a internet, para acceder a internet se debe 
habilitar 'dhcpcd'
$sudo pacman -S nano nvim dhcpcd

Para habilitar dhcpcd se debe iniciar el servicio con sistemd
$systemctl enable dhcpcd

Ahora si con nano se puede modificar /etc/locale.gen y se descomenta es_MX.UTF-8

Por ultimo se genera el idioma en base a este documento
$locale-gen

Por último se debe escribir en /etc/locale.conf
$echo LANG=es_MX.UTF-8 >> /etc/locale.conf

Y para el teclado también se debe editar /rtc/vconsole.conf
$echo KEYMAP=la-latin1 >> /etc/vconsole.conf


--> Configurando el Host (la máquina)

Para configurar en hostname se debe escribir al final del documento /etc/hostname

$echo NombreDelSistema >> /etc/hostname

Ahora se deben configurar las coincidencias de las entradas del host en el documento /etc/host

---------------------------------------------------------------------------------
127.0.0.1	localhost
::1	localhost
127.0.1.1	NombreDelSistema.localdomain	NombreDelSistema
---------------------------------------------------------------------------------


------> Contraseña de root

Para configurar la contraseña del usuario root se utiliza el comando passwd
$passwd


###############################################################################################
###############################3Grub como bootloader###########################################
###############################################################################################


Para arrancar el sistema se utiliza un bootloader de otra manera no se detectara el sistema
Grub es el más común, para ello se instala
$pacman -S grub

Y después se instala grub en el disco principal
$grub-install --target=i386-pc /dev/sda    //se instala en todo el disco

Posteriormente se personalizara el grub

Para generar el archivo principal de configuración 
$grub-mkconfig -o /boot/grub/grub.cfg



Posteriormente se reinicia el sistema para posteriormente configurarlos usuarios

se sale del sistema 
$exit

Y se desmonta la partición principal 
$umount /dev/sda2

Y por ultimo se hace un reboot
$reboot
y antes de se prenda el sistema se retira la usb

Al iniciar se inicia en usuario root

arch login: root
Password:

###############################################################################################
#################################Configurando usuarios#########################################
###############################################################################################


Para poder uzar un usuario se debe instlar sudo
$pacman -S sudo

Ahora se instala vi
$pacman -S vi

y se abre el archivo de configuración de sudo con el comando
#visudo

Y en ese archivo se descomenta la linea
---------------------------------------
%wheel ALL=(ALL) ALL
---------------------------------------

Para que  los usuarios que pertenecen al grupo wheel puedan utilizar el comando sudo

---->Añadiendo usurios

3ara crear un usuario se utiliza el siguiente comando
#useradd -m jordi             //donde -m indica que se debe crear la carpeta $Home del usuario

Y se le debe dar una contraseña de inicio de seción
#passwd jordi

---->Añadiendo el usuario a los grupos para que pueda acceder a las diferentes funciones

#usrmod -aG audio,disk,floppy,lp,network,optical,power,scanner,storage,video,wheel jordi

Y con esto puedo comprobar que se añadieron bien los grupos
#groups jordi

Ahora puedo salir de la seción del usuario root
#exit

E iniciar seción con el usuario jordi
arch login: jordi
pasword:



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%Comenzndo con el entorno gráfico%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Primero se necesita un gestor de ventanas, para ello se utiliza xorg, concretamente se
necesita xorg-server que es el servicio de ventanas y el xorg-xinit que nos proporciona una
forma de iniciar aplicaciones al arrancar xorg ya sea con un dm o con xstart para no tener
problemas se instla todo el paquete xorg con pacman
$sudo pacman -S xorg
 
Pero se debe instalar por separado el xorg-xinit
$sudo pacman -S xorg-xinit


############################################################################################
###########################Lightdm##########################################################
############################################################################################

Para no tener que iniciar la seción de xor con el comando 
$xstart 
se utiliza un entorno de inicio de seción
Lightdm es una muy buena opción, para poderlo configurar se utilizan greeters que son las
plantillas y algunas de ellas permiten ciertas configuraciones, el greeter gtk es el más
común y tiene un entorno de configuración gráfico, para instalar todo eso se utiliza
pacman:

$sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

Posteriormente se debe iniciar el servicio de lightdm con systemd:
$sudo system enable lightdm

Y se debe configurar el archivo de configuración del arranque de lightdm
$sudo nvim /etc/lightdm/lightdm.conf

Y se descomenta la linea
greeter-session=lightdm-gtk-greeter


Antes de reiniciar el sistema se debe instalar el gestor de ventanas bspwm y sxhkd


############################################################################################
#########################BSPWM##############################################################
############################################################################################

Para tener bspwm, se debe instalar bspwm con pacman y sxhkd para las teclas.
$sudo pacman -S bspwm sxhkd

Para dar una configuración inicial existen dos archivos de configuración que se instalan
al momento de instalar lo anterior, esos se deben copiar al fichero .config bajo
.config/bspwm/ y .config/sxhkd

$mkdir ~/.config/bspwm
$mkdir ~/.config/sxhkd

$cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm

$cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd

Al bspwm se le deben dar permisos de ejecución:
$chmod +x ~/.config/bspwm/bspwmrc

Además se deben modificar algunos atajos de teclado que se pueden ver en el video de 
s4avitar:
https://www.youtube.com/watch?v=mHLwfI1nHHY&t=404s

Ahora necesitamos una terminal, para ello utilizaremos alacritty que es el mejor emukador
de terminal

$sudo pacman -S alacritty

Para después modificar el sxhkdrc en el comando de la terminal

------------------------------
# terminal emulator
super + Return
    alacritty
----------------------

Posteriormente para poder arrancar con bspwm y poder utilizarlo, debemos agregarlo en 
xinit, copiando el archivo de configuración 

$cp /etc/X11/xinit/xinitrc ~/.xinitrc

En este archivo ~/.xinitrc se borran las últimas 5 líneas y se agrega

------------------------------
picom -f &
exec bspwm
------------------------------


Ahora se puede reiniciar el sistema e iniciar seción con bspwm y lightdm. Lo
siguiente es Instalar la Polybar para ello se debe instalar el ayudante de instalación 
yay




######################################################################################
###########################YAY########################################################
######################################################################################

Para no tener conflictos al instalarlo, primero se debe instalar un paquete de
desarrollo:

$sudo pacman -S base-devel git

Se utilizara git porque el paquete de yay es un repositorio y base devel contiene 
los paquetes que regularmente se ocupan para compilar como gcc y makepkg

Posteriormente se clona el repositorio y se compila

$cd ~
$git clone https://aur.archlinux.org/yay.git
$cd yay
$makepkg -si

Ahora si se podra instalar la poderosisima polybar

#####################################################################################
######################Polybar########################################################
#####################################################################################

Para instalar la polybar se puede utilizar pacman o descargarla y compilarla desde
github

$yay -S polybar

cd /home/s4vitar/Descargas/
git clone --recursive https://github.com/polybar/polybar
cd polybar/
mkdir build
cd build/
cmake ..
make -j$(nproc)
sudo make install

Posteriormente se debe agragar al archivo de configuración que se encuentra en 
/usr/share/doc/polybar/config
para sistemas arch y en /usr/local/share/doc/polybar/config para debian


Pero nosotros utilizaremos otra configuración que tiene como base el repositorio:
https://github.com/VaughnValle/blue-sky
Del cual tengo un fork por si en algun momento deja de funcionar:
https://github.com/jordi-olivares/blue-sky

Pero tiene ciertas modificaciones, de manera general son 
Una modificación importante es rofi-wifi-menu
https://github.com/jordi-olivares/rofi-wifi-menu
que puede ser abilitada en el módulo correspondiente en la configuración de
polybar, dichas modificaciónes estan en mi repositorio

Pero lo que se debe hacer es 

git clone https://github.com/VaughnValle/blue-sky.git
mkdir ~/.config/polybar
cd ~/Descargas/blue-sky/polybar/
cp * -r ~/.config/polybar

Después se agrega el lanzador al bspwmrc:

echo '~/.config/polybar/./launch.sh' >> ~/.config/bspwm/bspwmrc 

La parte de las fuentes me parece incesario por lo que una de las cosas
que se pueden hacer es modificar la configuración para trabajar solamente
con alguna Nerd Font
cd fonts
sudo cp * /usr/share/fonts/truetype/
fc-cache -v






Mi configuración de la polybar esta aqui:
https://github.com/jordi-olivares/ArchConfig





##########################################################################
######################Habilitar brillo y sonido###########################
##########################################################################

Para habilitar el brillo se utiliza brightnessctl

$sudo pacman -S brightnessctl

Y para habilitar las teclas se pone lo siguiente en el sxhkdrc

------------------------------------------------------
#teclas de brillo 
XF86MonBroghtnessDown
    brightnessctl set 2%-
XF86MonBrightnessUp
    brightnessctl set +2%
-----------------------------------------------------

Para las activar el sonido lo más sencillo es instalar pulseaudio
y para tener un entorno gráfico pavucontrol

$ sudo pacman -S pulseaudio pavucontrol

Y para que funcione se debe reiniciar el sistema

$reboot

Posteriormente para habilitar las teclas se debe poner lo
siguiente en el sxhkdrc:

------------------------------------------------------
#teclas de sonido
XF86AudioRaiseVolume
    pactl set-sink-volume @DEFAULT_SINK@ +5%
XF86AudioLowerVolume
    pactl set-sink-volume @DEFAULT_SINK@ -5%
XF86AudioMute
    pactl set-sink-mute @DEFAULT_SINK@ toggle

XF86AudioMicMute
    pactl set-source-mute @DEFAULT_SINK@ toggle

------------------------------------------------------


################################################################
#################Imprimir pantalla##############################
################################################################

Para habilitar esto se instala gnome-screenshot
$sudo pacman -S gnome-screenshot

Y se agraga lo siguiente a sxhkdrc

--------------------------------------
#Para imprimir pantalla
Print
    gnome-screenshot -i
---------------------------------------


################################################################
############Ranger##############################################
################################################################

Para instalar ranger
$sudo pacman -S ranger

Y para configurarlo se debe modificar el rc.conf
se debe modificar 
-------------------------------------
set preview_images_method ueberzug
-------------------------------------
Posteriormente para tener iconos se puede instalar lo siguiente

git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins

Y agregar lo siguiente a ~/.config/ranger/rc.conf
-------------------------
default_linemode devicons
--------------------------

Y tambien se debe modificar la siguientelinea:
-----------------------------
set show_hidden true
-----------------------------


*******En ubuntu
Para instalar ranger en ubuntu se puede hacer desde los repositorios oficiales
~$ sudo apt install ranger
Esto instala ranger pero no crea los archivos de configruarción para ello
se puede colocar el seguiente comando:
~$ranger --copy-option=all
Esto copia los archivos de configuración a la arpeta ~/.config/ranger/
los importantes son:
-rc.conf
Si no funciona este comando también se pueden copiar los repositorios manualmente
de 
/usr/share/doc/ranger/
Comunmente vienen comprimidos con terminación .gz pero se pueden descomprimir
con 
~$gzip -d documento

Posteriormente se debe instalar una fuente pached y agrgarla como fuente de la consola
Para ello se debe ir a la siguiente página:
https://github.com/ryanoasis/nerd-fonts
Y a la carpeta de patched-fonts, después se selecciona la fuente de interes
por ejemplo DaddyTime, y se abre su carpeta, después la carpeta "complete" y se
selecciona el archivo con extensión ttf que se desea instalar. por ejemplo:
DaddyTimeMono Nerd Font, se da doble click y ya por último se selecciona dowload.
Ya descargada la fuente pached, se debe copiar el archivo a la carpeta donde estan
las fuentes:
~$ sudo cp ~/Descargas/'DaddyTimeMono Nerd Font.ttf' /usr/local/share/fonts/

Si se está utilizando alacritty, se debe colocar el nombre de la fuente en su
apartado en el archivo ~/.config/alacritty/alacritty.yml
Cabe mensionar que el nombre se puede obtener abriendo la fuente con el gestor
de fuentes de ubuntu.

Ya que se tiene la fuente pached, se puede proseguir con los pasos de arch.
Si quieres personalizar más ranger, se puede ver el siguiente articulo:
https://atareao.es/software/utilidades/administrador-de-archivos-para-el-terminal/


###################################################################
#######################33Personalizando el grub####################
##################################################################

Para poder hacer esto primero se deben habilitar los arch user
repositories+
aur
Y eso se hace modificando /etc/pacman.conf

Y agregando al final de ese documento lo siguiente

------------------------------------------------
[archlinuxfr]
Server=http://repo.archlinux.fr/$arch
------------------------------------------------


ahora se instalara 
$yay -S update-grub

Despues se instala grub-customizer

$yay -S grub-customizer

Posteriormente se puede descargar un tema como el arch silence

ue se descarga clonando el siguiente repositorio

https://github.com/fghibellini/arch-silence

Después dentro de la carpeta se da permiso a 
install.sh y se ejecuta

$chmod +x install.sh
$./install.sh

Ahora se ejecuta 
$grub-customizer

y se va a configuración apariencia y se selecciona arch-silence

Se guarda y por ultimo se ejecuta
$sudo update-grub

Y se reinicia el sistema para poder ver los cambios




################################################################
###################Kernel zen###################################
################################################################

El kernel zen se puede buscar con yay ya que se tienen instalados
los aur 

$yay -s zen

Se busca el que tiene "linux zen 5.13.1zen1.1" o algo similar
y se instala 
Y para poderlo mostrar en el grub, de nuevo se hace

$sudo update-grub

Y ya se reinicia el sistema y se puede seleccionar en opciones
avanzadas el kernel zen






*********************************************************************
*********************************************************************
**********Alacritty en ubuntu****************************************
*********************************************************************
*********************************************************************

Alacritty esta construido en rust, por lo que se puede instalar con cargo
Primero tenemos que instalar cargo:
Cargo se puede instalar desde los repositorios oficiales:
~$ sudo apt install cargo
Lo cual instala rust y todo, después se deben instalar dependencias
Como se indica en su github:
https://github.com/alacritty/alacritty/blob/master/INSTALL.md
Y después se puede instalar alacritty desde cargo
~$cargo install alacritty




**************************************************************************
**************************************************************************
***********Distribución de teclado persistente****************************
**************************************************************************
**************************************************************************

Ubuntu utiliza systemd al igual que arch, por esta razon se pueden utilizar
todas las formas de cambiar los keymap que estan en la documentación de arch
https://wiki.archlinux.org/title/Xorg/Keyboard_configuration
Pero la más efectiva hace esta configuración directamente desde la configuración
de xorg en el archivo:
/etc/X11/xorg.conf.d/00-keyboard.conf

Por ejemplo para la distribución latinoamericana, con una computadora dell inspiron


Section "InputClass"
	Identifier "system-keyboard"
	MatchIsKeyboard "on"
	Option "XkbLayout" "latam"
	Option "XkbModel" "inspiron"
	Option "XkbVariant" "deadtilde"
EndSection


El deadtilde sirve para que el teclado espere cada vez que se pone un acento
