;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;   Stack Library Implementation in Assembly Language with C Interface
;   Copyright (C) 2025  J. McIntosh
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License along
;   with this program; if not, write to the Free Software Foundation, Inc.,
;   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%ifndef STACK_ASM
%define STACK_ASM 1
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
extern bzero
extern calloc
extern free
extern memmove64
;
ALIGN_SIZE_8    EQU     8
ALIGN_WITH_8    EQU     (ALIGN_SIZE_8 - 1)
ALIGN_MASK_8    EQU     ~(ALIGN_WITH_8)
;
ALIGN_SIZE_16   EQU     8
ALIGN_WITH_16   EQU     (ALIGN_SIZE_16 - 1)
ALIGN_MASK_16   EQU     ~(ALIGN_WITH_16)
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
%macro ALIGN_STACK_AND_CALL 2-4
      mov     %1, rsp                   ; backup stack pointer (rsp)
      and     rsp, QWORD ALIGN_MASK_16  ; align stack pointer (rsp) to
                                        ; 16-byte boundary
      call    %2 %3 %4                  ; call C function
      mov     rsp, %1                   ; restore stack pointer (rsp)
%endmacro
;
; Example: Call LIBC function
;         ALIGN_STACK_AND_CALL r15, calloc, wrt, ..plt
;
; Example: Call C callback function with address in register (rcx)
;         ALIGH_STACK_AND_CALL r12, rcx
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
%include "stack.inc"
;
section .text
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; C definition:
;
;   int stack_empty (t_stack *stack);
;
; param:
;
;   rdi = stack
;
; return:
;
;   rax = 0 (false) | 1 (true)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
      global stack_empty:function
stack_empty:
; if (stack->head == stack->buffer) return 1
      mov       eax, 1
      mov       rcx, QWORD [rdi + stack.head]
      cmp       rcx, QWORD [rdi + stack.buffer]
      je        .return
; return 0
      xor       eax, eax
.return:
      ret
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; C definition:
;
;   int stack_full (t_stack *stack);
;
; param:
;
;   rdi = stack
;
; return:
;
;   rax = 0 (FALSE) | 1 (TRUE)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
      global stack_full:function
stack_full:
; if (stack->head == stack->end) return 1
      mov       eax, 1
      mov       rcx, QWORD [rdi + stack.head]
      cmp       rcx, QWORD [rdi + stack.end]
      je        .return
; return 0
      xor       eax, eax
.return:
      ret
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; C definition:
;
;   int stack_init (t_stack *stack, size_t count, size_t const size);
;
; param:
;
;   rdi = stack
;   rsi = count
;   rdx = size
;
; return:
;
;   rax = 0 (success) | -1 (failure)
;
; stack:
;
;   QWORD [rbp - 8]   = rdi (stack)
;   QWORD [rbp - 16]  = buf_size
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
      global stack_init:function
stack_init:
; prologue
      push      rbp
      mov       rbp, rsp
      sub       rsp, 16
      push      r12
; QWORD [rbp - 8] = rdi (stack)
      mov       QWORD [rbp - 8], rdi
; stack->o_size = size
      mov       QWORD [rdi + stack.o_size], rdx
; stack->s_size = (size + ALIGN_SIZE_8 - 1) & ALIGN_MASK_8
      mov       rax, rdx
      add       rax, QWORD ALIGN_SIZE_8
      dec       rax
      and       rax, QWORD ALIGN_MASK_8
      test      rax, rax  ; test for 0 and adjust up to 8
      jnz       .not_zero
      mov       rax, QWORD ALIGN_SIZE_8
.not_zero:
      mov       QWORD [rdi + stack.s_size], rax
; size_t buf_size = stack->s_size * count
      mul       rsi
      mov       QWORD [rbp - 16], rax
; if ((stack->buffer = calloc(1, buf_size)) == NULL) return -1
      mov       rdi, 1
      mov       rsi, rax
      ALIGN_STACK_AND_CALL r12, calloc, wrt, ..plt
      mov       rdi, QWORD [rbp - 8]
      mov       QWORD [rdi + stack.buffer], rax
      mov       QWORD [rdi + stack.head], rax
      test      rax, rax
      jnz       .not_null
      mov       eax, -1
      jmp       .epilogue
.not_null:
; stack->end = stack->buffer + buf_size
      mov       rax, QWORD [rdi + stack.buffer]
      mov       rcx, QWORD [rbp - 16]
      add       rax, rcx
      mov       QWORD [rdi + stack.end], rax
; return 0
      xor       eax, eax
.epilogue:
      pop       r12
      mov       rsp, rbp
      pop       rbp
      ret
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; C definition:
;
;   int stack_pop (t_stack *stack, void *buffer)
;
; param:
;
;   rdi = stack
;   rsi = buffer
;
; return:
;
;   rax = 0 (success) | -1 (failure)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
      global stack_pop:function
stack_pop:
; if (stack->head == stack->buffer) return -1
      mov       eax, -1
      mov       rcx, QWORD [rdi + stack.head]
      cmp       rcx, QWORD [rdi + stack.buffer]
      je        .return
; stack->head -= stack->s_size
      mov       rax, QWORD [rdi + stack.s_size]
      sub       rcx, rax
      mov       QWORD [rdi + stack.head], rcx
; (void) memmove64 (buffer, stack->head, stack->o_size)
      mov       rdx, QWORD [rdi + stack.o_size]
      mov       rdi, rsi
      mov       rsi, rcx
      call      memmove64 wrt ..plt
; return 0
      xor       eax, eax
.return:
      ret
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; C definition:
;
;   int stack_push (t_stack *stack, void *buffer)
;
; param:
;
;   rdi = stack
;   rsi = buffer
;
; return:
;
;   rax = 0 (success) | -1 (failure)
;
; stack:
;
;   QWORD [rbp - 8] = rdi (stack)
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
      global stack_push:function
stack_push:
; prologue
      push      rbp
      mov       rbp, rsp
      sub       rsp, 8
; QWORD [rbp - 8] = rdi (stack)
      mov       QWORD [rbp - 8], rdi
; if (stack->head == stack->end) return -1
      mov       eax, -1
      mov       rcx, QWORD [rdi + stack.head]
      cmp       rcx, QWORD [rdi + stack.end]
      je        .epilogue
; (void) memmove64(stack->head, buffer, stack->o_size)
      mov       rdx, QWORD [rdi + stack.o_size]
      mov       rdi, QWORD [rdi + stack.head]
      call      memmove64 wrt ..plt
; stack->head += stack->s_size;
      mov       rdi, QWORD [rbp - 8]
      mov       rax, QWORD [rdi + stack.head]
      add       rax, QWORD [rdi + stack.s_size]
      mov       QWORD [rdi + stack.head], rax
; return 0
      xor       eax, eax
.epilogue:
      mov       rsp, rbp
      pop       rbp
      ret
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; C definition:
;
;   void stack_term (t_stack *stack)
;
; param:
;
;   rdi = stack
;
; stack:
;
;   QWORD [rbp - 8] = rdi (stack}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
      global stack_term:function
stack_term:
; prologue
      push      rbp
      mov       rbp, rsp
      sub       rsp, 8
      push      r12
; QWORD [rbp - 8] = rdi (stack}
      mov       QWORD [rbp - 8], rdi
; free item stack memory
      mov       rdi, QWORD [rdi + stack.buffer]
      ALIGN_STACK_AND_CALL r12, free, wrt, ..plt
; zero out stack structure
      mov       rdi, QWORD [rbp - 8]
      mov       rsi, QWORD stackSize
      ALIGN_STACK_AND_CALL r12, bzero, wrt, ..plt
; epilogue
      pop       r12
      mov       rsp, rbp
      pop       rbp
      ret
%endif
