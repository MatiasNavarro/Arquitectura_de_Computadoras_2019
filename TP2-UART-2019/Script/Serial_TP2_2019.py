try:
    from Tkinter import *
except ImportError:
    raise ImportError,"Se requiere el modulo Tkinter"

# coding: utf-8
import time 			# Para sleeps
import serial			# Comunicacion serie
from serial import *	# Comunicacion serie
import os				# Funciones del Sistema Operativo
import threading  		# Para uso de threads

 
#Constantes 
BAUDRATE = 9600
WIDTH_WORD = 8
CANT_STOP_BITS = 2
ESTADOS = ["PrimerOperando", "SegundoOperando", "CodigoOperacion"]


# Variables globales

ser = serial.Serial()
banderaPuertoLoop = 0
estadoPuerto = "NO CONECTADO"
etiquetaResultadoImpresion = "Resultado"
lock = threading.Lock()
currentState = ESTADOS [0]

# Funcion de traduccion del nombre de la operacion a su opcode correspondiente.
def getOPCODE (x):
    return {
        'ADD': '00100000',
        'SUB': '00100010',
		'AND': '00100100',
		'OR' : '00100101',
		'XOR': '00100110',
		'SRA': '00000011',
		'SRL': '00000010',
		'NOR': '00100111',
    }.get (x, '11111111')  #11111111 es el por defecto


# Funcion para desactivar botones

def desactivarBotones():
	lock.acquire()
	botonDesconectarFPGA.config (state = DISABLED)
	botonPrimerOperando.config (state = DISABLED)
	botonSegundoOperando.config (state = DISABLED)
	botonOperacion.config (state = DISABLED)
	lock.release()

# Funcion para activar botones, sigue el comportamiento de una maquina de estados

def activarBotones():
	lock.acquire()
	if (currentState == ESTADOS[0]):
		botonDesconectarFPGA.config (state = ACTIVE)
		botonPrimerOperando.config (state = ACTIVE)
		botonSegundoOperando.config (state = DISABLED)
		botonOperacion.config (state = DISABLED)
	elif (currentState == ESTADOS[2]):
		botonDesconectarFPGA.config (state = DISABLED)
		botonPrimerOperando.config (state = DISABLED)
		botonSegundoOperando.config (state = DISABLED)
		botonOperacion.config (state = ACTIVE)
	elif (currentState == ESTADOS[1]):
		botonDesconectarFPGA.config (state = DISABLED)
		botonPrimerOperando.config (state = DISABLED)
		botonSegundoOperando.config (state = ACTIVE)
		botonOperacion.config (state = DISABLED)
	else:
		botonDesconectarFPGA.config (state = ACTIVE)
		botonPrimerOperando.config (state = DISABLED)
		botonSegundoOperando.config (state = DISABLED)
		botonOperacion.config (state = DISABLED)
	lock.release()


# Funcion para conectar FPGA

def conectarFPGA(puerto):
	try:
		HiloConexion = threading.Thread (target = conexionViaThread, args = (puerto,)) 
		HiloConexion.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'


# Funcion que ejecuta el thread de la conexion
	
def conexionViaThread(puerto):
	global banderaPuertoLoop
	global ser
	global estadoPuerto
	global currentState
	
	print 'Thread de conexion/desconexion OK.'
	try:
		if (puerto == "disconnect" and estadoPuerto != "NO CONECTADO"):
			estadoPuerto = "NO CONECTADO"
			etiquetaPuertoEstado.config (text = estadoPuerto, fg = "red")
			desactivarBotones()
			botonConectarFPGA.config (state = ACTIVE)
			banderaPuertoLoop = 0
			ser.close()
			print 'Desconexion de puerto.'
		elif banderaPuertoLoop == 0:
			if puerto == "loop":
				ser = serial.serial_for_url ('loop://', timeout = 1)  #Configuracion del loopback test de esta forma
				ser.isOpen()        #Abertura del puerto.
				ser.timeout = None  #Siempre escucha
				ser.flushInput()	#Limpieza de buffers
				ser.flushOutput()
				estadoPuerto = "loop - OK"
				etiquetaPuertoEstado.config (text = estadoPuerto, fg = "dark green")
				currentState = ESTADOS[0]
				activarBotones()
				print 'Loop-ok: ', puerto
			else:
				try:
					ser=serial.Serial(
							port = puerto, #Configurar con el puerto
							baudrate = BAUDRATE,
							parity = serial.PARITY_NONE,
							stopbits = CANT_STOP_BITS, #Cant de bits de stop
							bytesize = WIDTH_WORD
					)
					estadoPuerto = str (puerto) + " - OK"
					etiquetaPuertoEstado.config (text = estadoPuerto, fg = "dark green")
					banderaPuertoLoop = 1
					ser.isOpen()        	#Abertura del puerto.
					ser.timeout = None    	#Siempre escucha
					ser.flushInput()		#Limpieza de buffers
					ser.flushOutput()
					currentState = ESTADOS[0]
					activarBotones()
					print 'Conexion OK en puerto : ', puerto
				except SerialException:
					estadoPuerto = str (puerto) + " - ERROR"
					etiquetaPuertoEstado.config (text = estadoPuerto, fg = "red")
					desactivarBotones()
					botonConectarFPGA.config(state = ACTIVE)
					print 'Error al tratar de abrir el puerto:', puerto
		else :
			print "Puerto ya configurado"
	except: 
		print 'Error en la conexion/desconexion.'
		activarBotones()


# Funcion que recibe el resultado obtenido de la ALU

def readResultado():
	while ser.inWaiting() == 1: #inWaiting -> cantidad de bytes en buffer esperando.
			lectura = ser.read(1)
			etiquetaResultadoImpresion = bin(ord (lectura))[2:][::-1]
			
			for i in range (0, 8 - len(etiquetaResultadoImpresion), 1):
				if (i != 8):	
					etiquetaResultadoImpresion = etiquetaResultadoImpresion + '0'
			print '>>',
			print etiquetaResultadoImpresion
			print '>>',
			print lectura
			etiquetaResultado.config (text = etiquetaResultadoImpresion, fg = "dark green")

		

# Funcion para setear los datos que forman parte de la operacion
# @param: dato 	Dato a cargar
# @param: tipo 	1 (primer operando), 2 (segundo operando), 3 (codigo de operacion)
def setDato (dato, tipo):
	try:
		hiloSetDato = threading.Thread (target = setDatoViaThread, args = (dato, tipo,)) 
		hiloSetDato.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'
		activarBotones()
		
	
# Funcion que ejecuta el hilo que setea los datos que forman parte de la operacion
# @param: dato 	Dato a cargar
# @param: tipo 	1 (primer operando), 2 (segundo operando), 3 (codigo de operacion)
def setDatoViaThread (dato, tipo):
	desactivarBotones()
	print 'Thread de seteo de datos OK.'
	global etiquetaResultadoImpresion
	global currentState
	try:
		ser.flushInput()
		ser.flushOutput()
		if (dato != ""):
			if (tipo == 1 and len (dato) == 8):
				ser.write (chr (int (dato, 2)))
				time.sleep (0.5) #Espera.
				currentState = ESTADOS [2]	
			elif (tipo == 2 and len (dato) == 8):
				ser.write (chr (int (dato, 2)))
				time.sleep (0.5) #Espera.
				readResultado() # Lectura de resultado
				currentState = ESTADOS [0]
			elif (tipo == 3 and (len (dato) == 3 or dato == 'OR')):
				opcode = getOPCODE (dato)	
				ser.write (chr (int (opcode, 2)))
				time.sleep (0.5) #Espera.
				currentState = ESTADOS [1]
			else:
				print 'Warning: Deben ser 8 bits.'
				etiquetaResultado.config (text = "Warning: Deben ser 8 bits", fg = "red")
		activarBotones()
	except: 
		print 'Error en el seteo de los datos.'
		etiquetaResultado.config (text = "ERROR_LOG", fg = "red")
		activarBotones()
		

# Funcion al presionar el boton salir.	
def salir():
	print 'Fin del programa.'
	exit(1)		

		
		



	
#Ventana principal - Configuracion

root = Tk() 
root.geometry ("380x600+0+0") #Tamanio
root.minsize (height=600, width=380)
root.maxsize (height=600, width=380)

# Rectangulos divisorios

canvasPuerto = Canvas (root)
canvasPuerto.create_rectangle (5, 5, 340, 80, outline='gray60')
canvasPuerto.place (x=1, y=1)

canvasOperaciones = Canvas (root)
canvasOperaciones.config (width=340, height=420)
canvasOperaciones.create_rectangle (5, 5, 340, 420, outline='gray60')
canvasOperaciones.place (x=1, y=100)



# Text boxes

campoPuerto = Entry (root) #Para ingresar texto.
campoPuerto.place (x = 87, y = 25)
campoPrimerOperando = Entry (root) #Para ingresar texto.
campoPrimerOperando.place (x = 200, y = 190)
campoSegundoOperando = Entry (root) #Para ingresar texto.
campoSegundoOperando.place (x = 200, y = 230)

# Menues desplegables
var = StringVar (root)
var.set ('Selecciones la operacion')
opciones = ['ADD', 'SUB', 'AND', 'OR', 'XOR', 'SRA', 'SRL', 'NOR']
menuOpCode = OptionMenu (root, var, *opciones)
menuOpCode.config (width = 20)
menuOpCode.pack (side = 'left', padx = 30, pady = 30)
menuOpCode.place (x = 170, y = 270)

# Botones

botonPrimerOperando = Button (root, text = "Cargar Primer operando", command = lambda: setDato (str (campoPrimerOperando.get()), 1), state = DISABLED)
botonPrimerOperando.place (x = 10, y = 190, width = 150, height = 30)
botonSegundoOperando = Button (root, text="Cargar Segundo operando", command = lambda: setDato (str (campoSegundoOperando.get()), 2), state = DISABLED)
botonSegundoOperando.place (x = 10, y = 230, width = 150, height = 30)
botonOperacion = Button (root, text = "Cargar Operacion", command = lambda: setDato (str (var.get()), 3), state = DISABLED)
botonOperacion.place (x = 10, y = 270, width = 150, height = 30)

### Botones - Conexion y desconexion FPGA

botonConectarFPGA = Button (root, text = "Conectar", command = lambda: conectarFPGA (str (campoPuerto.get())))
botonConectarFPGA.place (x = 250, y = 10, width = 80, height = 30)
botonDesconectarFPGA = Button (root, text = "Desconectar", state = DISABLED, command = lambda: conectarFPGA ("disconnect"))
botonDesconectarFPGA.place (x = 250, y = 40, width = 80, height = 30)

### Boton - Finalizar programa
botonSalir = Button (root, text = "Exit", command = lambda: salir(), state = ACTIVE)
botonSalir.place (x = 150, y = 550, width = 80, height = 30)




# Labels

etiquetaPuerto = Label (root, text = "Serial Port")
etiquetaPuerto.place (x = 20, y = 25)
etiquetaPuertoMensajeEstado = Label (root, text = "Status     : ")
etiquetaPuertoMensajeEstado.place (x = 20, y = 50)
etiquetaPuertoEstado = Label (root, text = estadoPuerto, fg = "red")
etiquetaPuertoEstado.place (x = 87, y = 50)
etiquetaInputDatos = Label (root, text = "Ingreso de datos: ", font = "TkDefaultFont 12")
etiquetaInputDatos.place (x = 10,  y = 110)
etiquetaOutputResultado = Label (root, text = "Resultado: ", font = "TkDefaultFont 12")
etiquetaOutputResultado.place (x = 10,  y = 360)
etiquetaResultado = Label (root, text = etiquetaResultadoImpresion, fg = "dark green", font = "TkDefaultFont 12")
etiquetaResultado.place (x = 10, y = 400)

# Titulo de la GUI 

root.title ("TP2 UART - Aagaard Martin, Navarro Matias")

  
# Ejecucion de loop propio de GUI

root.mainloop()
