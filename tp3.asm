global main
extern puts
extern gets
extern printf
extern fopen
extern fclose
extern fread
extern fgets
extern sscanf

section .data

    nombreArchivo           db  "prueba_asm.txt",0
    modo                    db  "r",0
	idArchivo               dq  0
    msjAperturaOk           db  "El archivo pudo ser abierto",10,0
    msjErrorApertura        db  "Error en la apertura del archivo",10,0
    msjLecturaIniciada      db  "Leyendo archivo...",10,0
    msjLecturaFinalizada    db  "Se termino de leer el archivo",10,0
    
    msjoperInicial          db  "Ingrese un operando inicial",0
    msjOpAND                db  "Procesando operacion AND...",0
    msjOpXOR                db  "Procesando operacion XOR...",0
    msjOpOR                 db  "Procesando operacion OR...",0
    aux						db	"La primer operacion es: %c",10,0
    
    ;resParcialStr	 		db '****************',0
	;resParcialFormat	    db '%hi',0	;16 bits (word)
	;resParcialNum			dw	0		;16 bits (word)
	
	msjParcialAux			db	"El resul parcial es: %hi",10,0
	msjOperaciones			db	"%hi %c %hi",10,0
	msjFinal				db	"El resultado final es: %hi",10,0

    regLogicos      times 0 db "" ; longitud total del registro: 19 (bytes)
        operando    times 16 db " "
        operacion   times 1 db " "
        EOL         times 1	db " "	; Byte para guardar el fin de linea q está en el archivo
        ZERO_BINA   times 1	db " "	; Byte para guardar el 0 binario que agrega la fgets

section .bss
    operInicial     resb    16
    resParcial      resb    16

section .text
main:
    call    abrirArchivo ; abro archivo
    call    leerArchivo ; leo archivo
    mov     rdi,    aux ; muestro primer operacion (debugging)
    mov		rsi,	[operacion]
    sub     rax,    rax

    call printf
    
    mov     rdi,    msjoperInicial ; pido operando inicial
    call    puts
    mov     rsi,    operInicial 
    call    gets

    mov     rax,    rsi 
    mov     [resParcial],   rax ; me guardo operando inicial en resParcial
    
    ; tengo que quedarme con la operacion correspondiente y hacer un jump hacia cada etiqueta
    
    cmp     byte[operacion],	"A" ; comparo para ver si la operacion es AND por ejemplo
    jz      operacionAND ; jz = 0 entonces significa que son iguales y bifurco
    cmp     byte[operacion],    "X"
    jz      operacionXOR
    cmp     byte[operacion],    "O"
    jz      operacionOR
    call    mostrarResulFinal ; imprimo resultado final por pantalla
    ret
	
    operacionAND:		
		mov		rdi,	msjOperaciones ; muestro que operandos se van a operar
		mov		rsi,	[resParcial]
		mov		rdx,	"A"
		mov		rcx,	[operando]
		sub		rax,	rax
		call	printf
		
		mov     rdi,    msjOpAND ; mensaje de debugg
		call    puts
		
		mov		rax,	[operando]
        AND     rax,    [resParcial] ; Aplico la operacion sobre 2 operandos
        
        mov		rdi,	msjParcialAux ; muestro mensaje de operacion parcial
        mov		rsi,	rax
        
        sub		rax,rax
        
        call	printf
        
    operacionXOR:		
		mov		rdi,	msjOperaciones
		mov		rsi,	[resParcial]
		mov		rdx,	"X"
		mov		rcx,	[operando]
		sub		rax,	rax
		call	printf
		
		mov     rdi,    msjOpXOR
		call    puts
		
		mov		rax,	[operando]
        XOR     rax,    [resParcial]
        mov		rdi,	msjParcialAux
        mov		rsi,	rax
        
        sub		rax,rax
        
        call	printf
        
    operacionOR:		
		mov		rdi,	msjOperaciones
		mov		rsi,	[resParcial]
		mov		rdx,	"O"
		mov		rcx,	[operando]
		sub		rax,	rax
		call	printf
		
		mov     rdi,    msjOpOR
		call    puts
		
		mov		rax,	[operando]
        OR      rax,    [resParcial]
        mov		rdi,	msjParcialAux
        mov		rsi,	rax
        
        sub		rax,rax
        
        call	printf

    mostrarResulFinal:
        mov     rdi,    msjFinal ; muestro mensaje final
		mov		rsi,	rax

        sub     rax,    rax

        call printf
        
    abrirArchivo: ;abre el archivo especificado en archivoNombre, en el modo especificado y retorna un id de archivo o un codigo de error (valor negativo)

        mov     rdi,    nombreArchivo
        mov     rsi,    modo
        call    fopen

        cmp     rax,    0
        jle     errorApertura ; manejo error de apertura
        mov     qword[idArchivo],   rax ; abro efectivamente el archivo
        call    msjAperturaOkey ; si no me fui a la etiqueta, el archivo se abrio bien
        ret
        


    leerArchivo:
	    mov     rdi,    msjLecturaIniciada ; hago un print para seguimiento
        call    puts
        mov     rdi,    regLogicos ; muevo el bloque de registros
        mov     rsi,    19
        ;mov    rdx,    1
        mov     rdx,    [idArchivo] ;esto antes era rcx porque la linea ant estaba descomentada
        call    fgets ; leo efectivamente el archivo (antes tenia fread)
        cmp     rax,    0 ; me fijo si llegue al fin de linea
        jle     cerrarArchivo ; cierro el archivo
        mov     rdi,    msjLecturaFinalizada ; hago un print para seguimiento
        call    puts
        ret
        

    ;procesarArchivo:
    ;    ...

    errorApertura:
        mov     rdi,    msjErrorApertura
        call    puts
        jmp     finPgm ; bifurco a fin de programa

    msjAperturaOkey:

        mov     rdi,    msjAperturaOk ; mensaje debugging
        call    puts
        ret

    cerrarArchivo:

        mov     rdi,    [idArchivo] ; cierro el archivo
        call    fclose

    finPgm:
	    ret


; Links utiles:
; https://www.tutorialspoint.com/assembly_programming/assembly_logical_instructions.htm
; http://site.iugaza.edu.ps/ahaniya/files/Assembly-Language-Lab6.pdf
