# RF-Sensors
Wireless church tower bell sensors using an inexpensive 433MHz OOK transmitter and receiver

This is a project for an electronics enthusiast. It's not a product but you are free to use the source code to develop your own solution, or indeed copy what I have done.

This project is for an 11 bit encoder and decoder for cheap OOK RF transmitters and receivers.
The software is written in Arizona Microchip PIC assembly language for the p16f628 processor.
The software was assembled and flashed to the processor with the Velleman PicProg 2009 application together with a Velleman P8048 PIC programmer.
Please read the pdf in the repository for a full description of the project.

16th November 2026 - Modifications:
a) Minor changes have been made to the encoder software (see V2 file).
b) The decoder software now includes simple error detection (see V3 file). Only consecutive packets containing identical data result in changes to the output states.
c) Small changes have also been made to the encoder and decoder electronics:
    i) The transmitter module now works at 10 V. The existing 5 V supply is boosted to 10 V for the transmitter module only. This greatly increases signal strength.
    ii) The sound sensor input is now dual purpose. It can either be used as before for the receipt of the strike signal, or now as a bottom dead centre signal from a dumbbell.
    
