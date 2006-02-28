/*
 * Copyright (C) 2006  Pekka Enberg
 */

#include <libharness.h>
#include <system.h>
#include <assembler.h>
#include <basic-block.h>
#include <instruction.h>

static void assert_emit_op_membase_reg(enum insn_opcode insn_opcode,
				       enum reg src_base_reg,
				       unsigned long src_disp,
				       enum reg dest_reg,
				       unsigned char opcode,
				       unsigned long modrm)
{
	struct basic_block *bb;
	unsigned char expected[] = { opcode, modrm, src_disp };
	unsigned char actual[3];

	bb = alloc_basic_block(0, 1);
	bb_insert_insn(bb, x86_op_membase_reg(insn_opcode, src_base_reg, src_disp, dest_reg));
	x86_emit_obj_code(bb, actual, ARRAY_SIZE(actual));
	assert_mem_equals(expected, actual, ARRAY_SIZE(expected));
	
	free_basic_block(bb);
}

void test_emit_mov_membase_reg(void)
{
	assert_emit_op_membase_reg(MOV, REG_EBP,  8, REG_EAX, 0x8b, 0x45);
	assert_emit_op_membase_reg(MOV, REG_EBP, 12, REG_EAX, 0x8b, 0x45);
	assert_emit_op_membase_reg(MOV, REG_EBP,  8, REG_EBX, 0x8b, 0x5D);
	assert_emit_op_membase_reg(MOV, REG_EBP,  8, REG_ECX, 0x8b, 0x4D);
	assert_emit_op_membase_reg(MOV, REG_EBP,  8, REG_EDX, 0x8b, 0x55);
}

void test_emit_add_membase_reg(void)
{
	assert_emit_op_membase_reg(ADD, REG_EBP, 4, REG_EAX, 0x03, 0x45);
}
