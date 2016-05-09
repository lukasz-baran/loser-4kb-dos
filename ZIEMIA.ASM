
        IleVertixow     equ     5*12+2
        IleFacow        equ     8*12+2*12

; ---------------------------------------------------------------------------
GenerateWorld  PROC

; generowanie JEDNEGO poludnika!
        mov     di, offset WorldPoints
        mov     angle, 30
        mov     cx, 5
 @@poludnik:

        fild    word ptr _100

        fldpi
        fimul   word ptr angle
        fidiv   word ptr _180

        fsincos                 ; cos = st(0)  sin = st(1)

        fmul    st(0), st(2)
        fstp    dword ptr ds:[ di + 4 ]   ; y

        fmul    st(0), st(1)
        fstp    dword ptr ds:[ di + 0 ]   ; x

; UWAGA! ponizsze linie pomijamy, bo na poczatku wszystko = 0 !!!
;        fldz
;        fstp    dword ptr ds:[ di + 8 ]   ; z

        add     di, 12
        add     angle, 30
        loop    @@poludnik




; generowanie reszty poludnikow (obrot pierwszego poludnika)
        mov     angle, 30
        mov     cx, 11
 @@calakula:
        push    cx

        fldpi
        fimul   word ptr [ angle ]
        fidiv   word ptr _180
        fsincos                 ; cos = st(0)  sin = st(1)
        fstp    dword ptr [ _cos ]
        fstp    dword ptr [ _sin ]


        mov     si, offset WorldPoints
        mov     cx, 5
 @@kazdypoludnik:

        fld     dword ptr ds:[ si + 0 ] ; x
        fmul    dword ptr [ _cos ]

        fld     dword ptr ds:[ si + 8 ] ; z
        fmul    dword ptr [ _sin ]

        fsubp   st(1), st(0)
        fstp    dword ptr ds:[ di + 0 ] ; st(0) = new X


        fld     dword ptr ds:[ si + 8 ] ; z
        fmul    dword ptr [ _cos ]

        fld     dword ptr ds:[ si + 0 ] ; x
        fmul    dword ptr [ _sin ]

        faddp   st(1), st(0)
        fstp    dword ptr ds:[ di + 8 ] ; new Z


        fld     dword ptr ds:[ si + 4 ]
        fstp    dword ptr ds:[ di + 4 ] ; new Y

        add     di, 12
        add     si, 12
        loop    @@kazdypoludnik

        add     angle, 30
        pop     cx
        loop    @@calakula

; gorny i dolny biegun - po jednym punkciku ( 0, 100, 0 )
        fild    word ptr _100
        fst     dword ptr ds:[ di + 4 ] ; y(1)
        fchs
        fstp    dword ptr ds:[ di + 16 ]

; ---------------------------------------------------------------------------
;       obliczamy dane dla facow
; ---------------------------------------------------------------------------
        xor     bx, bx

        mov     di, offset WorldFaces
        mov     cx, 11
  @@faceCalaKula:

        mov     dx, 4
  @@facePoludnik:

 ; pierwszy face w kwadraciku
        mov     ax, bx
        mov     ds:[di + 0], ax
        inc     ax
        mov     ds:[di + 2], ax
        add     ax, 4
        mov     ds:[di + 4], ax
 ;drugi face w kwadraciku
        mov     ax, bx
        inc     ax
        mov     ds:[di + 6], ax
        add     ax, 5
        mov     ds:[di + 8], ax
        dec     ax
        mov     ds:[di + 10], ax
        add     di, 12

        inc     bx

        dec     dx
        jnz     @@facePoludnik

        inc     bx

        loop    @@faceCalaKula

; ---------------------------------------------------------------------------
;       O S T A T N I   P R Z E B I E G
; ---------------------------------------------------------------------------
        mov     cx, 4
  @@facePoludnik2:

 ; pierwszy face w kwadraciku
        mov     ax, bx
        mov     ds:[di + 0], ax
        inc     ax
        mov     ds:[di + 2], ax
        sub     ax, 56
        mov     ds:[di + 4], ax
 ;drugi face w kwadraciku
        mov     ax, bx
        inc     ax
        mov     ds:[di + 6], ax
        sub     ax, 55
        mov     ds:[di + 8], ax
        dec     ax
        mov     ds:[di + 10], ax
        add     di, 12

        inc     bx

        loop    @@facePoludnik2

; --------------------------------------------------------------------------
;      S C I A N Y   N A   B I E G U N A C H
; --------------------------------------------------------------------------
        xor     cx, cx
 @@Bieguny:
        mov     word ptr ds:[di + 0], 60
        mov     word ptr ds:[di + 8], 61

        mov     ax, cx          ; \
        shl     ax, 2           ;  | mnozenie * 5
        add     ax, cx          ; /

        mov     word ptr ds:[di + 2], ax
        add     ax, 4
        mov     word ptr ds:[di + 6], ax

        cmp     cx, 11          ; sprawdzamy czy to ostatni face
        jne     @@nieRowne
        mov     word ptr ds:[di + 4], 0
        mov     word ptr ds:[di + 10], 4
        jmp     @@jednakBylyRowne
 @@nieRowne:
        add     ax, 5
        mov     word ptr ds:[di + 10], ax
        sub     ax, 4
        mov     word ptr ds:[di + 4], ax
 @@jednakbylyRowne:

        add     di, 12

        inc     cx
        cmp     cx, 12
        jne     @@Bieguny

        ret
GenerateWorld  ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
RenderWorld PROC

; ---- only points : ------------------------------

        push    cs
        pop     ds

 ; przygotowanie sinusow i cosinusow
        fldpi
        fild    word ptr [angleX]
        fmul    st(0), st(1)
        fidiv   word ptr [ _180 ]
        fsincos
        fstp    dword ptr [ cosX ]
        fstp    dword ptr [ sinX ]

        fild    word ptr [angleY]
        fmul    st(0), st(1)
        fidiv   word ptr [ _180 ]
        fsincos
        fstp    dword ptr [ cosY ]
        fstp    dword ptr [ sinY ]

        fild    word ptr [angleZ]
        fmulp   st(1), st(0)
        fidiv   word ptr [ _180 ]
        fsincos
        fstp    dword ptr [ cosZ ]
        fstp    dword ptr [ sinZ ]

        mov     si, offset WorldPoints
        mov     di, offset WorldScreen
        mov     cx, IleVertixow
 @@Render:

        mov     eax, dword ptr ds:[si+0]
        mov     ebx, dword ptr ds:[si+4]
        mov     edx, dword ptr ds:[si+8]
        mov     _x, eax
        mov     _y, ebx
        mov     _z, edx

 ; rotacje ---------------------------------
        fld     dword ptr _x
        fmul    dword ptr [ cosY ]
        fld     dword ptr _z
        fmul    dword ptr [ sinY ]
        fsubp   st(1), st(0)
        fld     dword ptr _x
        fmul    dword ptr [ sinY ]
        fld     dword ptr _z
        fmul    dword ptr [ cosY ]
        faddp   st(1), st(0)
        fstp    dword ptr _z
        fstp    dword ptr _x
;      x:=WorldPoints[i*3 + 0]*cosZ - WorldPoints[i*3 + 1]*sinZ;
;      y:=WorldPoints[i*3 + 0]*sinZ + WorldPoints[i*3 + 1]*cosZ;
;      WorldPoints[i*3 + 0]:=x;
;      WorldPoints[i*3 + 1]:=y;
        fld     dword ptr _x
        fmul    dword ptr [ cosZ ]
        fld     dword ptr _y
        fmul    dword ptr [ sinZ ]
        fsubp   st(1), st(0)
        fld     dword ptr _x
        fmul    dword ptr [ sinZ ]
        fld     dword ptr _y
        fmul    dword ptr [ cosZ ]
        faddp   st(1), st(0)
        fstp    dword ptr _y
        fstp    dword ptr _x
;      y:=WorldPoints[i*3 + 1]*cosX - WorldPoints[i*3 + 2]*sinX;
;      z:=WorldPoints[i*3 + 1]*sinX + WorldPoints[i*3 + 2]*cosX;
;      WorldPoints[i*3 + 1]:=y;
;      WorldPoints[i*3 + 2]:=z;
        fld     dword ptr _y
        fmul    dword ptr [ cosX ]
        fld     dword ptr _z
        fmul    dword ptr [ sinX ]
        fsubp   st(1), st(0)
        fld     dword ptr _y
        fmul    dword ptr [ sinX ]
        fld     dword ptr _z
        fmul    dword ptr [ cosX ]
        faddp   st(1), st(0)
        fstp    dword ptr _z
        fstp    dword ptr _y

 ; przeksztalcenie perspektywiczne ---------------
        fld1
        fld     dword ptr _z
        fadd    dword ptr PerspZ
        fdivp   st(1), st(0)     ; st(0) = st(1) / st(0)

        fst     st(1)            ; st(0) = st(1)
        fmul    dword ptr _x
        fimul   word ptr [ _1000 ]
        fiadd   word ptr [ _160 ]
        fistp   word ptr ds:[di]

        fmul    dword ptr _y
        fimul   word ptr [ _830 ]
        fiadd   word ptr [ _100 ]
        fistp   word ptr ds:[di+2]

        add     di, 4
        add     si, 12
        dec     cx
        jnz     @@Render


;------- teraz narysujemy to wszystko ---------------------
        mov     color, 63

        mov     bp, offset WorldFaces
        mov     di, offset WorldScreen
        mov     cx, IleFacow
 @@Render2:
        push    cx

        mov     bx, ds:[bp]
        shl     bx, 2           ; * 4
        mov     ax, ds:[di + bx]
        mov     _x1, ax
        mov     ax, ds:[di + bx + 2]
        mov     _y1, ax

        mov     bx, ds:[bp+2]
        shl     bx, 2
        mov     ax, ds:[di + bx]
        mov     _x2, ax
        mov     ax, ds:[di + bx + 2]
        mov     _y2, ax

        mov     bx, ds:[bp+4]
        shl     bx, 2
        mov     ax, ds:[di + bx]
        mov     _x3, ax
        mov     ax, ds:[di + bx + 2]
        mov     _y3, ax

        mov     ax, _x3
        sub     ax, _x1
        mov     bx, _y2
        sub     bx, _y1
        imul    bx

        mov     cx, ax

        mov     ax, _x2
        sub     ax, _x1
        mov     bx, _y3
        sub     bx, _y1
        imul    bx

        sub     cx, ax
        or      cx, cx
        js      @@Invisible

; ---- pierwsza linia -----------
        mov     bx, _x1
        mov     ax, _y1
        mov     cx, _x2
        mov     si, _y2

        call    Line
; ---- druga linia --------------
        mov     bx, _x1
        mov     ax, _y1
        mov     cx, _x3
        mov     si, _y3

        call    Line
; ----- trzecia linia ------------

        mov     bx, _x2
        mov     ax, _y2
        mov     cx, _x3
        mov     si, _y3
        call    Line

 @@Invisible:

        add     bp, 6
        pop     cx
        dec     cx
        jnz     @@Render2


        ret
RenderWorld ENDP
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
;        Persp           dd      700.0
        _1000           dw      1000
        _830            dw      830
        PerspZ          dd      1500.0
        _160            dw      160
        _100            dw      100

        _180            dw      180





