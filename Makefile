VERSION = 0.1.1

CLASSPATH_CONFIG = tools/classpath-config

CLASSPATH_INSTALL_DIR	?= $(shell ./tools/classpath-config)

GLIBJ		= $(CLASSPATH_INSTALL_DIR)/share/classpath/glibj.zip

uname_M		:= $(shell uname -m | sed -e s/i.86/i386/ | sed -e s/i86pc/i386/)
ARCH		:= $(shell sh scripts/gcc-arch.sh $(CC))
SYS		:= $(shell uname -s | tr A-Z a-z)

MAKEFLAGS += --no-print-directory

ifneq ($(ARCH),$(uname_M))
TEST		=
else
TEST		= test
endif

ifeq ($(ARCH),i386)
override ARCH	= x86
ARCH_POSTFIX	= _32
#WARNINGS	+= -Werror
MB_DEFINES	+= -DCONFIG_X86_32
ifeq ($(uname_M),x86_64)
ARCH_CFLAGS	+= -m32
TEST		= test
endif
endif

ifeq ($(ARCH),x86_64)
override ARCH	= x86
ARCH_POSTFIX	= _64
ARCH_CFLAGS	+= -fno-omit-frame-pointer
MB_DEFINES	+= -DCONFIG_X86_64
endif

ifeq ($(ARCH),ppc)
override ARCH	= ppc
ARCH_POSTFIX	= _32
MB_DEFINES	+= -DCONFIG_PPC
endif

ifeq ($(SYS),darwin)
DEFAULT_CFLAGS += -D_XOPEN_SOURCE=1
endif
export ARCH_CFLAGS

ARCH_CONFIG=arch/$(ARCH)/include/arch/config$(ARCH_POSTFIX).h

# Make the build silent by default
V =

PROGRAM		:= jato

include arch/$(ARCH)/Makefile$(ARCH_POSTFIX)
include sys/$(SYS)-$(ARCH)/Makefile

OBJS += $(ARCH_OBJS)
OBJS += $(SYS_OBJS)

OBJS += cafebabe/annotations_attribute.o
OBJS += cafebabe/attribute_array.o
OBJS += cafebabe/attribute_info.o
OBJS += cafebabe/class.o
OBJS += cafebabe/code_attribute.o
OBJS += cafebabe/constant_pool.o
OBJS += cafebabe/constant_value_attribute.o
OBJS += cafebabe/enclosing_method_attribute.o
OBJS += cafebabe/error.o
OBJS += cafebabe/exceptions_attribute.o
OBJS += cafebabe/field_info.o
OBJS += cafebabe/inner_classes_attribute.o
OBJS += cafebabe/line_number_table_attribute.o
OBJS += cafebabe/method_info.o
OBJS += cafebabe/source_file_attribute.o
OBJS += cafebabe/stream.o
OBJS += dalvik/dex-file.o
OBJS += jit/args.o
OBJS += jit/arithmetic-bc.o
OBJS += jit/basic-block.o
OBJS += jit/bc-offset-mapping.o
OBJS += jit/branch-bc.o
OBJS += jit/bytecode-to-ir.o
OBJS += jit/cfg-analyzer.o
OBJS += jit/compilation-unit.o
OBJS += jit/compiler.o
OBJS += jit/cu-mapping.o
OBJS += jit/dominance.o
OBJS += jit/elf.o
OBJS += jit/emit.o
OBJS += jit/emulate.o
OBJS += jit/exception-bc.o
OBJS += jit/exception.o
OBJS += jit/expression.o
OBJS += jit/fixup-site.o
OBJS += jit/gdb.o
OBJS += jit/interval.o
OBJS += jit/invoke-bc.o
OBJS += jit/linear-scan.o
OBJS += jit/liveness.o
OBJS += jit/load-store-bc.o
OBJS += jit/method.o
OBJS += jit/nop-bc.o
OBJS += jit/object-bc.o
OBJS += jit/ostack-bc.o
OBJS += jit/pc-map.o
OBJS += jit/perf-map.o
OBJS += jit/spill-reload.o
OBJS += jit/stack-slot.o
OBJS += jit/statement.o
OBJS += jit/subroutine.o
OBJS += jit/switch-bc.o
OBJS += jit/text.o
OBJS += jit/trace-jit.o
OBJS += jit/trampoline.o
OBJS += jit/tree-node.o
OBJS += jit/tree-printer.o
OBJS += jit/typeconv-bc.o
OBJS += jit/vtable.o
OBJS += jit/wide-bc.o
OBJS += lib/array.o
OBJS += lib/bitset.o
OBJS += lib/buffer.o
OBJS += lib/compile-lock.o
OBJS += lib/guard-page.o
OBJS += lib/hash-map.o
OBJS += lib/list.o
OBJS += lib/parse.o
OBJS += lib/pqueue.o
OBJS += lib/radix-tree.o
OBJS += lib/stack.o
OBJS += lib/string.o
OBJS += runtime/classloader.o
OBJS += runtime/java_lang_VMClass.o
OBJS += runtime/java_lang_VMRuntime.o
OBJS += runtime/java_lang_VMSystem.o
OBJS += runtime/java_lang_VMThread.o
OBJS += runtime/reflection.o
OBJS += runtime/stack-walker.o
OBJS += runtime/unsafe.o
OBJS += vm/annotation.o
OBJS += vm/boehm-gc.o
OBJS += vm/bytecode.o
OBJS += vm/call.o
OBJS += vm/class.o
OBJS += vm/classloader.o
OBJS += vm/debug-dump.o
OBJS += vm/die.o
OBJS += vm/fault-inject.o
OBJS += vm/field.o
OBJS += vm/gc.o
OBJS += vm/itable.o
OBJS += vm/jar.o
OBJS += vm/jato.o
OBJS += vm/jni-interface.o
OBJS += vm/jni.o
OBJS += vm/method.o
OBJS += vm/monitor.o
OBJS += vm/natives.o
OBJS += vm/object.o
OBJS += vm/preload.o
OBJS += vm/reference.o
OBJS += vm/signal.o
OBJS += vm/stack-trace.o
OBJS += vm/static.o
OBJS += vm/string.o
OBJS += vm/thread.o
OBJS += vm/trace.o
OBJS += vm/types.o
OBJS += vm/utf8.o
OBJS += vm/zalloc.o

RUNTIME_CLASSES =

CC		?= gcc
LINK		?= $(CC)
MONOBURG	:= ./tools/monoburg/monoburg
JAVA		?= $(shell pwd)/jato
JAVAC_OPTS	?= -encoding utf-8
INSTALL		?= install

ifeq ($(uname_M),x86_64)
JASMIN		?= java -jar tools/jasmin/jasmin.jar
JAVAC		?= java ./tools/ecj
else
JASMIN		?= $(JAVA) -jar tools/jasmin/jasmin.jar
JAVAC		?= JAVA=$(JAVA) ./tools/ecj
endif

DEFAULT_CFLAGS	+= $(ARCH_CFLAGS) -g -rdynamic -std=gnu99 -D_GNU_SOURCE -fstack-protector-all -D_FORTIFY_SOURCE=2

# boehmgc integration (see boehmgc/doc/README.linux)
DEFAULT_CFLAGS  += -D_REENTRANT -DGC_LINUX_THREADS -DGC_USE_LD_WRAP

JATO_CFLAGS  += -Wl,--wrap -Wl,pthread_create -Wl,--wrap -Wl,pthread_join \
	     -Wl,--wrap -Wl,pthread_detach -Wl,--wrap -Wl,pthread_sigmask \
             -Wl,--wrap -Wl,sleep

# XXX: Temporary hack -Vegard
DEFAULT_CFLAGS	+= -DNOT_IMPLEMENTED='fprintf(stderr, "%s:%d: warning: %s not implemented\n", __FILE__, __LINE__, __func__)'

WARNINGS	+=				\
		-Wall				\
		-Wcast-align			\
		-Wformat=2			\
		-Winit-self			\
		-Wmissing-declarations		\
		-Wmissing-prototypes		\
		-Wnested-externs		\
		-Wno-system-headers		\
		-Wold-style-definition		\
		-Wredundant-decls		\
		-Wsign-compare			\
		-Wstrict-prototypes		\
		-Wundef				\
		-Wvolatile-register-var		\
		-Wwrite-strings

DEFAULT_CFLAGS	+= $(WARNINGS)

OPTIMIZATIONS	+= -Os -fno-delete-null-pointer-checks
DEFAULT_CFLAGS	+= $(OPTIMIZATIONS)

INCLUDES	= -Iinclude -Iarch/$(ARCH)/include -Isys/$(SYS)-$(ARCH)/include -Ijit -Ijit/glib -include $(ARCH_CONFIG) -Iboehmgc/include
DEFAULT_CFLAGS	+= $(INCLUDES)

DEFAULT_LIBS	= -lrt -lpthread -lm -ldl -lz -lzip -lbfd -lopcodes -liberty -Lboehmgc -lboehmgc $(ARCH_LIBS)

all: $(PROGRAM)
.PHONY: all
.DEFAULT: all

VERSION_HEADER = include/vm/version.h

$(VERSION_HEADER): FORCE
	$(E) "  GEN     " $@
	$(Q) echo "#define JATO_VERSION \"$(VERSION)\"" > $(VERSION_HEADER)

$(CLASSPATH_CONFIG):
	$(E) "  LINK    " $@
	$(Q) $(LINK) -Wall $(CLASSPATH_CONFIG).c -o $(CLASSPATH_CONFIG)

monoburg:
	+$(Q) $(MAKE) -C tools/monoburg/
.PHONY: monoburg

boehmgc:
	+$(Q) ARCH=$(ARCH) $(MAKE) -C boehmgc/
.PHONY: boehmgc

%.o: %.c
	$(E) "  CC      " $@
	$(Q) $(CC) -MD -c $(DEFAULT_CFLAGS) $(CFLAGS) $< -o $@

# -gstabs is needed for correct backtraces.
%.o: %.S
	$(E) "  AS      " $@
	$(Q) $(CC) -c -gstabs $(DEFAULT_CFLAGS) $(CFLAGS) $< -o $@

arch/$(ARCH)/insn-selector.c: monoburg FORCE
	$(E) "  MONOBURG" $@
	$(Q) $(MONOBURG) -p -e $(MB_DEFINES) $(@:.c=.brg) > $@

$(PROGRAM): monoburg boehmgc $(VERSION_HEADER) $(CLASSPATH_CONFIG) compile $(RUNTIME_CLASSES)
	$(E) "  LINK    " $@
	$(Q) $(LINK) $(JATO_CFLAGS) $(DEFAULT_CFLAGS) $(CFLAGS) $(OBJS) -o $(PROGRAM) $(LIBS) $(DEFAULT_LIBS)

compile: $(OBJS)

check-unit: monoburg
	+$(MAKE) -C test/unit/vm/ SYS=$(SYS) ARCH=$(ARCH) ARCH_POSTFIX=$(ARCH_POSTFIX) $(TEST)
	+$(MAKE) -C test/unit/jit/ SYS=$(SYS) ARCH=$(ARCH) ARCH_POSTFIX=$(ARCH_POSTFIX) $(TEST)
	+$(MAKE) -C test/unit/arch-$(ARCH)/ SYS=$(SYS) ARCH=$(ARCH) ARCH_POSTFIX=$(ARCH_POSTFIX) $(TEST)
.PHONY: check-unit

REGRESSION_TEST_SUITE_CLASSES = \
	test/functional/jato/internal/VM.java \
	test/functional/java/lang/VMClassTest.java \
	test/functional/java/lang/JNITest.java \
	test/functional/java/lang/reflect/ClassTest.java \
	test/functional/java/lang/reflect/MethodTest.java \
	test/functional/jvm/ArgsTest.java \
	test/functional/jvm/ArrayExceptionsTest.java \
	test/functional/jvm/ArrayMemberTest.java \
	test/functional/jvm/ArrayTest.java \
	test/functional/jvm/BranchTest.java \
	test/functional/jvm/CFGCrashTest.java \
	test/functional/jvm/ClassExceptionsTest.java \
	test/functional/jvm/ClassLoaderTest.java \
	test/functional/jvm/ClinitFloatTest.java \
	test/functional/jvm/CloneTest.java \
	test/functional/jvm/ControlTransferTest.java \
	test/functional/jvm/ConversionTest.java \
	test/functional/jvm/DoubleArithmeticTest.java \
	test/functional/jvm/DoubleConversionTest.java \
	test/functional/jvm/ExceptionsTest.java \
	test/functional/jvm/ExitStatusIsOneTest.java \
	test/functional/jvm/ExitStatusIsZeroTest.java \
	test/functional/jvm/FibonacciTest.java \
	test/functional/jvm/FinallyTest.java \
	test/functional/jvm/FloatArithmeticTest.java \
	test/functional/jvm/FloatConversionTest.java \
	test/functional/jvm/GcTortureTest.java \
	test/functional/jvm/GetstaticPatchingTest.java \
	test/functional/jvm/IntegerArithmeticExceptionsTest.java \
	test/functional/jvm/IntegerArithmeticTest.java \
	test/functional/jvm/InterfaceFieldInheritanceTest.java \
	test/functional/jvm/InterfaceInheritanceTest.java \
	test/functional/jvm/InvokeinterfaceTest.java \
	test/functional/jvm/InvokestaticPatchingTest.java \
	test/functional/jvm/LoadConstantsTest.java \
	test/functional/jvm/LongArithmeticExceptionsTest.java \
	test/functional/jvm/LongArithmeticTest.java \
	test/functional/jvm/MethodInvocationAndReturnTest.java \
	test/functional/jvm/MethodInvocationExceptionsTest.java \
	test/functional/jvm/MethodInvokeVirtualTest.java \
	test/functional/jvm/MonitorTest.java \
	test/functional/jvm/MultithreadingTest.java \
	test/functional/jvm/ObjectArrayTest.java \
	test/functional/jvm/ObjectCreationAndManipulationExceptionsTest.java \
	test/functional/jvm/ObjectCreationAndManipulationTest.java \
	test/functional/jvm/ObjectStackTest.java \
	test/functional/jvm/ParameterPassingTest.java \
	test/functional/jvm/PrintTest.java \
	test/functional/jvm/PutfieldTest.java \
	test/functional/jvm/PutstaticPatchingTest.java \
	test/functional/jvm/PutstaticTest.java \
	test/functional/jvm/RegisterAllocatorTortureTest.java \
	test/functional/jvm/StackTraceTest.java \
	test/functional/jvm/StringTest.java \
	test/functional/jvm/SwitchTest.java \
	test/functional/jvm/SynchronizationExceptionsTest.java \
	test/functional/jvm/SynchronizationTest.java \
	test/functional/jvm/TestCase.java \
	test/functional/jvm/TrampolineBackpatchingTest.java \
	test/functional/jvm/VirtualAbstractInterfaceMethodTest.java \
	test/functional/jvm/lang/reflect/FieldTest.java \
	test/functional/sun/misc/UnsafeTest.java

JASMIN_REGRESSION_TEST_SUITE_CLASSES = \
	test/functional/jvm/DupTest.j \
	test/functional/jvm/EntryTest.j \
	test/functional/jvm/ExceptionHandlerTest.j \
	test/functional/jvm/InvokeResultTest.j \
	test/functional/jvm/InvokeTest.j \
	test/functional/jvm/NoSuchMethodErrorTest.j\
	test/functional/jvm/PopTest.j \
	test/functional/jvm/SubroutineTest.j \
	test/functional/jvm/WideTest.j

compile-java-tests: $(PROGRAM) FORCE
	$(E) "  JAVAC   " $(REGRESSION_TEST_SUITE_CLASSES)
	$(Q) JAVA=$(JAVA) $(JAVAC) -source 1.5 -cp $(GLIBJ):test/functional $(JAVAC_OPTS) -d test/functional $(REGRESSION_TEST_SUITE_CLASSES)
.PHONY: compile-java-tests

compile-jasmin-tests: $(PROGRAM) FORCE
	$(E) "  JASMIN  " $(JASMIN_REGRESSION_TEST_SUITE_CLASSES)
	$(Q) $(JASMIN) $(JASMIN_OPTS) -d test/functional $(JASMIN_REGRESSION_TEST_SUITE_CLASSES) > /dev/null
.PHONY: compile-jasmin-tests

$(RUNTIME_CLASSES): %.class: %.java
	$(E) "  JAVAC   " $@
	$(Q) $(JAVAC) -cp $(GLIBJ) $(JAVAC_OPTS) -d runtime/classpath $<

lib: $(CLASSPATH_CONFIG)
	+$(MAKE) -C lib/ JAVAC=$(JAVAC) GLIBJ=$(GLIBJ)
.PHONY: lib

compile-jni-test-lib:
	+$(MAKE) -C test/functional/jni CC='$(CC)'
.PHONY: compile-jni-test-lib

check-functional: monoburg $(CLASSPATH_CONFIG) $(PROGRAM) compile-java-tests compile-jasmin-tests compile-jni-test-lib
	$(E) "  REGRESSION"
	$(Q) ./tools/test.py
.PHONY: check-functional

check: check-unit check-functional
.PHONY: check

torture:
	$(E) "  MAKE"
	$(Q) $(MAKE) -C torture JAVA=$(JAVA)
.PHONY: torture

clean:
	$(E) "  CLEAN"
	$(Q) - rm -f $(PROGRAM)
	$(Q) - rm -f $(VERSION_HEADER)
	$(Q) - rm -f $(CLASSPATH_CONFIG)
	$(Q) - rm -f $(OBJS)
	$(Q) - rm -f $(OBJS:.o=.d)
	$(Q) - rm -f $(ARCH_TEST_OBJS)
	$(Q) - rm -f arch/$(ARCH)/insn-selector.c
	$(Q) - rm -f $(PROGRAM)
	$(Q) - rm -f $(ARCH_TEST_SUITE)
	$(Q) - rm -f test-suite.o
	$(Q) - rm -f $(ARCH_TESTRUNNER)
	$(Q) - rm -f $(RUNTIME_CLASSES)
	$(Q) - find test/functional/ -name "*.class" | xargs rm -f
	$(Q) - find runtime/ -name "*.class" | xargs rm -f
	$(Q) - rm -f tags
	$(Q) - rm -f include/arch
	+$(Q) - $(MAKE) -C tools/monoburg/ clean >/dev/null
	+$(Q) - $(MAKE) -C boehmgc/ clean >/dev/null
	+$(Q) - $(MAKE) -C test/functional/jni/ clean >/dev/null
	+$(Q) - $(MAKE) -C test/unit/vm/ clean >/dev/null
	+$(Q) - $(MAKE) -C test/unit/jit/ clean >/dev/null
	+$(Q) - $(MAKE) -C test/unit/arch-$(ARCH)/ clean >/dev/null
.PHONY: clean

INSTALL_PREFIX	?= $(HOME)

install: $(PROGRAM)
	$(E) "  INSTALL " $(PROGRAM)
	$(Q) $(INSTALL) -d -m 755 $(INSTALL_PREFIX)/bin
	$(Q) $(INSTALL) $(PROGRAM) $(INSTALL_PREFIX)/bin
.PHONY: install

tags: FORCE
	$(E) "  TAGS"
	$(Q) rm -f tags
	$(Q) ctags-exuberant -a -R arch/
	$(Q) ctags-exuberant -a -R include
	$(Q) ctags-exuberant -a -R jit/
	$(Q) ctags-exuberant -a -R lib/
	$(Q) ctags-exuberant -a -R runtime/
	$(Q) ctags-exuberant -a -R cafebabe/
	$(Q) ctags-exuberant -a -R vm/

PHONY += FORCE
FORCE:

include scripts/build/common.mk

-include $(OBJS:.o=.d)
