IDEAL
MODEL small
STACK 100h
p186
include "bmp.asm"

DATASEG
sape bitmap {ImagePath = "bar.bmp"}
bgpic bitmap {ImagePath = "game4000.bmp"}
back bitmap {ImagePath = "op2.bmp"}
rules bitmap {ImagePath = "ruler.bmp"}
pic_player1 bitmap {ImagePath = "p1_win.bmp"}
pic_player2 bitmap {ImagePath = "p2_win.bmp"}
press_1 bitmap {ImagePath = "space_1.bmp"}
press_2 bitmap {ImagePath = "space_2.bmp"}
num_1 bitmap {ImagePath = "num1.bmp"} 
num_2 bitmap {ImagePath = "num2.bmp"}
num_3 bitmap {ImagePath = "num3.bmp"}
num_4 bitmap {ImagePath = "num4.bmp"}
num_5 bitmap {ImagePath = "num5.bmp"}
num_6 bitmap {ImagePath = "num6.bmp"}
squre_size equ 7 ; משתנה קבוע של גודל השחקן
; --------------------------

; המיקום של השחקן במערך משבצות  
player1_index_x_in_arry dw 0 
player1_index_y_in_arry dw 0
player2_index_x_in_arry dw 0
player2_index_y_in_arry dw 0

player_x dw 0 ; האיקס של השחקן
player_y dw 0 ; הווי של השחקן
inc_cube dw 0 ; להוסיף עוד הזזה למקרה שהשחקן נוחת על סולם או נחש
player1_squre db 0 ; המשבצת של השחקן
player2_squre db 0 ; המשבצת של השחקן
count_in_arry dw 0 ; ספירה במערך הצבעים של הדמיות
next_player db 0 ; סופר כל תור
which_player db 0 ; השחקן הבא
random_num dw 0 ; מספר רנדומלי
all_white db 1 ; לצורך מחיקה של השחקן
win_status db 0 ; בודק אם השחקן הגיע למשבצת האחרונה
; האיקס והווי הקודמים של השחקן
old_player1_x dw, 0 
old_player1_y dw, 0
old_player2_x dw, 0
old_player2_y dw, 0

; --------------------------
; מערך הצבעים של שחקן 1
pixel_player1_arry db 0ffh,02h,02h,02h,02h,02h,0ffh   
                   db 0ffh,02h,02h,02h,02h,02h,0ffh   
                   db 0fh,0fh,0fh,0fh,0fh,0fh,0fh    
                   db 0fh,0fh,09h,09h,09h,0fh,0fh   
                   db 0fh,0fh,09h,09h,09h,0fh,0fh
					db 0fh,0fh,09h,09h,09h,0fh,0fh
					db 0fh,0fh,09h,09h,09h,0fh,0fh

;  מערך הצבעים של שחקן 2
pixel_player2_arry db 04h,04h,04h,04h,04h,04h,04h    
                   db 04h,04h,0ffh,04h,0fh,0fh,04h   
                   db 04h,04h,0ffh,04h,0fh,0fh,04h
					db 04h,04h,0ffh,04h,0fh,0fh,04h				   
                   db 04h,04h,0ffh,04h,0fh,0fh,04h  
                   db 04h,04h,0ffh,04h,0fh,0fh,04h  
				   db 04h,04h,04h,04h,0fh,0fh,04h
; מערך ה איקס של כל משבצת במערך
arry_x dw 311, 270, 228, 181, 134, 84, 39
	dw 39, 85, 134, 163, 229, 268, 310
	dw 311, 270, 228, 152, 134, 84, 39
	dw 39, 85, 134, 181, 229, 268, 310
	dw 313, 270, 228, 181, 134, 84, 39
	dw 39, 85, 134, 181, 229, 268, 313
	dw 313, 270, 228, 181, 134, 84, 39
	dw 39, 77, 134, 181, 229, 268, 310
	dw 311, 270, 228, 181, 134, 62, 39
	dw 39, 39, 39, 39, 39, 39, 39  ; שורות אלה נועדו למנוע התקדמות אחרי שהשחקן מגיע למשבצת הסופית      
; מערך הווי של כל שורה במערך	   
arry_y dw 179, 162, 144 , 125, 104, 82, 60, 41,21,21

; המערכים של האיקס והווי של הסולמות ונחשים
; שורה למעלה זה המקום שהם הגיעו אליו ושורה למטה זה לאן צריך לשגר אותם
arry_x_index_ledder dw 4, 54, 92
	dw 32, 82, 120

arry_y_index_ledder dw 0 , 6, 12
	dw 4, 10, 16
	
arry_x_index_snake dw 48, 94, 116
	dw 20, 66, 88

arry_y_index_snake dw 6, 12, 16
	dw 2, 8, 12






	



CODESEG
proc do_sound ; קריאה לסאונד עם תנאי שלא יהיה סאונד שיגיע למשבצת הניצחון
	pusha
    cmp [which_player], 1
    je first16
    jmp second16
first16:
    cmp [player1_index_x_in_arry], 124 ; בדיקה אם הגיע לקצה
    jna return3
	jmp exit20
second16:
    cmp [player2_index_x_in_arry], 124
    jna return3
exit20:
	popa
    ret
return3:
	call PlayMoveSound
    popa
    ret
endp do_sound
proc PlayMoveSound ; סאונד הזזה של משבצת
	pusha
    ; הפעל את הרמקול
    in     al, 61h
    or     al, 03h
    out    61h, al

    ; הגדר את התדר דרך פורט 43h
    mov    al, 0B6h
    out    43h, al

    ; צליל דו
    mov    ax, 053Bh
    out    42h, al        ; שלח את הבית הנמוך (3Bh)
    mov    al, ah
    out    42h, al        ; שלח את הבית הגבוה (05h)

    ; השהייה קצרה כדי שהצליל יהיה מורגש אך מהיר
    mov    cx, 2000      
delay1:
    loop delay1

    ; כבה את הרמקול
    in     al, 61h
    and    al, 0FCh
    out    61h, al
	popa
    ret
endp PlayMoveSound
proc ResetGame ; איפס כל המשתנים
; איפוס כל המשתנים
	pusha
	mov [player1_index_x_in_arry], 0
	mov [player1_index_y_in_arry], 0
	mov [player2_index_x_in_arry], 0
	mov [player2_index_y_in_arry], 0
	mov [player1_squre], 0
	mov [player2_squre], 0
	mov [next_player], 0
	mov [which_player], 0
	mov [random_num], 0
	mov [all_white], 1
	mov [win_status], 0
	mov [old_player1_x], 0
	mov [old_player1_y], 0
	mov [old_player2_x], 0
	mov [old_player2_y], 0
	mov [inc_cube], 0
	popa
	ret
endp ResetGame
proc opening ; מסך פתיחה / חוקים
    pusha

opening_click_loop:
    mov si, offset back
    display_BMP si, 0, 0          ; מציג את תמונת הפתיחה

click_loop:
    mov ax, 1h
    int 33h                       ; אתחול העכבר
    mov ax, 3h
    int 33h                       ; בדיקת מצב העכבר (כפתורים וקואורדינטות)
    cmp bx, 1
    jne click_loop                ; אם לא נלחץ כפתור שמאלי, ממשיך לבדוק

    shr cx, 1                     ; קנה מידה (המסך מוקטן פי 2)

    ; בדיקה אם נלחץ כפתור "התחל"
    cmp cx, 234
    jb check_rules
    cmp dx, 150
    jb check_rules
    cmp cx, 295
    ja check_rules
    cmp dx, 180
    ja check_rules

    call PlayMoveSound
    mov ax, 2
    int 33h                       ; שחרור כפתור העכבר
    popa
    ret

check_rules:                      ; בדיקה אם נלחץ כפתור "חוקים"
    cmp cx, 25
    jb check_exit
    cmp cx, 65
    ja check_exit
    cmp dx, 150
    jb check_exit
    cmp dx, 182
    ja check_exit

    call PlayMoveSound
    jmp rules_click_loop          ; מעבר לתצוגת החוקים

check_exit:                       ; בדיקה אם נלחץ כפתור יציאה
    cmp cx, 60
    ja no_right_click
    cmp dx, 25
    ja no_right_click

    call PlayMoveSound
    popa
    mov ax, 2
    int 10h                       ; מעבר למצב טקסט
    mov ax, 4c00h
    int 21h                       ; סיום התוכנית

rules_click_loop:
    mov ax, 2
    int 33h                       ; שחרור כפתור העכבר
    mov si, offset rules
    display_BMP si, 0, 0          ; מציג את תמונת החוקים

wait_for_click_release:
    mov ax, 3h
    int 33h
    cmp bx, 0
    jne wait_for_click_release

wait_for_click:                   ; מחכה ללחיצה חדשה
    mov ax, 1h
    int 33h                       ; אתחול העכבר
    mov ax, 3h
    int 33h                       ; בדיקת מצב העכבר
    cmp bx, 1
    jne wait_for_click

    shr cx, 1                     ; קנה מידה

    cmp cx, 275
    jb wait_for_click
    cmp dx, 32
    ja wait_for_click
    cmp cx, 310
    ja wait_for_click
    cmp dx, 10
    jb wait_for_click


    mov ax, 2
    int 33h                       ; שחרור כפתור העכבר
    call PlayMoveSound
    jmp opening_click_loop        ; חזרה למסך הפתיחה

no_right_click:
    jmp click_loop                ; לחיצה לא תקפה - מתעלם ממנה
endp opening
proc InitializeGame ; התחלת משחק

	pusha                          
	mov  si, offset bgpic          
	display_BMP si,0,0             ; מציג את תמונת הרקע של המשחק(לוח)

print_player1:
	mov si, [player1_index_x_in_arry]  
	mov ax, [arry_x + si]              ; מקבל את האיקס של השחקן הראשון לפי האינדקס במערך
	sub ax, 7                          ; מקזז 5 פיקסלים לשם התאמה גרפית
	mov [player_x], ax                 
	mov si, [player1_index_y_in_arry]  
	mov ax, [arry_y + si]              ; מקבל את הווי של השחקן במערך לפי האינדקס
	mov [player_y], ax                
	mov [which_player], 1             ; מגדיר שהשחקן שמוצג כעת הוא שחקן 1
	call printer_squre                ; מציג את הדמות של השחקן הראשון במיקום הנוכחי

	popa                              

print_player2: ;הדפסה של השחקן השני(בדיוק אותו הדבר כמו הראשון)
	pusha                             

	mov si, [player2_index_x_in_arry] 
	mov ax, [arry_x + si]             
	mov [player_x], ax                

	mov si, [player2_index_y_in_arry] 
	mov ax, [arry_y + si]             
	mov [player_y], ax                

	mov [which_player], 2             
	call printer_squre                

	mov [which_player], 1             ; מחזיר לשחקן הראשון כי הוא מתחיל את המשחק
	popa                              

	ret                               
endp InitializeGame
proc mov_player ; הזזה של השחקן
	pusha 
	mov cx, [random_num]           ; שומר את תוצאת הקובייה ברגיסטר CX
	call print_cube                ; מציג את הקובייה על המסך
	add cx, [inc_cube]             ; מוסיף לקוביה אם השחקן עלה על סולם או נחש(בשביל שהתור הראשון של הזזה לא יחשב)
	call which_player_isnext       ; בודק מי השחקן הבא בתור
	cmp [which_player], 1         ; אם זה שחקן 1
	je mov_loop1                   ; עבור לתנועת שחקן 1
	jmp mov_loop2                  ; אחרת עבור לתנועת שחקן 2


; תנועת שחקן 1:
mov_loop1:
	mov si, [old_player1_x]        ; מיקום קודם בציר X
	mov ax, [arry_x + si]
	sub ax, 7
	mov [player_x], ax            

	mov si, [old_player1_y]        ; מיקום קודם בציר Y
	mov ax, [arry_y + si]
	mov [player_y], ax

	mov [which_player], 1
	mov [all_white], 2           
	call printer_squre            ; על ידי ציור ריבוע לבן  הדמות   מחיקה של הדמות הקודמת                      
	mov [all_white], 1            ; מחזיר למערך צבעים של השחקנים

	call inc_index                ; מעלה את המיקום בלוח
	call do_sound
	call save_Coordinates

	mov si, [player1_index_x_in_arry]
	mov ax, [arry_x + si]
	sub ax, 7
	mov [player_x], ax

	mov si, [player1_index_y_in_arry]
	mov ax, [arry_y + si]
	mov [player_y], ax

	mov [which_player], 1
	call printer_squre            ; מציג את השחקן במיקום החדש

	call dealy                    ; השהיה בין צעדים 
	loop mov_loop1                ;חוזר לפי מספר צעדים (CX)

	call save_Coordinates ; שומר את המיקום 

	call ledders_and_snake        ; בודק אם נחת על סולם או נחש
	popa                          
	ret                             

; תנועת שחקן 2:
mov_loop2:
	mov si, [old_player2_x]
	mov ax, [arry_x + si]
	mov [player_x], ax

	mov si, [old_player2_y]
	mov ax, [arry_y + si]
	mov [player_y], ax

	mov [which_player], 2
	mov [all_white], 2
	call printer_squre           

	mov [all_white], 1

	call inc_index                
	call do_sound
	call save_Coordinates

	mov si, [player2_index_x_in_arry]
	mov ax, [arry_x + si]
	mov [player_x], ax

	mov si, [player2_index_y_in_arry]
	mov ax, [arry_y + si]
	mov [player_y], ax

	mov [which_player], 2
	call printer_squre           
	call dealy                    
	loop mov_loop2                

	call save_Coordinates

	call ledders_and_snake        
	popa
	ret
endp mov_player
proc save_Coordinates ; שומר את המיקום שלך על הלוח
	pusha
	cmp [which_player],1 ; בודק על איזה שחקן אנחנו עובדים
	je first13
	jmp second13
	
first13:
	mov bx, [player1_index_x_in_arry]
	mov [old_player1_x], bx       ; שומר מיקום חדש כישן (לפעם הבאה)
	mov bx, [player1_index_y_in_arry]
	mov [old_player1_y], bx
	popa
	ret
second13:
	mov bx, [player2_index_x_in_arry]
	mov [old_player2_x], bx
	mov bx, [player2_index_y_in_arry]
	mov [old_player2_y], bx
	popa
	ret
endp save_Coordinates
proc inc_index ; העלה של איקס וווי
	pusha                          ; שומר את הרגיסטרים

	cmp [which_player], 1         ; בדיקה אם זה שחקן 1
	je first                     
	jmp second                    

first:
	add [player1_index_x_in_arry], 2   ; האינדס מקבל 2, המערך משבצות הוא בית
	inc [player1_squre]                ; מעלה את מספר הריבועים שעבר
	mov al, [player1_squre]
	mov bl, 7                          ; מחלק ב־7 – יש 7 עמודות בשורה
	xor ah, ah
	div bl                             ; 
	cmp ah, 0
	je inc_y1                          ; אם השארית היא 0, צריך לעלות שורה
	jmp stop

inc_y1:
	inc [player1_index_y_in_arry]      ; מעלים את 2, המערך  הוא בית
	inc [player1_index_y_in_arry]       
	jmp stop

second:
	add [player2_index_x_in_arry], 2  
	inc [player2_squre]               
	mov al, [player2_squre]
	mov bl, 7                         ; גם כאן, שורה = 7 תאים
	xor ah, ah
	div bl
	cmp ah, 0
	je inc_y2
	jmp stop

inc_y2:
	inc [player2_index_y_in_arry]
	inc [player2_index_y_in_arry]
	jmp stop

stop:
	popa
	ret
endp inc_index
proc which_player_isnext ; בודק מי השחקן הבא
	pusha
	mov al, [next_player]        
	and al, 1                     ; בודק את הביט התחתון (0 = זוגי = שחקן 1)
	je first3                     ; אם 0 – זה שחקן 1
	jmp second3                   ; אם 1 – זה שחקן 2

first3:
	mov [which_player], 1         ; קובע שהשחקן בתור הוא 1
	inc [next_player]             
	popa
	ret

second3:
	mov [which_player], 2         ; קובע שהשחקן בתור הוא 2
	inc [next_player]             ; 
	popa
	ret
endp which_player_isnext
proc ledders_and_snake ; משנה את האיקס והווי של השחקן אם עלה על נחש או על סולם
    pusha
    mov al, [next_player]
    and al, 1               ; בדיקה אם AL זוגי או אי זוגי => קובע איזה שחקן בתור
    je first4                
    jmp second4            

; ---- שחקן 1 ----
first4:
    mov cx, 3               ; 3 סולמות
    mov si, 0
check_loop_ledder:
    mov bx, [player1_index_x_in_arry]
    cmp [arry_x_index_ledder+si], bx
    jne next_ledder_check
    mov bx, [player1_index_y_in_arry]
    cmp bx, [arry_y_index_ledder+si]
    je change_ledder_1     ; אם גם X וגם Y תואמים — שחקן עומד על סולם
next_ledder_check:
    add si, 2              ; עבור לסולם הבא
    loop check_loop_ledder

    mov cx, 3              ; 3 נחשים
    mov si, 0
check_loop_snake:
    mov bx, [player1_index_x_in_arry]
    cmp [arry_x_index_snake+si], bx
    jne next_snake_check
    mov bx, [player1_index_y_in_arry]
    cmp bx, [arry_y_index_snake+si]
    je change_snake_1      ; אם גם X וגם Y תואמים — שחקן עומד על ראש נחש
next_snake_check:
    add si, 2              ; עבור לנחש הבא
    loop check_loop_snake
    mov [inc_cube], 0      ; לא זזנו — אין סולם/נחש
    jmp exit2

change_ledder_1:
    mov [inc_cube], 1      ; כן זזנו
    mov bx, [arry_x_index_ledder + si + 6] ; 2*3 = 6 לפי האינדקס
    mov [player1_index_x_in_arry], bx
    mov bx, [arry_y_index_ledder + si + 6]
    mov [player1_index_y_in_arry], bx
    jmp exit2

change_snake_1:
    mov [inc_cube], 1
    mov bx, [arry_x_index_snake + si + 6] ; 2*3 = 6 לפי האינדקס
    mov [player1_index_x_in_arry], bx
    mov bx, [arry_y_index_snake + si + 6]
    mov [player1_index_y_in_arry], bx
    jmp exit2

; ---- שחקן 2 ----
second4:
    mov cx, 3
    mov si, 0
check_loop_ledder2:
    mov bx, [player2_index_x_in_arry]
    cmp [arry_x_index_ledder+si], bx
    jne next_ledder_check2
    mov bx, [player2_index_y_in_arry]
    cmp bx, [arry_y_index_ledder+si]
    je change_ledder_2
next_ledder_check2:
    add si, 2
    loop check_loop_ledder2

    mov cx, 3
    mov si, 0
check_loop_snake2:
    mov bx, [player2_index_x_in_arry]
    cmp [arry_x_index_snake+si], bx
    jne next_snake_check2
    mov bx, [player2_index_y_in_arry]
    cmp bx, [arry_y_index_snake+si]
    je change_snake_2
next_snake_check2:
    add si, 2
    loop check_loop_snake2
    mov [inc_cube], 0
    jmp exit2

change_ledder_2:
    mov [inc_cube], 1
    mov bx, [arry_x_index_ledder + si + 6]
    mov [player2_index_x_in_arry], bx
    mov bx, [arry_y_index_ledder + si + 6]
    mov [player2_index_y_in_arry], bx
    jmp exit2

change_snake_2:
    mov [inc_cube], 1
    mov bx, [arry_x_index_snake + si + 6]
    mov [player2_index_x_in_arry], bx
    mov bx, [arry_y_index_snake + si + 6]
    mov [player2_index_y_in_arry], bx
    jmp exit2

exit2:
    popa
    ret
endp ledders_and_snake
proc printer_squre ; מצייר את השחקן
    pusha
    mov [count_in_arry], 0
    mov cx, squre_size      ; גודל הריבוע
abrt:
    push [player_x]
    push cx
    call line                 ; מדפיס שורה אופקית
    pop cx
    pop [player_x]
    dec [player_y]            ; שורה אחת למעלה
    loop abrt
    popa
    ret
endp printer_squre
proc line ; שורה של שחקןר
    mov cx, squre_size      ; אורך שורה
abr:
    push cx
    call one_dot              ; הדפס נקודה אחת
    inc [player_x]
    inc [count_in_arry]
    pop cx
    loop abr
    ret
endp line
proc one_dot ; ציור הפיקסל
    pusha
    mov bh, 0h
    mov cx, [player_x]
    mov dx, [player_y]
    cmp [all_white], 2
    je white
    cmp [which_player], 1
    je one
    jmp two

white:
    mov al, 0ffh              ; לבן
    jmp continue
one:
    mov si, [count_in_arry]
    mov al, [byte ptr pixel_player1_arry + si]
    jmp continue
two:
    mov si, [count_in_arry]
    mov al, [byte ptr pixel_player2_arry + si]
    jmp continue

continue:
    mov ah, 0ch               ;  כתיבת פיקסל למסך
    int 10h
    popa
    ret
endp one_dot
proc dealy ; השאייה
half_second_delay:
    pusha

    mov ax, 0040h
    mov es, ax
    mov bx, [es:006Ch]    ; קריאת ערך הטיימר הנוכחי
    add bx, 9             ; מוסיפים 9 טיקים = חצי שנייה

wait_loop:
    mov ax, [es:006Ch]    ; קוראים שוב את הטיימר
    cmp ax, bx
    jb wait_loop         ; אם לא עברו 9 טיקים – המשך להמתין

    popa
    ret
endp dealy
proc win_check ; בודק אם שחקן ניצח
    pusha
    cmp [which_player], 1
    je first5
    jmp second5
first5:
    cmp [player1_index_x_in_arry], 122 ; בדיקה אם הגיע לקצה
    jna stop2
    mov si, offset pic_player1 ; תמונת ניצחון
    display_BMP si,0,0
    mov cx, 10
dealy_loop: ; דיילי קטן בשביל שנראה את התמונה
    call dealy
    loop dealy_loop
    popa
    mov [win_status], 1
    ret
second5:
    cmp [player2_index_x_in_arry], 122
    jna stop2
    mov si, offset pic_player2
    display_BMP si,0,0
    mov cx, 10
dealy_loop2:
    call dealy
    loop dealy_loop2
    popa
    mov [win_status], 1
    ret
stop2:
    mov [win_status], 0
    popa
    ret
endp win_check
proc print_cube ; מצייר את מספר הקוביה
    cmp [random_num], 1
    je num11
    cmp [random_num], 2
    je num22
    cmp [random_num], 3
    je num33
    cmp [random_num], 4
    je num44
    cmp [random_num], 5
    je num55
    cmp [random_num], 6
    je num66
num11:
    mov si, offset num_1
    display_BMP si,280,180
    jmp stop5
num22:
    mov si, offset num_2
    display_BMP si,280,180
    jmp stop5
num33:
    mov si, offset num_3
    display_BMP si,280,180
    jmp stop5
num44:
    mov si, offset num_4
    display_BMP si,280,180
    jmp stop5
num55:
    mov si, offset num_5
    display_BMP si,280,180
    jmp stop5
num66:
    mov si, offset num_6
    display_BMP si,280,180
    jmp stop5
stop5:
    xor si, si
    ret
endp print_cube
proc random_and_exit ; בודק אם לחץ רווח או esp
    pusha
	clear_keyboard_buffer:
    mov ah, 01h         ; בדיקה אם יש תו במקלדת
    int 16h
    jz wait_for_enter    ; אם אין, תצא מהלולאה
    mov ah, 00h         ; אם יש, תקרא אותו כדי לנקות
    int 16h
    jmp clear_keyboard_buffer
wait_for_enter:
	cmp [next_player], 0 ; אם זה התור הראשון, תקפוץ לשחקן הראשון
	je first9
	cmp [which_player], 2        ; בדיקה אם זה שחקן אחד(כאן הבדיקה היא הפוכה בגלל שאנחנו קוראים לפעולה הזאת לפי שאנחנו מזיזים את השחקן)
	je first9                     
	jmp second9                   
first9:
	mov si, offset press_1 ;תמונה של תלחץ על הכפתור
    display_BMP si,0,181
	jmp cont11
second9:
	mov si, offset press_2 ;תמונה של תלחץ על הכפתור
    display_BMP si,0,181
	jmp cont11
cont11:

	mov ah, 00h        ; מחכה להקשה
	int 16h
    cmp al, 27         ; בדיקה אם זה ESC (ASCII 27)
	je exit5
    cmp al, 32         ; בדיקה אם זה רווח (ASCII 32)
    jne wait_for_enter

	
generate_random:
	
    mov ax, 40h
    mov es, ax
    mov dx, [es:6Ch]   ; קריאת הטיימר של BIOS
    mov ax, dx
    xor dx, dx
    mov cx, 6
    div cx             ; ax / 6, השארית ב־dx
    inc dx             ; dx = 0–5 => dx = 1–6
    mov [random_num], dx
	mov  si, offset sape
	display_BMP si,0,179
    popa
    ret
exit5:
	popa
	mov ax, 2
    int 10h
    mov ax, 4c00h
    int 21h
endp random_and_exit




start:
    mov ax, @data
    mov ds, ax
	mov ax, 13h
	int 10h
; --------------------------
call ResetGame ; איפוס כל המשתנים
call opening ; התחלה
call InitializeGame ; התחלת המשחק
start_loop: ;לולאת המשחק
	call random_and_exit
    call mov_player
	call win_check
	cmp [win_status], 1
    jne start_loop ; אם השחקן לא ניצח, תקפוץ בחזרה
	jmp start ; אם השחקן ניצח, תחזור להתחלה
; --------------------------

exit:
    mov ah,00h
    int 16h
    ; לסיום – חזרה למוד טקסט
    mov ax, 2
    int 10h
    mov ax, 4c00h
    int 21h
END start