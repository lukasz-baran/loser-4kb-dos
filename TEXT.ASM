
; ---------------------------------------------------------------------------
PrepareFonts PROC


        mov     ax, 1130h    ; pobieramy adres fontow
        mov     bh, 6
        int     10h

        mov     segFonts, es
        mov     ofsFonts, bp

        mov     es, segFonts
        mov     di, ofsFonts

        mov     ax, cs
        mov     fs, ax    ; fs:[si] <- nasze znaki
        mov     si, offset Fonts

        add     di, 32*16    ; pomijamy pierwsze 32 znaki


        xor     bp, bp       ; tyle znakow wczytamy
 @@convertFonts:

        mov     si, bp
        shl     si, 3        ; mnozymy przez 8
        add     si, offset Fonts


        mov     dx, 16       ; to jest petla dla jednego tylko znaku!
   @@Char:

        mov     cx, 8        ; petla dla jednej tylko linii
   @@Line:
        mov     al, es:[ di ]

        mov     bl, 1
        shl     bl, cl

        and     al, bl
        jz      @@Zero
        mov     al, 64
        jmp     @@noZero
   @@Zero:
        xor     al, al
   @@noZero:                   ; w al mamy juz pixel ktory trzeba postawic

        mov     fs:[si], al

        inc     si

        loop    @@Line

        inc     di

;        sub     si, 8    ; <---- poprawka: patrz na dodawanie w petli !
;        add     si, 768    ; nastepna linia
add si, 768 - 8

        dec     dx
        jnz     @@Char

        inc     bp
        cmp     bp, 32*3     ; bo tyle znakow wczytamy
        jne     @@convertFonts

; teraz zblurujemy nasze fonty.

        mov     si, offset Fonts
        mov     dx, 32*3*8   ; = szerokosc tablicy z fontami
 @@yres:

        mov     cx, 16
 @@xres:

        mov     al, cs:[si - 1]
        add     al, cs:[si + 1]
        add     al, cs:[si - 32*3*8]
        add     al, cs:[si + 32*3*8]
        shr     al, 2
        mov     cs:[si], al

        inc     si
        loop    @@xres

        dec     dx
        jnz     @@yres

; koniec blurowania

        ret
ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; IN:   ds:si - adres lancucha
; OUT:  bx    - dlugosc tego lancucha = ile znakow do '$'
LengthString    PROC
        xor     bx, bx
 @@len:
        cmp     byte ptr ds:[si], '$'
        je      @@FoundEndChar
        inc     si
        inc     bx
        jmp     @@len
 @@FoundEndChar:
        ret
ENDP
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; IN:   es - ekran w ktorym piszemy
; OUT:  nothing
PutText PROC

        mov     ax, 4
        call    Random
        sub     ax, 2
        add     ax, 165
        imul    ax, 320
        mov     di, ax

        mov     ax, 4
        call    Random
        sub     ax, 2
        add     ax, 160
        push    ax

        push    cs
        pop     ds
        cld

; tutaj musi byc kod, ktory na podst. timer'a wyznaczy aktualny napis
; i wpisze do si jego offset
        mov     ax, timer
        shr     ax, 7
        cwd          ; ax -> dx:ax
        mov     bx, 7
        idiv    bx
        ;w dx jest teraz nr napisu
        mov     si, offset Text1
        or      dx, dx
        jz      @@noscan
 @@scan:
   @@subscan:
        lodsb
        cmp     al, '$'
        je      @@jest
        jmp     @@subscan
   @@jest:
        dec     dx
        jnz     @@scan
 @@noscan:
        ; w si jest juz prawidlowy offset!
        mov     adresik, si
        call    LengthString
        shl     bx, 3
        sar     bx, 1

        pop     ax      ; w ax jest teraz pozycja poczatku stringa na ekranie
        sub     ax, bx

        add     di, ax
        mov     ScrAddress, di

        mov     si, adresik

 @@text:

        xor     ax, ax
        mov     al, ds:[si]
        sub     al, 32
        shl     ax, 3                ; mnozenie przez 8

        mov     bp, offset Fonts     ; ds:[bp] <- tablica Fonts
        add     bp, ax

;        mov     di, 180*320 + 50
mov di, ScrAddress
        mov     ax, si
        sub     ax, adresik
        shl     ax, 3
        add     di, ax

        mov     cx, 16               ; es:[di] <- ekran
 @@yfont:

        mov     dx, 8
 @@xfont:

        mov     al, byte ptr ds:[ bp ]
        or      al, al
        jz      @@nothing
        mov     es:[di], al
 @@nothing:
        inc     bp
        inc     di

        dec     dx
        jnz     @@xfont

;        sub     bp, 8                   ; nastepny punkt w tablicy fonts
;        add     bp, 32*3*8
add bp, 32*3*8 - 8

;        sub     di, 8                   ; nastepny punkt na ekranie
;        add     di, 320
add di, 320 - 8

        loop    @@yfont

        add     di, 8

        inc     si                      ; nastepny znak
        cmp     byte ptr ds:[si], '$'
        jne     @@text

        ret
ENDP
; ---------------------------------------------------------------------------

Text1        db      'loser - pure assembly code and$'
Text2        db      'same old tricks you have already seen...$'
Text3        db      'a million times$'
Text4        db      'its just a simple show$'
Text5        db      'cant you see?$'
Text6        db      'and still there is a lot of space...$'
Text7        db      'for stupid text like this one:)$'



