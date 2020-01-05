INCLUDE Irvine32.inc

alpha struct 
	char byte ?
	freq byte ?
alpha ends
 
filter struct 
	index byte ?
	char byte ?
	freq byte ?
filter ends

huffman struct
	nodeindex byte ?
	char byte ?
	right byte 0
	left byte 0
	sumofnode byte 0
huffman ends

compress struct

	char byte 0
	code byte 50 dup(?)

compress ends


.DATA
	startPoint byte "Please Choose Compression(c) Or Decompressio(d) ? ",0
	string byte 600 dup(?)
	infile byte "input.txt",0
	outfile byte "output.txt",0
	inHandle dword ?
	arr alpha 26 dup({?,?})
	count byte 97
	len byte 0
	charlen byte ?
	chars filter 100 dup({0,0,0})
	tree huffman 100 dup({0,0,0,0,0})
	x byte 1
	min byte 0
	minchar byte ?
	minindex1 byte ?
	min2 byte 0
	minchar2 byte ?
	minindex2 byte ?
	code compress 28 dup({?,{?}})
	i byte 0
	ind byte 0
	indt byte ?
	enc byte 870 dup(?),0
	

	decom byte "0110101",0
	Decompress_word byte 20 dup(0)
	decompressFile BYTE "decompress.txt",0 
	inHandledecom dword ?
	de dword 0
	cnt dword 1
	ten dword 10
	String2 byte 80 dup(?)
	arr2 dword 100 dup(?)
	number dword 100 dup(?)
	chars2 byte 100 dup(?)
	numberOfChars byte 0
	numberOfNumbers byte 0
	distinct alpha 20 dup({0,0})

.code
main PROC


	mov edx , offset startPoint
	call writestring
	call readchar
	call crlf
	cmp al , 'd'
	je decomp
	call compOp
	jmp endSession
	decomp:
	;;;;;;;;;;;; Decompression ;;;;;;;;;;;;;;;;;;;

	mov edx , offset decom
	call writestring
	call crlf

	mov edx , offset decompressFile
	call openinputfile
	mov inHandledecom , eax 
	mov edx , offset String2
	mov ecx , lengthof String2
	call readfromfile
	mov eax, inHandledecom 
	call closefile

	call convert

	call Extract

	mov dl , numberOfChars
	mov len ,dl

	mov esi , offset distinct
	mov edi , offset chars
	mov edx , offset tree
	movzx ecx , numberOfChars
	call fill_data
	movzx ecx , len
	lll:
		push ecx
			call GetMin
			call ChangeChar
			call GetMin2
			call ChangeChar2
			call Append_Chars
			call Append_tree
			inc x 
			inc len	
		pop ecx
	Loop lll
	call Remove

		
	call Traverse

	call Display_huffman
	
	mov eax , 0
	mov edi,0
	mov edi , offset code
	movzx ecx , numberOfChars
	dispTrav:
		mov al , [edi].compress.char
		call writechar
		mov al , ' '
		call writechar
		push ecx 
		mov ecx , 50
		mov i , 0
		l: 
			movzx ebx , i
			mov al , [edi].compress.code[ebx]
			call writedec 
			inc i 
		loop l
		call crlf
		pop ecx
		add edi , sizeof compress
	Loop dispTrav 
	call crlf
	call crlf
	

	

	mov eax , 0
	mov edx , 0
	sub len , 2
	mov edi , offset tree
	mov eax , 5
	mul len
	add edi , eax
	add len , 2
	mov ecx , lengthof decom - 1
	mov esi , offset decom
	mov ebp , offset Decompress_word
	mov ebx , 0
	decompress:
		cmp byte ptr[esi] , 49
		je goLeft
			mov bl , [edi].huffman.right
			dec bl 
			mov edi , offset tree
			mov eax , 5
			mul bl
			add edi , eax
			cmp byte ptr[edi].huffman.char , '%'
			jne k1
			jmp nxt
			k1:
				mov bl , [edi].huffman.char
				mov byte ptr[ebp] , bl
				inc ebp
				sub len , 2
				mov edi , offset tree
				mov eax , 5
				mul len
				add edi , eax
			jmp nxt
		goLeft:
			mov bl , [edi].huffman.left
			dec bl 
			mov edi , offset tree
			mov eax , 5
			mul bl
			add edi , eax
			cmp byte ptr[edi].huffman.char , '%'
			jne k
			jmp nxt
			k:
				mov bl , [edi].huffman.char
				mov byte ptr [ebp] , bl
				inc ebp
				sub len , 2
				mov edi , offset tree
				mov eax , 5
				mul len
				add edi , eax
			nxt:
		inc esi
	loop decompress


	
	mov edx , offset outfile
	call CreateOutputFile
	mov inHandle , eax 
	mov edx , offset Decompress_word
	mov ecx , lengthof Decompress_word
	call writetofile
	mov eax, inHandle
	call CloseFile


	
	
	;;;;;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;
	endSession:




	exit
main ENDP










































Display_Alphapet proc

	mov edi , offset arr
	mov ecx , lengthof arr
	display:
		mov al , [edi].alpha.char
		call writechar 
		movzx eax , [edi].alpha.freq
		call writedec
		call crlf
		add edi,sizeof alpha
	Loop display
	call crlf
	call crlf

	ret
Display_Alphapet endp

Display_Chars proc

	mov edi , offset chars
	mov ecx , lengthof chars
	mov eax , 0
	disp:
		cmp [edi].filter.freq , 0
		je equal
		mov al , [edi].filter.index
		call writedec
		mov al  , ' '
		call writechar
		mov al , [edi].filter.char
		call writechar
		mov al  , ' '
		call writechar
		movzx eax , [edi].filter.freq
		call writedec
		call crlf
		equal:
		add edi , sizeof filter
	Loop disp
	call crlf
	call crlf
		
	ret
Display_Chars endp

Display_huffman proc

	mov eax , 0
	mov edx , 0
	mov ebx , 0
	mov edx , offset tree
	mov ecx , lengthof tree
	disp2:
		cmp [edx].huffman.sumofnode , 0
		je equal1
		mov al , [edx].huffman.nodeindex
		call writedec
		mov al , ' '
		call writechar
		mov al , [edx].huffman.char
		call writechar
		mov al , ' '
		call writechar
		mov al , [edx].huffman.left
		call writedec
		mov al , ' '
		call writechar
		mov al , [edx].huffman.right
		call writedec
		mov al , ' '
		call writechar
		movzx eax , [edx].huffman.sumofnode
		call writedec
		call crlf
		equal1:
		add edx , sizeof huffman
	Loop disp2
	call crlf
	call crlf

	ret
Display_huffman endp

Display_Codes proc

	mov eax , 0
	mov edi,0
	mov edi , offset code
	movzx ecx , charlen
	dispTrav:
		mov al , [edi].compress.char
		call writechar
		mov al , ' '
		call writechar
		push ecx 
		mov ecx , 50
		mov i , 0
		l: 
			movzx ebx , i
			mov al , [edi].compress.code[ebx]
			call writedec 
			inc i 
		loop l
		call crlf
		pop ecx
		add edi , sizeof compress
	Loop dispTrav 
	call crlf
	call crlf


	ret
Display_Codes endp

Display_Encryption proc

	mov edx , offset enc
	mov ecx , lengthof enc
	d:
		mov al , [edx]
		call writedec
		inc edx
	Loop d 
	call crlf
	call crlf

	ret
Display_Encryption endp

;;;;;;;;;;;;;;;;;;;;;;;; Start Compression ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initialize proc uses edi  ecx
	l:
		mov al , count
		mov [edi].alpha.char , al  
		inc count
		add edi,sizeof alpha
	Loop l
	ret 
initialize endp

increament proc uses edx  ecx
	l2:
		push ecx 
		mov ecx , lengthof arr
		mov edi , offset arr
		l3:
			mov bl , [edi].alpha.char
			cmp [edx],bl
			je found
			jne done
			found:
				add [edi].alpha.freq , 1
			done:
			add edi , sizeof alpha
		Loop l3
		inc edx
		pop ecx
	Loop l2
	ret
increament endp

Get_Length proc uses ecx edi 
	leng:
		cmp [edi].alpha.freq , 0
		je don
		inc len
		don:
		add edi , sizeof alpha
	Loop leng
	mov al , len 
	 mov charlen , al
	ret
Get_Length endp

fill_data proc uses ecx edi esi edx
	fil:
		cmp [esi].alpha.freq , 0
		je not_fount
			mov bl , x
			mov [edi].filter.index , bl
			mov bl , [esi].alpha.char
			mov [edi].filter.char , bl
			mov bl , [esi].alpha.freq
			mov [edi].filter.freq , bl

			mov bl , x
			mov [edx].huffman.nodeindex , bl
			mov bl , [esi].alpha.char
			mov [edx].huffman.char , bl
			mov [edx].huffman.left , 0
			mov [edx].huffman.right ,0
			mov bl , [esi].alpha.freq
			mov [edx].huffman.sumofnode , bl

			inc x
			add edi ,sizeof filter
			add edx , sizeof huffman
		not_fount:
		add esi , sizeof alpha
	Loop fil
	ret
fill_data endp

GetMin proc
		mov min , 200
		mov edi , offset chars
		mov ecx , lengthof chars
		Get_min:
			cmp [edi].filter.freq , 0
			je skip
				cmp [edi].filter.char , '-'
				je skip
				mov ebx,0
				mov bl , [edi].filter.freq
				cmp min , bl
				ja take
				jmp skip
				take:
					mov min , bl
					mov bl , [edi].filter.char
					mov minchar , bl
			skip:
			add edi , sizeof filter
		Loop Get_min
	ret
GetMin endp

ChangeChar proc
		mov edi , offset chars
		mov ecx , lengthof chars
		Change_Char:
			mov ebx,0
			mov bl , [edi].filter.char
			cmp minchar  , bl 
			je change
			jmp sk
			change:
				mov [edi].filter.char , '-'
				;mov [edi].filter.freq , 190
				mov bl , [edi].filter.index
				mov minindex1 , bl
				jmp outer
			sk:
			add edi , sizeof filter
		Loop Change_Char
		outer:
	ret
ChangeChar endp

GetMin2 proc
		mov min2 , 200
		mov edi , offset chars
		mov ecx , lengthof chars
		Get_min2:
			cmp [edi].filter.freq , 0
			je skip2
				cmp [edi].filter.char , '-'
				je skip2
				mov ebx,0
				mov bl , [edi].filter.freq
				cmp min2 , bl
				ja take2
				jmp skip2
				take2:
					mov min2 , bl
					mov bl , [edi].filter.char
					mov minchar2 , bl
			skip2:
			add edi , sizeof filter
		Loop Get_min2
	ret
GetMin2 endp

ChangeChar2 proc
		mov edi , offset chars
		mov ecx , lengthof chars
		Change_Char2:
			mov ebx,0
			mov bl , [edi].filter.char
			cmp minchar2  , bl 
			je change2
			jmp sk2
			change2:
				mov [edi].filter.char , '-'
				;mov [edi].filter.freq , 190
				mov bl , [edi].filter.index
				mov minindex2 , bl
				jmp outer
			sk2:
			add edi , sizeof filter
		Loop Change_Char2
		outer:
	ret
ChangeChar2 endp

Append_Chars proc
	
	mov ebx,0
	mov eax , 0
	mov edi , offset chars
	mov eax , 3
	mul len
	add edi , eax
	mov bl , x
	mov [edi].filter.index , bl
	mov [edi].filter.char , '%'
	mov al , min2
	add al , min
	mov [edi].filter.freq , al
	ret
Append_Chars endp

Append_tree proc
	mov ebx,0
	mov eax , 0
	mov edx , 0
	mov ebx,0
	mov eax , 0
	mov edx , 0
	mov edx , offset tree
	mov eax , 5
	mul len
	add edx , eax
	mov bl , x
	mov [edx].huffman.nodeindex , bl
	mov [edx].huffman.char , '%'
	mov bl , minindex1
	mov [edx].huffman.left , bl
	mov bl , minindex2
	mov [edx].huffman.right , bl
	mov al , min2
	add al , min
	mov [edx].huffman.sumofnode , al
	ret
Append_tree endp

Remove proc
		sub x , 1
		mov edi , offset chars 
		mov ecx , lengthof chars
		lastchars:
			mov bl , x
			cmp bl , [edi].filter.index
			je remove1
			jmp checks
			remove1:
				mov [edi].filter.index , 0 
				mov [edi].filter.char , 0 
				mov [edi].filter.freq , 0 
			 checks:
			 add edi , sizeof filter
		loop lastchars

		mov edi , offset tree
		mov ecx , lengthof tree
		lasttree:
			mov bl , x
			cmp bl , [edi].huffman.nodeindex
			je remove2
			jmp checks2
			remove2:
				mov [edi].huffman.nodeindex , 0 
				mov [edi].huffman.char , 0 
				mov [edi].huffman.left , 0 
				mov [edi].huffman.right , 0 
				mov [edi].huffman.sumofnode , 0 
			 checks2:
			 add edi , sizeof huffman
		loop lasttree
		ret
Remove endp

Traverse proc
	mov edx , offset tree
	mov eax , offset code
	mov ecx , lengthof tree
	trav:
		push ecx
		mov ind , 0
		cmp [edx].huffman.sumofnode , 0
		je iterate
		cmp [edx].huffman.char , '%'
		je iterate
		mov ebx , 0
		mov bl , [edx].huffman.char
		mov [eax].compress.char , bl
		mov bl ,  [edx].huffman.nodeindex
		mov indt , bl
		call Check

		add eax , sizeof compress
		iterate:
		add edx , sizeof huffman
		pop ecx	
	Loop trav
	ret
Traverse endp

Check proc
	mov esi , offset tree
		mov ecx , lengthof tree
		checks:
			cmp [esi].huffman.sumofnode , 0
			je skippy
			cmp [esi].huffman.char , '%'
			jne skippy
				cmp bl , [esi].huffman.left
				je left
				jmp choose
				left:
					movzx ebx , ind
					mov [eax].compress.code[ebx] , 1
					mov ebx , 0
					mov bl , [esi].huffman.nodeindex
					;mov indt , bl
					inc ind
					jmp skippy
				choose:
				cmp bl , [esi].huffman.right
				jne skippy
					movzx ebx , ind
					mov [eax].compress.code[ebx] , 0
					mov ebx , 0
					mov bl , [esi].huffman.nodeindex
					;mov indt , bl
					inc ind
			skippy:
			add esi , sizeof huffman
		Loop checks
	ret
Check endp

Compression proc
mov edx , offset enc
	mov esi , offset string
	mov ecx , lengthof string
	com:
		mov ind , 0
		push ecx
		mov edi , offset code
		movzx ecx , charlen
		e:
			push ecx
			mov bl , [edi].compress.char
			cmp [esi] , bl
			jne s
				mov ecx , 4
				ll:
				movzx eax , ind
				mov bl , [edi].compress.code[eax]
				mov [edx] , bl
				inc edx
				inc ind
				loop ll
			s:
			add edi,sizeof compress
			pop ecx
		Loop e
		inc esi
		pop ecx
	Loop com
	ret
Compression endp


compOp proc
	;;;;;;;;;;;;;;;;; Input File ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov edx , offset infile
	call openinputfile
	mov inHandle , eax 
	mov edx , offset string
	mov ecx , lengthof string
	call readfromfile

;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

;;;;;;; initialization array With Characters  ;;;;;;;;;;;

	mov edi , offset arr
	mov ecx , lengthof arr
	call initialize

;;;;;;;;;;;;; E-n-d ;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;; Increament Frequency of Characters ;;;;;;;;;;;;;;;;;;;

	mov edx , offset string
	mov ecx , lengthof string
	call increament

;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; Get Length Of Distinct Characters ;;;;;;;;;;;;;;;;;;;;;

	mov edi , offset arr
	mov ecx , 26 
	call Get_Length

;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;; Fill Array of filter struct and huffman struct With Data ;;;;;;;;;;;;;;;;;;;;;;;; 

	mov esi , offset arr
	mov edi , offset chars
	mov edx , offset tree
	mov ecx , lengthof arr
	call fill_data

;;;;;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;; Build Tree ;;;;;;;;;;;;;;;;;;;;;;;

		movzx ecx , len
		lll:
			push ecx
				call GetMin
				call ChangeChar
				call GetMin2
				call ChangeChar2
				call Append_Chars
				call Append_tree
				inc x 
				inc len	
			pop ecx
		Loop lll
		call Remove

;;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;; Travers Compression ;;;;;;;;;;;;;;;;;;;;;;

	call Traverse
	call Display_Chars
	call Display_huffman
	call Display_Codes

;;;;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;; Compress ;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	call Compression

	

;;;;;;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;; Write To File ;;;;;;;;;;;;;;;;;;;;
	

	mov edx , offset outfile
	call CreateOutputFile
	mov inHandle , eax 
	mov edx,0
	mov edx , offset enc
	mov ecx , lengthof enc
	convert_To_String:
		cmp byte ptr[edx] , 0
		je q

			mov byte ptr[edx] , 49
			jmp sk
		q:
			mov byte ptr[edx] , 48
		sk:
		inc edx
	Loop convert_To_String


	mov edx , offset enc
	mov ecx , lengthof enc
	call writetofile
	movzx eax, infile
	call CloseFile


;;;;;;;;;;;;;;;;;;;;;;;;; E-N-D ;;;;;;;;;;;;;;;;;;;;;

	ret
compOp endp
;;;;;;;;;;;;;;;;;;;;;;;; E-N-D Compression ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



convert proc

	mov edx, offset String2
	mov ecx,lengthof String2 
	mov edi , offset chars2 
	letters:
		mov al , [edx]
		cmp al , 97
		jae copy
		jmp skip
		copy:
			cmp al , 122
			jae skip
			mov [edi] , al
			inc numberOfChars
			inc edi
		skip:
		inc edx
	Loop letters

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov edx, offset String2 
	mov ecx,lengthof String2  
	l1:
	mov bl,[edx]
	cmp bl, 58
	ja goOut
	inc de
	movzx eax,bl
	push eax
	inc edx
	Loop l1
	goOut:
 
 
	mov ebx,0      ; el nateg hykon hna fi el a5er 
	mov ecx, de
	mov esi , offset arr2
	l2:
	pop eax
	cmp eax , ' '
	je space
	sub eax, '0'
	mul cnt
	add ebx,eax
	mov eax, cnt
	mul ten
	mov cnt, eax
	jmp done
	space:
	mov cnt,1
	mov eax, ebx
	mov [esi] ,eax 
	inc numberOfNumbers
	add esi , 4
	mov ebx,0
	;call crlf
	done:
	Loop l2

	

	
 
 
 
 
 
 
	movzx ecx,numberOfNumbers
	mov esi,offset arr2
	s:
	mov eax,[esi]
	push eax
	;call writedec
	;call crlf
	add esi , 4
 
	Loop s
 
 
 
	movzx ecx,numberOfNumbers
	mov esi,offset arr2
	s2:
	pop eax
	mov [esi],eax
	;call writedec
	;call crlf
	add esi , 4
 
	Loop s2
	
	sub numberOfNumbers,1

	mov esi , offset number
	mov eax,ebx
	mov [esi] ,eax 
	add esi , 4
	mov edi , offset arr2
	movzx ecx , numberOfNumbers
	lp:
		mov eax , [edi]
		mov [esi] , eax
		add esi , 4
		add edi , 4
	loop lp
 

	ret
convert endp


Extract proc

	mov edx , offset number 
	mov esi , offset number
	add esi , 4
	mov edi , offset number
	add edi , 8
	mov eax , offset chars2
	mov ebx , offset distinct
	movzx ecx , numberOfNumbers
	extract_letter_freq:
		cmp dword ptr[esi] , 0
		je c1
		jmp skip
		c1:
			mov ebp , [edi] 
			cmp dword ptr[edi] , 0
			jne skip
			push edx
			mov edx , 0 
			mov dl, [eax]
			mov [ebx].alpha.char , dl
			
			pop edx
			push eax
			mov eax , 0 
			mov al , [edx]
			mov [ebx].alpha.freq , al
			add ebx , sizeof alpha
			pop eax
			inc eax
		skip:
		add edx , 4
		add esi , 8
		add edi , 8
	loop extract_letter_freq

	ret
Extract endp

END main