%ifndef MEMMOVE64_ASM
%define MEMMOVE64_ASM 1
;
QW_SIZE     EQU     8
;
section .text
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; C definition:
;
;   void * memmove64 (void *dst, void const *src, size_t size);
;
; passed in:
;
;   rdi = dst
;   rsi = src
;   rdx = size
;
; return:
;
;   rax = dst
;
; WARNING: this routine does not handle the overlapping source-destination
;          senario.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
      global memmove64:function
memmove64:
      push      rdi
      mov       rax, rdx
      xor       rdx, rdx
      mov       r11, QW_SIZE
      div       r11
      mov       rcx, rax
      rep movsq
      mov       rcx, rdx
      rep movsb
      pop       rax
      ret
%endif
