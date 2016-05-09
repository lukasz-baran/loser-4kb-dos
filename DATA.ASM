
IlePalet equ 5

; tutaj same dane 'zerowe' do kazdej procki

ZeroData:
; ----------- dane do pliku ZIEMIA.ASM ------------
angle           dw      0
WorldPoints     dd      3*5*12 + 2*3      dup(0)
WorldFaces      dw      (8*12+2*12)*3     dup(0)
WorldScreen     dw      (5*12+2)*2        dup(0)  ; wspolrzedne punktow
                          ; z WorldPoints przeksztalcone na ekran
_x1             dw      0
_y1             dw      0
_x2             dw      0
_y2             dw      0
_x3             dw      0
_y3             dw      0

sinX            dd      0
cosX            dd      0
sinY            dd      0
cosY            dd      0
sinZ            dd      0
cosZ            dd      0

_sin            dd      0
_cos            dd      0

        _x              dd      0
        _y              dd      0
        _z              dd      0
        angleX          dw      0
        angleY          dw      0
        angleZ          dw      0

;---------  dane do pliku LINE.ASM ---------------------
        color  db      0

        wsk1   dw  0
        wsk2   dw  0
        podpr  dw  0

;------------ dane do pliku procs.asm -----------------
count           dw              0
ScaleXArray     dw              320  dup(0)
ScaleYArray     dw              200  dup(0)
dummyWord       dw              0

ktora_paleta    dw              0

Seed            dw              0

aktualPal       db              768  dup(0)

Palety          db              3*64*IlePalet  dup(0)
; tutaj bedziemy przechowywac wszystkie palety, po kolei o tak:
;   paleta_szara              db 3*64 dup(0)
;   paleta_czerwona           db 3*64 dup(0)
;   paleta_niebieska itd......
; tylko 64 kolory sa wykorzystywane !!!!

;---------- dane do pliku text.asm --------------------

adresik      dw      0

segFonts   dw  0
ofsFonts   dw  0

ScrAddress   dw      0

DummyTable1 db  32*3*8    dup(0)  ; zeby nie bylo bledow przy blurowaniu fontow
Fonts       db  32*3*8*16 dup(0)  ; <--- tutaj przechowujemy nasze fonty
DummyTable2 db  32*3*8    dup(0)  ; zeby nie bylo bledow przy blurowaniu fontow

;---------- dane do pliku tunnel.asm --------------------

        TempSin         dw      0
        Sinus           db      258 dup(0)

        tempX           dd      0
        tempY           dd      0
        tempW           dw      0
        Pi              dd      0
        DummySth        dd      0

;---------- dane do pliku flares.asm --------------------

xEkr            dw              0
yEkr            dw              0
zOdl            dw              0
TempF           dw              0

Flary           dd  4*IleFlar   dup(0)  ; tablica z pozycjami swiatelek w 3d

Flara           db  32*32       dup(0)

        delta           dd      0
        FlareSize       dw      0

        Licznik         dw      0
