; 10 port decoder

#DEFINE BANK0 BCF STATUS,5  ; clear STATUS bit 5 (RP0)
#DEFINE BANK1 BSF STATUS,5  ; set   STATUS bit 5 (RP0)

           include p16f628.inc

           __config  h'3F30'    ; internal 4MHz oscillator

        CBLOCK h'20'
BITCOUNT
TIML
TIMH
TEMPBITS
FIRST8BITS
GOTFIRST8

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
           movlw b'10000000'   ; set PORTB RB7 as input
           movwf TRISB

           movlw b'00000000'   ; set PORTA for all output
           movwf TRISA
           movlw b'10000000'   ; pull-ups off (bit 7 = 1)
           movwf OPTION_REG
           BANK0               ; set for Bank 0

           clrf T1CON          ; timer 1 prescale 1/1, and timer off
           clrf TMR1L          ; reset timer 1 LSB
           clrf TMR1H          ; reset timer 1 MSB

WSTART     btfss PORTB,7       ; wait RB7 until a leading edge
           goto WSTART
WSTART1    btfsc PORTB,7       ; wait RB7 until a trailing edge
           goto WSTART1
           clrf T1CON          ; stop timer 1
           movf TMR1H,W        ; store timer1 MSB count
           movwf TIMH
           clrf TMR1L          ; reset timer 1 LSB
           clrf TMR1H          ; reset timer 1 MSB
           bsf T1CON,0         ; start timer 1
           bcf STATUS,C        ; clear carry bit
           movlw 255           ; pulse period > 255 uS?
           addwf TIMH,W
           btfss STATUS,C      ; carry bit set?
           goto WSTART         ; no, look at the next pulse

WDATA      movlw 8             ; received start bit. need 8 data bits
           movwf BITCOUNT
           clrf TEMPBITS       ; reset bit storage buffer
           clrf GOTFIRST8      ; reset "got 1st 8 bits" flag
BITDATA    btfss PORTB,7       ; wait RB7 until a leading edge
           goto BITDATA
BITDATA1   btfsc PORTB,7       ; wait RB7 until a trailing edge
           goto BITDATA1
           clrf T1CON          ; stop timer 1
           movf TMR1L,W        ; store timer1 LSB count
           movwf TIML
           movf TMR1H,W        ; store timer1 MSB count
           movwf TIMH
           clrf TMR1L          ; reset timer 1 LSB
           clrf TMR1H          ; reset timer 1 MSB
           bsf T1CON,0         ; start timer 1
           bcf STATUS,C        ; clear carry bit
           rrf TEMPBITS,F      ; rotate temporary bit storage right
           bcf STATUS,C        ; clear carry bit
           movlw 255           ; pulse period > 255 uS? (start bit)
           addwf TIMH,W
           btfsc STATUS,C      ; carry bit clear?
           goto WDATA          ; received a start bit. wait for data
           movlw 82            ; pulse period > 174 uS? (high data bit)
           addwf TIML,W
           btfsc STATUS,C      ; carry bit clear?
           goto BIT1           ; no, received a high bit
           movlw 132           ; pulse period > 124 uS? (low data bit)
           addwf TIML,W
           btfss STATUS,C      ; carry bit set?
           goto WSTART         ; bad data. not low/high. wait for start
           goto DECCOUNT       ; received a low bit
BIT1       bsf TEMPBITS,7      ; set the leftmost bit
DECCOUNT   decfsz BITCOUNT,F   ; decrement req bits. jump if zero
           goto BITDATA        ; not zero. get next bit
           btfsc GOTFIRST8,0   ; count zero. another 3 bits?
           goto WRITEBITS      ; all bits received. write to pins
           movf TEMPBITS,W     ; need another 3 bits. store TEMPBITS
           movwf FIRST8BITS
           movlw 3             ; get another 3 bits
           movwf BITCOUNT
           bsf GOTFIRST8,0     ; set "got 1st 8 bits" flag
           goto BITDATA        ; get remaining bits

WRITEBITS  btfss FIRST8BITS,0
           goto PORTA0L
           bsf PORTA,0         ; write 1 to RA0
           goto PORTA1
PORTA0L    bcf PORTA,0         ; write 0 to RA0
PORTA1     btfss FIRST8BITS,1
           goto PORTA1L
           bsf PORTA,1         ; write 1 to RA1
           goto PORTA2
PORTA1L    bcf PORTA,1         ; write 0 to RA1
PORTA2     btfss FIRST8BITS,2
           goto PORTA2L 
           bsf PORTA,2         ; write 1 to RA2
           goto PORTA3
PORTA2L    bcf PORTA,2         ; write 0 to RA2
PORTA3     btfss FIRST8BITS,3
           goto PORTA3L
           bsf PORTA,3         ; write 1 to RA3
           goto PORTB0
PORTA3L    bcf PORTA,3         ; write 0 to RA3
PORTB0     btfss FIRST8BITS,4
           goto PORTB0L
           bsf PORTB,0         ; write 1 to RB0
           goto PORTB1
PORTB0L    bcf PORTB,0         ; write 0 to RB0
PORTB1     btfss FIRST8BITS,5
           goto PORTB1L
           bsf PORTB,1         ; write 1 to RB1
           goto PORTB2
PORTB1L    bcf PORTB,1         ; write 0 to RB1
PORTB2     btfss FIRST8BITS,6
           goto PORTB2L
           bsf PORTB,2         ; write 1 to RB2
           goto PORTB3
PORTB2L    bcf PORTB,2         ; write 0 to RB2
PORTB3     btfss FIRST8BITS,7
           goto PORTB3L
           bsf PORTB,3         ; write 1 to RB3
           goto PORTB4
PORTB3L    bcf PORTB,3         ; write 0 to RB3
PORTB4     btfss TEMPBITS,5
           goto PORTB4L
           bsf PORTB,4         ; write 1 to RB4
           goto PORTB5
PORTB4L    bcf PORTB,4         ; write 0 to RB4
PORTB5     btfss TEMPBITS,6
           goto PORTB5L
           bsf PORTB,5         ; write 1 to RB5
           goto PORTB6
PORTB5L    bcf PORTB,5         ; write 0 to RB5
PORTB6     btfss TEMPBITS,7
           goto PORTB6L
           bsf PORTB,6         ; write 1 to RB6
           goto WSTART         ; all done. wait for another start bit
PORTB6L    bcf PORTB,6         ; write 0 to RB6
           goto WSTART         ; all done. wait for another start bit
    
        END
