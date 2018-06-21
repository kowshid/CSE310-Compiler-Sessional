%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "1505102_symbolTable.h"
#include "y.tab.h"

int line_count = 1;
extern int error_count = 0;

extern FILE *error_out;

SymbolTable st(10);

char extractChar(string String)
{
	int len = String.length();
	//cout << String << endl;
	if (len > 3)
	{
		if(String[2] == 'n') return '\n';
		if(String[2] == 't') return '\t';
		if(String[2] == '\\') return '\\';
		if(String[2] == 'a') return '\a';
		if(String[2] == 'f') return '\f';
		if(String[2] == 'r') return '\r';
		if(String[2] == 'b') return '\b';
		if(String[2] == 'v') return '\v';
		if(String[2] == '\0') return '\0';
		if(String[2] == '\'') return '\'';

	}	
	
	else return String[1];
}

void increaseCount(string String)
{
	int len = String.length();
	while(len)
	{	
		len--;
		if(String[len] == '\n') line_count++;
	}
}

%}

WHITESPACE [ \t\f\r\v]+

NUMBER [0-9]+

FLOAT_1 [0-9]*\.[0-9]+
FLOAT_2 [0-9]+\.[0-9]*
FLOAT_3 [0-9]*\.?[0-9]+(E(\+|-)?[0-9]+)

CHAR_LITERATE ['][^'\n][']
SPECIAL_CHAR '\\n'|'\\t'|'\\\\'|'\\a'|'\\f'|'\\r'|'\\b'|'\\v'|'\\0'|'\\''

IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*

STRING ["]([^"\n]|\\\"|\\\n)*["]                                     

COMMENT_1 "//"([ -~]|"\\\n")*
COMMENT_2 "/*"([^*]|\*+[^/])*"*/"

/*ERRORS*/

FLOAT_ERROR_1 {FLOAT_1}{FLOAT_2}+|{FLOAT_2}{FLOAT_1}+
FLOAT_ERROR_2 {FLOAT_3}\.{NUMBER}

ID_ERROR [0-9]+[_a-zA-Z0-9]+

CHAR_ERROR_1 ['][^'\n][^'\n]+[']
CHAR_ERROR_2 ['][^'\n]*

STRING_ERROR ["]([^"\n]|\\\"|\\\n)*

COMMENT_ERROR "/*"([^*]|\*+[^/*])*

%%

{WHITESPACE}  	{ }

\n 		{line_count++;}

{COMMENT_1}|{COMMENT_2} {
			return COMMENT;
		}

['][']		{
			fprintf(error_out,"\nError at Line no %d: Empty character constant %s\n",line_count,yytext);
			error_count++;
		}

'\\'		{
			fprintf(error_out,"\nError at Line no %d: Unterminated character %s\n",line_count,yytext);
			error_count++;
		}


"if"		{
			return IF;
		}
		
"else"		{
			return ELSE;
		}

"for"		{
			return FOR;
		}

"do"		{
			return DO;
		}

"int"		{
			return INT;
		}

"float"		{
			return FLOAT;
		}

"void"		{
			return VOID;
		}

"default"	{
			return DEFAULT;
		}

"switch"	{
			return SWITCH;
		}

"while"		{
			return WHILE;
		}

"break"		{
			return BREAK;
		}

"char"		{
			return CHAR;
		}

"double"	{
			return DOUBLE;
		}

"return"	{
			return RETURN;
		}

"case"		{
			return CASE;
		}

"continue"	{
			return CONTINUE;
		}

"+"|"-"		{
			SymbolInfo *temp = new SymbolInfo(yytext, "ADDOP");
			yylval.var = temp;
			return ADDOP;
		}

"*"|"/"|"%" 	{
			SymbolInfo *temp = new SymbolInfo(yytext, "MULOP");
			yylval.var = temp;
			return MULOP;

		}	

"++"|"--"    	{
			SymbolInfo *temp = new SymbolInfo(yytext, "INCOP");
			yylval.var = temp;
			return INCOP;
		} 

"<"|"<="|">"|">="|"=="|"!=" {
			SymbolInfo *temp = new SymbolInfo(yytext, "RELOP");
			yylval.var = temp;
			return RELOP;	
		}

"="		{
			return ASSIGNOP;
		}

"&&"|"||" 	{
			SymbolInfo *temp = new SymbolInfo(yytext, "LOGICOP");
			yylval.var = temp;
			return LOGICOP;
		}
		
"&"|"|"|"^"|"<<"|">>" 	{
			SymbolInfo *temp = new SymbolInfo(yytext, "BITOP");
			yylval.var = temp;
			return BITOP;
		}

			
"!"		{
			return NOTOP;
		}

"("		{	
			return LPAREN;	
		}

")"		{
			return RPAREN;		
		}

"{"		{
			return LCURL;		
		}

"}"		{
			return RCURL;	
		}

"["		{
			return LTHIRD;		
		}

"]"		{
			return RTHIRD;			
		}

","		{
			return COMMA;	
		}

";"		{
			return SEMICOLON;	
		}


{CHAR_LITERATE}|{SPECIAL_CHAR}	{
			char in = extractChar(yytext);
			string input;
			input.push_back(in);
			SymbolInfo *temp = new SymbolInfo(input, "CONST_CHAR");
			yylval.var = temp;
			return CONST_CHAR;
		}

{FLOAT_1}|{FLOAT_2}|{FLOAT_3}	{
			SymbolInfo *temp = new SymbolInfo(yytext, "CONST_FLOAT");
			yylval.var = temp;
			return CONST_FLOAT;			
		} 

{NUMBER}	{
			SymbolInfo *temp = new SymbolInfo(yytext, "CONST_INT");
			yylval.var = temp;
			return CONST_INT;
		}

{IDENTIFIER}	{
			SymbolInfo *temp = new SymbolInfo(yytext, "ID");
			yylval.var = temp;
			return ID;
		}

{STRING}	{
			SymbolInfo *temp = new SymbolInfo(yytext, "STRING");
			yylval.var = temp;
			return STRING;	
		}

{FLOAT_ERROR_1} {
			fprintf(error_out,"\nError at Line no %d: Too many decimal point %s\n",line_count,yytext);
			error_count++;
		}

{FLOAT_ERROR_2} {
			fprintf(error_out,"\nError at Line no %d: Ill formed number %s\n",line_count,yytext);
			error_count++;
		}

{ID_ERROR}	{
			fprintf(error_out,"\nError at Line no %d: Invalid prefix on ID or invalid suffix on Number %s\n",line_count,yytext);
			error_count++;
		}

{CHAR_ERROR_1}	{
			fprintf(error_out,"\nError at Line no %d: Multi character constant error %s\n",line_count,yytext);
			error_count++;
		}

{CHAR_ERROR_2}	{
			fprintf(error_out,"\nError at Line no %d: Unterminated character %s\n",line_count,yytext);
			error_count++;
		}

{STRING_ERROR}	{
			fprintf(error_out,"\nError at Line no %d: Unterminated String %s\n",line_count,yytext);
			error_count++;
			increaseCount(yytext);
		}

{COMMENT_ERROR}	{
			fprintf(error_out,"\nError at Line no %d: Unfinished comment error %s\n",line_count,yytext);
			error_count++;
			increaseCount(yytext);
		}

.		{
			fprintf(error_out,"\nError at Line no %d: Unrecognized character error. Lexeme %s found\n",line_count,yytext);
			error_count++;
		}

%%

