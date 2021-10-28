global main
extern puts
extern gets
extern printf
extern fopen
extern fclose
extern fread
extern fgets

section .data

    msjPantalla             db  "%c",10,0
    nombreArchivo           db  "prueba_asm.txt",0
    modo                    db  "r",0
    msjAperturaOk           db  "El archivo pudo ser abierto",10,0
    msjErrorApertura        db  "Error en la apertura del archivo",10,0
    msjLecturaIniciada      db  "Leyendo archivo...",10,0
    msjLecturaFinalizada    db  "Se termino de leer el archivo",10,0
    msjoperInicial		    db  "Ingrese un operando inicial",0
    msjOpAND                db  "Procesando operacion AND...",10,0
    msjOpXOR                db  "Procesando operacion XOR...",10,0
    msjOpOR                 db  "Procesando operacion OR...",10,0
    idArchivo               dq  0
    opAND                   db  "A",0
    opXOR                   db  "X",0
    opOR                    db  "O",0

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
    call    abrirArchivo ; tengo que abrir el archivo
    call    leerArchivo ; tengo que leer el archivo
    mov     rdi,    msjoperInicial
    call    puts
    mov     rdi,    operInicial
    call    gets
    mov     rax,    operInicial ; Muevo el operando al rax
    ; tengo que quedarme con la operacion correspondiente y hacer un jump hacia cada etiqueta
    cmp     rax,    opAND
    jle     operacionAND ;rcx igual a cero, significa que son iguales entonces bifurco
    cmp     rax,    opXOR
    jle     operacionXOR
    cmp     rax,    opOR
    jle     operacionOR
    call    mostrarResulParcial ; luego tengo que imprimir el resultado parcial por pantalla
	ret
	
    operacionAND:
	    mov     rdi,    msjOpAND
		call    puts
        AND     rax,    operando ; Aplico la operacion al operando (tengo que cargar dos operandos y hacerlo entre ellos)
        mov     [resParcial], rax ; Como aplicar la operacion me lo guarda en el rax, me guardo el resul en resParcial
    operacionXOR:
    	mov     rdi,    msjOpXOR
		call    puts
        XOR     rax,    operando ; Aplico la operacion al operando (tengo que cargar dos operandos y hacerlo entre ellos)
        mov     [resParcial],   rax ; Como aplicar la operacion me lo guarda en el rax, me guardo el resul en resParcial
    operacionOR:
    	mov     rdi,    msjOpOR
		call    puts
        OR      rax,    operando ; Aplico la operacion al operando (tengo que cargar dos operandos y hacerlo entre ellos)
        mov     [resParcial],   rax ; Como aplicar la operacion me lo guarda en el rax, me guardo el resul en resParcial

    mostrarResulParcial: ; muestro resultado parcial por pantalla
        mov     rdi,    msjPantalla
        mov     rsi,    resParcial

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
        jmp     finPgm

    msjAperturaOkey:

    mov     rdi,    msjAperturaOk
    call    puts
    ret

    cerrarArchivo:

        mov     rdi,    [idArchivo]
        call    fclose

    finPgm:
	    ret


; Links utiles:
; https://www.tutorialspoint.com/assembly_programming/assembly_logical_instructions.htm
; http://site.iugaza.edu.ps/ahaniya/files/Assembly-Language-Lab6.pdf
