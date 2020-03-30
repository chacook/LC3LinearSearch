; Author:      Chad Cook
; Version:     2020/03/07
;
; Purpose:     Calls a subroutine to linearly search a source array to find the position of various targets in the source array
;
; Main Register Dictionary:
; --------------------
; R0 - input/output
; R1 - pointer to current target
; R2 - number of remaining targets
; R3 - work on return value
; R4 - ASCII offset
; R5 - temp storage of subroutine parameters
; R6 - stack pointer
; R7 - PC counter

;
; Static Variables:
; -----------------
; STACKBASE - base of runtime stack used during linearSearch call
; TARGETS - starting address of targets array
; NUMTARGETS - length of targets array
; SOURCE - starting address of source array (the array that is searched)
; N - length of source array


.orig x3000

;initialize stack pointer
ld r6,STACKBASE

;get pointer to first target
lea r1,TARGETS

;get number of targets
ld r2,NUMTARGETS

;loop through targets
LOOP
brnz END_LOOP

;push address of source array onto stack (first param for linearSearch)
lea r5,SOURCE
add r6,r6,#-1
str r5,r6,#0

;push length of source array onto stack (second param for linearSearch)
ld r5,N
add r6,r6,#-1
str r5,r6,#0

;push current target onto stack (third param for linearSearch)
add r6,r6,#-1
str r1,r6,#0

;leave an empty space for return value of linearSearch
add r6,r6,#-1

;call linear search subroutine
jsr linearSearch

;get return value (position of target in source array)
ldr r3,r6,#0

;if pos > 0
brn NOTFOUND

;print found message
lea r0,FOUNDMSG
puts

;print target's position in source array
and r0,r0,#0
ld r4,ASCII
add r0,r3,r4
out
br ENDPRINT

;else, print not found message
NOTFOUND
lea r0,NOTFOUNDMSG
puts

ENDPRINT

;reinitialize stack pointer
ld r6,STACKBASE

;move target pointer to next target
add r1,r1,#1

;decrement number of remaining targets
add r2,r2,#-1

br LOOP
END_LOOP

lea r0,EOPMSG
puts

halt

; Subroutine linearSearch
; Params: address of source array, length of source array, target to find in source array
; Return: earliest position that target is found in source array, if the target is found. If not found, returns -1
; Purpose: performs a linear search to determine the earliest position of a given target in the source array

; linearSearch Register Dictionary:
; --------------------
; R1 - address of current element in source array
; R2 - number of remaining elements to search in source array
; R3 - inverse of target
; R4 - workspace to set default return value/determine if element == target
; R5 - frame pointer
; R6 - stack pointer
; R7 - PC counter

linearSearch

;push previous R5 on the stack
add r6,r6,#-1
str r5,r6,#0

;set R5 as frame pointer
and r5,r5,#0
add r5,r6,#1

;push previous R1 on stack
add r6,r6,#-1
str r1,r6,#0

;push R2
add r6,r6,#-1
str r2,r6,#0

;push R3
add r6,r6,#-1
str r3,r6,#0

;push R4
add r6,r6,#-1
str r4,r6,#0

;----- begin subroutine work -----

;set default return value to -1
and r4,r4,#0
add r4,r4,#-1
str r4,r5,#0

;get inverse of target
ldr r3,r5,#1
ldr r3,r3,#0
not r3,r3
add r3,r3,#1

;get address of first element in array
ldr r1,r5,#3

;get length of array (number of remaining elements)
ldr r2,r5,#2

LSLOOP
brnz END_LSLOOP

;get current array element
ldr r4,r1,#0

;add target inverse to current array element
add r4,r4,r3

;check if result = 0,
brnp NOT_EQUAL

;if so, get position in source array
add r4,r2,#-10
not r4,r4
add r4,r4,#1

;set return value
str r4,r5,#0

;exit loop
br END_LSLOOP

NOT_EQUAL

;increment source array pointer
add r1,r1,#1

;decrement number of remaining elements
add r2,r2,#-1

br LSLOOP
END_LSLOOP

;----- subroutine work is done -----

;restore R4 by popping off the stack
ldr r4,r6,#0
add r6,r6,#1

;pop R3
ldr r3,r6,#0
add r6,r6,#1

;pop R2
ldr r2,r6,#0
add r6,r6,#1

;pop R1
ldr r1,r6,#0
add r6,r6,#1

;pop R5
ldr r5,r6,#0
add r6,r6,#1

ret
; end linearSearch subroutine

ASCII .fill x30
FOUNDMSG .stringz "\nFound at position: "
NOTFOUNDMSG .stringz "\nNot found."
EOPMSG .stringz "\nEnd of Processing.\nProgrammed by Chad Cook.\n"
N .fill #10
SOURCE .fill #99
.fill #-33
.fill #57
.fill #0
.fill #29
.fill #-123
.fill #17
.fill #79
.fill #-1
.fill #22
NUMTARGETS .fill #4
TARGETS .fill #99
.fill #-123
.fill #22
.fill #88
STACKBASE .fill x4000

.end