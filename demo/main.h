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
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>
#include <string.h>
#include "../util/util.h"

#define TYPE_DOUBLE     1
#define TYPE_LONG       2
#define TYPE_STRING     3
#define TYPE_BOOLEAN    4

#define ITEM_COUNT      24

typedef struct data data_t;

struct data {
  int       type;
  union {
    double  dbl;
    long    lng;
    char *  str;
  } value;
};

typedef struct pair pair_t;

struct pair {
  char *    key;
  data_t    data;
};

char const *TRUE = "true";
char const *FALSE = "false";

void data_assign_boolean (data_t *, char const *);
void data_assign_double (data_t *, double);
void data_assign_long (data_t *, long);
void data_assign_string (data_t *, char const *);
void data_stack_term (t_stack *);
void data_stack_test (void);
void data_term (data_t *);
void pair_assign_boolean (pair_t *, char const *, char const *);
void pair_assign_double (pair_t *, char const *, double);
void pair_assign_long (pair_t *, char const *, long);
void pair_assign_string (pair_t *, char const *, char const *);
void pair_stack_term (t_stack *);
void pair_stack_test (void);
void pair_term (pair_t *);
void print_data (data_t *);
void print_pair (pair_t *);

