
        IleFlar         equ     80

; ---------------------------------------------------------------------------
GenerateFlare PROC

        mov     di, offset Flara

        mov     cx, 32
 @@flarey:
        mov     bp, 32
 @@flarex:
        mov     ax, cx
        sub     ax, 16
        imul    ax, ax

        mov     bx, bp
        sub     bx, 16
        imul    bx, bx

        add     ax, bx
        mov     TempF, ax

        fild    word ptr TempF
        fsqrt
        fistp   word ptr TempF

        mov     ax, TempF
        cmp     ax, 16
        jle     @@flareOK
        mov     ax, 16
 @@flareOK:

        mov     bx, 16
        sub     bx, ax
        shl     bx, 2
        dec     bx
        mov     cs:[di], bl

        inc     di

        dec     bp
        jnz     @@flarex

        loop    @@flarey

        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; ustala nowe pozycje dla flar
InitFlares PROC

        mov     di, offset Flary
        mov     cx, IleFlar*4
 @@init:
        push    cx
        mov     ax, 240
        call    Random
        sub     ax, 120
        mov     TempF, ax

        fild    word ptr TempF
        fstp    dword ptr [di]

        add     di, 4

        pop     cx
        loop    @@init
        ret
ENDP
; ---------------------------------------------------------------------------



; ---------------------------------------------------------------------------
; draws flare on screen
; IN:   di - adres poczatku
;       ax - rozmiar sprite'a na ekranie
DrawFlare PROC
        push    bp

        mov     FlareSize, ax

        mov     eax, 32*10000h
        cdq
        movsx   ebx, word ptr FlareSize
        idiv    ebx
        mov     delta, eax

        xor     ebp, ebp

        mov     cx, FlareSize
 @@drawy:

        cmp     di, 64000
        ja      @@grejter

        mov     eax, ebp
        shr     eax, 16
        shl     ax, 5
        mov     si, ax
        add     si, offset Flara

        xor     ebx, ebx
        mov     dx, FlareSize
 @@drawx:
        ror     ebx, 16
        mov     al, cs:[si + bx]   ; bajt z tablicy z flara
        ror     ebx, 16

        or      al, al
        jz      @@fuckyou

        cmp     al, es:[di]
        jl      @@leeee
        mov     es:[di], al
 @@leeee:

 @@fuckyou:

        add     ebx, delta

        inc     di              ; nastepny bajt na ekranie
        dec     dx
        jnz     @@drawx

 @@grejter:

        add     ebp, delta

        add     di, 320
        sub     di, FlareSize
        loop    @@drawy

        pop     bp
        ret
ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
FlareEffect PROC

        mov     ax, timer
        or      ax, ax
        jnz     @@niez
        mov     ax, 1
 @@niez:
        mov     Licznik, ax

        fldpi
        fild    Licznik
        fmulp   st(1), st(0)
        fidiv   word ptr [ _180 ]
        fsincos
        fstp    dword ptr [ cosZ ]
        fstp    dword ptr [ sinZ ]

        mov     es, Buffer3
        mov     bp, offset Flary

        mov     cx, IleFlar
 @@render:
        push    cx


        fld     dword ptr [ bp + 0 ] ; x
        fmul    dword ptr [ cosZ ]
        fld     dword ptr [ bp + 4 ] ; y
        fmul    dword ptr [ sinZ ]
        fsubp   st(1), st(0)
        fld     dword ptr [ bp + 0 ] ; x
        fmul    dword ptr [ sinZ ]
        fld     dword ptr [ bp + 4 ] ; y
        fmul    dword ptr [ cosZ ]
        faddp   st(1), st(0)
        fstp    dword ptr _y
        fstp    dword ptr _x


        fld1
        fld     dword ptr [ bp + 8 ] ;z
        fadd    dword ptr PerspZ
        fdivp   st(1), st(0)     ; st(0) = st(1) / st(0)

        fst     st(1)            ; st(0) = st(1)
        fmul    dword ptr _x
        fimul   word ptr [ _1000 ]
        fiadd   word ptr [ _160 ]
        fistp   word ptr xEkr

        fmul    dword ptr _y
        fimul   word ptr [ _830 ]
        fiadd   word ptr [ _100 ]
        fistp   word ptr yEkr

 ; trzeba obliczyc wielkosc swiatelka na ekranie
        fild    word ptr _300
        fsub    dword ptr [ bp + 8 ] ;z
        fidiv   word ptr _15
        fistp   word ptr TempF

        mov     ax, 32
        sub     ax, TempF

        mov     di, yEkr        ; obliczenie adresu
        sub     di, ax
        imul    di, 320
        add     di, xEkr
        sub     di, ax

        call    DrawFlare

        add     bp, 16
        pop     cx
        dec     cx
        jnz     @@render

 ;---- ponizsza procka to jest transformacja swiatelek w przestrzeni -------
        mov     bp, offset Flary
        mov     cx, IleFlar
 @@Transform:

        fild    Licznik
        fadd    dword ptr [ bp + 12 ]
        fidiv   _15
        fsin
        fmul    dword ptr [ bp + 12 ]
        fstp    dword ptr [ bp + 0 ]
comment #
        fild    Licznik
        fsub    dword ptr [ bp + 12 ]
        fidiv   _48
        fcos
        fmul    dword ptr [ bp + 12 ]
        fstp    dword ptr [ bp + 4 ]

        fild    Licznik
        fadd    dword ptr [ bp + 12 ]
        fidiv   _15
        fcos
        fmul    dword ptr [ bp + 12 ]
        fstp    dword ptr [ bp + 8 ]
#
        add     bp, 16
        loop     @@Transform

        ret
ENDP
; ---------------------------------------------------------------------------

        _300            dw      300
        _150            dw      150

        _15             dw      25

        _48             dw      48

