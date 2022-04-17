;   enc.asm
;    author: t2o0n321
;    description: Encrypt input string 

Include Irvine32.inc

; --------------------- ;
MAX_BUF_SIZE = 128      ;
; --------------------- ;
; Define buffer size    ;
; --------------------- ;

.data
inputPlaintextPrompt    BYTE    "Enter plaintext: ",    0
inputKeyPrompt          BYTE    "Enter enc key: ",      0
completeKeyPrompt       BYTE    "Complete key: ",       0
encPrompt               BYTE    "Encrypt: ",            0
plaintextBuff           BYTE    MAX_BUF_SIZE+1 DUP(0)
keyBuff                 BYTE    MAX_BUF_SIZE+1 DUP(0)
encBuff                 BYTE    MAX_BUF_SIZE+1 DUP(0)
plaintextSize           DWORD   ?
keySize                 DWORD   ?


.code

;   Main func
main PROC
    call    displayInputPromptAndEnterPlaintext
    call    displayInputPromptAndEnterKey

    ; comparing size
    mov eax, keySize
    cmp eax, plaintextSize
    jne fixKey
    jmp encryptText

fixKey:
    call GenKey

encryptText:
    call encrypt
    call displayEncryptedText
   
    exit
main ENDP

; Functions

; -------------------------------------- ;
displayInputPromptAndEnterPlaintext PROC ;
; -------------------------------------- ;
; Display the prompt and input plaintext ;
; -------------------------------------- ;
    pushad

    ; Displaying prompt
    mov edx, OFFSET inputPlaintextPrompt
    call    WriteString

    ; Input buffer
    mov ecx,MAX_BUF_SIZE      
    mov edx,OFFSET plaintextBuff   ; point to the buffer
    call    ReadString          ; input the string
    mov plaintextSize,eax         ; save the length
    call    Crlf

    popad
    ret
displayInputPromptAndEnterPlaintext ENDP

; --------------------------------- ;
displayInputPromptAndEnterKey PROC  ;
; --------------------------------- ;
; Asking user enter key             ;
; --------------------------------- ;
    pushad

    ; Display prompt
    mov edx, OFFSET inputKeyPrompt
    call    WriteString

    ; Input buffer
    mov ecx,MAX_BUF_SIZE      
    mov edx,OFFSET keyBuff   ; point to the buffer
    call    ReadString          ; input the string
    mov keySize,eax         ; save the length
    call    Crlf

    popad
    ret
displayInputPromptAndEnterKey ENDP

; ---------------- ;
GenKey PROC        ;
; ---------------- ;
; Generate key     ;
; ---------------- ;
    push ebp
    mov ebp, esp
    pushad
    
    mov eax, keySize
    cmp eax, plaintextSize
    jl MoreKey
    jmp LessKey
MoreKey:
    ; Get lenght that we have to gen
    ; Store in eax
    xor eax, eax
    mov eax, plaintextSize
    sub eax, keySize

    ; Add to key
    mov esi, OFFSET plaintextBuff
    mov edi, OFFSET keyBuff
    add edi, keySize

    mov ecx, eax
L1:
    mov al, [esi]   ; let al be the first char of plainttext
    mov [edi], al   ; let the last + 1 char of key be al

    add esi, type byte
    add edi, type byte
    loop L1

    jmp CmpEnd
LessKey:
    ; Get length that we have to cut
    ; Store in eax
    xor eax, eax
    mov eax, keySize
    sub eax, plaintextSize

    mov esi, OFFSET keyBuff
    add esi, plaintextSize

    mov ecx, eax
L2:
    mov al, 0   ; Let al be none
    mov [esi], al   ; let rest of key be al
    add esi, type byte
    loop L2

    jmp CmpEnd
CmpEnd:
    mov edx, OFFSET completeKeyPrompt
    call WriteString
    mov edx, OFFSET keyBuff
    call WriteString
    call Crlf

    popad
    pop ebp
    ret 8
GenKey ENDP

; ------------------------------------------- ;
encrypt PROC                                  ;
; ------------------------------------------- ;
; ENCRYPT plaintext whem the key is compelte  ;
; ------------------------------------------- ;
    push ebp
    mov ebp, esp
    pushad

    ; encrypt by xor
    mov esi, 0
    mov ecx, plaintextSize
L1:
    mov al, plaintextBuff[esi]
    xor al, keyBuff[esi]

    mov encBuff[esi], al

    add esi, type byte
    loop L1

    jmp encEnd
encEnd:
    popad
    pop ebp
    ret 8
encrypt ENDP

; ----------------------------- ;
displayEncryptedText PROC       ;
; ----------------------------- ;
; Display encrypted text        ;
; ----------------------------- ;
    push ebp
    mov ebp, esp
    pushad

    mov edx, OFFSET encPrompt
    call WriteString

    mov edx, OFFSET encBuff
    call WriteString

    call Crlf

    popad
    pop ebp
    ret 8
displayEncryptedText ENDP

END main