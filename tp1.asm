global main
extern puts
extern gets
extern printf
extern fopen
extern fclose
extern fread
extern sscanf

section .data
    ; Definiciones del archivo
    nombreArchivo           db  "file_prueba_tp1.DAT",0
    modo                    db  "rb",0
    idArchivo               dq  0

    ; Mensajes de debugg
    msjAperturaOk           db  "El archivo pudo ser abierto",10,0
    msjErrorApertura        db  "Error en la apertura del archivo",10,0
    msjLecturaIniciada      db  "Leyendo archivo...",10,0
    msjLecturaFinalizada    db  "Se termino de leer el archivo",10,0
    msjErrorValidacion      db  "Hubo un error validando los registros",10,0

    ; Mensajes de operaciones
    msjoperInicial          db  "Ingrese un operando inicial",0
    msjOpAND                db  "Procesando operacion AND...",0
    msjOpXOR                db  "Procesando operacion XOR...",0
    msjOpOR                 db  "Procesando operacion OR...",0
    msjParcial			    db	"El resul parcial es: %hi",10,0
	msjOperaciones			db	"%hi %c %hi",10,0
	msjFinal				db	"El resultado final es: %hi",10,0
	
    ; Registro
    regLogicos      times 0 db "" ; longitud total del registro: 17 (bytes)
        operando    times 16 db " "
        operacion   times 1 db " "

section .bss
    operInicial     resb    16
    resParcial      resb    16
    esValido        resb    1
    es1             resb    1
    es0             resb    1
    resAux          resb    1

section .text
main:
    call    abrirArchivo ; Abro archivo y manejo excepciones
    call    leerArchivo ; Leo archivo y manejo excepciones
    call    procesarArchivo

    abrirArchivo: ; Abre el archivo especificado en archivoNombre, en el modo especificado y retorna un id de archivo o un codigo de error (valor negativo)

        mov     rdi, nombreArchivo
        mov     rsi, modo
        call    fopen

        cmp     rax, 0
        jle     errorApertura ; manejo error de apertura
        mov     qword[idArchivo], rax ; abro efectivamente el archivo
        jle     msjErrorApertura
        call    msjAperturaOkey ; si no me fui a la etiqueta, el archivo se abrio bien
        ret

    leerArchivo:
            mov     rdi, msjLecturaIniciada ; hago un print para seguimiento
            call    puts
        leerRegistros:
            mov     rdi, regLogicos ; muevo el bloque de registros
            mov     rsi, 17
            mov     rdx, 1
            mov     rcx, [idArchivo]
            call    fread ; leo efectivamente el archivo (antes tenia fread)
            cmp     rax, 0 ; me fijo si llegue al fin de linea
            jle     cerrarArchivo ; cierro el archivo
            call    VALREG
            jmp     leerRegistros
            mov     rdi, msjLecturaFinalizada ; hago un print para seguimiento
            call    puts
            ret

    VALREG:
        call operandoValido
        call operacionValida
        ret

    operandoValido:
        mov rbx, 0
        recorrerCadenaOperando:
            cmp byte[operando + rbx], 0
            je  validarTamanio
            inc rbx
            jmp recorrerCadenaOperando
        validarTamanio:
            cmp rsi, 16
            je  validarFormato
            jmp setearInvalido
        validarFormato:
            mov rbx, 0
            sigDigitoOperando:
                cmp byte[operando + rbx], '1'
                jne setearInvalido
                cmp byte[operando + rbx], '0'
                jne setearInvalido
                inc rbx
                loop sigDigitoOperando
                mov word[esValido], "V"

    operacionValida:
        mov rbx, 0
        recorrerCadenaOperacion:
            cmp byte[operacion + rbx], 0
            je  validarTamanioOp
            inc rbx
            jmp recorrerCadenaOperacion
        validarTamanioOp:
            cmp rsi, 1
            je  validarFormatoOp
            jmp setearInvalido
        validarFormatoOp:
            mov rbx, 0
            sigDigitoOperacion:
                cmp byte[operacion + rbx], 'N'
                jne setearInvalido
                cmp byte[operacion + rbx], 'O'
                jne setearInvalido
                cmp byte[operacion + rbx], 'X'
                jne setearInvalido
                inc rbx
                loop sigDigitoOperacion
                mov word[esValido], "V"
            
    mostrarInvalido:
            mov     rdi, msjErrorValidacion
            call    puts
    setearInvalido:
	        mov     word[esValido], "F" ; Devuelve F en la variable esValido si es un registro invalido
            jmp     finPgm
    setearValido:
	    mov  word[esValido], "V" ; Devuelve V en la variable esValido si es un registro valido

    procesarArchivo:
       pidoOperInicial:
            mov     rdi, msjoperInicial ; pido operando inicial
            call    puts
            mov     rsi, operInicial
            call    gets

            mov     rax, rsi 
            mov     [resParcial], rax ; me guardo operando inicial en resParcial

    operEs1:
        mov  word[es1], "S"
    operEs0:
        mov  word[es0], "S"

    operacionAND:
        mov rbx, 0
        recorroCadenaAND:
            sigOperandoAND:
            cmp byte[operando + rbx], '1' ; oper de archivo es 1
            je insertoNuevoByteAND
            cmp byte[operando + rbx], '0' ; oper de archivo es 0
            je agregoCeroBinario
            inc rbx
            loop sigOperandoAND
        insertoNuevoByteAND:
            mov  word[es1], "N"
            cmp byte[resParcial + rbx], '1' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs1 ; oper inicial es 1
            cmp word[operEs1], 'S'
            je  agregoUnoBinario ; A AND B = 1 SII A = 1 Y B = 1
            call agregoCeroBinario ; Si ambos opers no son 1, entonces agrego 0


    operacionOR:
        mov rbx, 0
        recorroCadenaOR:
            sigOperandoOR:
            cmp byte[operando + rbx], '1' ; oper de archivo es 1
            je insertoNuevoByteOR
            cmp byte[operando + rbx], '0' ; oper de archivo es 0
            je agregoUnoBinario
            inc rbx
            loop sigOperandoOR
        insertoNuevoByteOR:
            mov  word[es0], "N"
            cmp byte[resParcial + rbx], '0' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs0 ; oper inicial es 0
            cmp word[operEs0], 'S'
            je  agregoCeroBinario ; A OR B = 0 SII A = 0 Y B = 0
            call agregoUnoBinario ; Si ambos opers no son 0, entonces agrego 1
    
    
    operacionXOR:
        mov rbx, 0
        recorroCadenaXOR:
            sigOperandoXOR:
            cmp byte[operando + rbx], '1' ; oper de archivo es 1
            je insertoNuevoByteXORUno
            cmp byte[operando + rbx], '0' ; oper de archivo es 0
            je insertoNuevoByteXORCero
            inc rbx
            loop sigOperandoXOR
        insertoNuevoByteXORUno:
            mov  word[es1], "N"
            cmp byte[resParcial + rbx], '1' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs1 ; oper inicial es 1
            cmp word[operEs1], 'S'
            je  agregoCeroBinario ; A XOR B = 1 SII A = 1 Y B = 1
            call agregoUnoBinario ; Si ambos opers no son 1, entonces agrego 1
        insertoNuevoByteXORCero:
            mov  word[es0], "N"
            cmp byte[resParcial + rbx], '0' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs0 ; oper inicial es 1
            cmp word[operEs0], 'S'
            je  agregoCeroBinario ; A XOR B = 0 SII A = 0 Y B = 0
            call agregoUnoBinario ; Si ambos opers no son 0, entonces agrego 1

    agregoCeroBinario:
        ; Tengo que agregar en la pos correspondiente de mi cadena de bytes el nuevo byte agregado
    agregoUnoBinario:
        ; Tengo que agregar en la pos correspondiente de mi cadena de bytes el nuevo byte agregado

    errorApertura:
        mov     rdi, msjErrorApertura
        call    puts
        jmp     finPgm ; bifurco a fin de programa

    msjAperturaOkey:

        mov     rdi, msjAperturaOk ; mensaje debugging
        call    puts
        ret

    cerrarArchivo:

        mov     rdi, [idArchivo] ; cierro el archivo
        call    fclose

    finPgm:
	    ret