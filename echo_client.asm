; comment section
; soc.sin_family=AF_INET;
; soc.sin_port=htons(4096);
; soc.sin_addr.s_addr=inet_addr("127.0.0.1");
; sfd = socket (AF_INET, SOCK_DGRAM, 0)
; sendto (sfd, "hello", 5, 0, &soc, sizeof(struct sockaddr_in)));

global _start

section .data
  m db 'hello'
  s dw 2             ; AF_INET
  p db 10h,00h       ; port number=4096
    db 7fh,0h,0h,01h ; ip addr 127.0.0.1
    db 0,0,0,0,0,0,0,0
  msg db "Exit", 0x0a
  len equ $ - msg
  buf db 64 dup (?)
  newl db 0xA, 0xD
  newll equ $-newl


section .text
_start:

  ;make socket
  xor rax, rax ; zero
  mov rax, 41 ; socket()
  mov rdi, 2  ; AF_INET
  mov rsi, 2  ; SOCK_DGRAM
  mov rdx, 0  ; flags
  syscall
  cmp rax, -1 ; error
  jle _exit
  push rax

  ;sendto server
  xor rax, rax ; zero
  mov rax, [rsp]
  mov rdi, rax ; socket file descriptor
  mov rax, 44  ; sendto()
  mov rsi, m   ; 'hello'
  mov rdx, 6   ; strlen('hello')
  mov r8, s    ; socket
  mov r9, 16   ; size of s
  syscall
  cmp rax, -1 ; error
  jle _exit
  
  ;Receive
  mov rdi, [rsp] 
  lea rsi, [buf] ; store buffer
  mov rdx, 8     
  xor rax, rax   
  mov r8, rax    
  mov r9, rax    
  mov r10, rax   
  mov rax, 45    ; receive
  syscall
  
  ;write response
  mov eax, 4 ; sys write
  mov ebx, 1 ; stdout
  mov ecx, buf  ; recmessage
  mov edx, 6 ; length
  int 0x80   ; execute syscall
  
  ;newline after response
  mov edx, newll
  mov ecx, newl
  mov ebx, 1
  mov eax, 4
  int 0x80

  cmp rax, -1
  jle _exit

  ;exit message
  mov eax, 4 ; sys write
  mov ebx, 1 ; stdout
  mov ecx, msg ; text
  mov edx, len ; length
  int 0x80   ; execute syscall
  
  ;exit 
  mov eax, 1 ; sys exit
  mov ebx, 0 ; return value 0
  int 0x80 ; execute syscall
  
  
  _exit:
    mov eax, 1 ; exit
    mov ebx, 1 ; return 1
    int 0x80

  ; complete... X
  ; receive reply X
  ; print the received reply X
