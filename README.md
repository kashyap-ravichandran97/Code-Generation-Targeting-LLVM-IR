# Code-Generation-Targeting-LLVM-IR

A Lisp Based Programming Language is compiled and is represented using LLVM IR. I have used Bison and Lex to parse and scan the file respectively. 

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

## Creating a test file

Based on the rules given in the above section create a test file with the extension ".p1". 


## How the main program functions :

A starter code was provided which dumps the generated function into a module with the name of the test file and the module has two arguments an array and its size. 
The C++ representation of the function 
