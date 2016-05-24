; 10 port encoder

#DEFINE BANK0 BCF STATUS,5  ; clear STATUS bit 5 (RP0)
#DEFINE BANK1 BSF STATUS,5  ; set   STATUS bit 5 (RP0)

           include p16f628.inc

           __config  h'3F30'    ; internal 4MHz oscillator

        CBLOCK h'20'
DELAY

        ENDC

           ORG 0              ; reset vector
           goto STARTIT
           ORG 4              ; Interrupt vector address
           goto STARTIT
           ORG 5              ; PIC program mem loc at which to start 
           goto STARTIT

STARTIT    clrf PORTA          ; clear PORTA's outputs if any
           clrf PORTB          ; clear PORTB's outputs if any
           movlw 7             ; set PORTA as digital
           movwf CMCON         

           BANK1               ; set for Bank 1
           movlw b'01111111'   ; set PORTB for RB0,RB1,RB2,RB3,RB4,RB5,RB6 as input
           movwf TRISB

           movlw b'00001111'   ; set PORTA for RA0,RA1,RA2,RA3 as input
           movwf TRISA
           movlw b'10000000'   ; pull-ups off (bit 7 = 1)
           movwf OPTION_REG
           BANK0               ; set for Bank 0

           movlw b'00000000'   ; timer 1 prescale 1/1, and timer off
           movwf T1CON

FOREVER    call STARTBIT       ; Set start bit on RB7
           btfsc PORTA,0       ; Test RA0
           goto PORTA0H
           call BIT0
           goto PORTA1
PORTA0H    call BIT1
PORTA1     btfsc PORTA,1       ; Test RA1
           goto PORTA1H
           call BIT0
           goto PORTA2
PORTA1H    call BIT1
PORTA2     btfsc PORTA,2       ; Test RA2
           goto PORTA2H
           call BIT0
           goto PORTA3
PORTA2H    call BIT1
PORTA3     btfsc PORTA,3       ; Test RA3
           goto PORTA3H
           call BIT0
           goto PORTB0
PORTA3H    call BIT1
PORTB0     btfsc PORTB,0       ; Test RB0
           goto PORTB0H
           call BIT0
           goto PORTB1
PORTB0H    call BIT1
PORTB1     btfsc PORTB,1       ; Test RB1
           goto PORTB1H
           call BIT0
           goto PORTB2
PORTB1H    call BIT1
PORTB2     btfsc PORTB,2       ; Test RB2
           goto PORTB2H
           call BIT0
           goto PORTB3
PORTB2H    call BIT1
PORTB3     btfsc PORTB,3       ; Test RB3
           goto PORTB3H
           call BIT0
           goto PORTB4
PORTB3H    call BIT1
PORTB4     btfsc PORTB,4       ; Test RB4
           goto PORTB4H
           call BIT0
           goto PORTB5
PORTB4H    call BIT1
PORTB5     btfsc PORTB,5       ; Test RB5
           goto PORTB5H
           call BIT0
           goto PORTB6
PORTB5H    call BIT1
PORTB6     btfsc PORTB,6       ; Test RB6
           goto PORTB6H
           call BIT0
           goto FOREVER        ; Resend start bit and rescan from RA0
PORTB6H    call BIT1
           goto FOREVER        ; Resend start bit and rescan from RA0

STARTBIT   movlw 170           ; Wait 170uS
           movwf DELAY
           call PAUSE
           call SETBIT
           return

BIT0       movlw 20            ; Wait 20uS
           movwf DELAY
           call PAUSE
           call SETBIT
           return

BIT1       movlw 70            ; Wait 70uS
           movwf DELAY
           call PAUSE
           call SETBIT
           return

SETBIT     bsf PORTB,7         ; Set RB7 high
           movlw 80            ; Wait 80uS
           movwf DELAY
           call PAUSE
           bcf PORTB,7         ; Set RB7 low
           return

PAUSE      bcf T1CON,0         ; Stop timer1
           movlw 255
           movwf TMR1L
           movwf TMR1H
           movf DELAY,W
           subwf TMR1L,1       ; Set timer1 to expire in DELAY uS
           bsf T1CON,0         ; Start timer1
PAUSE1     btfss PIR1,TMR1IF   ; Expired?
           goto PAUSE1
           bcf PIR1,TMR1IF     ; timer expired
           return
    
        END
