%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "symbol.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

extern int line_count;

FILE *error_out;
FILE *log_out;

SymbolTable table(99);

void yyerror(char *s)
{
	//write your code
}

%union {
	SymbolInfo *var;
}

%}

%token IF ELSE FOR DO INT FLOAT VOID DEFAULT SWITCH WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE ASSIGNOP NOTOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON

%token <var> COMMENT
%token <var> ADDOP
%token <var> MULOP
%token <var> INCOP
%token <var> RELOP
%token <var> LOGICOP
%token <var> BITOP
%token <var> CONST_CHAR
%token <var> CONST_INT
%token <var> CONST_FLOAT
%token <var> ID
%token <var> STRING

%%

start : program
	{
		fprintf(log_out,"line no. %d: start : program\n\n",line_count);
	}
	;

program : program unit 
	{
		fprintf(log_out,"line no. %d: program : program unit\n\n",line_count);
	} 
	| unit 
	{
		fprintf(log_out,"line no. %d: program : unit\n\n",line_count);
	}
	;
	
unit : var_declaration 
	{
		fprintf(log_out,"line no. %d: unit: var_declaration\n\n",line_count);
	}
    | func_declaration 
    {
     	fprintf(log_out,"line no. %d: unit: func_declaration\n\n",line_count);
    }
    | func_definition 
    {
     	fprintf(log_out,"line no. %d: unit: func_definition\n\n",line_count);
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON 
	{
		fprintf(log_out,"line no. %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON 
	{
		fprintf(log_out,"line no. %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",line_count);
	}
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement 
	{
		fprintf(log_out,"line no. %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n",line_count);
	}
	| type_specifier ID LPAREN RPAREN compound_statement 
	{
		fprintf(log_out,"line no. %d: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);
	}
 	;				


parameter_list : parameter_list COMMA type_specifier ID 
	{
		fprintf(log_out,"line no. %d: parameter_list : parameter_list COMMA type_specifier ID\n\n",line_count);
	}
	| parameter_list COMMA type_specifier 
	{
		fprintf(log_out,"line no. %d: parameter_list : parameter_list COMMA type_specifier\n\n",line_count);
	}
 	| type_specifier ID 
 	{
		fprintf(log_out,"line no. %d: parameter_list : type_specifier ID\n\n",line_count);
	}
	| type_specifier 
	{
		fprintf(log_out,"line no. %d: parameter_list : type_specifier\n\n",line_count);
	}
 	;

 		
compound_statement : LCURL statements RCURL 
	{
		fprintf(log_out,"line no. %d: compound_statement : LCURL statements RCURL\n\n",line_count);
	}
 	| LCURL RCURL 
 	{
		fprintf(log_out,"line no. %d: compound_statement : LCURL RCURL\n\n",line_count);
	}
 	;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
	{
		fprintf(log_out,"line no. %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);
	}
 	;
 		 
type_specifier : INT
	{
		fprintf(log_out,"line no. %d: type_specifier : INT\n\n",line_count);
	}
 	| FLOAT
	{
		fprintf(log_out,"line no. %d: type_specifier : FLOAT\n\n",line_count);
	}
 	| VOID
	{
		fprintf(log_out,"line no. %d: type_specifier : VOID\n\n",line_count);
	}
 	;
 		
declaration_list : declaration_list COMMA ID
	{
		fprintf(log_out,"line no. %d: declaration_list : declaration_list COMMA ID\n\n",line_count);
	}
 	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
	{
		fprintf(log_out,"line no. %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
	}
 	| ID
	{
		fprintf(log_out,"line no. %d: declaration_list : ID\n\n",line_count);
	}
 	| ID LTHIRD CONST_INT RTHIRD
	{
		fprintf(log_out,"line no. %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
	}
 	;
 		  
statements : statement
	{
		fprintf(log_out,"line no. %d: statements : statement\n\n",line_count);
	}
    | statements statement
	{
		fprintf(log_out,"line no. %d: statements : statements statement\n\n",line_count);
	}
    ;
	   
statement : var_declaration
	{
		fprintf(log_out,"line no. %d: statement : var_declaration\n\n",line_count);
	}
	| expression_statement
	{
		fprintf(log_out,"line no. %d: statement : expression_statement\n\n",line_count);
	}
	| compound_statement
	{
		fprintf(log_out,"line no. %d: statement : compound_statement\n\n",line_count);
	}
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		fprintf(log_out,"line no. %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
	}
	| IF LPAREN expression RPAREN statement
	{
		fprintf(log_out,"line no. %d: statement : IF LPAREN expression RPAREN statement\n\n",line_count);
	}
	| IF LPAREN expression RPAREN statement ELSE statement
	{
		fprintf(log_out,"line no. %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);
	}
	| WHILE LPAREN expression RPAREN statement
	{
		fprintf(log_out,"line no. %d: statement : WHILE LPAREN expression RPAREN statement\n\n",line_count);
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON
	{
		fprintf(log_out,"line no. %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);
	}
	| RETURN expression SEMICOLON
	{
		fprintf(log_out,"line no. %d: statement : RETURN expression SEMICOLON\n\n",line_count);
	}
	;
	  
expression_statement : SEMICOLON
	{
		fprintf(log_out,"line no. %d: expression_statement : SEMICOLON\n\n",line_count);
	}
	| expression SEMICOLON 
	{
		fprintf(log_out,"line no. %d: expression_statement : expression SEMICOLON\n\n",line_count);
	}
	;
	  
variable : ID
	{
		fprintf(log_out,"line no. %d: variable: ID\n\n",line_count);
	} 		
	| ID LTHIRD expression RTHIRD 
	{
		fprintf(log_out,"line no. %d: variable: ID LTHIRD expression RTHIRD\n\n",line_count);
	}
	;
	 
 expression : logic_expression	
	{
		fprintf(log_out,"line no. %d: expression : logic_expression \n\n",line_count);
	}
    | variable ASSIGNOP logic_expression 
	{
		fprintf(log_out,"line no. %d: expression : variable ASSIGNOP logic_expression\n\n",line_count);
	}
    ;
			
logic_expression : rel_expression 
	{
		fprintf(log_out,"line no. %d: logic_expression : rel_expression \n\n",line_count);
	}
    | rel_expression LOGICOP rel_expression    
	{
		fprintf(log_out,"line no. %d: logic_expression : rel_expression LOGICOP rel_expression \n\n",line_count);
	}
    ;
			
rel_expression	: simple_expression 
	{
		fprintf(log_out,"line no. %d: rel_expression : simple_expression \n\n",line_count);
	}
	| simple_expression RELOP simple_expression	
	{
		fprintf(log_out,"line no. %d: rel_expression : simple_expression RELOP simple_expression \n\n",line_count);
	}
	;
				
simple_expression : term 
	{
		fprintf(log_out,"line no. %d: simple_expression : term \n\n",line_count);
	}
    | simple_expression ADDOP term 
	{
		fprintf(log_out,"line no. %d: simple_expression : simple_expression ADDOP term \n\n",line_count);
	}
    ;
					
term :	unary_expression
	{
		fprintf(log_out,"line no. %d: term : unary_expression\n\n",line_count);
	}
    |  term MULOP unary_expression
	{
		fprintf(log_out,"line no. %d: term : term MULOP unary_expression\n\n",line_count);
	}
    ;

unary_expression : ADDOP unary_expression  
	{
		fprintf(log_out,"line no. %d: unary_expression : ADDOP unary_expression\n\n",line_count);
	}
	| NOT unary_expression 
	{
		fprintf(log_out,"line no. %d: unary_expression : NOT unary_expression \n\n",line_count);
	}
	| factor 
	{
		fprintf(log_out,"line no. %d: unary_expression : factor \n\n",line_count);
	}
	;
	
factor	: variable 
	{
		fprintf(log_out,"line no. %d: factor : variable\n\n",line_count);
	}
	| ID LPAREN argument_list RPAREN
	{
		fprintf(log_out,"line no. %d: factor : ID LPAREN argument_list RPAREN\n\n",line_count);
	}
	| LPAREN expression RPAREN
	{
		fprintf(log_out,"line no. %d: factor : LPAREN expression RPAREN\n\n",line_count);
	}
	| CONST_INT
	{
		fprintf(log_out,"line no. %d: factor : CONST_INT\n\n",line_count);
	} 
	| CONST_FLOAT
	{
		fprintf(log_out,"line no. %d: factor : CONST_FLOAT \n\n",line_count);
	}
	| variable INCOP 
	{
		fprintf(log_out,"line no. %d: factor : variable INCOP \n\n",line_count);
	}
	| variable DECOP
	{
		fprintf(log_out,"line no. %d: factor : variable DECOP \n\n",line_count);
	}
	;
	
argument_list : arguments
	{
		fprintf(log_out,"line no. %d: argument_list : arguments\n\n",line_count);
	}
	| {}
	;
	
arguments : arguments COMMA logic_expression
	{
		fprintf(log_out,"line no. %d: arguments : arguments COMMA logic_expression \n\n",line_count);
	}
	| logic_expression
	{
		fprintf(log_out,"line no. %d: arguments : logic_expression \n\n",line_count);
	}
	;
 

%%
int main(int argc,char *argv[])
{

	if((yyin=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	log_out= fopen(argv[2],"w");
	fclose(log_out);
	error_out= fopen(argv[3],"w");
	fclose(error_out);
	
	log_out= fopen(argv[2],"a");
	error_out= fopen(argv[3],"a");
	
	yyparse();
	
	fclose(log_out);
	fclose(error_out);
	
	return 0;
}
