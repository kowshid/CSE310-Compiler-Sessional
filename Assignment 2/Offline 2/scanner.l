%option noyywrap
%x MYSTATE
%x MYSTRING
%{
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
#include<string>
#include<fstream>
#include<string.h>
#define NULL_VALUE -999999
#define INFINITY1 999999

using namespace std;

int line_count=1;
int error_count = 0;

FILE *log;
FILE *token;
class SymbolInfo{
public:
    string name;
    string type;
};
class ArrayList
{
	SymbolInfo * list;
	int length ;
	int listMaxSize ;
	int listInitSize ;
public:
	ArrayList() ;
	~ArrayList() ;
	int searchItem(string item) ;
    	void insertItem(SymbolInfo item) ;
	void removeItem(SymbolInfo item) ;
	void removeItemAt(int position);
	SymbolInfo getItem(int position) ;
	int getLength();
	bool empty();
	void printList();
} ;

ArrayList::ArrayList()
{
	listInitSize = 2 ;
	listMaxSize = listInitSize ;
	list = new SymbolInfo[listMaxSize] ;
	length = 0 ;
}

void ArrayList::insertItem(SymbolInfo newitem)
{
	SymbolInfo * tempList ;
	if (length == listMaxSize)
	{
		//allocate new memory space for tempList
		listMaxSize = 2 * listMaxSize ;
		tempList = new SymbolInfo[listMaxSize] ;
		int i;
        for( i = 0; i < length ; i++ )
        {
            tempList[i] = list[i] ; //copy all items from list to tempList
        }
        delete[] list ; //free the memory allocated before
        list = tempList ; //make list to point to new memory
	};

	list[length] = newitem ; //store new item
	length++ ;
}

int ArrayList::searchItem(string item)
{
	int i = 0;
	for (i = 0; i < length; i++)
	{
		if( list[i].name == item ) return i;
	}
	return NULL_VALUE;
}

void ArrayList::removeItemAt(int position) //do not preserve order of items
{
	if ( position < 0 || position >= length ) return ; //nothing to remove
	for(int i = position; i < length - 1; i++){
        list[i] = list[i+1];
	}
	length-- ;
}

void ArrayList::removeItem(SymbolInfo item)
{
	int position;
	position = searchItem(item.name) ;
	if ( position == NULL_VALUE ) return ; //nothing to remove
	removeItemAt(position) ;
}

SymbolInfo ArrayList::getItem(int position)
{
	return list[position] ;
}

int ArrayList::getLength()
{
	return length ;
}

bool ArrayList::empty()
{
    if(length==0)return true;
    else return false;
}

void ArrayList::printList()
{
    int i;
    for(i=0;i<length;i++) cout << list[i].name << " : " << list[i].type;
    cout << listMaxSize << length;
}

ArrayList::~ArrayList()
{
    if(list) delete [] list;
    list = 0 ;
}

class SymbolTable
{
	int nRow ;
	ArrayList  * adjList ;

public:
	SymbolTable();
	~SymbolTable();
	void setnRow(int n);
	void Insert(int u, SymbolInfo v);
	void Delete(int u, SymbolInfo v);
    int getDegree(int u);
    void printSymbolTable();
    int look_up(string s,int u);
    int hashFunction(SymbolInfo s,int u);
};


SymbolTable::SymbolTable()
{
	nRow = 0 ;
	adjList = 0 ;
	//if(adjList!=0) delete[] adjList ;
	//adjList = new ArrayList[31] ;
}

void SymbolTable::setnRow(int n)
{
	this->nRow = n ;
	if(adjList!=0) delete[] adjList ;
	adjList = new ArrayList[nRow] ;
}

void SymbolTable::Insert(int u, SymbolInfo v)
{
	adjList[u].insertItem(v);
}


void SymbolTable::Delete(int u, SymbolInfo v)
{

    adjList[u].removeItem(v);
}

int SymbolTable::getDegree(int u)
{
    return adjList[u].getLength();
}

void SymbolTable::printSymbolTable()
{
    for(int i=0;i<nRow;i++)
    {
        if(adjList[i].getLength() > 0){
            fprintf(log,"%d --> ",i);
            for(int j=0; j<adjList[i].getLength();j++)
            {
                //fprintf(log," < %s : %s >  ",adjList[i].getItem(j).name,adjList[i].getItem(j).type);
		//log << "<" << adjList[i].getItem(j).name << "," << adjList[i].getItem(j).type << "> ";
		char a[250];
		std::string s = "<" + adjList[i].getItem(j).name + "," + adjList[i].getItem(j).type + "> ";
		//strncpy(a,s, sizeof(a) - 1);
		//a = s;
		strcpy(a,s.c_str());
		a[sizeof(a) - 1] = 0;
		fprintf(log,"%s",a);
            }
            fprintf(log,"\n");
        }
    }
	fprintf(log,"\n");
}

int SymbolTable::hashFunction(SymbolInfo s,int u)
{
    int len = s.name.length();
    int hasValue;
    hasValue = 0;
    for(int i = 0; i < len; i++){
        hasValue += s.name[i];
    }
    hasValue = hasValue%u;
    return hasValue;
}

int SymbolTable::look_up(string s,int u)
{
    int pos = adjList[u].searchItem(s);
    if( pos != NULL_VALUE) return pos;
    return -1;
}

SymbolTable::~SymbolTable()
{
    if(adjList) delete [] adjList;
    adjList = 0;
}


int n = 31;
SymbolTable g;
int ind = 0;
string temp;

void cmain(string s)
{
    
    int random = n;
    SymbolInfo v;
    if(ind == 0){
	g.setnRow(n);
	ind = 1;
	}
    v.name = yytext;
    v.type = s;
    int u = g.hashFunction(v,random);
    int j = g.look_up(v.name,u);
    if (j != -1 ) {
        string t = "<" + v.name + "," + v.type + "> " + " Already exists!\n";
        char a[250];
        strcpy(a,t.c_str());
	a[sizeof(a) - 1] = 0;
	fprintf(log,"%s",a);
    }
    else{
        g.Insert(u, v);
        //cout << "<" << v.name << "," << v.type << "> " << " Inserted at " << u << "," << g.getDegree(u) - 1;
    }
    g.printSymbolTable();
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
FLOAT_NUMBER [0-9]*([.][0-9]+)?(E[+-]?[0-9]+)?
NEWLINE \n
CHARACTER '[A-Za-z0-9]'
CHARACTER_EX '\\[ntabfv0\r"v]'
IDENTIFIER ([A-Za-z_]([A-Za-z0-9_]*)?)
NOT_IDENTIFIER [0-9]+[A-Za-z0-9_]+

SINGLE_LINE_COMMENT "//"[^\n]*

DECIMAL_POINT_ERROR [0-9]*[.][0-9]*([.]+[0-9]*)*
ILL_FORMATTED_NUMBER  [0-9]*((E[+-]?[0-9]+)([.][0-9]+)*)(E[+-]?[0-9]+)?([.][0-9]+)*
ILL_FORMATTED_CHAR '[A-Za-z0-9][A-Za-z0-9]+'
UNDETERMINED_CHAR '[A-Za-z0-9]*
UNFINISHED_STRING1 \"[^\\\"]*[^\\]^\"{WHITESPACE}

UNFINISHED_STRING \"([^\"\n]|(\\{NEWLINE}))*
A1 "\*"
%%



{NEWLINE} {	line_count++;
		
		}	
{WHITESPACE} {}

"if"	{
			fprintf(token,"<IF>");
			fprintf(log,"Line no %d: TOKEN <IF> Lexeme %s found\n\n",line_count,yytext);
		}

"for"	{
			fprintf(token,"<FOR>");
			fprintf(log,"Line no %d: TOKEN <FOR> Lexeme %s found\n\n",line_count,yytext);
		}
"do"	{
			fprintf(token,"<DO>");
			fprintf(log,"Line no %d: TOKEN <DO> Lexeme %s found\n\n",line_count,yytext);
		}
"int"	{
			fprintf(token,"<INT>");
			fprintf(log,"Line no %d: TOKEN <INT> Lexeme %s found\n\n",line_count,yytext);
		}
"float"	{
			fprintf(token,"<FLOAT>");
			fprintf(log,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n\n",line_count,yytext);

		}
"void"	{
			fprintf(token,"<VOID>");
			fprintf(log,"Line no %d: TOKEN <VOID> Lexeme %s found\n\n",line_count,yytext);
		}
"switch"	{
			fprintf(token,"<SWITCH>");
			fprintf(log,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n\n",line_count,yytext);
		}
"default"	{
			fprintf(token,"<DEFAULT>");
			fprintf(log,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n\n",line_count,yytext);
		}

"else"	{
			fprintf(token,"<ELSE>");
			fprintf(log,"Line no %d: TOKEN <ELSE> Lexeme %s found\n\n",line_count,yytext);
		}
"while"	{
			fprintf(token,"<WHILE>");
			fprintf(log,"Line no %d: TOKEN <WHILE> Lexeme %s found\n\n",line_count,yytext);
		}
"break"	{
			fprintf(token,"<BREAK>");
			fprintf(log,"Line no %d: TOKEN <BREAK> Lexeme %s found\n\n",line_count,yytext);
		}
"char"	{
			fprintf(token,"<CHAR>");
			fprintf(log,"Line no %d: TOKEN <CHAR> Lexeme %s found\n\n",line_count,yytext);
		}
"double"	{
			fprintf(token,"<DOUBLE>");
			fprintf(log,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n\n",line_count,yytext);
		}
"return"	{
			fprintf(token,"<RETURN>");
			fprintf(log,"Line no %d: TOKEN <RETURN> Lexeme %s found\n\n",line_count,yytext);
		}
"case"	{
			fprintf(token,"<CASE>");
			fprintf(log,"Line no %d: TOKEN <CASE> Lexeme %s found\n\n",line_count,yytext);
		}
"continue"	{
			fprintf(token,"<CONTINUE>");
			fprintf(log,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n\n",line_count,yytext);
		}

{DIGIT}+ 	{
				fprintf(token,"<CONST_INT,%s>",yytext);
				fprintf(log,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n\n",line_count,yytext);
				cmain("CONST_INT");
			}
{FLOAT_NUMBER}	{
				fprintf(token,"<CONST_FLOAT,%s>",yytext);
				fprintf(log,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n\n",line_count,yytext);
				cmain("CONST_FLOAT");
			}
{CHARACTER}	{
				fprintf(token,"<CONST_CHAR,%s>",yytext);
				fprintf(log,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
				cmain("CONST_CHAR");
			}
{CHARACTER_EX}	{
				fprintf(token,"<CONST_CHAR,%s>",yytext);
				fprintf(log,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
				cmain("CONST_CHAR");
			}
{IDENTIFIER}	{
				fprintf(token,"<ID,%s>",yytext);
				fprintf(log,"Line no %d: TOKEN <ID> Lexeme %s found\n\n",line_count,yytext);
				cmain("ID");
			}

[+-]		{
			fprintf(token,"<ADDOP,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n\n",line_count,yytext);
			cmain("ADDOP");
			}
[*/%]		{
			fprintf(token,"<MULOP,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <MULOP> Lexeme %s found\n\n",line_count,yytext);
			cmain("MULOP");
			}
"++"|"--"		{
			fprintf(token,"<INCOP,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <INCOP> Lexeme %s found\n\n",line_count,yytext);
			cmain("INCOP");
			}
">"|">="|"<"|"<="|"=="|"!="		{
			fprintf(token,"<RELOP,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			cmain("RELOP");
			}
"="		{
			fprintf(token,"<ASSIGNOP,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n\n",line_count,yytext);
			cmain("ASSIGNOP");
			}
"&&"|"||"|"!"		{
			fprintf(token,"<LOGICOP,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
			cmain("LOGICOP");
			}
"("		{
			fprintf(token,"<LPAREN,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n\n",line_count,yytext);
			cmain("LPAREN");
			}
")"		{
			fprintf(token,"<RPAREN,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n\n",line_count,yytext);
			cmain("RPAREN");
			}
"{"		{
			fprintf(token,"<LCURL,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <LCURL> Lexeme %s found\n\n",line_count,yytext);
			cmain("LCURL");
			}
"}"		{
			fprintf(token,"<RCURL,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <RCURL> Lexeme %s found\n\n",line_count,yytext);
			cmain("RCURL");
			}
"["		{
			fprintf(token,"<LBRACKET,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <LBRACKET> Lexeme %s found\n\n",line_count,yytext);
			cmain("LBRACKET");
			}
"]"		{
			fprintf(token,"<RBRACKET,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <RBRACKET> Lexeme %s found\n\n",line_count,yytext);
			cmain("RBRACKET");
			}
","		{
			fprintf(token,"<COMMA,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <COMMA> Lexeme %s found\n\n",line_count,yytext);
			cmain("COMMA");
			}
";"		{
			fprintf(token,"<SEMICOLON,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);
			cmain("SEMICOLON");
			}
<MYSTRING>{NEWLINE}     {
			line_count++;			
			//fprintf(log,"%s",yytext);
			}
\"      { 
			BEGIN (MYSTRING);
			fprintf(token,"<STRING>,%s",yytext);
			fprintf(log,"Line no %d: TOKEN <STRING> Lexeme %s ",line_count,yytext);
			
		}

<MYSTRING>\"    {
			fprintf(token,"\">");			
			fprintf(log,"%s found\n\n",yytext);
			BEGIN INITIAL;
			//line_count++;
			}


<MYSTRING>([\.])*     {
			fprintf(log,"%s",yytext);
			}


    

{SINGLE_LINE_COMMENT} { 
			//fprintf(token,"<COMMENT,%s>",yytext);
			fprintf(log,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n",line_count,yytext);
}
		

{DECIMAL_POINT_ERROR} {
			fprintf(log,"Error at line no %d: Too many decimal point %s\n\n",line_count,yytext);
			error_count++;
			}
{ILL_FORMATTED_NUMBER} {
			fprintf(log,"Error at line no %d: Ill formatted number %s\n\n",line_count,yytext);
			error_count++;
			}
{NOT_IDENTIFIER}  {
			fprintf(log,"Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n",line_count,yytext);
			error_count++;
		}
{ILL_FORMATTED_CHAR} {
			fprintf(log,"Error at line no %d: Ill formatted character %s\n\n",line_count,yytext);
			error_count++;
			}
{UNDETERMINED_CHAR} {
			fprintf(log,"Error at line no %d: Undetermined character %s\n\n",line_count,yytext);
			error_count++;
			}
{UNFINISHED_STRING} {
			fprintf(log,"Error at line no %d: Unfinished string %s\n\n",line_count,yytext);
			error_count++;
			}

<MYSTATE>{NEWLINE}     {
			line_count++;			
			fprintf(log,"%s",yytext);
			}
"/*"      	{ 
			BEGIN (MYSTATE);
			//fprintf(log,"Error at line no %d: Unterminated comment %s",line_count,yytext);
			fprintf(log,"Line no %d: TOKEN <COMMENT> Lexeme %s",line_count,yytext);
			
			
		}

<MYSTATE>"*/"    {
			fprintf(log,"%s found\n\n",yytext);
			BEGIN INITIAL;
			//line_count++;
			}
<MYSTATE>[^\n]  {
			fprintf(log,"%s",yytext);
			if(yytext[0] == '\n')line_count++;
			}

<MYSTATE><<EOF>> 	{
			fprintf(log,"Total Line Number: %d\n\n",line_count); 
			fprintf(log,"Total Errors: %d\n",error_count);
			g.~SymbolTable();
			return 0;
			}
<<EOF>> 	{
			fprintf(log,"Total Line Number: %d\n\n",line_count); 
			fprintf(log,"Total Errors: %d\n",error_count);
			g.~SymbolTable();
			return 0;
			}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	log= fopen("1305087_log.txt","w");
	token= fopen("1305087_token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(token);
	fclose(log);
	return 0;
}
