/*
 * Copyright (c) 2009  Pekka Enberg
 *
 * This file is released under the GPL version 2 with the following
 * clarification and special exception:
 *
 *     Linking this library statically or dynamically with other modules is
 *     making a combined work based on this library. Thus, the terms and
 *     conditions of the GNU General Public License cover the whole
 *     combination.
 *
 *     As a special exception, the copyright holders of this library give you
 *     permission to link this library with independent modules to produce an
 *     executable, regardless of the license terms of these independent
 *     modules, and to copy and distribute the resulting executable under terms
 *     of your choice, provided that you also meet, for each linked independent
 *     module, the terms and conditions of the license of that module. An
 *     independent module is a module which is not derived from or based on
 *     this library. If you modify this library, you may extend this exception
 *     to your version of the library, but you are not obligated to do so. If
 *     you do not wish to do so, delete this exception statement from your
 *     version.
 *
 * Please refer to the file LICENSE for details.
 */

#include <arch/emit-code.h>
#include <arch/instruction.h>
#include <jit/basic-block.h>
#include <vm/buffer.h>

#include <stdlib.h>

void emit_prolog(struct buffer *buf, unsigned long nr_locals)
{
	abort();
}

void emit_ret(struct buffer *buf)
{
	abort();
}

void emit_epilog(struct buffer *buf, unsigned long nr_locals)
{
	abort();
}

void emit_branch_rel(struct buffer *buf, unsigned char prefix,
		     unsigned char opc, long rel32)
{
	abort();
}

void emit_body(struct basic_block *bb, struct buffer *buf)
{
	abort();
}

void emit_trampoline(struct compilation_unit *cu, void *call_target,
		     struct buffer *buf)
{
	abort();
}