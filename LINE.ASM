
        ClipXMin        equ     0
        ClipXMax        equ     319
        ClipYMin        equ     0
        ClipYMax        equ     199

; ---------------------------------------------------------------------------
Line    PROC
        pushad

        mov     es, VScreen

        cmp     ax, si
        jbe     @NO_SWAP    ; always draw downwards
        xchg    bx, cx
        xchg    ax, si
 @NO_SWAP:

        sub     si, ax      ; yd (pos) = y2 - y1
        sub     cx, bx      ; xd (+/-) = x2 - x1
        cld                 ; set up direction flag
        jns     @H_ABS
        neg     cx          ; make x positive
        std
 @H_ABS:

        mov     di, 320
        mul     di          ;
        mov     di, ax
        add     di, bx      ; di = y1*320 + x1
        or      si, si
        jnz     @NOT_H

 ; horizontal line
        mov     al, color
        inc     cx
        rep     stosb
        jmp     @EXIT

 @NOT_H:
        or      cx,cx
        jnz     @NOT_V

 ; vertical line
        cld
        mov     al,color
        mov     cx,si
        inc     cx
        mov     bx, 320-1
 @VLINE_LOOP:
        stosb
        add     di, bx
        loop    @VLINE_LOOP
        jmp     @EXIT

 @NOT_V:
        cmp     cx, si      ; which is greater distance?
        lahf                ; then store flags (ah = mniej znaczacy bajt znacznikow)
        ja      @H_IND
        xchg    cx, si      ; swap for redundant calcs
 @H_IND:
        mov    dx, si       ; inc2 (adjustment when decision var rolls over)
        sub    dx, cx
        shl    dx, 1
        shl    si, 1        ; inc1 (step for decision var)
        mov    bx, si       ; decision var, tells when we need to go secondary direction
        sub    bx,cx
        inc    cx
        push   bp           ; need another register to hold often-used constant
        mov    bp,320
        mov    al,color
        sahf                ; restore flags
        jb      @DIAG_V
; mostly-horizontal diagonal line
        or      bx,bx       ; set flags initially, set at end of loop
                            ; for other iterations
 @LH:
        stosb               ; plot and move x, doesn't affect flags
        jns     @SH         ; decision var rollover in bx?
        add     bx,si
        loop    @LH         ; doesn't affect flags
        jmp     @X
 @SH:
        add     di,bp
        add     bx,dx
        loop    @LH         ; doesn't affect flags
        jmp     @X
 @DIAG_V:
; mostly-vertical diagonal line
        or      bx,bx       ; set flags initially, set at end of loop
                            ; for other iterations
 @LV:
        mov     es:[di],al  ; plot, doesn't affect flags
        jns     @SV         ; decision var rollover in bx?
        add     di,bp       ; update y coord
        add     bx,si
        loop    @LV         ; doesn't affect flags
        jmp     @X
 @SV:
        scasb               ; sure this is superfluous but
                            ; it's a quick way to inc/dec x coord!
        add     di,bp       ; update y coord
        add     bx,dx
        loop    @LV         ; doesn't affect flags
 @X:
        pop     bp


 @EXIT:
        popad
        ret
Line    ENDP
; ---------------------------------------------------------------------------




