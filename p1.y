/*
Kashyap Ravichandran
kravich2
ECE 566
*/

%{
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <list>
#include <map>
#include<iostream>
  
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"

#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Support/SystemUtils.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/FileSystem.h"

using namespace llvm;
using namespace std;

extern FILE *yyin;
int yylex(void);
int yyerror(const char *);

// From main.cpp
extern char *fileNameOut;
extern Module *M;
extern LLVMContext TheContext;
extern Function *Func;
extern IRBuilder<> Builder;

// Used to lookup Value associated with ID
map<string,Value*> idLookup;
string st="_size";

 
%}

%code requires {
    struct node {
        Value* LHS;
        Value* RHS;
        int type;
    };
}

%union {
  int num;
  char *id;
  node val;
  std::list <Value*> *listptr;
}

%token IDENT NUM MINUS PLUS MULTIPLY DIVIDE LPAREN RPAREN SETQ SETF AREF MIN MAX ERROR MAKEARRAY NEWL

%type <num> NUM 
%type <id> IDENT
%type <listptr> token_or_expr_list
%type <val> token expr token_or_expr exprlist

%start program

%%


/*
   IMPLMENT ALL THE RULES BELOW HERE!
 */

program : exprlist 
{ 
  /* 
    IMPLEMENT: return value
    Hint: the following code is not sufficient
  */
  Builder.CreateRet($1.RHS);
  return 0;
}
;

exprlist:  exprlist expr 
{
	$$=$2;
}
| expr // MAYBE ADD ACTION HERE?
{
	$$=$1;
}
| exprlist NEWL expr
{
	$$=$3;
}
;         

expr: LPAREN MINUS token_or_expr_list RPAREN
{ 
  // IMPLEMENT
 // only one element?
 	//count=0;
	if($3->size()==1)
	{
		$$.RHS=Builder.CreateNeg($3->front(),"neg");
		$$.type=0;
	}
	else
	{
		yyerror("More than one element with (-)");
		 YYABORT; 
	} 
}
| LPAREN PLUS token_or_expr_list RPAREN
{
  // IMPLEMENT
	Value* temp;
	Value* temp1, *temp2;
	int size=$3->size()-1;
	for(int i=0;i<size;i++)
	{
		temp1=$3->front();
		$3->pop_front();
		temp2=$3->front();
		$3->pop_front();
		temp=Builder.CreateAdd(temp1,temp2,"add");
		$3->push_front(temp);
	}
	$$.RHS=$3->front();
	$$.type=0;
	$3->pop_front();
	//$$=
}
| LPAREN MULTIPLY token_or_expr_list RPAREN
{
  // IMPLEMENT
	Value* temp;
	Value* temp1, *temp2;
	int size=$3->size()-1;
	for(int i=0;i<size;i++)
	{
		temp1=$3->front();
		$3->pop_front();
		temp2=$3->front();
		$3->pop_front();
		temp=Builder.CreateMul(temp1,temp2,"mul");
		$3->push_front(temp);
	}
	$$.RHS=$3->front();
	$$.type=1;
	$3->pop_front();
}
| LPAREN DIVIDE token_or_expr_list RPAREN
{
  // IMPLEMENT
	Value* temp;
	Value* temp1, *temp2;
	int size=$3->size()-1;
	for(int i=0;i<size;i++)
	{
		temp1=$3->front();
		$3->pop_front();
		temp2=$3->front();
		$3->pop_front();
		temp=Builder.CreateSDiv(temp1,temp2,"sdiv");
		$3->push_front(temp);
	}
	$$.RHS=$3->front();
	$$.type=0;
	$3->pop_front();
}
| LPAREN SETQ IDENT token_or_expr RPAREN
{
  // IMPLEMENT
  // We need use assigining it here! 
	Value* var=NULL;
	if(idLookup.find($3)==idLookup.end())
	{
		var=Builder.CreateAlloca(Builder.getInt32Ty(),nullptr,$3);
		idLookup[$3]=var;

	}
	else 
	{
		var=idLookup[$3];
	}
	Builder.CreateStore($4.RHS,var);
}
| LPAREN MIN token_or_expr_list RPAREN
{
  // HINT: select instruction
	/*list <int> a;
	a=$3;	
	a.sort();
	$$=a.front();*/
	Value* LHS;
	Value* RHS;
	int size=$3->size()-1;
	for(int i=0;i<size;i++)
	{
		LHS=$3->front();
		$3->pop_front();
		RHS=$3->front();
		$3->pop_front();
		Value* condition=Builder.CreateICmpSLT(LHS,RHS,"min");
		Value* select=Builder.CreateSelect(condition,LHS,RHS,"minswap",nullptr);
		$3->push_front(select);
	}
	$$.RHS=$3->front();
	$$.type=0;
	$3->pop_front();
}
| LPAREN MAX token_or_expr_list RPAREN
{
  // HINT: select instruction
  	int size=$3->size()-1;
	for(int i=0;i<size;i++)
	{
		Value* LHS=$3->front();
		$3->pop_front();
		Value* RHS=$3->front();
		$3->pop_front();
		Value* condition=Builder.CreateICmpSGT(LHS,RHS,"max");
		Value* select=Builder.CreateSelect(condition,LHS,RHS,"maxswap",nullptr);
		$3->push_front(select);
	}
	$$.RHS=$3->front();
	$$.type=0;
	$3->pop_front();
}
| LPAREN SETF token_or_expr token_or_expr RPAREN
{
  // ECE 566 only
  // IMPLEMENT
	//Value* Array = Builder.CreateAlloca(Builder.getInt32Ty(),
	Builder.CreateStore($4.RHS,$3.LHS);
	$$.RHS=$4.RHS;
	
}
| LPAREN AREF IDENT token_or_expr RPAREN
{
    // IMPLEMENT

	Value * temp;
	//cout<<$3+st;
	//temp=idLookup[$3+st];
	//llvm::ConstantInt* CI = dyn_cast<llvm::ConstantInt>(temp);
	//llvm::ConstantInt* CII = dyn_cast<llvm::ConstantInt>($4.RHS);
	//long long size=CI->getZExtValue(),index=CII->getZExtValue();
	//if(index>size)
	//{
	//	yyerror(" The parser has detected a seg fault");
	//	YYABORT;
	//}
	//else
	//{
		if(idLookup.find($3)!=idLookup.end())
		{
			temp=Builder.CreateGEP(idLookup[$3],$4.RHS);
			$$.RHS=Builder.CreateLoad(temp);
			$$.LHS=temp;
			$$.type=1;
		}
		else 
		{
		 yyerror(" Array not Declared");
		 YYABORT;
		}
	//}
	
}
| LPAREN MAKEARRAY IDENT NUM token_or_expr RPAREN
{

  Value* num=Builder.getInt32($4);
  Value* Array = Builder.CreateAlloca(Builder.getInt32Ty(),num,$3);
  idLookup[$3]=Array;
  Value* temp;
  Value* j;
  for(int i=0;i<$4;i++)
  {
  	j=Builder.getInt32(i);
  	temp=Builder.CreateGEP(Array,j);
  	Builder.CreateStore($5.RHS,temp);
  }
  $$.RHS=$5.RHS;
  $$.type=0;

  // To detect seg faults
  //num=Builder.getInt32($4);
  //string s=$3+st;
  //Value * tempq=Builder.CreateAlloca(Builder.getInt32Ty(),nullptr,s);
  //idLookup[s]=tempq;
  //Builder.CreateStore(num,tempq);

}
;

token_or_expr_list:   token_or_expr_list token_or_expr
{
  // IMPLEMENT
  //push it in the list list 
	$1->push_back($2.RHS);
	$$=$1;
}
| token_or_expr
{
  // IMPLEMENT
  // HINT: $$ = new std::list<Value*>;
	//arr.push_back($1);
	$$= new std::list<Value*>;
	$$->push_back($1.RHS);
}
;

token_or_expr :  token
{
  // IMPLEMENT
  // Send it to the upper level
	$$=$1;
}
| expr
{
  // IMPLEMENT
	$$=$1;

}
; 

token:   IDENT
{
  //str=$1;
  if (idLookup.find($1) != idLookup.end())
  {
  	$$.RHS = Builder.CreateLoad(idLookup[$1]);
  	$$.type=0;
  }
  else
    {
      yyerror(" Variable not declared");      
       YYABORT; 
    }

}
| NUM
{
  // IMPLEMENT
	
	$$.RHS=Builder.getInt32($1);
	$$.type=0;
}
;

%%

void initialize()
{
  string s = "arg_array";
  idLookup[s] = (Value*)(Func->arg_begin()+1);

  string s2 = "arg_size";
  Argument *a = Func->arg_begin();
  Value * v = Builder.CreateAlloca(a->getType());
  Builder.CreateStore(a,v);
  idLookup[s2] = (Value*)v;
  //ConstantInt *ci=dyn_cast<ConstantInt>(a);
  //printf("Hey There %ld",ci->getSExtValue());
  //idLookup2[s] = (int)a;
  /* IMPLEMENT: add something else here if needed */
}

extern int line;

int yyerror(const char *msg)
{
  printf("%s at line %d.\n",msg,line);
  return 0;
}
