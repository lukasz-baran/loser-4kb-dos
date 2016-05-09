
; ---------------------------------------------------------------------------
; Generuje liczbe pseudolosowa z zakresu (0 .. ax)
; IN:  ax = zakres liczb losowych
; OUT  ax = liczba losowa
Random  PROC
        mov     bx, ax
        mov     ax, Seed
        mov     cx, 31413
        mul     cx
        add     ax, 13849
        mov     Seed, ax
        mul     bx
        mov     ax, dx
        ret
ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; ta procka przygotowuje wszystkie palety w tablicy 'Palety'
PreparePalettes PROC
        push    cs
        pop     es
        mov     di, offset Palety

        cld

 ; szara paleta
        mov     cx, 64
        xor     ax, ax
 @@GreyPal:
        stosb
        stosb
        stosb
        inc     ax
        loop    @@GreyPal

 ; czerwona paleta
        mov     cx, 64
        xor     bx, bx
 @@RedPal:
        mov     al, bl
        stosb
        xor     ax, ax
        stosb
        stosb
        inc     bx
        loop    @@RedPal

 ; niebieska paleta
        mov     cx, 64
        xor     bx, bx
 @@BluePal:
        xor     ax, ax
        stosb
        stosb
        mov     al, bl
        stosb
        inc     bx
        loop    @@BluePal

 ; zielona paleta
        mov     cx, 64
        xor     bx, bx
 @@GreenPal:
        xor     ax, ax
        stosb
        mov     al, bl
        stosb
        xor     ax, ax
        stosb
        inc     bx
        loop    @@GreenPal

        ret
ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; Ustawia pierwsze 64 kolory palety z tablicy AktualPal
; IN:   ds:si - adres 64*3 bajtow palety do ustawienia
SetPal  PROC
        mov     dx, 3c8h
        xor     al, al
        out     dx, al
        inc     dx

        mov     si, offset AktualPal
        mov     cx, 3*64
        cld
 @@sp:
        mov     al, cs:[si]
        inc     si
        out     dx, al
        loop    @@sp

        ret
ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; Ustawia pierwsze 64 kolory palety z tablicy AktualPal
; dodatkowo dodaje jakis kolor do kazdego koloru
; IN:   ds:si - adres 64*3 bajtow palety do ustawienia
;       bl    - ile dodac do kazdego koloru??
SetLightenPal  PROC
        mov     dx, 3c8h
        xor     al, al
        out     dx, al
        inc     dx

        mov     si, offset AktualPal
        mov     cx, 3*64
        cld
 @@sp:
        mov     al, cs:[si]
        inc     si
        add     al, bl
        cmp     al, 64
        jl      @@wyglad
        mov     al, 63
 @@wyglad:
        out     dx, al
        loop    @@sp

        ret
ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; Ustawia pierwsze 64 kolory palety z tablicy AktualPal
; dodatkowo odejmuje jakis kolor od kazdego koloru
; IN:   ds:si - adres 64*3 bajtow palety do ustawienia
;       bl    - ile odjac od kazdego koloru??
SetDarkenPal  PROC
        mov     dx, 3c8h
        xor     al, al
        out     dx, al
        inc     dx

        mov     si, offset AktualPal
        mov     cx, 3*64
        cld
 @@sp:
        mov     al, cs:[si]
        inc     si
        cmp     al, bl
        jge     @@wyglad
        mov     al, bl
 @@wyglad:
        out     dx, al
        loop    @@sp

        ret
ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
PrepareEffect PROC
        xor     bx, bx
;       mov     count, 0
 @@Xprep:
        fild    word ptr [ count ]
        fidiv   word ptr [ _319 ]
        fimul   word ptr [ factor2 ]
        fiadd   word ptr [ factor ]
        fistp   word ptr [ ScaleXArray + bx ]

        add     bx, 2
        inc     count
        cmp     count, 320
        jne     @@Xprep

        xor     bx, bx
        mov     count, 0
 @@Yprep:
        fild    word ptr [ count ]
        fidiv   word ptr [ _199 ]
        fimul   word ptr [ factor3 ]
        fiadd   word ptr [ factor ]
        fistp   word ptr dummyWord

        mov     ax, dummyWord
        imul    ax, 320
        mov     [ ScaleYArray + bx ], ax

        add     bx, 2
        inc     count
        cmp     count, 200
        jne     @@Yprep

        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
Scale PROC
        mov     fs, Buffer1
        mov     es, Buffer2
        xor     di, di
        xor     bx, bx
 @@ScaleY:

        xor     cx, cx
 @@ScaleX:

        mov     bp, bx
        shl     bp, 1
        mov     si, word ptr [ ScaleYArray + bp ]

        mov     bp, cx
        shl     bp, 1
        add     si, word ptr [ ScaleXArray + bp ]

        mov     al, fs:[si]

        mov     es:[di], al

        inc     di

        inc     cx
        cmp     cx, 320
        jne     @@ScaleX

        inc     bx
        cmp     bx, 200
        jne     @@ScaleY

        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
Blur    PROC

        mov     fs, Buffer2
        mov     gs, Buffer3
        xor     di, di

        mov     cx, 200
 @@BlurY:
        push    cx

        mov     cx, 320
 @@BlurX:
        mov     al, fs:[ di - 1 ]
        add     al, fs:[ di + 1 ]
        add     al, fs:[ di + 320 ]
        add     al, fs:[ di - 320 ]
        shr     al, 2
        sbb     al, 3

        cmp     al, 63
        jna     @@ok
        xor     al, al
 @@ok:

        mov     gs:[di], al

        inc     di
        loop    @@BlurX

        pop     cx
        loop    @@BlurY

        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; IN:  ax = virtual screen which you want to copy to video memory
DrawScr PROC
        push    ds
        cld
        mov     ds, ax
        xor     si, si
        xor     di, di
        mov     ax, 0a000h
        mov     es, ax
        mov     ecx, 16000
        rep     movsd
        pop     ds
        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; IN:  ax = segment pamieci z ekranem
ClearScr PROC
        cld
        mov     es, ax
        xor     eax, eax
        xor     di, di
        mov     ecx, 16384
        rep     stosd
        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; OUT: ax = segment pamieci
AllocMemory PROC
        mov     bx, 4096
        mov     ah, 4ah
        int     21h
;w bx jest jeszcze 4096...
        mov     ah, 48h
        int     21h
        jnc     @@Koniec
        int     20h
@@Koniec:
        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
InitTimer  PROC

        push    0                      ; es = 0
        pop     es
        cli
        mov     eax, es:[4*8]          ; tablica przerwan
        mov     cs:[oldint8], eax
        lea     bx, cs:[newint8]
        mov     es:[4*8], bx
        mov     es:[4*8+2], cs

        mov     al, 36h
        out     43h, al
        mov     al, 00h                ; mlodszy bajt
        out     40h, al
        mov     al, 30h                ; starszy bajt
        out     40h, al
        sti

        ret
InitTimer  ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
CloseTimer  PROC

        push    0
        pop     es
        cli
        mov     eax, cs:[oldint8]
        mov     es:[4*8], eax

        mov     al, 36h
        out     43h, al
        xor     ax, ax
        out     40h, al
        out     40h, al
        sti
        ret

CloseTimer  ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
newint8 PROC    NEAR

        cli
        inc     cs:timer
        sti
        jmp     dword ptr cs:oldint8

newint8 endp
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
WaitVBL     PROC
        mov     dx, 3dah
  @waitvbl1:
        in      al, dx
        test    al, 8
        jne     @waitvbl1
  @waitvbl2:
        in      al, dx
        test    al, 8
        je      @waitvbl2
        ret
WaitVBL     ENDP
; ---------------------------------------------------------------------------

_factor      equ        6
factor       dw         _factor
factor2      dw         319-2*_factor
factor3      dw         199-2*_factor
_319         dw         319
_199         dw         199


