/*------------------------------------------------------------------------------
    Stack Library Implementation in Assembly Language with C Interface
    Copyright (C) 2025  J. McIntosh

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
------------------------------------------------------------------------------*/
#ifndef UTIL_H
#define UTIL_H  1

#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct stack t_stack;

struct stack {
  size_t      o_size;
  size_t      s_size;
  void *      head;
  void *      end;
  void *      buffer;
};

#define stack_alloc() (calloc(1, sizeof(t_stack)))
#define stack_free(P) (free(P), P = NULL)

int stack_empty (t_stack *);
int stack_full (t_stack *);
void * stack_init (t_stack *, size_t const, size_t const);
int stack_pop (t_stack *, void *);
int stack_push (t_stack *, void const *);
void stack_term (t_stack *);
#endif
