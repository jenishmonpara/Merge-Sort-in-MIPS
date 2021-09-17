# Jenish Monpara
# 1901cs28

.data
alen: .word 4           # alen is array length
temp: .space 400        # extra space which will come handy while merging two sorted arrays into one
array: .space 400       # space for main array
asklen: .asciiz "Enter the size of the array: "
msg1: .asciiz "Enter the numbers in the array:\n"
msg2: .asciiz "Array after Merge Sort:\n"
endl: .asciiz "\n"


.text

.globl main

j main



# merge_sort( starting_address = $a1, ending_address = $a2 ) 
# sorts array within address a1 to a2
merge_sort:

        # return if sub segment of array passed has size 1
        bge $a1,$a2,return

        # calculating mid element's address which is $a3
        sub $t0,$a2,$a1
        div $t0,$t0,4
        div $t0,$t0,2
        mul $t0,$t0,4
        add $a3,$a1,$t0

        # once a recursive call is made; a1,a2,a3,ra will get changed
        # so we need to store them if we want to access them again after any recursive call
        # storing the variables in stack
        sub $sp,$sp,4
        sw $ra,0($sp)
        sub $sp,$sp,4
        sw $a1,0($sp)
        sub $sp,$sp,4
        sw $a2,0($sp)
        sub $sp,$sp,4
        sw $a3,0($sp)

        # sorting the left half by calling merge_sort() after setting new a1 and a2
        move $a2,$a3
        jal merge_sort

        # sorting the right half by calling merge_sort() after setting new a1 and a2
        lw $a1,0($sp)
        lw $a2,4($sp)
        add $a1,$a1,4
        jal merge_sort


        # t1 and t3 are begin and end pointers of left half sorted array
        # t2 and t4 are begin and end pointers of right half sorted array
        # t0 is iterator over temp array which we will use for merging
        lw $t1,8($sp)
        lw $t3,0($sp)
        lw $t4,4($sp)
        add $t2,$t3,4
        la $t0,temp

        merge_loop:
                # if end of left sorted array or right sorted array is reached then break
                bgt $t1,$t3,done_merge
                bgt $t2,$t4,done_merge

                lw $t5,0($t1)
                lw $t6,0($t2)

                # comparing elements at t1 and at t2
                blt $t6,$t5,store2

                store1:
                        sw $t5,0($t0)
                        add $t1,$t1,4
                        j donestore
                store2:
                        sw $t6,0($t0)
                        add $t2,$t2,4

                donestore:

                add $t0,$t0,4
                j merge_loop

        done_merge:


        # if end of left sorted array is not reachwd then we will keep appending its element
        append1:
                bgt $t1,$t3,done_append1
                lw $t5,0($t1)
                sw $t5,0($t0)
                add $t1,$t1,4
                add $t0,$t0,4
                j append1
        done_append1:


        # if end of left sorted array is not reachwd then we will keep appending its element
        append2:
                bgt $t2,$t4,done_append2
                lw $t6,0($t2)
                sw $t6,0($t0)
                add $t2,$t2,4
                add $t0,$t0,4
                j append2
        done_append2:



        copying_to_original_array_from_temp:
                lw $a1,8($sp)
                lw $a2,4($sp)
                la $t0,temp

                copy_loop:
                        bgt $a1,$a2,done_copying
                        lw $t1,0($t0)
                        sw $t1,0($a1)
                        add $t0,$t0,4
                        add $a1,$a1,4
                        j copy_loop
        done_copying:

        # popping elements from stack
        lw $ra,12($sp)
        add $sp,$sp,16
        
        return:
        jr $ra



main:
        takeinputs:

                # asking and storing array size
                li $v0,4
                la $a0,asklen
                syscall
        
                la $t0,alen
                li $v0,5
                syscall
                sw $v0,0($t0)

                li $v0,4
                la $a0,msg1
                syscall

                # setting s1 as array start pointer and s2 as array end pointer and t0 as array iterator
                la $s1,array
                la $s2,array
                lw $t0,alen
                mul $t0,$t0,4
                add $s2,$s2,$t0
                sub $s2,$s2,4
                move $t0,$s1

                # input loop
                loop:
                        # break condition
                        bgt $t0,$s2,doneinput
                        li $v0,5
                        syscall
                        sw $v0,0($t0)

                        # loop update
                        add $t0,$t0,4
                        j loop
        doneinput:


        # setting parameters and calling merge sort
        move $a1,$s1
        move $a2,$s2

        jal merge_sort


        # outputting the new array
	displayoutput:
		li $v0,4
		la $a0, msg2
		syscall
		
		move $t0,$s1
		
		outputloop:
                        # break condition
			bgt $t0,$s2, doneoutput
		
			li $v0, 4
			la $a0, endl
			syscall
			
			li $v0, 1
			lw $a0, 0($t0)
			syscall
			
                        # loop update
			addi $t0,$t0,4
			j outputloop
	doneoutput:

        exit:
		li $v0, 10
		syscall
