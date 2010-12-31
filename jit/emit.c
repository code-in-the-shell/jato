/*
 * Emits machine code.
 *
 * Copyright (C) 2007  Pekka Enberg
 *
 * This file is released under the GPL version 2. Please refer to the file
 * LICENSE for details.
 */

#include "lib/buffer.h"
#include "vm/class.h"
#include "vm/method.h"
#include "vm/object.h"
#include "vm/die.h"
#include "vm/vm.h"

#include "jit/compilation-unit.h"
#include "jit/inline-cache.h"
#include "jit/basic-block.h"
#include "jit/compiler.h"
#include "jit/emit-code.h"
#include "jit/exception.h"
#include "jit/gdb.h"
#include "jit/instruction.h"
#include "jit/statement.h"
#include "jit/text.h"

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>

static void emit_monitorenter(struct compilation_unit *cu)
{
	if (vm_method_is_static(cu->method))
		emit_lock(cu->objcode, cu->method->class->object);
	else
		emit_lock_this(cu->objcode);
}

static void emit_monitorexit(struct compilation_unit *cu)
{
	if (vm_method_is_static(cu->method))
		emit_unlock(cu->objcode, cu->method->class->object);
	else
		emit_unlock_this(cu->objcode);
}
static void backpatch_branches(struct buffer *buf,
			       struct list_head *to_backpatch,
			       unsigned long target_offset)
{
	struct insn *this, *next;

	list_for_each_entry_safe(this, next, to_backpatch, branch_list_node) {
		backpatch_branch_target(buf, this, target_offset);
		list_del(&this->branch_list_node);
	}
}

static void backpatch_tableswitch(struct tableswitch *table)
{
	int count;

	count = table->high - table->low + 1;

	for (int i = 0; i < count; i++) {
		int idx = bb_lookup_successor_index(table->src,
						    table->bb_lookup_table[i]);

		if (branch_needs_resolution_block(table->src, idx)) {
			table->lookup_table[i] =
				(void *)table->src->resolution_blocks[idx].addr;
		} else {
			table->lookup_table[i] =
				bb_native_ptr(table->bb_lookup_table[i]);
		}
	}
}

static void backpatch_lookupswitch(struct lookupswitch *table)
{
	for (unsigned int i = 0; i < table->count; i++) {
		int idx = bb_lookup_successor_index(table->src,
						    table->pairs[i].bb_target);

		if (branch_needs_resolution_block(table->src, idx)) {
			table->pairs[i].target =
				(void *)table->src->resolution_blocks[idx].addr;
		} else {
			table->pairs[i].target =
				bb_native_ptr(table->pairs[i].bb_target);
		}
	}
}

static void backpatch_tableswitch_targets(struct compilation_unit *cu)
{
	struct tableswitch *this;

	list_for_each_entry(this, &cu->tableswitch_list, list_node)
	{
		backpatch_tableswitch(this);
	}
}

static void backpatch_lookupswitch_targets(struct compilation_unit *cu)
{
	struct lookupswitch *this;

	list_for_each_entry(this, &cu->lookupswitch_list, list_node)
	{
		backpatch_lookupswitch(this);
	}
}

void emit_body(struct basic_block *bb, struct buffer *buf)
{
	struct insn *insn;

	bb->mach_offset = buffer_offset(buf);
	bb->is_emitted = true;

	backpatch_branches(buf, &bb->backpatch_insns, bb->mach_offset);

	for_each_insn(insn, &bb->insn_list) {
		emit_insn(buf, bb, insn);
	}

	if (opt_trace_machine_code)
		emit_nop(buf);
}

static void emit_resolution_blocks(struct basic_block *bb, struct buffer *buf)
{
	for (unsigned int i = 0; i < bb->nr_successors; i++) {
		struct resolution_block *block;
		unsigned long mach_offset;
		struct insn *insn;

		mach_offset = buffer_offset(buf);
		block = &bb->resolution_blocks[i];
		block->addr = (unsigned long) buffer_ptr(buf) + mach_offset;

		if (list_is_empty(&block->insns))
			continue;

		backpatch_branches(buf, &block->backpatch_insns, mach_offset);

		for_each_insn(insn, &block->insns) {
			emit_insn(buf, NULL, insn);
		}

		emit_insn(buf, NULL, jump_insn(bb->successors[i]));
	}
}

static void process_call_fixup_sites(struct compilation_unit *cu)
{
	struct fixup_site *site, *next;

	list_for_each_entry_safe(site, next, &cu->call_fixup_site_list, list_node) {
		site->mach_offset = site->relcall_insn->mach_offset;

		pthread_mutex_lock(&site->target->mutex);
		list_move(&site->list_node, &site->target->fixup_site_list);
		pthread_mutex_unlock(&site->target->mutex);
	}
}

/* LOCKING: jit_text_lock() to be held when called */
static void *emit_inline_cache(struct compilation_unit *cu)
{
	void *inline_check;
	struct buffer *buf;
	unsigned long start;

	buf = alloc_exec_buffer();
	if (!buf)
		return NULL;

	start = buffer_offset(buf);

	buf->buf = jit_text_ptr();

#if 0
	fprintf(stderr, "%s: %s.%s => %p\n", __func__, cu->method->class->name, cu->method->name, buf->buf);
#endif

	inline_check = emit_inline_cache_check(buf);

	assert(buffer_offset(buf) == INLINE_CACHE_CHECK_SIZE);

	jit_text_reserve_noalign(buffer_offset(buf));

	return inline_check;
}

int emit_machine_code(struct compilation_unit *cu)
{
	void *inline_check = NULL;
	unsigned long frame_size;
	struct basic_block *bb;
	struct buffer *buf;
	int err = 0;

	buf = alloc_exec_buffer();
	if (!buf)
		return warn("out of memory"), -ENOMEM;

	jit_text_lock();

	assert(!vm_method_is_native(cu->method));

	if (inline_cache_supports_method(cu->method)) {
		inline_check = emit_inline_cache(cu);
		if (!inline_check)
			return warn("out of memory"), -ENOMEM;
	}

	buf->buf = jit_text_ptr();
	cu->objcode = buf;

	frame_size = frame_locals_size(cu->stack_frame);

	emit_prolog(cu->objcode, frame_size);
	if (method_is_synchronized(cu->method))
		emit_monitorenter(cu);

	if (opt_trace_invoke)
		emit_trace_invoke(cu->objcode, cu);

	for_each_basic_block(bb, &cu->bb_list)
		emit_body(bb, cu->objcode);

	emit_body(cu->exit_bb, cu->objcode);
	if (method_is_synchronized(cu->method))
		emit_monitorexit(cu);
	cu->exit_past_unlock_ptr = buffer_current(cu->objcode);
	emit_epilog(cu->objcode);

	emit_body(cu->unwind_bb, cu->objcode);
	if (method_is_synchronized(cu->method))
		emit_monitorexit(cu);
	cu->unwind_past_unlock_ptr = buffer_current(cu->objcode);
	emit_unwind(cu->objcode);

	for_each_basic_block(bb, &cu->bb_list) {
		emit_resolution_blocks(bb, cu->objcode);
	}

	process_call_fixup_sites(cu);
	backpatch_tableswitch_targets(cu);
	backpatch_lookupswitch_targets(cu);
	build_exception_handlers_table(cu);

	cu->exit_bb_ptr = bb_native_ptr(cu->exit_bb);
	cu->unwind_bb_ptr = bb_native_ptr(cu->unwind_bb);

	if (inline_check)
		emit_inline_cache_fail(cu->objcode, (unsigned long) cu->method->virtual_index, inline_check);

	jit_text_reserve(buffer_offset(cu->objcode));

	jit_text_unlock();

	gdb_register_method(cu->method);

	return err;
}

struct jit_trampoline *alloc_jit_trampoline(void)
{
	struct jit_trampoline *trampoline;

	trampoline = malloc(sizeof(*trampoline));
	if (!trampoline)
		return NULL;

	memset(trampoline, 0, sizeof(*trampoline));

	trampoline->objcode = alloc_exec_buffer();
	if (!trampoline->objcode)
		goto failed;

	INIT_LIST_HEAD(&trampoline->fixup_site_list);
	pthread_mutex_init(&trampoline->mutex, NULL);

	return trampoline;

  failed:
	free_jit_trampoline(trampoline);
	return NULL;
}

void free_jit_trampoline(struct jit_trampoline *trampoline)
{
	free_buffer(trampoline->objcode);
	free(trampoline);
}
