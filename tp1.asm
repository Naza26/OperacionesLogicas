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
    regLogicos      times 0 db ""
        operando    times 16 db " "
        operacion   times 1 db " "

    ; Variable auxiliar para guardar resultado parcial
    resParcial  times 16 db "0000000000000000"

    msjContador     db  "El contador es: %hhi",10,0

    msjAux  db "Resultado inicial cargado: %hi",10,0

section .bss
    operInicial     resb    16
    esValido        resb    1
    es1             resb    1
    es0             resb    1
    contador        resb    1
section .text
main:
    call    procesarArchivo
    call    abrirArchivo ; Abro archivo y manejo excepciones
    call    leerArchivo ; Leo archivo y manejo excepciones
    call    mostrarResulFinal ; muestro resultado final

    abrirArchivo:

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
        leerRegistros:
            mov     rdi, regLogicos
            mov     rsi, 17
            mov     rdx, 1
            mov     rcx, [idArchivo]
            call    fread
            cmp     rax, 0
            jle     cerrarArchivo
            ; call    VALREG
            ; cmp     byte[esValido], 'F'
            ; je      mostrarInvalido
            call    aplicoOperacionLogica
            jmp     leerRegistros
            mov     rdi, msjLecturaFinalizada
            call    puts
            ret

    aplicoOperacionLogica:
        mov byte[contador], 0
        cmp byte[operacion], 'N'
        je operacionAND
        cmp byte[operacion], 'O'
        je operacionOR
        cmp byte[operacion], 'X'
        je operacionXOR

    ; VALREG:
    ;     call operandoValido
    ;     call operacionValida

    ; operandoValido:
    ;     mov rsi, 0
    ;     recorrerCadenaOperando:
    ;         cmp byte[operando + rsi], 0
    ;         je  validarTamanio
    ;         inc rsi
    ;         jmp recorrerCadenaOperando
    ; validarTamanio:
    ;     cmp rsi, 16
    ;     je  validarFormato
    ;     jmp setearInvalido
    ; validarFormato:
    ;     mov rsi, 0
    ;     compararOperando:
    ;         cmp byte[operando + rsi], '1'
    ;         je operandValido
    ;         cmp byte[operando + rsi], '0'
    ;         je operandValido
    ;         jmp setearInvalido
    ;     operandValido:
    ;         cmp rsi, 15
    ;         je  setearValido
    ;         inc rsi,
    ;         jmp compararOperando

    ; operacionValida:
    ;     mov rsi, 0
    ;     recorrerCadenaOperacion:
    ;         cmp byte[operacion + rsi], 0
    ;         je  validarTamanioOp
    ;         inc rsi
    ;         jmp recorrerCadenaOperacion
    ; validarTamanioOp:
    ;     cmp rsi, 1
    ;     je  validarFormatoOp
    ;     jmp setearInvalido
    ; validarFormatoOp:
    ;     mov rsi, 0
    ;     compararOperacion:
    ;         cmp byte[operacion + rsi], 'N'
    ;         je operacValida
    ;         cmp byte[operacion + rsi], 'O'
    ;         je operacValida
    ;         cmp byte[operacion + rsi], 'X'
    ;         je operacValida
    ;         jmp setearInvalido

    ;     operacValida:
    ;         cmp rsi, 0
    ;         je  setearValido
    ;         inc rsi,
    ;         jmp compararOperacion
            
    mostrarInvalido:
            mov     rdi, msjErrorValidacion
            call    puts
    setearInvalido:
	        mov     byte[esValido], 'F'
            jmp     finPgm
    setearValido:
	    mov  byte[esValido], 'V'

    procesarArchivo:
       pidoOperInicial:
            mov     rdi, msjoperInicial
            call    puts
            mov     rsi, operInicial
            call    gets

            mov [resParcial], rsi
            mov rdi, msjAux
            mov rsi, [resParcial]
            sub rax, rax
            call printf

    operEs1:
        mov  byte[es1], 'S'
        ret
    operEs0:
        mov  byte[es0], 'S'
        ret

    operacionAND:
        mov rdi, msjOpAND
        call puts
        mov rdi, msjOperaciones
        mov rsi, [resParcial]
        mov rdx, [operacion]
        mov rcx, [operando]
        sub rax, rax
        call printf
        recorroCadenaAND:
            mov rbx, [contador]
            mov rcx, 16
            sigOperandoAND:
                cmp byte[operando + rbx], '1' ; oper de archivo es 1
                je insertoNuevoByteAND
                cmp byte[operando + rbx], '0' ; oper de archivo es 0
                je agregoCeroBinario
                inc byte[contador]
                mov rdi, msjContador
                mov rsi, [contador]
                sub rax, rax
                call printf
                loop sigOperandoAND
            ;call mostrarResulParcial

        insertoNuevoByteAND:
            mov  byte[es1], 'N'
            mov  rcx, [contador]
            cmp byte[resParcial + rcx], '1' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs1 ; oper inicial es 1
            cmp byte[es1], 'S'
            je  agregoUnoBinario ; A AND B = 1 SII A = 1 Y B = 1
            call agregoCeroBinario ; Si ambos opers no son 1, entonces agrego 0

    operacionOR:
        mov rdi, msjOpOR
        call puts
        mov rdi, msjOperaciones
        mov rsi, [resParcial]
        mov rdx, [operacion]
        mov rcx, [operando]
        sub rax, rax
        call printf
        recorroCadenaOR:
            mov rbx, [contador]
            mov rcx, 16    
            sigOperandoOR:
                cmp byte[operando + rbx], '1' ; oper de archivo es 1
                je insertoNuevoByteOR
                cmp byte[operando + rbx], '0' ; oper de archivo es 0
                je agregoUnoBinario
                inc byte[contador]
                mov rdi, msjContador
                mov rsi, [contador]
                sub rax, rax
                call printf
                loop sigOperandoOR
            ;call mostrarResulParcial

        insertoNuevoByteOR:
            mov byte[es0], 'N'
            mov rcx, [contador]
            cmp byte[resParcial + rcx], '0' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs0 ; oper inicial es 0
            cmp byte[es0], 'S'
            je  agregoCeroBinario ; A OR B = 0 SII A = 0 Y B = 0
            call agregoUnoBinario ; Si ambos opers no son 0, entonces agrego 1
    
    operacionXOR:
        mov rdi, msjOpXOR
        call puts
        mov rdi, msjOperaciones
        mov rsi, [resParcial]
        mov rdx, [operacion]
        mov rcx, [operando]
        sub rax, rax
        call printf
        recorroCadenaXOR:
            mov rbx, [contador]
            mov rcx, 16
            sigOperandoXOR:
                cmp byte[operando + rbx], '1' ; oper de archivo es 1
                je insertoNuevoByteXORUno
                cmp byte[operando + rbx], '0' ; oper de archivo es 0
                je insertoNuevoByteXORCero
                inc byte[contador]
                mov rdi, msjContador
                mov rsi, [contador]
                sub rax, rax
                call printf
                loop sigOperandoXOR
            ;call mostrarResulParcial

        insertoNuevoByteXORUno:
            mov byte[es1], 'N'
            mov rcx, [contador]
            cmp byte[resParcial + rcx], '1' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs1 ; oper inicial es 1
            cmp byte[es1], 'S'
            je  agregoCeroBinario ; A AND B = 1 SII A = 1 Y B = 1
            call agregoUnoBinario ; Si ambos opers no son 1, entonces agrego 1
            

        insertoNuevoByteXORCero:
            mov byte[es0], 'N'
            mov rcx, [contador]
            cmp byte[resParcial + rcx], '0' ; rbx persiste de la etiqueta anterior? porque necesito recorrer el resultado parcial tambien byte a byte
            je  operEs0 ; oper inicial es 1
            cmp byte[es0], 'S'
            je  agregoCeroBinario ; A AND B = 0 SII A = 0 Y B = 0
            call agregoUnoBinario ; Si ambos opers no son 0, entonces agrego 1
            

    agregoCeroBinario:
        mov rbx, [contador]
        mov byte[resParcial + rbx], '0'

    agregoUnoBinario:
        mov rbx, [contador]
        mov byte[resParcial + rbx], '1'
        

    mostrarResulParcial:
        mov     rdi, msjParcial
        mov     rsi, [resParcial]
        sub     rax, rax
        call    printf

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

    finPgm:
	    ret