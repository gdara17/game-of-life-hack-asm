// The game of life world consists of 2D grid 16x32, the grid is mapped in memory:
// RAM[100] == grid(0, 0)
// RAM[132] == grid(1, 0)
// RAM[611] == grid(16, 31)
//
// RAM[99] contains number of generations to iterate over the Game of life world (aka grid)
//
// Iteration rules:
// For a space that is 'populated':
// * Each cell with one or no neighbours dies, as if by solitude.
// * Each cell with four or more neighbours dies, as if by overpopulation.
// * Each cell with two or three neighbours survives.
//
// For a space that is 'empty' or 'unpopulated'
// * Each cell with three neighbours becomes populated.
//
// initial values are set by test. The are only two values allowed:
// 1 -- the cell is populated
// 0 -- the cell is empty

(LIFE)
    // D = M[99]
    @99
    D=M

    // if (num_epochs == 0) jump to STOP
    @END
    D;JEQ

    // num_epochs--
    @99
    M=M-1

    // call SUCCESSOR_STATE
    @SUCCESSOR_STATE
    0;JMP
    (SUCCESSOR_STATE_RETURN)

    // call UPDATE_WORLD
    @UPDATE_WORLD
    0;JMP
    (UPDATE_WORLD_RETURN)

    @LIFE
    0;JMP


(SUCCESSOR_STATE)
    // p_curr_cell = 100
    @100
    D=A
    @p_curr_cell
    M=D

    // p_curr_cell_copy = p_curr_cell + 900
    @900
    D=A
    @p_curr_cell
    D=D+M // D = p_curr_cell + 900
    @p_curr_cell_copy
    M=D

    (SUCCESSOR_STATE_LOOP)
    // if (num_left == 0): return to SUCCESSOR_STATE_RETURN
    @p_curr_cell
    D=M
    @612
    D=A-D // D = num_left
    @SUCCESSOR_STATE_RETURN
    D;JEQ

    // call GET_NEIGHBOURS
    @GET_NEIGHBOURS
    0;JMP
    (GET_NEIGHBOURS_RETURN)
    @R0
    D=M
    @neighbours
    M=D // save returned value in neighbours

    // switch(neighbours):
    @p_curr_cell
    A=M
    D=M
    @HANDLE_EMPTY_CELL
    D;JEQ
    // if(neighbours < 2 || neighbours > 3): pass
    @neighbours
    D=M // D = neighbours
    @2
    D=D-A
    @CONTINUE
    D;JLT
    @neighbours
    D=M // D = neighbours
    @3
    D=D-A
    @CONTINUE
    D;JGT

    // else: M[p_curr_cell_copy] = 1
    @p_curr_cell_copy
    A=M
    M=1
    @CONTINUE
    0;JMP

    (HANDLE_EMPTY_CELL)
    @neighbours
    D=M // D = neighbours
    // if(neighbours == 3): M[p_curr_cell] = 1
    @3
    D=D-A
    @CONTINUE
    D;JNE
    // M[p_curr_cell_copy] = 1
    @p_curr_cell_copy
    A=M
    M=1

    (CONTINUE)
    // p_curr_cell++, p_curr_cell_copy++
    @p_curr_cell
    M=M+1
    @p_curr_cell_copy
    M=M+1

    @SUCCESSOR_STATE_LOOP
    0;JMP

(UPDATE_WORLD)
    // p_curr_cell = 100
    @100
    D=A
    @p_curr_cell
    M=D

    // p_curr_cell_copy = p_curr_cell + 900
    @900
    D=A
    @p_curr_cell
    D=D+M // D = p_curr_cell + 900
    @p_curr_cell_copy
    M=D

    (UPDATE_WORLD_LOOP)
    // if (num_left == 0): return to UPDATE_WORLD_RETURN
    @p_curr_cell
    D=M
    @612
    D=A-D // D = num_left
    @UPDATE_WORLD_RETURN
    D;JEQ

    // M[p_curr_cell] = M[p_curr_cell_copy]
    @p_curr_cell_copy
    A=M
    D=M
    @p_curr_cell
    A=M
    M=D

    // M[R1] = p_curr_cell
    @p_curr_cell
    D=M
    @R1
    M=D

    // M[R2] = M[p_curr_cell]
    @p_curr_cell
    A=M
    D=M
    @R2
    M=D

    // call DRAW_SQUARE
    @DRAW_SQUARE
    0;JMP

    (DRAW_SQUARE_RETURN)
    // M[p_curr_cell_copy] = 0
    @p_curr_cell_copy
    A=M
    M=0

    // p_curr_cell++, p_curr_cell_copy++
    @p_curr_cell_copy
    M=M+1
    @p_curr_cell
    M=M+1

    @UPDATE_WORLD_LOOP
    0;JMP


(GET_NEIGHBOURS)
    // neighbours = 0
    @neighbours
    M=0

    @p_curr_cell
    D=M
    @100
    D=D-A
    @R1
    M=D // M[R1] = p_curr_cell_index -> for DIV call

    // remainder = p_curr_cell_index % 32
    @31
    D=D&A
    @remainder
    M=D
    
    // M[R2] = 32 -> for DIV call
    @32
    D=A
    @R2
    M=D

    // set RET_ADDR(R16)
    @DIV_RETURN_GET_NEIGHBOURS
    D=A
    @R16
    M=D

    // call DIV
    @DIV
    0;JMP
    (DIV_RETURN_GET_NEIGHBOURS)
    @R0
    D=M
    @quotient
    M=D

    // if(remainder == 0): jump to SKIPPED_NEIGHBOUR_1
    @remainder
    D=M
    @SKIPPED_NEIGHBOUR_1
    D;JEQ

    // D = M[p_curr_cell - 1]
    @p_curr_cell
    A=M-1
    D=M
    // neighbours += M[p_curr_cell - 1]
    @neighbours
    M=M+D

    (SKIPPED_NEIGHBOUR_1)
    // if(remainder == 0): jump to SKIPPED_NEIGHBOUR_2
    @remainder
    D=M
    @SKIPPED_NEIGHBOUR_2
    D;JEQ
    
    // if(quotient == 0): jump to SKIPPED_NEIGHBOUR_2
    @quotient
    D=M
    @SKIPPED_NEIGHBOUR_2
    D;JEQ

    // D = M[p_curr_cell - 33]
    @33
    D=A
    @p_curr_cell
    A=M-D
    D=M
    // neighbours += M[p_curr_cell - 33]
    @neighbours
    M=M+D

    (SKIPPED_NEIGHBOUR_2)
    // if(quotient == 0): jump to SKIPPED_NEIGHBOUR_3
    @quotient
    D=M
    @SKIPPED_NEIGHBOUR_3
    D;JEQ

    // D = M[p_curr_cell - 32]
    @32
    D=A
    @p_curr_cell
    A=M-D
    D=M
    // neighbours += M[p_curr_cell - 32]
    @neighbours
    M=M+D

    (SKIPPED_NEIGHBOUR_3)
    // if(remainder == 31): jump to SKIPPED_NEIGHBOUR_4
    @31
    D=A
    @remainder
    D=M-D
    @SKIPPED_NEIGHBOUR_4
    D;JEQ
    
    // if(quotient == 0): jump to SKIPPED_NEIGHBOUR_4
    @quotient
    D=M
    @SKIPPED_NEIGHBOUR_4
    D;JEQ

    // D = M[p_curr_cell - 31]
    @31
    D=A
    @p_curr_cell
    A=M-D
    D=M
    // neighbours += M[p_curr_cell - 31]
    @neighbours
    M=M+D

    (SKIPPED_NEIGHBOUR_4)
    // if(remainder == 31): jump to SKIPPED_NEIGHBOUR_5
    @31
    D=A
    @remainder
    D=M-D
    @SKIPPED_NEIGHBOUR_5
    D;JEQ

    // D = M[p_curr_cell + 1]
    @p_curr_cell
    A=M+1
    D=M
    // neighbours += M[p_curr_cell + 1]
    @neighbours
    M=M+D

    (SKIPPED_NEIGHBOUR_5)
    // if(remainder == 31): jump to SKIPPED_NEIGHBOUR_6
    @31
    D=A
    @remainder
    D=M-D
    @SKIPPED_NEIGHBOUR_6
    D;JEQ

    // if(quotient == 15): jump to SKIPPED_NEIGHBOUR_6
    @15
    D=A
    @quotient
    D=M-D
    @SKIPPED_NEIGHBOUR_6
    D;JEQ

    // D = M[p_curr_cell + 33]
    @33
    D=A
    @p_curr_cell
    A=M+D
    D=M
    // neighbours += M[p_curr_cell + 33]
    @neighbours
    M=M+D
    
    (SKIPPED_NEIGHBOUR_6)
    // if(quotient == 15): jump to SKIPPED_NEIGHBOUR_7
    @15
    D=A
    @quotient
    D=M-D
    @SKIPPED_NEIGHBOUR_7
    D;JEQ

    // D = M[p_curr_cell + 32]
    @32
    D=A
    @p_curr_cell
    A=M+D
    D=M
    // neighbours += M[p_curr_cell + 32]
    @neighbours
    M=M+D
    
    (SKIPPED_NEIGHBOUR_7)
    // if(remainder == 0): jump to SKIPPED_NEIGHBOUR_8
    @remainder
    D=M
    @SKIPPED_NEIGHBOUR_8
    D;JEQ
    
    // if(quotient == 15): jump to SKIPPED_NEIGHBOUR_8
    @15
    D=A
    @quotient
    D=M-D
    @SKIPPED_NEIGHBOUR_8
    D;JEQ
    
    // D = M[p_curr_cell + 31]
    @31
    D=A
    @p_curr_cell
    A=M+D
    D=M
    // neighbours += M[p_curr_cell + 31]
    @neighbours
    M=M+D

    (SKIPPED_NEIGHBOUR_8)
    // return neighbours
    @neighbours
    D=M
    @R0
    M=D
    @GET_NEIGHBOURS_RETURN
    0;JMP

(DRAW_SQUARE)
    @SCREEN
    D=A
    @addr
    M=D

    // inner_p_curr_cell = M[R1]
    @R1
    D=M
    @inner_p_curr_cell
    M=D

    // filler = -1 if M[R2] == 1 else 0
    @R2
    D=M
    @FILLER_IS_ZERO
    D;JEQ
    D=-1
    (FILLER_IS_ZERO)
    @filler
    M=D

    // inner_p_curr_cell_index  = inner_p_curr_cell - 100
    @inner_p_curr_cell
    D=M
    @100
    D=D-A
    @inner_p_curr_cell_index
    M=D

    // remainder = inner_p_curr_cell_index % 32
    @31
    D=D&A
    @remainder
    M=D

    // offset = (inner_p_curr_cell_index - remainder) * 16
    @inner_p_curr_cell_index
    D=M
    @remainder
    D=D-M
    @R1
    M=D
    
    // M[R2] = 16 -> for MULT call
    @16
    D=A
    @R2
    M=D

    // set RET_ADDR(R16)
    @MULT_RETURN_DRAW_SQUARE
    D=A
    @R16
    M=D

    // call DIV
    @MULT
    0;JMP
    (MULT_RETURN_DRAW_SQUARE)
    @R0
    D=M
    @offset
    M=D

    // update addr
    @remainder
    D=D+M
    @addr
    M=M+D

    // row = 0
    @row
    M=0

    (DRAW_SQUARE_LOOP)
    // if (row > 15): jump to DRAW_SQUARE_RETURN
    @row
    D=M
    @15
    D=D-A
    @DRAW_SQUARE_RETURN
    D;JGT

    // M[addr] = filler
    @filler
    D=M
    @addr
    A=M
    M=D

    @row
    M=M+1
    @32
    D=A
    @addr
    M=D+M
    @DRAW_SQUARE_LOOP
    0;JMP


(MULT)
    // i = R1
    @R1
    D=M
    @i
    M=D
    
    // result = 0
    @result
    M=0

    (MULT_LOOP)
    // if (i == 0) jump to MULT_STOP
    @i
    D=M
    @MULT_STOP 
    D;JEQ
    
    // result += R2
    @R2
    D=M
    @result
    M=D+M

    //i--
    @i
    M=M-1 
    
    @MULT_LOOP
    0;JMP

    (MULT_STOP)
    // R0 = result
    @result
    D=M
    @R0
    M=D

    // return
    @R16
    A=M
    0;JMP

(DIV)
    // numerator = R1
    @R1
    D=M
    @numerator
    M=D

    // denominator = R2
    @R2
    D=M
    @denominator
    M=D
    
    // result = 0
    @result
    M=0

    (DIV_LOOP)
    // if (numerator - denominator < 0) jump to DIV_STOP
    @numerator
    D=M
    @denominator
    D=D-M
    @DIV_STOP
    D;JLT
    
    // result++
    @result
    M=M+1

    // numerator -= denominator
    @denominator
    D=M
    @numerator
    M=M-D
    
    @DIV_LOOP
    0;JMP

    (DIV_STOP)
    // R0 = result
    @result
    D=M
    @R0
    M=D
    
    // return
    @R16
    A=M
    0;JMP


(END)
    @END
    0;JMP