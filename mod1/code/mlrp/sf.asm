; Example program to demonstrate file I/O.
; This example program will open a file, read the
; contents, and write the contents to the screen.
; This routine also provides some very simple examples
; regarding handling various errors on system services.
; Note, the file name is hard-coded for this example.

section .data
; -----
; Define standard constants.
LF          equ 10          ; line feed
NULL        equ 0           ; end of string
TRUE        equ 1           ; true
FALSE       equ 0           ; false
EXIT_SUCCESS equ 0         ; success code
STDIN       equ 0           ; standard input
STDOUT      equ 1           ; standard output
STDERR      equ 2           ; standard error
SYS_read    equ 0           ; read syscall
SYS_write   equ 1           ; write syscall
SYS_open    equ 2           ; file open syscall
SYS_close   equ 3           ; file close syscall
SYS_fork    equ 57          ; fork syscall
SYS_exit    equ 60          ; terminate syscall
SYS_creat   equ 85          ; file open/create syscall
SYS_time    equ 201         ; get time syscall
O_CREAT     equ 0x40        ; create file flag
O_TRUNC     equ 0x200       ; truncate file flag
O_APPEND    equ 0x400       ; append flag
O_RDONLY    equ 0x0         ; read-only
O_WRONLY    equ 0x1         ; write-only
O_RDWR      equ 0x2         ; read-write
S_IRUSR     equ 00400       ; read permission for owner
S_IWUSR     equ 00200       ; write permission for owner
S_IXUSR     equ 00100       ; execute permission for owner

; -----
; Variables/constants for main.
BUFF_SIZE   equ 255         ; buffer size for file reading
newLine     db LF, NULL
header      db LF, "File Read Example.", LF, NULL
fileName    db "url.txt", NULL
fileDesc    dq 0            ; file descriptor storage
errMsgOpen  db "Error opening the file.", LF, NULL
errMsgRead  db "Error reading from the file.", LF, NULL

section .bss
readBuffer  resb BUFF_SIZE  ; buffer to store read content

; -------------------------------------------------------
section .text
global _start
_start:
    ; -----
    ; Display header line...
    mov rdi, header
    call printString

    ; -----
    ; Attempt to open file - Use system service for file open
    mov rax, SYS_open           ; syscall for file open
    mov rdi, fileName           ; file name string
    mov rsi, O_RDONLY           ; read-only access
    syscall                     ; call the kernel

    cmp rax, 0                  ; check for success
    jl errorOnOpen              ; if error, jump to error handling

    mov qword [fileDesc], rax   ; save file descriptor

    ; -----
    ; Read from file.
    mov rax, SYS_read           ; syscall for reading from file
    mov rdi, qword [fileDesc]   ; file descriptor
    mov rsi, readBuffer         ; address of the buffer
    mov rdx, BUFF_SIZE          ; number of bytes to read
    syscall                     ; call the kernel

    cmp rax, 0                  ; check for success
    jl errorOnRead              ; if error, jump to error handling

    ; -----
    ; Print the buffer.
    ; Add NULL termination for the print string
    mov rsi, readBuffer
    mov byte [rsi + rax], NULL  ; NULL terminate the buffer
    mov rdi, readBuffer
    call printString

    ; -----
    ; Print new line
    mov rdi, newLine
    call printString

    ; -----
    ; Close the file.
    mov rax, SYS_close          ; syscall for closing file
    mov rdi, qword [fileDesc]   ; file descriptor
    syscall

    jmp exampleDone

; -----
; Error on open.
errorOnOpen:
    mov rdi, errMsgOpen
    call printString
    jmp exampleDone

; -----
; Error on read.
errorOnRead:
    mov rdi, errMsgRead
    call printString
    jmp exampleDone

; -----
; Example program done.
exampleDone:
    mov rax, SYS_exit          ; syscall for exit
    mov rdi, EXIT_SUCCESS      ; exit with success
    syscall                    ; call the kernel to exit the program

; **********************************************************
; Generic procedure to display a string to the screen.
; String must be NULL terminated.
; Algorithm:
; 1) Count characters in string (excluding NULL)
; 2) Use syscall to output characters
;
; Arguments:
; 1) address, string
;
; Returns: nothing

global printString
printString:
    push rbx                  ; Save rbx
    mov rbx, rdi              ; Load address of string into rbx
    mov rdx, 0                ; Initialize character count to 0

    ; Count characters in string.
strCountLoop:
    cmp byte [rbx], NULL       ; Check for NULL terminator
    je strCountDone            ; If NULL, we are done counting
    inc rdx                    ; Increment character count
    inc rbx                    ; Move to the next byte in the string
    jmp strCountLoop           ; Continue the loop

strCountDone:
    cmp rdx, 0                 ; If no characters, skip print
    je prtDone                 ; If no characters, skip print

    ; -----
    ; Call OS to output string.
    mov rax, SYS_write         ; Syscall code for write
    mov rsi, rdi               ; Address of string to write
    mov rdi, STDOUT            ; Standard output
    syscall                    ; Call syscall to write the string

prtDone:
    pop rbx                    ; Restore rbx
    ret                        ; Return to caller
