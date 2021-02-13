;------------------------------------------------------------------------------
;Archivo: Lab2
;Microcontrolador: PIC16F887
;Autor: Andy Bonilla
;Programa: suma de dos contadores
;Descripción:  suma de 2 contadores de 4 bits con push buttons
;Hardware: 
;------------------------------------------------------------------------------

;---------libreras a emplementar-----------------------------------------------
PROCESSOR 16F887
#include <xc.inc>

;----------------------bits de configuración-----------------------------------
;------configuration word 1----------------------------------------------------
CONFIG  FOSC=XT		    ;se declara osc externo
CONFIG  WDTE=OFF            ; Watchdog Timer apagado
CONFIG  PWRTE=ON            ; Power-up Timer prendido
CONFIG  MCLRE=OFF           ; MCLRE apagado
CONFIG  CP=OFF              ; Code Protection bit apagado
CONFIG  CPD=OFF             ; Data Code Protection bit apagado

CONFIG  BOREN=OFF           ; Brown Out Reset apagado
CONFIG  IESO=OFF            ; Internal External Switchover bit apagado
CONFIG  FCMEN=OFF           ; Fail-Safe Clock Monitor Enabled bit apagado
CONFIG  LVP=ON		    ; low voltaje programming prendido

;------configuration word 2-------------------------------------------------
CONFIG BOR4V=BOR40V	    ;configuración de brown out reset
CONFIG WRT = OFF	    ;apagado de auto escritura de código

PSECT udata_bank0	    ; 
    cont:	DS 1 ; variable de contador 1 byte

PSECT resVect, class=CODE, abs, delta=2 ; ubicación de resetVector 2bytes

;---------------reset vector----------------------------------------------------
ORG 0x000		    ; ubicación inicial de resetVector
resetVec:		    ; se declara el vector
    PAGESEL main	    
    goto    main
    
PSECT code, delta=2, abs    ; se ubica el código de 2bytes
ORG 0x100
 
;-------------configuración de programa-----------------------------------------
main:			    ; se declaran y configuran puertos
    banksel	ANSEL	    ; entrada digital
    clrf	ANSEL	    ; limpieza de regustro
    clrf	ANSELH	    ; limpieza de registro
    
    banksel	TRISA	    ; se establece como entrada analógica
    bsf		TRISA, 0    ; puerto 0 PortA entrada analógica
    bsf		TRISA, 1    ; puerto 1 PortA entrada analógica
    bsf		TRISA, 2    ; puerto 2 PortA entrada analógica
    bsf		TRISA, 3    ; puerto 3 PortA entrada analaógica
    bsf		TRISA, 4    ; puerto 4 PortA entrada analógica
    clrf	TRISB	    ; nos aseguramos que comience en 0
    clrf	TRISC	    ; nos aseguramos que comience en 0
    clrf	TRISD	    ; nos aseguramos que comience en 0
    
    banksel	PORTA	    
    clrf	PORTB	    ; limpieza de Port
    clrf	PORTC	    ; limpieza de PortC
    clrf	PORTD	    ; limpieza de PortD
    
;--------------loop principal de suma de bits-----------------------------------
loop:			    ;función de ciclo
    call	delay_small ; se llama a subrutina de antirrebotes
    btfsc	PORTA, 0    ; set=1 si puerto está libre
    call	inc_portb   ; se llama a sbrutina de suma en PortB
        
    btfsc	PORTA, 1    ; set=1 si puerto está libre
    call	dec_portb   ; se llama a subrutina de resta en PortB
    
    btfsc	PORTA, 2    ;(pin2)    ; set=1 si puerto está libre
    call	inc_portc   ; se llama a sbrutina de suma en PortC
        
    btfsc	PORTA, 3    ; set=1 si puerto está libre
    call	dec_portc   ; se llama a subrutina de resta en PortC
    
    btfsc	PORTA, 4    ; set=1 si pin RA4 
    call	suma_cont   ; se llama a subtrutina de suma de contadores
    
    goto	loop	    ; se regresa al principio
    
;------------------subrutinas--------------------------------------------------
inc_portb:		    ; se nombra subrutina de suma
    btfsc	PORTA, 0    ; set=1 si puerto RA0 está libre
    goto	$-1	    ; regresar una linea en código
    incf	PORTB, F    ; incrementarse a sí mismo en 1
    return
    
dec_portb:		    ; se nombra subrutina de resta
    btfsc	PORTA, 1	    ; set=1 si puerto RA1 está libre
    goto	$-1	    ; regresar una linea de código
    decfsz	PORTB, F    ; se resta a sí mismo en 1
    return

inc_portc:		    ; se nombra subrutina de suma
    btfsc	PORTA, 2  ; set=1 si puerto RA0 está libre
    goto	$-1	    ; regresar una linea en código
    incf	PORTC, F    ; incrementarse a sí mismo en 1
    return
    
dec_portc:		    ; se nombra subrutina de resta
    btfsc	PORTA, 3 ; set=1 si puerto RA1 está libre
    goto	$-1	    ; regresar una linea de código
    decfsz	PORTC, F    ; se resta a sí mismo en 1
    return    

suma_cont:
    movf	PORTB, 0    ; se toman los valor del primer contador
    addwf	PORTC, 0    ; se suman valor de PortB con PortC
    movwf	PORTD	    ; el resuitado se mueve a PortD
    goto	$-4
    clrf	PORTD	    ; se asegura que comienza en 0
    return
    
delay_small:
    movlw	150	    ; se toma tiempo de 
    movwf	cont	    ;
    decfsz	cont, 1	    ; se resta 1 a variable contadora
    goto	$-1
    return
    
END


