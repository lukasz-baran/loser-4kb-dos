

; ---------------------------------------------------------------------------
; OUT:  Buffer1 = tablica pierwsza dla tunelu
;       Buffer2 = tablica druga dla tunelu
GenerateTunnel PROC

        mov     fs, Buffer1
        mov     gs, Buffer2
        xor     di, di

        fldpi
        fstp    dword ptr Pi

        mov     bp, 200
 @@TunelY:

        mov     cx, 320
 @@TunelX:

        xor     eax, eax
        mov     ax, cx
        sub     eax, 160
        mov     tempX, eax

        xor     ebx, ebx
        mov     bx, bp
        sub     ebx, 100
        mov     tempY, ebx

        fild    dword ptr tempX
        fild    dword ptr tempY

        fpatan                          ; arcus tangens

        fimul   word ptr _128           ; 128, bo chcemy miec wartosci
        fdiv    dword ptr Pi            ; z zakresu (0-255)

        fistp   word ptr tempW

; a teraz obliczanie drugiej wartosci

        imul    eax, eax
        imul    ebx, ebx
        add     eax, ebx
        mov     tempX, eax
        fild    dword ptr tempX

        fsqrt

        fild    word ptr Perspval
        fdiv    st,st(1)
        fistp   dword ptr TempX
        fstp    dword ptr DummySth

        mov     al, byte ptr TempX
        mov     fs:[di], al

        mov     al, byte ptr TempW
        mov     gs:[di], al

        inc     di

        loop    @@TunelX

        dec     bp
        jnz     @@TunelY

        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; generate sinus
GenerateSin PROC
        xor     si, si
        mov     cx, 257
        mov     bp, offset Sinus
        fild    word ptr _127
        fldpi                           ;pi
        fild    word ptr _128           ;128
        fdivp   st(1), st               ;pi/128
 @@MakeSIN:
        mov     ax, si
        mov     TempSin, ax
        fild    word ptr TempSin        ;x
        fmul    st,st(1)                ;x*(pi/128)
        fsin                            ;sin(x*(pi/128))
        fmul    st,st(2)                ;127*sin(x*(pi/128))
        fistp   word ptr cs:[bp + si]
        inc     si
        loop    @@MakeSIN
        finit
        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Generate texture (Buffer3)
GenText PROC
        mov     fs, Buffer3

 ; losowe punkty
        mov     bp, 10000
 @@gent:
        mov     ax, 0ffffh
        call    Random
        mov     di, ax
        mov     byte ptr fs:[di], 63
        dec     bp
        jnz     @@gent

 ; blur
        mov     cx, 3
 @@gent1:
        mov     di, 0ffffh
 @@gent2:
        mov     al, fs:[di+1]
        add     al, fs:[di-1]
        add     al, fs:[di+256]
        add     al, fs:[di-256]
        shr     al, 2
        mov     fs:[di], al
        dec     di
        jnz     @@gent2
        loop    @@gent1

 ; lighten texture
        mov     bx, 0ffffh
 @@lighten:
        mov     al, fs:[bx]
        add     al, 8
        cmp     al, 64
        jl      @@NoNeedLighten
        mov     al, 63
 @@NoNeedLighten:
        mov     byte ptr fs:[bx], al

        dec     bx
        jnz     @@lighten

        ret
ENDP
; ---------------------------------------------------------------------------

        _128            dw      128
        _127            dw      127
        Perspval        dw      1500



