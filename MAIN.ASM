

; ---------------------------------------------------------------------------
; stale uzywane w programie

        GreyPalOffset    equ     0
        RedPalOffset     equ     64*3
        BluePalOffset    equ     64*3*2
        GreenPalOffset   equ     64*3*3
        BlackPalOffset   equ     64*3*4

        eTime1           equ     1000
        eTime2           equ     1000+64

; ---------------------------------------------------------------------------
; dolaczamy plik z makrami
        include          macros.inc


.386p
locals

seg_a  segment byte public use16
       assume  cs:seg_a, ds:seg_a

org 100h

start:

        lea     di, [ZeroData]
        mov     cx, di
        neg     cx
        repz    stosb

; Buffer2 = VScreen

        call    GenerateSin             ; tablica z sinusem
        call    GenerateWorld
        call    PrepareEffect
        call    PreparePalettes
        call    GenerateFlare
        call    InitFlares

        call    AllocMemory
        mov     Buffer1, ax
        call    AllocMemory
        mov     Buffer2, ax
        mov     VScreen, ax
        call    AllocMemory
        mov     Buffer3, ax
        call    AllocMemory
        mov     Buffer4, ax

        call    PrepareFonts
        call    InitTimer

        mov     ax, Buffer1
        call    ClearScr
        mov     ax, Buffer2
        call    ClearScr
        mov     ax, Buffer3
        call    ClearScr
; ---------------------------------------------------------------------------
;  S P H E R E
; ---------------------------------------------------------------------------
        mov     ax, 13h
        int     10h

        push    cs
        pop     ds

 ; na poczatku tablica AktualPal jest wypelniona zerami
        call    SetPal

 @@MainLoop1:
        call    @@EFECT_1
        call    @@CHANGE_PAL
        in      al, 60h
        cmp     al, 1
        je      @@KONIEC
        mov     ax, timer
        cmp     ax, eTime1
        jbe     @@MainLoop1

; ---------------------------------------------------------------------------
; rozjasnienie do bialego
; ---------------------------------------------------------------------------
        xor     cx, cx
 @@FadeToWhite:
        push    cx
        push    cx
        call    @@EFECT_1

        mov     cx, timer
        shr     cx, 5
        and     cx, 011b
        mov     cs:ktora_paleta, cx
        mov     si, offset Palety
 ; w cx jest licznik dla palety
 @@addi1:
        add     si, 64*3
        loop    @@addi1

        xor     bx, bx
 @@copypal2:
        mov     al, cs:[si + bx]
        mov     cs:AktualPal[bx], al
        inc     bx
        cmp     bx, 64*3
        jne     @@copypal2

        call    WaitVBL

        pop     bx
        call    SetLightenPal

        pop     cx

        in      al, 60h
        cmp     al, 1
        je      @@KONIEC
        inc     cx
        cmp     cx, 64
        jne     @@FadeToWhite

        call    GenerateTunnel
        call    GenText

        mov     timer, 0

; ---------------------------------------------------------------------------
; od calkowitej bialosci do tunelu:
; ---------------------------------------------------------------------------
        mov     cx, 63
 @@FadeFromWhite:
        push    cx
        push    cx
        call    @@EFECT_2

        mov     cx, timer
        shr     cx, 5
        and     cx, 011b
        mov     cs:ktora_paleta, cx
        mov     si, offset Palety
 ; w cx jest licznik dla palety
 @@addi3:
        add     si, 64*3
        loop    @@addi3

        xor     bx, bx
 @@copypal4:
        mov     al, cs:[si + bx]
        mov     cs:AktualPal[bx], al
        inc     bx
        cmp     bx, 64*3
        jne     @@copypal4

        call    WaitVBL

        pop     bx
        call    SetDarkenPal

        pop     cx

        in      al, 60h
        cmp     al, 1
        je      @@KONIEC

        dec     cx
        jnz     @@FadeFromWhite

; ---------------------------------------------------------------------------
;  T U N N E L
; ---------------------------------------------------------------------------
 @@MainLoop2:
        call    @@EFECT_2
        call    @@CHANGE_PAL
        in      al, 60h
        cmp     al, 1
        je      @@KONIEC
        mov     ax, timer
        cmp     ax, eTime1
        jbe     @@MainLoop2

; ---------------------------------------------------------------------------
; rozjasnienie do bialego
; ---------------------------------------------------------------------------
        xor     cx, cx
 @@FadeToWhite_:
        push    cx
        push    cx
        call    @@EFECT_2

        mov     cx, timer
        shr     cx, 5
        and     cx, 011b
        mov     cs:ktora_paleta, cx
        mov     si, offset Palety
 ; w cx jest licznik dla palety
 @@addi1_:
        add     si, 64*3
        loop    @@addi1_

        xor     bx, bx
 @@copypal2_:
        mov     al, cs:[si + bx]
        mov     cs:AktualPal[bx], al
        inc     bx
        cmp     bx, 64*3
        jne     @@copypal2_

        call    WaitVBL

        pop     bx
        call    SetLightenPal

        pop     cx

        in      al, 60h
        cmp     al, 1
        je      @@KONIEC
        inc     cx
        cmp     cx, 64
        jne     @@FadeToWhite_
; ---------------------------------------------------------------------------

        mov     timer, 0

; ---------------------------------------------------------------------------
; od calkowitej bialosci do wobble'a
; ---------------------------------------------------------------------------
        mov     cx, 63
 @@FadeFromWhite1_:
        push    cx
        push    cx
        call    @@EFECT_4

        mov     cx, timer
        shr     cx, 5
        and     cx, 011b
        mov     cs:ktora_paleta, cx
        mov     si, offset Palety
 ; w cx jest licznik dla palety
 @@addi5_:
        add     si, 64*3
        loop    @@addi5_

        xor     bx, bx
 @@copypal5_:
        mov     al, cs:[si + bx]
        mov     cs:AktualPal[bx], al
        inc     bx
        cmp     bx, 64*3
        jne     @@copypal5_

        call    WaitVBL

        pop     bx
        call    SetDarkenPal

        pop     cx

        in      al, 60h
        cmp     al, 1
        je      @@KONIEC

        dec     cx
        jnz     @@FadeFromWhite1_

; ---------------------------------------------------------------------------
; W O B B L Y   T U N N E L
; ---------------------------------------------------------------------------
 @@MainLoop4:
        call    @@EFECT_4
        call    @@CHANGE_PAL
        in      al, 60h
        cmp     al, 1
        je      @@KONIEC

        mov     ax, timer
        cmp     ax, eTime1
        jbe     @@MainLoop4
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; rozjasnienie do bialego
; ---------------------------------------------------------------------------
        xor     cx, cx
 @@FadeToWhite__:
        push    cx
        push    cx
        call    @@EFECT_4

        mov     cx, timer
        shr     cx, 5
        and     cx, 011b
        mov     cs:ktora_paleta, cx
        mov     si, offset Palety
 ; w cx jest licznik dla palety
 @@addi1__:
        add     si, 64*3
        loop    @@addi1__

        xor     bx, bx
 @@copypal2__:
        mov     al, cs:[si + bx]
        mov     cs:AktualPal[bx], al
        inc     bx
        cmp     bx, 64*3
        jne     @@copypal2__

        call    WaitVBL

        pop     bx
        call    SetLightenPal

        pop     cx

        in      al, 60h
        cmp     al, 1
        je      @@KONIEC
        inc     cx
        cmp     cx, 64
        jne     @@FadeToWhite__
; ---------------------------------------------------------------------------


        mov     timer, 0
; ---------------------------------------------------------------------------
; od calkowitej bialosci do swiatelek:
; ---------------------------------------------------------------------------
        mov     cx, 63
 @@FadeFromWhite1:
        push    cx
        push    cx
        call    @@EFECT_3

        mov     cx, timer
        shr     cx, 5
        and     cx, 011b
        mov     cs:ktora_paleta, cx
        mov     si, offset Palety
 ; w cx jest licznik dla palety
 @@addi5:
        add     si, 64*3
        loop    @@addi5

        xor     bx, bx
 @@copypal5:
        mov     al, cs:[si + bx]
        mov     cs:AktualPal[bx], al
        inc     bx
        cmp     bx, 64*3
        jne     @@copypal5

        call    WaitVBL

        pop     bx
        call    SetDarkenPal

        pop     cx

        in      al, 60h
        cmp     al, 1
        je      @@KONIEC

        dec     cx
        jnz     @@FadeFromWhite1


; ---------------------------------------------------------------------------
;  F L A R E S
; ---------------------------------------------------------------------------
 @@MainLoop3:
        call    @@EFECT_3
        call    @@CHANGE_PAL
        in      al, 60h
        cmp     al, 1
        je      @@KONIEC

        mov     ax, timer
        cmp     ax, eTime1
        jbe     @@MainLoop3

 @@KONIEC:
        mov     ax,3
        int     10h
        call    CloseTimer
        int     20h       ; koniec programu


; --- p r o c e d u r e s ---------------------------------------------------

; ---------------------------------------------------------------------------
 @@EFECT_1:
        call    Scale            ; Buffer1 -> Buffer2
        call    RenderWorld      ; draw on Buffer2
        call    Blur             ; Buffer2 -> Buffer3
        mov     es, Buffer3
        call    PutText          ; write texts in Buffer3
        mov     ax, Buffer3
        call    DrawScr
        mov     ax, Buffer1     ; swap Buffer1 and Buffer3
        xchg    ax, Buffer3
        mov     Buffer1, ax
        mov     ax, timer
        mov     angleX, ax
        mov     angleY, ax
        mov     angleZ, ax
        ret
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Zwykly tunel
 @@EFECT_2:
        mov     dx, cs:timer
        shr     dx, 1
        mov     dh, dl
        mov     fs, Buffer1
        mov     gs, Buffer2
        mov     es, Buffer3
        push    ds
        mov     ds, Buffer4
        xor     di, di
        mov     cx, 64000
  @@tunel:
        mov     bl, fs:[di]
        mov     bh, gs:[di]
        add     bx, dx
        mov     al, es:[bx]
        mov     ds:[di], al
        inc     di
        loop    @@tunel
        pop     ds
        mov     es, Buffer4
        call    PutText
        mov     ax, Buffer4
        call    DrawScr
        ret
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Swiatelka
 @@EFECT_3:
        call    Blur
        call    FlareEffect
        mov     es, Buffer3
        call    PutText          ; write texts in Buffer3
        mov     ax, Buffer3
        call    DrawScr
        mov     ax, Buffer2
        xchg    ax, Buffer3
        mov     Buffer2, ax
        ret
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Tunel wobble'owany
 @@EFECT_4:
        mov     dx, cs:timer
        shr     dx, 1
        mov     dh, dl
        mov     fs, Buffer1
        mov     gs, Buffer2
        mov     es, Buffer3
        push    ds
        mov     ds, Buffer4
        xor     di, di
        mov     cx, 64000
  @@wobbel:
        mov     ah, fs:[di]
        mov     al, gs:[di]

        xor     bx, bx
;        add     bx, dx
        mov     bl, al
        add     bl, dl
        mov     bl, cs:Sinus[bx]
        add     ah, bl

        mov     bl, al
        add     bl, dh
        mov     bl, cs:Sinus[bx]
        add     al, bl

        mov     bx, ax

        mov     al, es:[bx]
        mov     ds:[di], al
        inc     di
        loop    @@wobbel

        pop     ds
        mov     es, Buffer4
        call    PutText
        mov     ax, Buffer4
        call    DrawScr
        ret
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; zmiana palety
 @@CHANGE_PAL:
        mov     cx, timer
        shr     cx, 5
        and     cx, 011b
        cmp     cx, cs:ktora_paleta
        je      @@dontChangePal
        mov     cs:ktora_paleta, cx
        push    cs
        pop     ds
        mov     si, offset Palety
 ; w cx jest licznik dla palety
 @@addi:
        add     si, 64*3
        loop    @@addi

        xor     bx, bx
 @@copypal3:
        mov     al, cs:[si + bx]
        mov     cs:AktualPal[bx], al
        inc     bx
        cmp     bx, 64*3
        jne     @@copypal3

        call    WaitVBL
        call    SetPal
 @@dontChangePal:
        ret
; ---------------------------------------------------------------------------

; --- i n c l u d e ---------------------------------------------------------

        include           procs.asm
        include           ziemia.asm
        include           line.asm
        include           tunnel.asm
        include           flares.asm
        include           text.asm

; --- d a n e ---------------------------------------------------------------

        include           data.asm

        oldint8           dd    0
        timer             dw    0

        fadeCount         dd    0  ;licznik dla fade'a
        Fade              dw    0

        Buffer1           dw    0
        Buffer2           dw    0
        Buffer3           dw    0
        Buffer4           dw    0
        VScreen           dw    0


seg_a ends


end start