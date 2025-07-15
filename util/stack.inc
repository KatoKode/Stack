;-------------------------------------------------------------------------------
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
;-------------------------------------------------------------------------------
%ifndef STACK_INC
%define STACK_INC 1
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
struc stack
    .o_size       resq    1     ; object size
    .s_size       resq    1     ; slot size == o_size rounded up to nearest 8
                                ; byte boundary
    .head         resq    1     ; pointer to head of stack
    .end          resq    1     ; pointer to end of stack buffer
    .buffer       resq    1     ; pointer to stack buffer
endstruc
;
stackSize     EQU     stack_size
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%endif
