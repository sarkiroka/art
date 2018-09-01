org 256
	jmp start
;konstansok
	objects_intersect_methods:
		dw egyik
		dw masik
		dd 0
	camera_screen_distance: dw 200
nop
nop
nop
nop
egyik:
	mov al,'X'
	call dbg
	ret
masik:
	mov al,'Y'
	call dbg
	ret

start:
;minden képpontra sorban
next_point:
	mov ah,1								; kilépünk ha nyomtak egy gombot
	int 16h									; keyboard check
	jz next_point_calculation				; ha nincs gomb, akkor nincs gond
	int 20h									; kilépés
next_point_calculation:
	;mov al,'B'								;debug
	;call dbg
	inc word ptr point_x					; vizszintesen következő pont
	cmp word ptr point_x,320				; sor végén vagyunk?
	jnz kovetkezo_keppont_ok				; ha nem akkor minden oké
	mov word ptr point_x,0					; sor végén kinullázzuk az x koordinátát
	inc word ptr point_y					; függőlegesen következő képpont
	cmp word ptr point_y,240				; a képernyő végén vagyunk-e
	jnz kovetkezo_keppont_ok				; ha nem akkor minden oké
	mov word ptr point_y,0					; ha kész vagyunk a képernyővel, akkor felmegyünk a tetejébe és
	inc word ptr camera_angle				; és a kamerát arrébb forgatjuk
	cmp word ptr camera_angle,360			; kamera körbeért?
	jnz kovetkezo_keppont_ok				; ha nem ért körbe akkor minden oké
	mov word ptr camera_angle,0				; ha körbeért akkor normalizáljuk
kovetkezo_keppont_ok:
	;mov al,'K'								; debug
	;call dbg

;egyenest számitani a kamerából a képponton át
	;z nem változik alapból, csak x-y mentén forog a camera_angle alapján. ebből a normálvektor 3d-s x-y koordinátái
	;nx=sin(camera_angle)
	;ny=cos(camera_angle)
	;ezt kell korrigálni az adott képpont 2d-s x-y koordinátáival.
	;vizszintes szög beta, függőleges szög gamma
	;beta=atan(point_x/camera_screen_distance)+camera_angle
	;gamma=atan(point_y/camera_screen_distance)
	;ebből a sugár 3d-s normálvektorának 3 koordinátája
	;x=sin(beta)*cos(gamma)
	;y=cos(beta)*cos(gamma)
	;z=sin(gamma)
	
;minden tárgyra
	mov byte ptr current_object,-1			; inicializáljuk a tárgymutatót
	next_object:							; következő tárgy
;	mov al,'n'								; debug
;	call dbg
	inc byte ptr current_object				; vesszük a következő tárgymutatót (ami egy relativ offset)
	xor bh,bh								
	mov bl,[current_object]
	shl bx,1								; *2
	add bx,objects_intersect_methods		; rendes offsetté alakitjuk
	mov bx,[bx]								; betöltjük a metszéspontszámító fv cimét
	cmp bx,0								; nincs ilyen cím?
	jz next_point							; ha nincs több cim akkor jöhet a következő képpont
;metszéspontot számitani a tárggyal és a sugárral
	mov word ptr intersect_distance,0ffffh	; inicializáljuk a sugarat a lehető legnagyobb értékre
	call near bx							; meghívjuk a metszéspontszámítót
	;ha a d távolság kisebb, akkor ezt eltároljuk
	cmp word ptr intersect_distance, 0ffffh	; megnézzük hogy volt-e metszéspont?
;ha van d távolság, akkor az kirajzoljuk a képre
	jz next_object							; nem volt, jöhet a következő metszéspontszámító
	call plot								; volt, rajzolni kell TODO ide kell a szín
	jmp next_object							; következő metszéspontszámító

plot:
	mov al,'P'
	call dbg
	ret
dbg:
	mov ah,0eh
	mov bx,1
	mov cx,1
	int 10h
	ret

;változók
	point_x: dw 0
	point_y: dw 0
	camera_angle: dw 0
	current_object: db 0
	intersect_distance: dw ?
