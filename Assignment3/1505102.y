%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<vector>
#include "1505102_symbolTable.h"

using namespace std;

int yyparse(void);
int yylex(void);
int error_count = 0;
extern FILE *yyin;

string variableType;
bool check;
SymbolInfo *symbolInfo;

extern int line_count;

FILE *error_out;
FILE *log_out;

SymbolTable table(41);
vector<SymbolInfo*> paramList;

void yyerror(char *s)
{
	error_count++;
	fprintf(error_out, "line no. %d: Error no. %d found\n%s\n", line_count, error_count, s);
}

%}

%union 
{
	SymbolInfo *var;
}

%token NOT IF ELSE FOR DO INT FLOAT VOID DEFAULT SWITCH WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE ASSIGNOP NOTOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON DECOP INCOP PRINTLN

%token <var> COMMENT
%token <var> ADDOP
%token <var> MULOP
%token <var> RELOP
%token <var> LOGICOP
%token <var> BITOP
%token <var> CONST_CHAR
%token <var> CONST_INT
%token <var> CONST_FLOAT
%token <var> ID
%token <var> STRING

%type <var> start program compound_statement type_specifier parameter_list declaration_list var_declaration unit func_declaration statement statements variable expression factor arguments argument_list expression_statement unary_expression simple_expression logic_expression rel_expression term func_definition 

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		fprintf(log_out,"line no. %d: start : program\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "start");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;

program : program unit 
	{
		fprintf(log_out,"line no. %d: program : program unit\n\n",line_count);

		$$->setName($$->getName() + $2->getName());

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	} 
	| unit 
	{
		fprintf(log_out,"line no. %d: program : unit\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "program");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;
	
unit : var_declaration 
	{
		fprintf(log_out,"line no. %d: unit: var_declaration\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo('\n' + $1->getName(), "unit");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    | func_declaration 
    {
     	fprintf(log_out,"line no. %d: unit: func_declaration\n\n",line_count);

     	SymbolInfo *temp = new SymbolInfo('\n' + $1->getName(), "unit");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
    }
    | func_definition 
    {
     	fprintf(log_out,"line no. %d: unit: func_definition\n\n",line_count);

     	SymbolInfo *temp = new SymbolInfo('\n' + $1->getName(), "unit");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON 
	{
		fprintf(log_out,"line no. %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
		
		string line = $1->getName() + $2->getName() + "(" + $4->getName() + ");";

		SymbolInfo *temp = new SymbolInfo(line, "func_declaration");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());

		$2->returnType = $1->varType;
		//cout << $2->getName() << " " << $2->returnType << endl;

		check = table.insertSymbol($2->getName(), "ID", 0);

		if (check == false)
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nAlready Exists\n\n", error_count, line_count);
		}

		//table.printCur(log_out);
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON 
	{
		fprintf(log_out,"line no. %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",line_count);
	
		string line = $1->getName() + $2->getName() + "();";

		SymbolInfo *temp = new SymbolInfo(line, "func_declaration");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());

		$2->returnType = $1->varType;
		//cout << $2->getName() << " " << $2->returnType << endl;

		check = table.insertSymbol($2->getName(), "ID", 0);

		if (check == false)
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nAlready Exists\n\n", error_count, line_count);
		}
		//table.printCur(log_out);
	}
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {table.enterScope();} compound_statement 
	{
		fprintf(log_out,"line no. %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n",line_count);

		string line = $1->getName() + $2->getName() + "(" + $4->getName() + ")" + $7->getName();

		SymbolInfo *temp = new SymbolInfo(line, "func_definition");
		$$ = temp;

		$2->returnType = $1->varType;
		//cout << $2->getName() << " " << $2->returnType << endl;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());

		for(int i = 0; i < paramList.size(); i++)
		{
			table.insertSymbol(paramList[i]->getName(), "ID", 0);
		}

		paramList.clear();

		table.printCur(log_out);
		table.removeScope();

		SymbolInfo *sInfo = table.srch($2->getName());

		if(sInfo == NULL)
		{
			table.insertSymbol($2->getName(), "ID", 0);
		}

		symbolInfo = table.srch($2->getName());
		symbolInfo->returnType = $1->getName();

		table.printAll(log_out);
	}
	| type_specifier ID LPAREN RPAREN {table.enterScope();} compound_statement 
	{
		fprintf(log_out,"line no. %d: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);
	
		string line = $1->getName() + $2->getName() + "()" + $6->getName();

		SymbolInfo *temp = new SymbolInfo(line, "func_definition");
		$$ = temp;

		$2->returnType = $1->varType;
		//cout << $2->getName() << " " << $2->returnType << endl;		

		table.insertSymbol($2->getName(), "ID", 0);

		symbolInfo = table.srch($2->getName());
		symbolInfo->returnType = $1->getName();

		fprintf(log_out, "%s\n\n", $$->getName().c_str());

		table.printCur(log_out);
		table.removeScope();
		table.printAll(log_out);
	}
 	;				


parameter_list : parameter_list COMMA type_specifier ID 
	{
		fprintf(log_out,"line no. %d: parameter_list : parameter_list COMMA type_specifier ID\n\n",line_count);

		string line = $1->getName() + ", " + $3->getName() + $4->getName();

		SymbolInfo *temp = new SymbolInfo(line, "parameter_list");
		$$ = temp;

		$4->varType = variableType;
		$4->returnType = $3->returnType;
		
		paramList.push_back($4);

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| parameter_list COMMA type_specifier 
	{
		fprintf(log_out,"line no. %d: parameter_list : parameter_list COMMA type_specifier\n\n",line_count);
	
		string line = $1->getName() + ", " + $3->getName();

		SymbolInfo *temp = new SymbolInfo(line, "parameter_list");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
 	| type_specifier ID 
 	{
		fprintf(log_out,"line no. %d: parameter_list : type_specifier ID\n\n",line_count);

		$$->setName($$->getName() + $2->getName());

		$2->varType = $1->varType;
		
		paramList.push_back($2);

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| type_specifier 
	{
		fprintf(log_out,"line no. %d: parameter_list : type_specifier\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "parameter_list");
		$$ = temp;

		//$1->varType = variableType;
		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
 	;

 		
compound_statement : LCURL statements RCURL 
	{
		fprintf(log_out,"line no. %d: compound_statement : LCURL statements RCURL\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo("{\n" + $2->getName() + "\n}", "parameter_list");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
 	| LCURL RCURL 
 	{
		fprintf(log_out,"line no. %d: compound_statement : LCURL RCURL\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo("{}", "parameter_list");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
 	;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
	{
		fprintf(log_out,"line no. %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);
	
		SymbolInfo *temp = new SymbolInfo($1->getName() + $2->getName() + ";", "parameter_list");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
 	;
 		 
type_specifier : INT
	{
		fprintf(log_out,"line no. %d: type_specifier : INT\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo("int","type_specifier");
		$$ = temp;

		variableType = "int";
		
		$$->varType = "int";

		fprintf(log_out,"%s\n\n",$$->getName().c_str());
	}
 	| FLOAT
	{
		fprintf(log_out,"line no. %d: type_specifier : FLOAT\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo("float ", "type_specifier");
		$$ = temp;

		variableType = "float";
		
		$$->varType = "float";

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
 	| VOID
	{
		fprintf(log_out,"line no. %d: type_specifier : VOID\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo("void ", "type_specifier");
		$$ = temp;

		variableType = "void";
		
		$$->varType = "void";

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
 	;
 		
declaration_list : declaration_list COMMA ID
	{
		fprintf(log_out,"line no. %d: declaration_list : declaration_list COMMA ID\n\n",line_count);

		$$->setName($$->getName() + ", " + $3->getName());

		fprintf(log_out,"%s\n\n", $$->getName().c_str());

		check = table.insertSymbol($3->getName(), "ID", 0);

		if (check == false)
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nAlready Exists\n\n", error_count, line_count);
		}

		SymbolInfo *sInfo = table.srch($3->getName());
		
		if(variableType != "void")
		{
			sInfo->varType = variableType;
		}

		else 
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nVariable type can't be void\n\n", error_count, line_count);
		}

		//table.printCur(log_out);
	}
 	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
	{
		fprintf(log_out,"line no. %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_count);

		$$->setName($$->getName() + ", " + $3->getName() + "[" + $5->getName() + "]" );

		fprintf(log_out, "%s\n\n", $$->getName().c_str());

		int number = atoi($5->getName().c_str());

		check = table.insertSymbol($3->getName(), "ID", number);

		if (check == false)
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nAlready Exists\n\n", error_count, line_count);
		}

		//table.printCur(log_out);

		SymbolInfo *sInfo = table.srch($3->getName());
	
		if(variableType != "void")
		{
			sInfo->varType = variableType;
		}

		else 
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nVariable type can't be void\n\n", error_count, line_count);
		}
	}
 	| ID
	{
		fprintf(log_out,"line no. %d: declaration_list : ID\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(),"declaration_list");
		$$ = temp;

		fprintf(log_out,"%s\n\n", $$->getName().c_str());

		check = table.insertSymbol($1->getName(), "ID", 0);

		if (check == false)
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nAlready Exists\n\n", error_count, line_count);
		}

		SymbolInfo *sInfo = table.srch($1->getName());
	
		if(variableType != "void")
		{
			sInfo->varType = variableType;
		}

		else 
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nVariable type can't be void\n\n", error_count, line_count);
		}
		

		//table.printCur(log_out);
	}
 	| ID LTHIRD CONST_INT RTHIRD
	{
		fprintf(log_out,"line no. %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",line_count);

		string line = $1->getName() + "[" + $3->getName() + "]";

		SymbolInfo *temp = new SymbolInfo(line, "declaration_list");
		$$ = temp;

		fprintf(log_out,"%s\n\n", $$->getName().c_str());

		int number=atoi($3->getName().c_str());
		
		check = table.insertSymbol($1->getName(), "ID", number);

		if (check == false)
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nAlready Exists\n\n", error_count, line_count);
		}

		SymbolInfo *sInfo = table.srch($1->getName());
		
		if(variableType != "void")
		{
			sInfo->varType = variableType;
		}

		else 
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nVariable type can't be void\n\n", error_count, line_count);
		}

		//table.printCur(log_out);
	}
 	;
 		  
statements : statement
	{
		fprintf(log_out,"line no. %d: statements : statement\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "statements");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    | statements statement
	{
		fprintf(log_out,"line no. %d: statements : statements statement\n\n",line_count);

		$$->setName($$->getName() + $2->getName());

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    ;
	   
statement : var_declaration
	{
		fprintf(log_out,"line no. %d: statement : var_declaration\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + '\n', "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| expression_statement
	{
		fprintf(log_out,"line no. %d: statement : expression_statement\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName()+ '\n', "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| compound_statement
	{
		fprintf(log_out,"line no. %d: statement : compound_statement\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + '\n', "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		fprintf(log_out,"line no. %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
	
		string line = "for (" + $3->getName() + $4->getName() + $5->getName() + ") " + $7->getName();

		SymbolInfo *temp = new SymbolInfo(line, "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| IF LPAREN expression RPAREN statement 		%prec LOWER_THAN_ELSE
	{
		fprintf(log_out,"line no. %d: statement : IF LPAREN expression RPAREN statement\n\n",line_count);
	
		string line = "if (" + $3->getName() + ") " + $5->getName();

		SymbolInfo *temp = new SymbolInfo(line, "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| IF LPAREN expression RPAREN statement ELSE statement
	{
		fprintf(log_out,"line no. %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);
	
		string line = "if (" + $3->getName() + ") " + $5->getName() + "else " + $7->getName();

		SymbolInfo *temp = new SymbolInfo(line, "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| WHILE LPAREN expression RPAREN statement
	{
		fprintf(log_out,"line no. %d: statement : WHILE LPAREN expression RPAREN statement\n\n",line_count);
	
		string line = "while (" + $3->getName() + ") " + $5->getName();

		SymbolInfo *temp = new SymbolInfo(line, "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON
	{
		fprintf(log_out,"line no. %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);
	}
	| RETURN expression SEMICOLON
	{
		fprintf(log_out,"line no. %d: statement : RETURN expression SEMICOLON\n\n",line_count);
	
		SymbolInfo *temp = new SymbolInfo("return " + $2->getName() + ";", "statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;
	  
expression_statement : SEMICOLON
	{
		fprintf(log_out,"line no. %d: expression_statement : SEMICOLON\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo(";", "expression_statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| expression SEMICOLON 
	{
		fprintf(log_out,"line no. %d: expression_statement : expression SEMICOLON\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + ";", "expression_statement");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;
	  
variable : ID
	{
		fprintf(log_out,"line no. %d: variable: ID\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "variable");
		$$ = temp;

		symbolInfo = table.srch($1->getName());

		if(symbolInfo != NULL) $$->varType = symbolInfo->varType;
		
		//cout<<$$->getName()<<"  hg  "<<$$->varType<<endl;
 
		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	} 		
	| ID LTHIRD expression RTHIRD 
	{
		fprintf(log_out,"line no. %d: variable: ID LTHIRD expression RTHIRD\n\n",line_count);
	
		SymbolInfo *temp = new SymbolInfo($1->getName() + "[" + $3->getName() + "]", "variable");
		$$ = temp;

		$$->varType = $1->varType;
		
		if($3->varType != "int")
		{
			error_count++;
			fprintf(error_out, "Error no. %d at line no. %d\nArray indexing error\n\n", error_count, line_count);
			//cout << $3->getName() << " \'" << $3->varType << "\' id:" << $1->getName() << endl ;
		}

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;
	 
 expression : logic_expression	
	{
		fprintf(log_out,"line no. %d: expression : logic_expression \n\n",line_count);
	
		SymbolInfo *temp = new SymbolInfo($1->getName(), "expression");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    | variable ASSIGNOP logic_expression 
	{
		fprintf(log_out,"line no. %d: expression : variable ASSIGNOP logic_expression\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + " = " + $3->getName(), "expression");
		$$ = temp;

		string t = "";
		for(int i = 0; i < $1->getName().length(); i++)
		{
			if($1->getName()[i] == '[') break;
			
			else
			{
				t.push_back($1->getName()[i]);
			}
		}

		SymbolInfo *sInfo = table.srch(t);

		if(sInfo == 0)
		{
			error_count++;
			fprintf(log_out,"variable %s not declared\n",t.c_str());
		}

		else
		{
			if(sInfo->varType != $3->varType)
			{
				error_count++;
				fprintf(error_out, "Error no. %d at line no. %d\nAssignment error\n\n", error_count, line_count);
			}
		}

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    ;
			
logic_expression : rel_expression 
	{
		fprintf(log_out,"line no. %d: logic_expression : rel_expression \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "logic_expression");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    | rel_expression LOGICOP rel_expression    
	{
		fprintf(log_out,"line no. %d: logic_expression : rel_expression LOGICOP rel_expression \n\n",line_count);
		
		SymbolInfo *temp = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "logic_expression");
		$$ = temp;

		$$->varType = "int";

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    ;
			
rel_expression	: simple_expression 
	{
		fprintf(log_out,"line no. %d: rel_expression : simple_expression \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "rel_expression");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| simple_expression RELOP simple_expression	
	{
		fprintf(log_out,"line no. %d: rel_expression : simple_expression RELOP simple_expression \n\n",line_count);
	
		SymbolInfo *temp = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "rel_expression");
		$$ = temp;
		
		$$->varType = "int";

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;
				
simple_expression : term 
	{
		fprintf(log_out,"line no. %d: simple_expression : term \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "simple_expression");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    | simple_expression ADDOP term 
	{
		fprintf(log_out,"line no. %d: simple_expression : simple_expression ADDOP term \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "simple_expression");
		$$ = temp;

		if($1->varType == "float" || $3->varType == "float")
		{
			$$->varType = "float";
		}

		else
		{
			$$->varType = "int";
		}

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    ;
					
term : unary_expression
	{
		fprintf(log_out,"line no. %d: term : unary_expression\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "term");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    |  term MULOP unary_expression
	{
		fprintf(log_out,"line no. %d: term : term MULOP unary_expression\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "term");
		$$ = temp;

		if($1->varType == "float" || $3->varType == "float")
		{
			$$->varType = "float";
		}

		else
		{
			$$->varType = "int";
		}

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
    ;

unary_expression : ADDOP unary_expression  
	{
		fprintf(log_out,"line no. %d: unary_expression : ADDOP unary_expression\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + $2->getName(), "unary_expression");
		$$ = temp;

		$$->varType = $2->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| NOT unary_expression 
	{
		fprintf(log_out,"line no. %d: unary_expression : NOT unary_expression \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo("!" + $2->getName(), "unary_expression");
		$$ = temp;

		$$->varType = $2->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| factor 
	{
		fprintf(log_out,"line no. %d: unary_expression : factor \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "unary_expression");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;
	
factor : variable 
	{
		fprintf(log_out,"line no. %d: factor : variable\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "factor");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| ID LPAREN argument_list RPAREN
	{
		fprintf(log_out,"line no. %d: factor : ID LPAREN argument_list RPAREN\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "factor");
		$$ = temp;

		symbolInfo = table.srch($1->getName());
		$$->varType = symbolInfo->returnType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| LPAREN expression RPAREN
	{
		fprintf(log_out,"line no. %d: factor : LPAREN expression RPAREN\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo("(" + $2->getName() + ")", "factor");
		$$ = temp;

		$$->varType = $2->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| CONST_INT
	{
		fprintf(log_out,"line no. %d: factor : CONST_INT\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "factor");
		$$ = temp;

		$$->varType = "int";

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	} 
	| CONST_FLOAT
	{
		fprintf(log_out,"line no. %d: factor : CONST_FLOAT \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "factor");
		$$ = temp;

		$$->varType = "float";

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| variable INCOP 
	{
		fprintf(log_out,"line no. %d: factor : variable INCOP \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + "++", "factor");
		$$ = temp;

		$$->varType = $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| variable DECOP
	{
		fprintf(log_out,"line no. %d: factor : variable DECOP \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + "--", "factor");
		$$ = temp;

		$$->varType == $1->varType;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	;
	
argument_list : arguments
	{
		fprintf(log_out,"line no. %d: argument_list : arguments\n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "argument_list");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| { }
	;
	
arguments : arguments COMMA logic_expression
	{
		fprintf(log_out,"line no. %d: arguments : arguments COMMA logic_expression \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName() + ", " + $3->getName(), "arguments");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
	}
	| logic_expression
	{
		fprintf(log_out,"line no. %d: arguments : logic_expression \n\n",line_count);

		SymbolInfo *temp = new SymbolInfo($1->getName(), "arguments");
		$$ = temp;

		fprintf(log_out, "%s\n\n", $$->getName().c_str());
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

	table.printAll(log_out);
	fprintf(log_out,"total lines: %d\n",line_count);
	fprintf(log_out,"total errors encountered: %d\n",error_count);
	
	fclose(log_out);
	fclose(error_out);
	
	return 0;
}
