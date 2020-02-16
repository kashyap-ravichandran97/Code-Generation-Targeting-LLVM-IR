# Code Generation Targeting LLVM IR

A Lisp Based Programming Language is compiled and is represented using LLVM IR. I have used Bison and Flex to parse and scan the file respectively. 

## Programming Rules 

| Rules | Explanation |
| ----  | ----- | 
| ( + 1 2 ) | Add the operands and returns the result |
| ( - 1 ) | Negates the operand |
| ( * 1 2 ) | Returns the product of the operands |
| ( / 5 2 ) | Returns the Quotient of the operands |
| ( min 1 2 ) | Returns the Minimum of the value that are passed as arguments |
| ( max 1 2 ) | Returns the Maximum of the value that are passed as arguments |
| ( make-array a 100 1 ) | Creates an array A of size 100 and initializes the element to the value 1 |
| ( aref a 1 ) | Used to refer the 1st element of the array |
| ( setf i 1 ) | assigns the ith position to the value 1. The i value is obtained using the aref function|

Separate one function from another using the enter key. 

## Tokens Identified

Apart from the function names mentioned in the table, the scanner picks up numbers, letters and underscores, "\t"s and "\n"s.

## Exception and Violations 

The language is extremely limited and the programming using the given language would rise to very few exceptions. These are trapped and an error message is printed before aborting the program. Run time execution errors like divide by zero, seg faults are allowed to rise an exception when the program runs. 

## How the main program functions :

A starter code was provided which dumps the generated function into a module with the name of the test file and the module has two arguments an array and its size. 
The C++ representation of the function using the rules mentioned above is as follows
  
        int p1_program(int arg_size, int *arg_array)
        {
             // do something
             return 0;
         }

The return value is the result of the last function that is executed by the program. 


## Creating a test file

Based on the rules given in the above section create a test file with the extension ".p1". You should also create a data file with which the generate is going to compare the output with. 

Consider the following .p1 file
    
      (+ 1 2 3)
      
The .data file should be as mentioned below 

      0
      6
      1
      
The first line gives you the size of the array that is passed, the second line is the value of the return value. This was a school project and the third line was used to represent the number of points that was allocated for this test case. 
When we need to pass an array to the function the .p1 and .data files are as shown below. 

`.p1 File` :

    (+ arg_size (aref arg_array 0))

`.data File` :
  
       1              // array size, the variable `arg_size` is used to refer to this value
       20             // The array that is passed as an argument. Seperate the elements using a space. The name `arg_array` is the name of this array 
       21             // The value returned by the function 
       20             // `arg_array` at the end of execution
       3              // Points alloted for this test case
  
The explantion of the .data file is represented as comments above don't include them while creating the file.


## Executing the program 

- After cloning the repo, run the `make` command to compile the `.cpp` file, the `lex` file and `bison` file. 
- Add your `.p1` and `.data` file to the tests folder. 
- Edit the Makefile inside tests folder to include the test file you have created. 
- Run `make` inside the tests folder. The make file also disambled the code and dumps them in a .ll file that you can view. 

If you run `make test` instead of `make` inside the tests folder the console would give you the percentage of the test case that is successful and a summary of the output if there were any errors .  

## Important 

You need to have clang, Flex, Bison and other dependencies mentioned in the makefile to run the code.  
