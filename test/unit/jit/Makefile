RUNNER=jit-test-runner
SUITE=jit-test-suite.c

TOPLEVEL_OBJS := \
	sys/$(SYS)-$(ARCH)/backtrace.o \
	cafebabe/attribute_array.o \
	cafebabe/attribute_info.o \
	cafebabe/class.o \
	cafebabe/constant_pool.o \
	cafebabe/error.o \
	cafebabe/field_info.o \
	cafebabe/method_info.o \
	cafebabe/source_file_attribute.o \
	cafebabe/stream.o \
	jit/args.o \
	jit/arithmetic-bc.o \
	jit/basic-block.o \
	jit/bc-offset-mapping.o \
	jit/branch-bc.o \
	jit/bytecode-to-ir.o \
	jit/cfg-analyzer.o \
	jit/compilation-unit.o \
	jit/cu-mapping.o \
	jit/exception-bc.o \
	jit/exception.o \
	jit/expression.o \
	jit/fixup-site.o \
	jit/interval.o \
	jit/invoke-bc.o \
	jit/linear-scan.o \
	jit/liveness.o \
	jit/load-store-bc.o \
	jit/method.o \
	jit/nop-bc.o \
	jit/object-bc.o \
	jit/ostack-bc.o \
	jit/spill-reload.o \
	jit/stack-slot.o \
	jit/statement.o \
	jit/switch-bc.o \
	jit/text.o \
	jit/tree-node.o \
	jit/tree-printer.o \
	jit/typeconv-bc.o \
	jit/subroutine.o \
	jit/pc-map.o \
	jit/wide-bc.o \
	lib/bitset.o \
	lib/buffer.o \
	lib/compile-lock.o \
	lib/guard-page.o \
	lib/list.o \
	lib/pqueue.o \
	lib/radix-tree.o \
	lib/stack.o \
	lib/string.o \
	vm/call.o \
	vm/bytecode.o \
	vm/die.o \
	vm/trace.o \
	vm/types.o \
	vm/zalloc.o \
	arch/mmix/args.o \
	arch/mmix/call.o \
	arch/mmix/instruction.o \
	arch/mmix/register.o \
	arch/mmix/stack-frame.o \
	arch/mmix/use-def.o \
	test/unit/libharness/libharness.o \
	test/unit/vm/class-stub.o \
	test/unit/vm/classloader-stub.o \
	test/unit/vm/gc-stub.o \
	test/unit/vm/object-stub.o \
	test/unit/vm/preload-stub.o \
	test/unit/vm/jni-stub.o \
	test/unit/vm/stack-trace-stub.o \
	test/unit/vm/thread-stub.o \
	test/unit/jit/trace-stub.o

TEST_OBJS := \
	args-test-utils.o \
	arithmetic-bc-test.o \
	basic-block-test.o \
	bc-test-utils.o \
	branch-bc-test.o \
	bytecode-to-ir-test.o \
	cfg-analyzer-test.o \
	compilation-unit-test.o \
	expression-test.o \
	invoke-bc-test.o \
	linear-scan-test.o \
	live-range-test.o \
	liveness-test.o \
	load-store-bc-test.o \
	object-bc-test.o \
	ostack-bc-test.o \
	spill-reload-test.o \
	stack-slot-test.o \
	tree-printer-test.o \
	typeconv-bc-test.o

include ../../../scripts/build/test.mk

DEFAULT_CFLAGS += -I../../../arch/mmix/include -std=gnu99
