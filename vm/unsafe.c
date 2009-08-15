/*
 * Copyright (c) 2009 Pekka Enberg
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

#include "jit/exception.h"

#include "arch/atomic.h"

#include "vm/reflection.h"
#include "vm/preload.h"
#include "vm/object.h"
#include "vm/unsafe.h"
#include "vm/jni.h"

jint native_unsafe_compare_and_swap_int(struct vm_object *this,
					struct vm_object *obj, jlong offset,
					jint expect, jint update)
{
	void *p = &obj->fields[offset];

	return atomic_cmpxchg_32(p, (uint32_t)expect, (uint32_t)update) == (uint32_t)expect;
}

jint native_unsafe_compare_and_swap_object(struct vm_object *this,
					   struct vm_object *obj,
					   jlong offset,
					   struct vm_object *expect,
					    struct vm_object *update)
{
	void *p = &obj->fields[offset];

	return atomic_cmpxchg_ptr(p, expect, update) == expect;
}

jlong native_unsafe_object_field_offset(struct vm_object *this,
					struct vm_object *field)
{
	struct vm_field *vmf;

	vmf = vm_object_to_vm_field(field);
	if (!vmf)
		return 0;

	return vmf->offset;
}
