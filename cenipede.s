#####################################################################
#
# CSC258H Winter 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Maadhav Adit Krishnan, 1004270380
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the project handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the project handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

# .data can be thought of as the place where data is stored in memory (allocated to RAM), they are essentially where variables are stored 
.data
	displayAddress:	.word 0x10008000
	bugLocation: .word 814 # location of the bug blaster 
	centipedLives : .word 3 #Stores how many lives the centipede currently has 
	centipedLocation: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 #Array of values 
	centipedDirection: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 #1 means all segments are moving to the right, while -1 means it is to the left 
.text 

Loop:
	jal check_keystroke
	jal disp_centiped
	jal init_centipede_movement 
	
	j Loop	

Exit:
	li $v0, 10		# terminate the program gracefully
	syscall


# Registers and what values it appears each one is storing
# $sp: stack pointer, dictates what function is completely being executed and we can pop and push elements from it like any
# other stack
# $ra: program counter, contains the current instruction being executed 
# $a1: contains centipedLocation
# $a2: contains centipedDirection
# $a3: loaded with value 10 (the number of times the arr_loop is going to run)
# $t1: contains the first word value from centipedLocation
# $t2: contains the first word value from centipedDirection
# $t3: stores the red color code 
# $t4: The current location of the centipede part we are coloring in
# $t5: contains the first word from centipedDirection array
# $t8: contains the hexadecimal value of 0xffff0000 

# function to display a static centiped	
disp_centiped:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing 
	sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack
	
	addi $a3, $zero, 10	 # load a3 with the loop count (10)
	la $a1, centipedLocation # load the address of the array into $a1
	la $a2, centipedDirection # load the address of the array into $a2

arr_loop:			 # iterate over the loops elements to draw each body in the centiped
	lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1
	lw $t5, 0($a2)		 # load a word from the centipedDirection  array into $t5
	#####
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0xff0000	# $t3 stores the red colour code
		
	sll $t4,$t1, 2		# $t4 is the bias of the old body location in memory (offset*4) (shift the value in register $t1 by 2 bits to the left and store it in $t4)
				# Why is this line needed? It is because each location in the display array is comprised of 4 bytes, so we load the centipede location values, and 
				# multiply each of them by 4 to accomodate for this, then add them to the base address
	add $t4, $t2, $t4	# $t4 is the address of the old bug location (add the value stored in register $t2 to the register $t4)
	sw $t3, 0($t4)		# paint the body with red

	addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array (to point to next body part of centipede)
	addi $a2, $a2, 4	 # increment $a2 by one, to point to next element in the centipedeDirectionArray
	addi $a3, $a3, -1	 # decrement $a3 by 1
	bne $a3, $zero, arr_loop
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


# main function that controls the zig zag movement of the centipede 
init_centipede_movement:
	#t1: contains the current number of centipede lives 
	#a1: contains the address of the centipedLocation array
	#t2: contains the location of the centipede head
	#t3: dummy variable in left boundary for loop, that stores values 0, 32, 64, ..., 992, to check if the centipede head falls anywhere there
	#t4: contains the value 992 (leftmost pixel in the last row)
	#t5: initilized with the value 0, and will have values 0, 1, ...., 31 to represent the leftmost boundaries we are checking of each row
	#t6: contains value 31, to represent we have checked all the leftmost boundaries and will be moving on to checking the rightmost boundary 
	# check right boundary will be containing the same registers with each register serving the same purpose, but values will be tweaked to serve the right boundary 

	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing (pop) 
	sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack



	# main centipede movement while loop
	while_init_centipede_movement: beqz $t1, end_init_centipede_movement # if centipede lives is at 0, its game over, otherwise keep moving it 
		# load the centipede lives value stored in RAM to a function register value 
		lw $t1, centipedLives
	
		# load in the address of the location of the head of the centipede
		la $a1, centipedLocation
		addi $a1, $a1, 36
		lw $t2, 0($a1)
		
		# check if the centipede head is at the bottom and branch to the bottom if so, if not move on to checking if it is at one of the boundaries
		beq $t2, 800, if_centipede_bottom
		beq $t2, 831, if_centipede_bottom
		
		# for loops to check which boundary the centipede head is currently falling under
		
		# check to see if centipede head is at the left boundary 
		check_left_boundary: add $t3, $zero, $zero
		      		     addi $t4, $t4, 992
		      		     addi $t5, $t5, 0
		      		     addi $t6, $t6, 31
		start_check_left_boundary: beq $t3, $t2, if_centipede_left_boundary
		       			   beq $t5, $t6, check_right_boundary  
		update_variables_left: addi $t3, $t3, 32
		        	       addi $t5, $t5, 1
		        	       j start_check_left_boundary
		
		# check to see if the centipede head is at the right boundary
		check_right_boundary: addi $t3, $zero, 31
		      		      addi $t4, $t4, 1023
		      		      addi $t5, $t5, 0
		      		      addi $t6, $t6, 31
		start_check_right_boundary: beq $t3, $t2, if_centipede_right_boundary
		       			    beq $t5, $t6, else_init_centipede_movement # left and right boundaries are checked, centipede head is not there, so we continue movement  
		update_variables_right: addi $t3, $t3, 32
				 	addi $t5, $t5, 1
				  	j start_check_right_boundary    
		
		#if centipede head at right boundary 
		if_centipede_right_boundary:
			add $t3, $t3, $zero
			add $t4, $t4, 10
			
			# move the stack pointer back to pointing at the top, after the init_centipede_movement calls 
			addi $sp, $sp, 4	
			sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack
			
			j update_centipede_down_right # move the centipede in zig-zag fashion when it reaches the right side boundary  
			
			
		# moves the centipede to the left until the centipede reaches a left boundary 	
		move_centipede_left:
		
				
			
		
		#if centipede head at left boundary 
		if_centipede_left_boundary:
		

		#if centipede head has reached the bottom (leftmost part of bottom row or rightmost part of bottom row)
		if_centipede_bottom:
		
		
		#else move the centipede accoring to the value within direction array
		else_init_centipede_movement:
			jal move_centipede 
			
		j while_init_centipede_movement
	
	end_init_centipede_movement:
		# game over screen?

		
#moves the centipede down when it is at a right boundary 
update_centipede_down_right:		
	init_for_loop: # for m in range(10)
		       add $s4, $zero, $zero
		       add $s5, $zero, 10 # there variables will be used for the initialization and running of the for loop
		       # use a register to keep track of the part of by how much the current centipede part is wriggling 
		       # downward by
	 	       addi $s1, $zero, 31 #val 
		       #use a register to keep track of which entries we will iterate by 1, this will start at value 10 and gradually go down by 1 each time from that point (9, 8, ...)
		       addi $s2, $zero, 9 #j
	start_for_loop: 
			#retrieve the centipedDirection arrays
			la $a2, centipedDirection
			beq $s4, $s5, exit_for_loop
			#centipede_dir_array[j] += val
			sll $t6, $s2, 2 # do 9*4, to calculate the offset value for the 9th element in the centiped dir array
			add $a2, $t6, $a2 # add this value to $a2 (pointer to first element in the array), so that we are currently 
					  # pointing at the 9th element in the array) (head of the centipede)
			lw $t7, 0($a2) # load into regiester $t7 the current value at this point in the array
			add $t7, $t7, $s1 # add the value $t1 to the $t7 register (moving that part of the centipede down from the right boundary)
			sw $t7, 0($a2) # store this value back into the array 
			#if(9 - j > 0)
			addi $t8, $t8, -9
			#register $t9 contains 9 - j now
			add $t9, $t8, $s2
			bgtz $t9, case_while_loop
			case_while_loop:
				init_while_loop:
					addi $t6, $s2, 1 # k = j + 1 
					addi $a0, $a0, 10
					addi $a1, $a1, 0
				# while k < 10:
				start_while_loop: beq $a0, $a1, end_while_loop
						  # multiply k by 4 to accomodate for array size offset 
						  sll $t6, $t6, 2						 
						  #re-load the address of the centiped_dir_array 
						  la $a2, centipedDirection
						  #we are now pointing at the element of the k index within the dir array
						  add $a2, $a2, $t6
						  #centipede_dir_array[k] = 0
						  sw $zero, 0($a2)
						  # k += 1
						  addi $t6, $t6, 1
				end_while_loop:
						addi $s1, $s1, -1
						addi $s2, $s2, -1
						j update_for_loop
	update_for_loop: addi $s4, $s4, 1	
			 #addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing (pop) 
			 #sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack
			 jal move_centipede 
			 j start_for_loop
	
	exit_for_loop: 
		 	j move_centipede_left 
		     		 	
		
# function used in moving the centipede one location from where it currently is (either one spot right, down, or left)
# (note on its own, all this function does is add the array values of centipedDirection to centipedLocation array and save those 
# values. A call to displayCentiped is required to display the centipede)
move_centipede:
	addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing (pop) 
	sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack

	# re-load both the centipedLocation and centipedDirection arrays 
	la $a1, centipedLocation 
	la $a2, centipedDirection
	
	#clear the tail end of the centipede, before moving it to the right 
	
	# retrieve the displayAddress in the $t7 register
	lw $t7, displayAddress
	# store the value of the first entry in the centipedLocation array
	lw $t6, 0($a1)
	# multiply this value by 4, since each of the pixels are 4 bytes
	sll $t6, $t6, 2
	# add the centipedOffset by display address to get the exact address of the tail end of the centipede 
	add $t1, $t7, $t6
	
	# store a value of black into this memory address
	li $t9, 0x000000
	sw $t9, 0($t1) 
	
	# we iterate through each of the 10 locations of the centipede body, and update each of them by adding one to each of the locations 	
	addi $t2, $zero, 10
	add $t3, $zero, $zero
	
	while_move_centipede: beq $t2, $t3, end
		lw $t1, 0($a1)		# load a word from the centipedLocation array into $t1
		lw $t5, 0($a2)		# load a word from the centipedDirection  array into $t5
		add $t6, $t1, $t5	# add both of these words together  
		sw $t6, 0($a1)		# store the sum in the centipedLocation array
		addi $a1, $a1, 4	# iterate the current pointer in the centipedLocation array by 1 
		addi $a2, $a2, 4	# iterate the current pointer in the centipedDirection array by 1
		addi $t3, $t3, 1	# iterate the counter by 1 
		j while_move_centipede
			
	end: jal disp_centiped
	     # pop a word off the stack and move the stack pointer
	     lw $ra, 0($sp)
	     addi $sp, $sp, 4
	     jr $ra

# function to detect any keystroke
check_keystroke:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t8, 0xffff0000
	beq $t8, 1, get_keyboard_input # if key is pressed, jump to get this key
	addi $t8, $zero, 0
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# function to get the input key
get_keyboard_input:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x6A, respond_to_j
	beq $t2, 0x6B, respond_to_k
	beq $t2, 0x78, respond_to_x
	beq $t2, 0x73, respond_to_s
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# Call back function of j key
respond_to_j:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation (we multiply by 4 since we need 4 bytes to draw the bug?)
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	beq $t1, 800, skip_movement # prevent the bug from getting out of the canvas
	addi $t1, $t1, -1	# move the bug one location to the right
skip_movement:
	sw $t1, 0($t0)		# save the bug location

	li $t3, 0xffffff	# $t3 stores the white colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# Call back function of k key
respond_to_k:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the block with black
	
	beq $t1, 831, skip_movement2 #prevent the bug from getting out of the canvas
	addi $t1, $t1, 1	# move the bug one location to the right
skip_movement2:
	sw $t1, 0($t0)		# save the bug location

	li $t3, 0xffffff	# $t3 stores the white colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the block with white
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
respond_to_x:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $v0, $zero, 3
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
respond_to_s:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $v0, $zero, 4
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

delay:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a2, 10000
	addi $a2, $a2, -1
	bgtz $a2, delay
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
