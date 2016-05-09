

; ---------------------------------------------------------------------------
; inicjuje generator liczb losowych
Randomize MACRO
        push    0
        pop     gs
        mov     ax, gs:[ 46Ch ]
        mov     Seed, ax
ENDM
; ---------------------------------------------------------------------------
