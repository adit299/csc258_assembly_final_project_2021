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
		check_left_boundary: li $t3, 0
		      		     li $t4, 992
		      		     li $t5, 0
		      		     li $t6, 31
		start_check_left_boundary: beq $t3, $t2, if_centipede_left_boundary
		       			   beq $t5, $t6, check_right_boundary  
		update_variables_left: addi $t3, $t3, 32
		        	       addi $t5, $t5, 1
		        	       j start_check_left_boundary
		
		# check to see if the centipede head is at the right boundary
		check_right_boundary: li $t3, 31
		      		      li $t4, 1023
		      		      li $t5, 0
		      		      li $t6, 31
		start_check_right_boundary: beq $t3, $t2, if_centipede_right_boundary
		       			    beq $t5, $t6, else_init_centipede_movement # left and right boundaries are checked, centipede head is not there, so we continue movement  
		update_variables_right: addi $t3, $t3, 32
				 	addi $t5, $t5, 1
				  	j start_check_right_boundary    
		
		#if centipede head at right boundary 
		if_centipede_right_boundary:	
			addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing 
			sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack
			jal update_centipede_down_right # update the centipede to move in a zig-zag pattern on a rightside boundary
			shift_centipede_direction_left_label:
				jal shift_centipede_direction_left # update the centipede to shift direction to move to the left 
			
			# centipede has completed boundary looping movement, and will continue to move left 
			j else_init_centipede_movement
		
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
		

#sets all the values of the centipede direction vector to -1, so that the centipede shifts direction to moving to the left 
shift_centipede_direction_left:
	# set a register with the value of -1
	li $t0, -1
	
	# load the address of the beginning of the centipedDirArray
	la $a1, centipedDirection
	
	# iterate through the 10 locations of the centipedDirection array 
	
	#initialize registers with the values of zero and ten 
	li $t2, 0
	li $t3, 10
	
	#start the for-loop to iterate through the locations of the centipedLocations array 
	start_shift_direction_loop:
				# if done with iterating through every section of the centipedDirection array end the loop
				beq $t2, $t3, end_shift_direction_loop
				# multiply the array element offset by 4 to accomodate for the byte size 
				sll $t4, $t2, 2
				# add this amount to the array address to access the next element 
				add $t5, $a1, $t4
				# store negative value to this array location	
				sw $t0, 0($t5)
				# iterate the current array position by 1 
				addi $t2, $t2, 1
				j start_shift_direction_loop
			
	end_shift_direction_loop:
				jr $ra 
	
#moves the centipede down when it is at a right boundary into a proper rightside zig zag pattern  
update_centipede_down_right:
	# set a register with the value of 0
	li $t1, 0
	# set all the array values to equal zero 
	la $a2, centipedDirection
	# for m in range(10)
	add $s4, $zero, $zero
	add $s5, $zero, 10 # there variables will be used for the initialization and running of the for loop
	
	start_zero_for_loop:
		beq $s4, $s5, init_for_loop
		# shift current offset by 2 spots (mutliply by 4)
		sll $s6, $s4, 2
		# add this amount to the pointer to the address 
		add $s7, $s6, $a2
		sw $t1, 0($s7)
		# iterate $s4 by 1
		addi $s4, $s4, 1
		j start_zero_for_loop
	
																																																																																																																																																																																																																																																																			
	init_for_loop: # for m in range(10)
		       add $s4, $zero, $zero
		       add $s5, $zero, 10 # there variables will be used for the initialization and running of the for loop
		       # use a register to keep track of the part of by how much the current centipede part is wriggling 
		       # downward by
	 	       addi $s3, $zero, 41 #val 
		       #use a register to keep track of which entries we will iterate by 1, this will start at value 10 and gradually go down by 1 each time from that point (9, 8, ...)
		       addi $s2, $zero, 0 #j
		       # set register to have value -1 so that we can load 
		       li $s7, -1
		       
	start_for_loop: 
			#retrieve the centipedDirection arrays
			la $a2, centipedDirection
			beq $s4, $s5, exit_for_loop
			
			#centipede_dir_array[j] = val
			sll $t6, $s2, 2 # do 9*4, to calculate the offset value for the 9th element in the centiped dir array
			add $a2, $t6, $a2 # add this value to $a2 (pointer to first element in the array), so that we are currently 
					  # pointing at the 9th element in the array) (head of the centipede)
			sw $s3, 0($a2) # store this value back into the array 
			
			case_while_loop:
				init_while_loop:
					li $a1, 0
					
				# while l < j:
				start_while_loop: beq $s2, $a1, update_for_loop
						  #re-retrieve the address of the centipede_direction array 
						  la $a2, centipedDirection  
						  # shift l by 2 bits (and store it in $t7)
						  sll $t7, $a1, 2
						  # add this value to $a2
						  add $a2, $a2, $t7
						  # set that element to equal -1
						  sw $s7, 0($a2)
						  # l += 1
						  addi $a1, $a1, 1 	  
						  j start_while_loop
	update_for_loop: addi $s2, $s2, 1 # j += 1
			 addi $s3, $s3, -1 # val -= 1
			 addi $s4, $s4, 1 	
			 #addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing (pop) 
			 #sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack
			 jal move_centipede_update_right
			 j start_for_loop
	
	exit_for_loop: 
			j shift_centipede_direction_left_label
		 	

# function used in moving the centipede one location from where it currently is (either one spot right, down, or left)
# (note on its own, all this function does is add the array values of centipedDirection to centipedLocation array and save those 
# values. A call to displayCentiped is required to display the centipede)
move_centipede_update_right:
	addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing (pop) 
	sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack

	# re-load both the centipedLocation and centipedDirection arrays 
	la $a1, centipedLocation 
	la $a2, centipedDirection
	
	#clear the tail end of the centipede, before moving it to the right 
	
	# retrieve the displayAddress in the $t7 register
	lw $t7, displayAddress
	
	# get the value in the j register and retrieve the element in the array that matches that index number  
	# shift the j value by 4 bytes to account for byte size 
	sll $s3, $s2, 2
	# shift the pointer in the centipedLocation array to point to this location
	add $a1, $a1, $s3
	# load in that value 
	lw $t2, 0($a1)
	
	# shift that value by 4 bits
	sll $t2, $t2, 2
	
	# add that to the displayAddress to store the value that we want to black out
	add $t1, $t2, $t7
		
	# store the value of the last entry in the centipedLocation array
	#lw $t6, 36($a1)
	# multiply this value by 4, since each of the pixels are 4 bytes
	#sll $t6, $t6, 2
	# add the centipedOffset by display address to get the exact address of the tail end of the centipede 
	#add $t1, $t7, $t6
	
	# store a value of black into this memory address
	addi $t1, $t1, 4
	li $t9, 0x000000
	sw $t9, 0($t1) 
	
	# we iterate through each of the 10 locations of the centipede body, and update each of them by adding one to each of the locations 	
	addi $t2, $zero, 10
	add $t3, $zero, $zero
	
	# re-load both the centipedLocation and centipedDirection arrays, so that pointers are in first poistion again  
	la $a1, centipedLocation 
	la $a2, centipedDirection
	
	while_move_centipede_update_right: beq $t2, $t3, end
		lw $t1, 0($a1)		# load a word from the centipedLocation array into $t1
		lw $t5, 0($a2)		# load a word from the centipedDirection  array into $t5
		add $t6, $t1, $t5	# add both of these words together  
		sw $t6, 0($a1)		# store the sum in the centipedLocation array
		addi $a1, $a1, 4	# iterate the current pointer in the centipedLocation array by 1 
		addi $a2, $a2, 4	# iterate the current pointer in the centipedDirection array by 1
		addi $t3, $t3, 1	# iterate the counter by 1 
		j while_move_centipede_update_right
			
	end_update_right: jal disp_centiped
	     		  # pop a word off the stack and move the stack pointer
	     		  lw $ra, 0($sp)
	     		  addi $sp, $sp, 4
	     		  jr $ra

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
