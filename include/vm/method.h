#ifndef __VM_METHOD_H
#define __VM_METHOD_H

#include <vm/vm.h>
#include <vm/types.h>

#include <stdbool.h>
#include <string.h>

static inline enum vm_type method_return_type(struct methodblock *method)
{
	char *return_type = method->type + (strlen(method->type) - 1);
	return str_to_type(return_type);
}

#include <cafebabe/code_attribute.h>
#include <cafebabe/class.h>
#include <cafebabe/method_info.h>

#include <jit/compilation-unit.h>
#include <jit/compiler.h>

#include <vm/buffer.h>

struct vm_class;

struct vm_method {
	struct vm_class *class;
	const struct cafebabe_method_info *method;

	char *name;

	struct cafebabe_code_attribute code_attribute;

	struct compilation_unit *compilation_unit;
	struct jit_trampoline *trampoline;

	void *jit_code;
};

int vm_method_init(struct vm_method *vmm,
	struct vm_class *vmc, unsigned int method_index);

static inline bool vm_method_is_static(struct vm_method *vmm)
{
	return vmm->method->access_flags & CAFEBABE_METHOD_ACC_STATIC;
}

static inline bool vm_method_is_native(struct vm_method *vmm)
{
	return vmm->method->access_flags & CAFEBABE_METHOD_ACC_NATIVE;
}

static inline bool vm_method_is_constructor(struct vm_method *vmm)
{
	return strcmp(vmm->name, "<init>") == 0;
}

int vm_method_prepare_jit(struct vm_method *vmm);

static inline void *vm_method_trampoline_ptr(struct vm_method *vmm)
{
	return buffer_ptr(vmm->trampoline->objcode);
}

#endif
