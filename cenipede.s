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
	mushroomColor: .word 0x00ff00
	fleaColor: .word 0x800080
	
	bugLocation: .word 814 # location of the bug blaster 
	
	centipedLives : .word 3 #Stores how many lives the centipede currently has 
	centipedLocation: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 #stores where currently the centiped is within the display map 
	centipedDirection: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 #1 means all segments are moving to the right, while -1 means it is to the left
	
	mushroomLocations: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # stores all the locations of the mushrooms 
	
	fleaLocation: .word 0 # stores the current location of the flea
	fleaDropAmount: .word 0 # stores the offset by how much the flea is currently dropped 
	isFleaDropped: .word 0 # boolean value which stores whether a flea is currently being dropped from top to bottom 
	
	
	bugBlastLocation: .word 0 # stores the current offset location of where the bug blast is (shot taken by bug blaster)
	isBugBlast: .word 0 # boolean value which stores whether a shot taken by the user is currently travelling on the screen  
	        
.text 


Loop:
	jal disp_centiped
	jal init_mushroom_locations
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

# "update" function, in charge of updating the locations of all items currently on the scrren
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
	
	#### implementation to color the head of the centipede a different color 
	# Overwrite the head of the centipede with a different color 
	# depending on whether the centipede is moving to the right or to the left, the head we repaint will be a different color 
	# Registers available after the above code has executed: $a3 = 1, $a1 = -1, $a2(centipedDirection), $t1(first term of centipedDirection), $t5 (color yellow), $t2 (displayAddress), $t3 (last term of centipedDirection), $t4.

	#lw $t2, displayAddress # store display address within register $t2
	
	#la $a2, centipedDirection # store address of centipedDirection array 
	#la $a1, centipedLocation 
	
	# load the first and last terms of the centipede dir array into seperate registers 
	#lw $s7, 0($a2)	# contains the address of the first term of the centipedDirection array
	#lw $t3, 36($a2) # contains the address of the last term of the centipedDirection array 
	
	#li $a3, 1 # comparison registers  
	#li $s6, -1
	
	# choose a register, and store the color of the centipede head
	#li $t5, 0xffff00 
		
	#beq $s7, $a3, centipede_moving_right # if first term of centipede direction array is equal to 1, branch to centipede_moving_right
	#beq $t3, $s6, centipede_moving_left  # if last term of centipede direction array equals -1, branch to centipede_moving_left 
	
	#centipede_moving_right:
		# retrieve the last value of the centipede location array 
		#lw $s5, 36($a1) # register $s5 contains the value of the head of the centipede
		#sll $s5, $s5, 2 # multiply this value by 4, for byte offset 
		#add $t2, $t2, $s5 # add to display address to figure out wihch value to overwrite with the color  
		#sw $t5, 0($t2) # store the value of yellow within this register, so that the head is colored yellow
		#j finish_disp_centiped
		
	#centipede_moving_left:
		#lw $s5, 0($a1) # register $t8 contains the value of the head of the centipede
		#sll $s5, $s5, 2 # multiply this value by 4, for byte offset 
		#add $t2, $t2, $s5 # add to display address to figure out wihch value to overwrite with the color  
		#sw $t5, 0($t2) # store the value of yellow within this register, so that the head is colored yellow
		#j finish_disp_centiped
	
	
	# pop a word off the stack and move the stack pointer
	
	# after updating the location of the centipede, check for any keyboard input, to update the location of the bug blaster 
	jal check_keystroke
	
	# update location of bug blast (move it one square upwards, if player has taken a shot)
	
	la $a1, isBugBlast # load in address of the isBugBlast memory location value 
	lw $t0, 0($a1) # load the value of this memory location variable into register $t0  
	beq $t0, 1, branch_update_bug_blast
	bne $t0, 1, branch_not_update_bug_blast
	
	branch_update_bug_blast:
		jal update_bug_blast_location
	
	branch_not_update_bug_blast:
	
	# update location of flea (move it one square downwards)
	jal drop_flea 
	
	# check for collisions between bug blast and any mushroom (if so, color the spot where the bug blast collided with mushroom, black) re-color the mushrooms
	jal redraw_mushrooms 
	
	# check for collisions between bug blast and centipede (if so, reduce number of centipedeLives):
	
	
	# check for collisions between flea and bugBlaster (if so, put up the game over screen)
	
	
	# sleep (add some delay)
	
	
	
	finish_disp_centiped:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	
		jr $ra

# drops a flea from a random point in the topmost part of the board 
drop_flea:
	# load in the isDroppedFlea memory variable and the flea location memory variable
	la $a1, isFleaDropped
	lw $t1, 0($a1) # $t1 now contains the isFleaDropped variable 
	
	li $t4, 1 # set $t4 to have the value 1
	  
	beq $t1, $zero, initFleaLocation # if no flea is currently being dropped, initialize one at a random spot 
	beq $t1, $t4, updateFleaLocation # otherwise, update the current flea being dropped by one spot down  
	
	# means there is currently no flea being dropped, so initialize a flea at a random spot at the top of the board 
	initFleaLocation:	
		la $a0, displayAddress
		lw $t5, 0($a0) # load in the value for the diplay address in register in $t5
		
		la $a2, fleaLocation # load the address of the fleaLocation variable 
		# generate a random integer between 0 to 31 
		# value to signify that we are generating a random integer value 
		li $v0, 42
		# set upper bound on register $a1
		li $a1, 31
		# do a syscall
		syscall
		# random integer is stored within the register $a0 
		sw $a0, 0($a2) #store the random integer within the memory location for "fleaLocation" 
		lw $t2, 0($a2) #after storing it in memory, re-retrieve it and store it in register $t2, it now contains the location of the flea 
		
		la $a1, isFleaDropped
				
		# color in the location of the flea
		sll $t2, $t2, 2 # multiply the random value by 4 to accomodate byte offset 
		add $t5, $t5, $t2 # add the value to display address 
		sw $t7, 0($t5) # store the purple value at this point to signify that a flea has been initialized 
		
		sw $t4, 0($a1) # store the value 1 into the isFleaDropped value to signify that a flea has been dropped 
		
		j end_drop_flea # finish initializing the flea, so we can exit the function 
		
	# otherwise, there is a flea currently being dropped, so update it one spot downwards from where it currently is 
	updateFleaLocation:	
		la $a0, displayAddress
		lw $t5, 0($a0) # load in the value for the diplay address in register $t5
		
		la $a2, fleaLocation 
		lw $t2, 0($a2) # $t2 now contains the fleaLocation variable 
	
		la $a3, fleaDropAmount 
		lw $t3, 0($a3) # $t3 contains the offset of the amount the flea has currently been dropped 
			
		# black out the current location of the flea 
		li $t4, 0x000000 # store value of black into register $t4 
		add $t6, $t2, $t3 # add the values of the flea location and the flea drop amount, to determine the current flea location
		sll $t6, $t6, 2 #multiply this value by 4 to accomodate for byte offset 
		add $t5, $t5, $t6 # add the value to the displayAddress  
		sw $t4, 0($t5) # store a value of black here, so current flea location is blacked out 
		
		la $a0, displayAddress
		lw $t5, 0($a0) # re-load in the value for the diplay address in register $t5
		
		# update the flea location at the new spot (paint new spot purple)
		la $a3, fleaDropAmount 
		lw $t3, 0($a3) # $t3 contains the offset of the amount the flea has currently been dropped
		
		addi $t3, $t3, 32 # add 32 to the current fleaDropAmount 
		sw $t3, 0($a3) # store this value back into the flea drop amount memory location 
		  
		add $t6, $t2, $t3 # add the values of the flea location and the flea drop amount, to determine the current flea location
		sll $t6, $t6, 2 #multiply this value by 4 to accomodate for byte offset 
		add $t5, $t5, $t6 # add the value to the displayAddress
		
		
		la $t8, fleaColor # load in the address of the flea color 
		lw $t9, 0($t8) # load in the value into $t9
		
		sw $t9, 0($t5) # store the purple value at this point to signify that a flea has been initialized 
		
	end_drop_flea:
		jr $ra 
	
# player has taken a shot, so updates the location of this particular shot, and if top most boundary is reached, finishes the shot 
update_bug_blast_location:
	# load in the current value of the bug blaster 
	la $a1, bugLocation
	lw $t0, 0($a1) # contains the current location of the bug blaster 
	
	# load in the current value of the bug blast location
	la $a2, bugBlastLocation
	lw $t1, 0($a2) # contains the current location of the bug blast (offset value)
	
	# load in the display address
	la $a3, displayAddress
	lw $t2, 0($a3) # contains the value of the display address
	
	beq $t1, $zero, paint_new_location # if bugblastLocation register equals zero (first shot taken by user) do not black out previous location, just paint new location
	beq $t1, 832, end_bug_blast_update #bugBlast has reached the end of the board, so reset the value back to zero, and terminate update
	
	
	# load a value of black into a particular register 
	black_out_current_shot_location:
		# black out the current location of the shot, before updating it one row upwards 
		li $t3, 0x000000	# $t3 stores the black colour code 
		sub $t4, $t0, $t1	# subtract the bug blast location value from the buglocation, so that $t4 stores the current blast location
		sll $t4, $t4, 2		# multiply this value by 4, to accomodate for byte size 
		add $t2, $t2, $t4	# add this value to diplay address
		sw $t3, 0($t2)		# load in black color into this value  	
	
	paint_new_location:
		la $a1, bugLocation
		lw $t0, 0($a1) # contains the current location of the bug blaster 
	
		la $a3, displayAddress	#reset the display address value 
		lw $t2, 0($a3) 
	
		li $t5, 0xffffff # store the white value into a register 
	
		addi $t1, $t1, 32 	# add 32 to the value of the bug blast location, to move it one row upwards 
		sub $t4, $t0, $t1	# subtract this value from the bug blaster location, so that we get the exact spot we want to color in 
		sll $t4, $t4, 2		# multiply this value by 4, to accomodate for byte size 
		add $t2, $t2, $t4	# add this value to diplay address
		sw $t5, 0($t2)		# store white value into this new position	
		sw $t1, 0($a2)		# update bug blast memory variable with the new value 
		jr $ra 
		
	end_bug_blast_update:
		sw $zero, 0($a2) #reset bugBlast value back to zero
		la $a1, isBugBlast # load in address of the isBugBlast memory location value 
		sw $zero, 0($a1) # store a value of zero into the isBugBlast memory location to signify end of shot 
		jr $ra
	
# initialize the mushroom location array, by initlializing values for where the 10 mushroom locations are 
init_mushroom_locations:
	# variables used in the operation of the for-loop for assigning random values to each of the 10 
	# mushroom array locations 
	li $t0, 0
	li $t1, 10
	
	# load in the address of the mushroomLocations array 
	la $a2, mushroomLocations 
	
	init_mushroom_locations_for_loop: beq $t0, $t1, end_mushroom_locations_for_loop
		# value to signify that we are generating a random integer value 
		li $v0, 42
		# set upper bound on register $a1
		li $a1, 799
		# do a syscall
		syscall 
		# randomly generated integer value is at $a0
		# store random integer value into the current location of the random mushroom location array 
		sw $a0, 0($a2)
		# iterate $t0 by 1 value 
		addi $t0, $t0, 1
		#iterate the current pointer to the mushroomLocations array by 1 value 
		addi $a2, $a2, 4
		# jump back to the beginning for-loop 
		j init_mushroom_locations_for_loop
	
	# refactored into own function, eliminate this code if time permits 
	end_mushroom_locations_for_loop:
		# after storing the random integer values in the array, display them in the display location
		
		# re-load the for-loop operation variables 
		li $t0, 0
		li $t1, 10
		
		#re-load the address of the mushroomLocations array
		la $a2, mushroomLocations 
		
		#load mushroom color into a register 
		lw $t5, mushroomColor
	
		# load the displayAddress into a particular register 
		lw $t3, displayAddress
	
		init_mushroom_display_array: beq $t0, $t1, end_mushroom_location_operation 	
			# load a value from the mushroom display array 
			lw $t2, 0($a2)
			# multiply this value by 4 to accomodate byte offset 
			sll $t2, $t2, 2
			# add this value to the display address, for the location of the mushroom
			add $t4, $t2, $t3
			# store a value of green into this location of the display
			sw $t5, 0($t4) 
			# iterate $t0 by 1 
			addi $t0, $t0, 1
			# jump to next location of the mushroom display array
			addi $a2, $a2, 4
			# jump back to beginning of array
			j init_mushroom_display_array
		end_mushroom_location_operation:
			# return to where this function was called 
			jr $ra 
			
# redraw mushroom locations 
redraw_mushrooms:
	# re-load the for-loop operation variables 
	li $t0, 0
	li $t1, 10
		
	#re-load the address of the mushroomLocations array
	la $a2, mushroomLocations 
		
	#load mushroom color into a register 
	lw $t5, mushroomColor
	
	# load the displayAddress into a particular register 
	lw $t3, displayAddress
	
	init_mushroom_display_array_redraw: beq $t0, $t1, end_mushroom_location_operation_redraw
		# load a value from the mushroom display array 
		lw $t2, 0($a2)
		# multiply this value by 4 to accomodate byte offset 
		sll $t2, $t2, 2
		# add this value to the display address, for the location of the mushroom
		add $t4, $t2, $t3
		# store a value of green into this location of the display
		sw $t5, 0($t4) 
		# iterate $t0 by 1 
		addi $t0, $t0, 1
		# jump to next location of the mushroom display array
		addi $a2, $a2, 4
		# jump back to beginning of array
		j init_mushroom_display_array_redraw
	end_mushroom_location_operation_redraw:
		# return to where this function was called 
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
		
		
		# load in the address of the tail of the centipede 
		la $a1, centipedLocation
		lw $s0, 36($a1)
		
		# check if the centipede head is at the bottom and branch to the bottom if so, if not move on to checking if it is at one of the boundaries
		jal check_centipede_at_bottom
		
		   
		# for loops to check which boundary the centipede head is currently falling under
		
		# check to see if centipede head is at the left boundary 
		check_left_boundary: add $t3, $zero, $zero
		      		     add $t4, $zero, 992
		      		     li $t5, 0
		      		     li $t6, 31
		start_check_left_boundary: beq $t3, $s0, if_centipede_left_boundary
		       			   beq $t5, $t6, check_right_boundary  
		update_variables_left: addi $t3, $t3, 32
			       	       addi $t5, $t5, 1
			       	       j start_check_left_boundary
		
		# check to see if the centipede head is at the right boundary
		check_right_boundary: addi $t3, $zero, 31
		      		      addi $t4, $zero, 1023
		      		      li $t5, 0
		      		      li $t6, 31
		start_check_right_boundary: beq $t3, $s0, if_centipede_right_boundary
		       			    beq $t5, $t6, else_init_centipede_movement # left and right boundaries are checked, centipede head is not there, so we continue movement  
		update_variables_right: addi $t3, $t3, 32
				 	addi $t5, $t5, 1
				  	j start_check_right_boundary    
		
		#if centipede head at right boundary 
		if_centipede_right_boundary:	
			# move the stack pointer back to pointing at the top, after the init_centipede_movement calls 
			addi $sp, $sp, 4	
			sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack
			
			j update_centipede_down_right # move the centipede in zig-zag fashion when it reaches the right side boundary  
			
		# moves the centipede to the left until the centipede reaches a left boundary 	
		move_centipede_left:
			jal set_movement_left # sets the direction array to have all negative terms 
			
			# make this a while loop that will move the centipede left until it reaches a boundary 
			li $s1, 0
			li $s2, 22
			# if the centipede reaches the left boundary, branch to the left boundary movement case 
			left_movement_while_loop: 
				beq $s1, $s2, if_centipede_left_boundary
				jal moving_centipede_left # moves the centipede left
				finish_centipede_left_update: addi, $s1, $s1, 1 #after moving the centipede left, we move back to this spot 
				j left_movement_while_loop	
		
		# if centipede head at left boundary
		# moves the centipede in a zig-zag fashion when it reaches the left boundary, preparing it to move rightwards after that point 
		if_centipede_left_boundary:
			j update_centipede_down_left # moves the centipede in a zig-zag fashion at a left boundary 
			
		#if centipede head has reached the bottom (leftmost part of bottom row or rightmost part of bottom row)
		if_centipede_bottom:
			# create while loops here that will infinitely move the centipede back and forth 
			li $s1, 0
			li $s2, 13
			li $s3, 0
			li $s4, 32
			jal set_movement_left 
			left_movement_while_loop_bottom: 
				beq $s1, $s2, set_array_right
				jal moving_centipede_left # moves the centipede left
				addi, $s1, $s1, 1 # iterate the counter by 1
				j left_movement_while_loop_bottom
			set_array_right: 
				jal set_movement_right
			right_movement_while_loop_bottom:
				beq $s3, $s4, if_centipede_bottom
				jal move_centipede 
				addi $s3, $s3, 1 # iterate the counter by 1 
				j right_movement_while_loop_bottom
		#else move the centipede accoring to the value within direction array
		else_init_centipede_movement:
			jal move_centipede 
			
		j while_init_centipede_movement
	
	end_init_centipede_movement:
		# game over screen?

# checks if the centipede is at the bottom of the screen
check_centipede_at_bottom:
	# load in the address of the location of the head of the centipede
	la $a1, centipedLocation
	addi $a1, $a1, 36
	lw $t2, 0($a1)
			
	# load in the address of the tail of the centipede 
	la $a1, centipedLocation
	lw $s0, 36($a1)
		
	# check if the centipede head is at the bottom and branch to the bottom if so, if not move on to checking if it is at one of the boundaries
	beq $t2, 822, if_centipede_bottom
	beq $s0, 822, if_centipede_bottom
		
	#beq $t2, 831, if_centipede_bottom
	#beq $s0, 831, if_centipede_bottom 
	
	# if centipede not found, return to where this function was called 
	jr $ra
	
# moves the centipede in zig-zag fashion at the left boundary
update_centipede_down_left:
	init_for_loop_left: # for m in range(10)
		add $s4, $zero, $zero
		add $s5, $zero, 10 # there variables will be used for the initialization and running of the for loop
		# use a register to keep track of the part of by how much the current centipede part is wriggling 
		# downward by
	 	addi $s1, $zero, 32 #val 
		#use a register to keep track of which entries we will iterate by 1, this will start at value 0 (first value) and gradually go up by 1 each time from that point (0, 1, ...)
		li $s2, 0 #j
	start_for_loop_update_left:
		la $a2, centipedDirection
		beq $s4, $s5, end_for_loop_update_left
		# centipede_dir_array[j] = val 
		sll $t6, $s2, 2
		add $a2, $a2, $t6
		sw $s1, 0($a2)
		# k = 0
		li $t5, 0
		# while k < j:
		update_left_while_loop:
			# if(k == j) branch out 
			beq $t5, $s2, end_left_while_loop
			# centipede_dir_array[k] = 0
			la $a2, centipedDirection
			sll $t7, $t5, 2
			add $a2, $a2, $t7
			sw $zero, 0($a2)
			# k += 1
			addi $t5, $t5, 1
			j update_left_while_loop # loop back to the start 
		end_left_while_loop:
			addi $s1, $s1, 1
			addi $s2, $s2, 1
			j update_variables_left_while_loop	
	update_variables_left_while_loop:
		addi $s4, $s4, 1
		addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing (pop) 
		sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack
		jal moving_centipede_left 
		j start_for_loop_update_left 
	end_for_loop_update_left:
		jal set_movement_right # sets all the values of the centipedDirection array to 1, so that centipede is moving right
		j while_init_centipede_movement
		
# changes all the entries of the centipede movement array to 1, so that the centipede is moving right 
set_movement_right:
	# load in registers with value 0 and 10, to represent iterating through each of the entries 
	# of the centipedeDirection array
	li $t0, 0
	li $t1, 10
	li $t3, 1
	
	# while loop to set all the elements of direction array to 1
	while_set_movement_right:
		beq $t0, $t1, end_movement_right
		# re-load the address so that the pointer is back at the initial element 
		la $a2, centipedDirection
		# multiply the current iteration element by 4 for byte offset 
		sll $t2, $t0, 2 
		# add this value to the centipedeDirection array, so that it is pointing to next element 
		add $a2, $a2, $t2
		# store a value of 1 into this position of the centipedeDirArray 
		sw $t3, 0($a2)
		# iterate $t0 by 1 
		addi $t0, $t0, 1
		# jump back to the beginning of the while loop
		j while_set_movement_left 
	end_movement_right:
		jr $ra
					
# changes all the entries of the centipede movement array to -1, so that the centipede is moving left 
set_movement_left:
	# load in registers with value 0 and 10, to represent iterating through each of the entries 
	# of the centipedeDirection array
	li $t0, 0
	li $t1, 10
	li $t3, -1
	
	# while loop to set all the elements of direction array to -1 
	
	while_set_movement_left:
		beq $t0, $t1, end_movement_left
		# re-load the address so that the pointer is back at the initial element 
		la $a2, centipedDirection
		# multiply the current iteration element by 4 for byte offset 
		sll $t2, $t0, 2 
		# add this value to the centipedeDirection array, so that it is pointing to next element 
		add $a2, $a2, $t2
		# store a value of -1 into this position of the centipedeDirArray 
		sw $t3, 0($a2)
		# iterate $t0 by 1 
		addi $t0, $t0, 1
		# jump back to the beginning of the while loop
		j while_set_movement_left 
		
	end_movement_left:
		jr $ra
	
# function in charge of moving the centipede left until it reaches a left boundary 
moving_centipede_left:
	addi $sp, $sp, -4 # Move the stack pointer one point downwards from where it is currently pointing (pop) 
	sw $ra, 0($sp) # Push the contents of the current instruction to the top of the stack

	# re-load both the centipedLocation and centipedDirection arrays 
	la $a1, centipedLocation 
	la $a2, centipedDirection
	
	#clear the tail end of the centipede, before moving it to the right 
	
	# retrieve the displayAddress in the $t7 register
	lw $t7, displayAddress
	# store the value of the first entry in the centipedLocation array
	lw $t6, 36($a1)
	# multiply this value by 4, since each of the pixels are 4 bytes
	sll $t6, $t6, 2
	# add the centipedOffset by display address to get the exact address of the tail end of the centipede 
	add $t1, $t7, $t6
	
	# store a value of black into this memory address (if no mushroom exists at this location, otherwise keep moving)
	li $t9, 0x000000
	sw $t9, 0($t1) 
	
	# we iterate through each of the 10 locations of the centipede body, and update each of them by adding one to each of the locations 	
	addi $t2, $zero, 10
	add $t3, $zero, $zero
	
	while_move_centipede_left: beq $t2, $t3, end_left
		lw $t1, 0($a1)		# load a word from the centipedLocation array into $t1
		lw $t5, 0($a2)		# load a word from the centipedDirection  array into $t5
		add $t6, $t1, $t5	# add both of these words together  
		sw $t6, 0($a1)		# store the sum in the centipedLocation array
		addi $a1, $a1, 4	# iterate the current pointer in the centipedLocation array by 1 
		addi $a2, $a2, 4	# iterate the current pointer in the centipedDirection array by 1
		addi $t3, $t3, 1	# iterate the counter by 1 
		j while_move_centipede_left
			
	end_left: jal disp_centiped # after displaying the centipede, move back to the for loop
		  #j finish_centipede_left_update
	     	  # pop a word off the stack and move the stack pointer
	     	  jal check_centipede_at_bottom 
	     	  lw $ra, 0($sp)
	     	  addi $sp, $sp, 4
	     	  jr $ra
	     

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
	     # after displaying the centipede, check if the centipede has reached the bottom
	     jal check_centipede_at_bottom
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
	
	# update the value of the bugLocation variable
	la $t0, bugLocation	# load the address of buglocation from memory
	sw $t1, 0($t0)		# load the current location of bugBlaster back to this memory value 
	
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
	# update the value of the bugLocation variable
	la $t0, bugLocation	# load the address of buglocation from memory
	sw $t1, 0($t0)		# load the current location of bugBlaster back to this memory value 
	
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
	
	li $t0, 1 # load in a value of 1 into a chosen register 
	
	la $a3, isBugBlast # load in the address for boolean value of whether a bug blast is currently active 
	
	sw $t0, 0($a3) # store the value of 1 into isBugBlast to signify that the player has taken a shot  
	
	
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
