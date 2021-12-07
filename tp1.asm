global main
extern puts
extern gets
extern printf
extern fopen
extern fclose
extern fgets
extern sscanf

section .data
    ; Definiciones del archivo
    nombreArchivo           db  "file_tp1.txt",0
    modo                    db  "r",0

    ; Mensajes de debugg
    msjAperturaOk           db  "El archivo pudo ser abierto",10,0
    msjErrorApertura        db  "Error en la apertura del archivo",10,0
    msjLecturaIniciada      db  "Leyendo archivo...",10,0
    msjLecturaFinalizada    db  "Se termino de leer el archivo",10,0
    msjValidacionFormato    db  "Se esta validando el formato",10,0
    msjValidacionTamanio    db  "Se esta validando el tamanio",10,0
    msjFinValidacion        db  "Se validaron los registros exitosamente",10,0
    msjErrorValidacion      db  "Hubo un error validando los registros",10,0

    ; Mensajes de operaciones
    msjoperInicial          db  "Ingrese un operando inicial",0
    msjOpAND                db  "Procesando operacion AND...",0
    msjOpXOR                db  "Procesando operacion XOR...",0
    msjOpOR                 db  "Procesando operacion OR...",0
    msjParcial			    db	"El resul parcial es: %s",10,0
	msjOperaciones			db	"%s %c %s",10,0
	msjFinal				db	"El resultado final es: %s",10,0
	
    ; Registro
    regLogicos      times 0 db ""
        operando    times 16 db " "
        operacion   times 1 db " "
        ceroBin     db 0

    msjContador     db  "El indice es: %hhi",10,0

    msjCharOperacion db "Operacion: %s",10,0

    msjCharOperando db "Operando: %s",10,0

    msjAux  db "Resultado inicial cargado: %s",10,0

    msjDebuggXORCero db "Estoy parada en XOR Cero",10,0
    msjDebuggORCero db "Estoy parada en OR Cero",10,0
    msjDebuggANDCero db "Estoy parada en AND Cero",10,0

    msjDebuggXORUno db "Estoy parada en XOR Uno",10,0
    msjDebuggORUno db "Estoy parada en OR Uno",10,0
    msjDebuggANDUno db "Estoy parada en AND Uno",10,0

    ; Variable auxiliar para guardar resultado parcial
    resParcial  db "0000000000000000",0

    numAux  db "0000000000000000"

section .bss
    idArchivo       resq    1
    operInicial     resb    16
    esCharValido    resb    1
    esOperValido    resb    1
    es1             resb    1
    es0             resb    1
    indice          resb    1
section .text
main:
    call    procesarArchivo
    call    abrirArchivo
    jmp    leerArchivo

    finPgm:
	    ret

    abrirArchivo: ; Abro el archivo y valido que no haya errores en la apertura del mismo

        mov     rdi, nombreArchivo
        mov     rsi, modo
        call    fopen

        cmp     rax, 0
        jle     errorApertura
        mov     qword[idArchivo], rax
        call    msjAperturaOkey
        ret

    leerArchivo:
            mov     rdi, msjLecturaIniciada
            call    puts
        leerRegistros: ; Leo cada registro, los valido y luego procedo a hacer las operaciones logicas
            mov     rdi, regLogicos
            mov     rsi, 18 ; tuve que agregarle 2 bytes para que ande, por què?
            mov     rdx, [idArchivo]
            call    fgets
            cmp     rax, 0
            jle     cerrarArchivo
            mov     rdi, msjCharOperando
            mov     rsi, operando
            sub     rax, rax
            call printf
            mov     rdi, msjCharOperacion
            mov     rsi, operacion
            sub     rax, rax
            call printf
            call    VALREG
            revisarValidacionOperando:
                cmp     byte[esCharValido], 'F'
                je      mostrarInvalido
                jmp     sigoProcesando
            revisarValidacionOperacion:
                cmp     byte[esOperValido], 'F'
                je      mostrarInvalido
                jmp     sigoProcesando
            sigoProcesando:
            mov     rdi, msjFinValidacion
            call    puts
            call    aplicoOperacionLogica
            jmp     mostrarResulParcial
            siguienteRegistro:
            jmp     leerRegistros
            mov     rdi, msjLecturaFinalizada
            call    puts
            jmp     finPgm

    procesarArchivo: ; Pido operando inicial para empezar a ejecutar la logica del programa
       pidoOperInicial:
            mov     rdi, msjoperInicial
            call    puts
            mov     rdi, resParcial
            call    gets
            ret

; Procesamiento de Operaciones Logicas

aplicoOperacionLogica: ; Inicializo mi indice con el cual me voy a mover entre las cadenas de operando (vectores)y me dirijo a la operacion correspondiente
        mov byte[indice], 0
        cmp byte[operacion], 'N'
        je operacionAND
        mov rdi, msjLecturaFinalizada
        call puts
        cmp byte[operacion], 'O'
        je operacionOR
        cmp byte[operacion], 'X'
        je operacionXOR

    operacionAND: ; Proceso operacion AND entre dos operandos y almaceno cada actualizacion de bytes en resParcial
        mov rdi, msjOpAND
        call puts
        mov rdi, msjOperaciones
        mov rsi, resParcial
        mov rdx, [operacion]
        mov rcx, operando
        sub rax, rax
        call printf
        recorroCadenaAND:
            mov al, byte[indice]
            mov rcx, 16
            sigOperandoAND:
                cmp byte[operando + rax], '1'
                je insertoNuevoByteAND
                cmp byte[operando + rax], '0'
                je agregoCeroBinarioAND
                incrementoIndiceAND:
                inc byte[indice]
                loop sigOperandoAND
                jmp mostrarResulParcial

        finOperacionAND:
            ret

            insertoNuevoByteAND:
            mov byte[es1], 'N'
            mov al, byte[indice]
            cmp byte[resParcial + rax], '1'
            je  operANDEs1
            verificoNumeroAND:
            cmp byte[es1], 'S'
            je  agregoUnoBinarioAND ; A AND B = 1 SII A = 1 Y B = 1
            jmp agregoCeroBinarioAND ; Si ambos opers no son 1, entonces agrego 0

    operacionOR: ; Proceso operacion OR entre dos operandos y almaceno cada actualizacion de bytes en resParcial
        mov rdi, msjOpOR
        call puts
        mov rdi, msjOperaciones
        mov rsi, resParcial
        mov rdx, [operacion]
        mov rcx, operando
        sub rax, rax
        call printf
        recorroCadenaOR:
            mov al, byte[indice] 
            mov rcx, 16    
            sigOperandoOR:
                cmp byte[operando + rax], '1'
                je insertoNuevoByteOR
                cmp byte[operando + rax], '0'
                je agregoUnoBinarioOR
                incrementoIndiceOR:
                inc byte[indice]
                loop sigOperandoOR
                jmp mostrarResulParcial
    
        finOperacionOR:
        ret

        insertoNuevoByteOR:
            mov byte[es0], 'N'
            mov al, byte[indice]
            cmp byte[resParcial + rax], '0'
            je  operOREs0
            verificoNumeroOR:
            cmp byte[es0], 'S'
            je  agregoCeroBinarioOR ; A OR B = 0 SII A = 0 Y B = 0
            jmp agregoUnoBinarioOR ; Si ambos opers no son 0, entonces agrego 1

    operacionXOR: ; Proceso operacion XOR entre dos operandos y almaceno cada actualizacion de bytes en resParcial
        mov rdi, msjOpXOR
        call puts
        mov rdi, msjOperaciones
        mov rsi, resParcial
        mov rdx, [operacion]
        mov rcx, operando
        sub rax, rax
        call printf
        recorroCadenaXOR:
            mov al, byte[indice] 
            mov rcx, 16
            sigOperandoXOR:
                cmp byte[operando + rax], '1'
                je insertoNuevoByteXORUno
                cmp byte[operando + rax], '0'
                je insertoNuevoByteXORCero
                incrementoIndiceXOR:
                inc byte[indice]
                loop sigOperandoXOR
                jmp mostrarResulParcial

    finOperacionXOR:
        ret

        insertoNuevoByteXORUno:
            mov byte[es1], 'N'
            mov al, byte[indice]
            cmp byte[resParcial + rax], '1'
            je  operXOREs1
            verificoNumero1XOR:
            cmp byte[es1], 'S'
            je  agregoCeroBinarioXOR ; A AND B = 1 SII A = 1 Y B = 1
            jmp agregoUnoBinarioXOR ; Si ambos opers no son 1, entonces agrego 1
            

        insertoNuevoByteXORCero:
            mov byte[es0], 'N'
            mov al, byte[indice]
            cmp byte[resParcial + rax], '0'
            je  operXOREs0
            verificoNumero0XOR:
            cmp byte[es0], 'S'
            je  agregoCeroBinarioXOR ; A AND B = 0 SII A = 0 Y B = 0
            call agregoUnoBinarioXOR ; Si ambos opers no son 0, entonces agrego 1
            

    agregoCeroBinarioAND:
        mov al, byte[indice]
        mov byte[resParcial + rax], '0'
        jmp incrementoIndiceAND

    agregoCeroBinarioOR:
        mov al, byte[indice]
        mov byte[resParcial + rax], '0'
        jmp incrementoIndiceOR

    agregoCeroBinarioXOR:
        mov al, byte[indice]
        mov byte[resParcial + rax], '0'
        jmp incrementoIndiceXOR

    agregoUnoBinarioAND:
        mov al, byte[indice]
        mov byte[resParcial + rax], '1'
        jmp incrementoIndiceAND

    
    agregoUnoBinarioOR:
        mov al, byte[indice]
        mov byte[resParcial + rax], '1'
        jmp incrementoIndiceOR
    

    agregoUnoBinarioXOR:
        ; mov rdi, msjDebugg
        ; call puts ; en la primer iter entra aca porque tengo una X en el operando (17 bytes)
        mov al, byte[indice]
        mov byte[resParcial + rax], '1'
        jmp incrementoIndiceXOR

    operANDEs1:
    mov byte[es1], 'S'
    jmp verificoNumeroAND
    
    operOREs0:
        mov byte[es0], 'S'
        jmp verificoNumeroOR

    operXOREs1:
        mov byte[es1], 'S'
        jmp verificoNumero1XOR

    operXOREs0:
        mov byte[es0], 'S'
        jmp verificoNumero0XOR
            

    mostrarResulParcial:
        mov     rdi, msjParcial
        mov     rsi, resParcial
        sub     rax, rax
        call    printf
        jmp siguienteRegistro

    mostrarResulFinal:
        mov     rdi, msjFinal
        mov     rsi, [resParcial]
        sub     rax, rax
        call    printf
        ret

    errorApertura:
        mov     rdi, msjErrorApertura
        call    puts
        jmp     finPgm

    msjAperturaOkey:
        mov     rdi, msjAperturaOk
        call    puts
        ret

    cerrarArchivo:
        mov     rdi, [idArchivo]
        call    fclose

; Subrutina de validacion

VALREG: ; Valido cada registro en base a su formato y tamaño
        operandoValido:
        mov rsi, 17 
        recorrerCadenaOperando:
            cmp byte[operando + rsi], 0
            je  validarTamanio
            dec rsi
            jmp recorrerCadenaOperando
        validarTamanio:
            cmp rsi, 17
            je  validarFormato
            jmp setearOperandoInvalido
        validarFormato:
            mov rsi, 0
            compararOperando:
                cmp byte[operando + rsi], '1'
                je operandValido
                cmp byte[operando + rsi], '0'
                je operandValido
                jmp setearOperandoInvalido
            operandValido:
                cmp rsi, 15
                je  setearOperandoValido
                inc rsi
                jmp compararOperando

     operacionValida:
            ; mov rdi, msjCharOperacion
            ; mov rsi, [operacion]
            ; sub rax, rax
            ; call printf
            mov rsi, 0
            recorrerCadenaOperacion:
                cmp byte[operacion], 0
                je  validarFormatoOp
                inc rsi
                jmp recorrerCadenaOperacion
            validarTamanioOp:
                cmp rsi, 1
                je  validarFormatoOp
                jmp setearOperacionInvalido
        validarFormatoOp:
            compararOperacion:
                cmp byte[operacion], 'N'
                je setearOperacionValida
                cmp byte[operacion], 'O'
                je setearOperacionValida
                cmp byte[operacion], 'X'
                je setearOperacionValida
                jmp setearOperacionInvalido
        finValidar:
        ret
    mostrarInvalido:
            mov     rdi, msjErrorValidacion
            call    puts
            jmp     finPgm

    setearOperacionInvalido:
	    mov     byte[esOperValido], 'F'
        jmp     finValidar

    setearOperacionValida:
	    mov  byte[esOperValido], 'V'
        jmp     finValidar

    setearOperandoInvalido:
	    mov     byte[esCharValido], 'F'
        jmp     finValidar

    setearOperandoValido:
	    mov  byte[esCharValido], 'V'
        jmp     finValidar