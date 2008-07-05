# uint64_t rdtsc();

        .text
.globl rdtsc
        .type rdtsc, @function
rdtsc:
        pushl %ebx
        movl $0, %eax
        cpuid
        rdtsc
        movl %eax, -8(%esp)
        movl %edx, -4(%esp)
        movl $0, %eax
        cpuid
        movl -8(%esp), %eax
        movl -4(%esp), %edx
        popl %ebx
        ret
        .size rdtsc, .-rdtsc
