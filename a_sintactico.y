	
%{
#include <iostream>
#include "scanner.h"
#include "nodo.h"
#include "Reporte/error.h"
#include "Mis_estructuras/jlista.h"



using namespace std;

extern int yylineno;
extern char *yytext;
extern int yyfila;
extern int yycolumna;

Nodo *raiz = nullptr;
JLista<Error*> *mi_lista_error = new JLista<Error*>();//nuevo

bool bandera = true;
char *error_salida;
char *nombreClase;

bool funciono = false;
Nodo *GetRaiz(){
	return raiz;
}

bool parseoCorrectamente(){
	return funciono;
}

void resetRaiz(){
	raiz=nullptr;
	//yyfila=1;//nuevo
	//yycolumna=0;//nuevo
}

char *getError(){
	return error_salida;
}


JLista<Error*> *getErrores(){//nuevo
	return mi_lista_error;
}
/*Prototipos propios*/
Nodo* addValor(Nodo*,Nodo*);
void addAmbito(Nodo*,char*);
/*Prototipos propios*/


int yyerror(const char *error){
	cout<<"\n\nError Sintactico:\n"<<error<<"\n\n";
	char *salida;
	mi_lista_error->add(new Error(yytext,yyfila-1,yycolumna,"sintactico"/*,salida*/));
	qDebug(error);
	qDebug(yytext);
	raiz = nullptr;
	bandera = false;
	return 0;
}

%}

%error-verbose

%union {
	char cadena[256];
	struct Nodo *NODO;
}

/*Terminales*/
%token <cadena> tCaracter
//visibilidad
%token <cadena> reservada_Publico
%token <cadena> reservada_Privado
//tipo de datos
%token <cadena> tipo_Int
%token <cadena> tipo_Double
%token <cadena> tipo_Bool
%token <cadena> tipo_Char
%token <cadena> tipo_String
//Operadores Relacionales
%token <cadena> relacional_Igual
%token <cadena> relacional_Distinto
%token <cadena> relacional_Menor
%token <cadena> relacional_Menor_Igual
%token <cadena> relacional_Mayor
%token <cadena> relacional_Mayor_Igual
//Operadores Logicos
%token <cadena> logico_OR
%token <cadena> logico_AND
%token <cadena> logico_NAND
%token <cadena> logico_NOR
%token <cadena> logico_XOR
%token <cadena> logico_NOT
//Operadores Matematicos
%token <cadena> mas
%token <cadena> menos
%token <cadena> por
%token <cadena> dividido
%token <cadena> elevado
//relativos clases
%token <cadena> reservada_Clase
%token <cadena> reservada_Import
%token <cadena> fin_de_Sentencia
%token <cadena> lKey
%token <cadena> rKey
//relativo a variables
%token <cadena> token_Caracter
%token <cadena> token_Cadena
%token <cadena> token_Real
%token <cadena> token_Id
%token <cadena> reservada_Var
%token <cadena> reservada_This
%token <cadena> token_Coma
%token <cadena> token_Punto
%token <cadena> token_PyC
%token <cadena> token_Igual
%token <cadena> token_Aumento
%token <cadena> token_Decremento
%token <cadena> lCorchete
%token <cadena> rCorchete
%token <cadena> lParen
%token <cadena> rParen
//sentencias de control
%token <cadena> sentencia_If
%token <cadena> sentencia_Else
%token <cadena> sentencia_For
%token <cadena> sentencia_While
%token <cadena> sentencia_Do
%token <cadena> reservada_Salir
//funciones
%token <cadena> reservada_Void
%token <cadena> reservada_Retorna
%token <cadena> reservada_Conservar
%token <cadena> reservada_Main
//funciones nativas
%token <cadena> nativa_Graficar
%token <cadena> nativa_Print
//otros
%token <cadena> bool_False
%token <cadena> bool_True
%token <cadena> mas_mas
%token <cadena> menos_menos
%token <cadena> mas_igual
%token <cadena> menos_igual
/*Terminales*/


/*Precedencia y Asociatividad*/
///////////////Operadores Logicos
%left logico_OR logico_NOR logico_XOR
%left logico_AND logico_NAND
%right logico_NOT
///////////////Operadores Relacionales
%left relacional_Distinto relacional_Igual relacional_Mayor relacional_Mayor_Igual relacional_Menor relacional_Menor_Igual
///////////////Operadores Aritmeticos
%left mas menos
%left por dividido
%right elevado
/*Precedencia y Asociatividad*/


/*No Terminales*/
%type <NODO> Clase
%type <NODO> Imports
%type <NODO> Visibilidad
%type <NODO> Cuerpo_clase
%type <NODO> Atributo
%type <NODO> ID_solo
%type <NODO> Tipo_dato
%type <NODO> Tamanyo
%type <NODO> Asignacion
%type <NODO> Asignacion_arreglo
%type <NODO> Asignacion_arregloP
%type <NODO> Valores
//%type <NODO> ID_asignado
%type <NODO> Expresion
%type <NODO> ID_acceso
%type <NODO> Acceso
%type <NODO> Condicion
%type <NODO> Comparacion
%type <NODO> Relacional
%type <NODO> If
%type <NODO> Else 
%type <NODO> For
%type <NODO> Declaracion_for
%type <NODO> Paso
%type <NODO> More_o_Less
%type <NODO> While
%type <NODO> DoWhile
%type <NODO> Sentencia
%type <NODO> Graficar
%type <NODO> Imprimir
%type <NODO> Funcion
%type <NODO> Con_sin_parametro
%type <NODO> Parametro 
%type <NODO> Main


/*No Terminales*/



%start S%%
/*Producciones*/

S:					Clase{
					funciono=true;
					raiz=$1;//new Nodo("Inicio"," ",0,0);
					//raiz->addHijo($1);
					}
					;
/*Producciones de la Clase*/					
Clase: 				Imports Visibilidad reservada_Clase token_Id lKey Cuerpo_clase rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						padre->addHijo($1);	
						padre->addHijo($2);						
						//padre->addHijo(new Nodo("reservada_Clase",$3,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$4,yyfila,yycolumna));
						addAmbito($6,$4);//nuevo
						padre->addHijo($6);
						nombreClase=$4;//para poner el ambito a las funciones 
						$$=padre;
					}	
					|Visibilidad reservada_Clase token_Id lKey Cuerpo_clase rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						padre->addHijo($1);						
						//padre->addHijo(new Nodo("reservada_Clase",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$3,yyfila,yycolumna));
						addAmbito($5,$3);//nuevo
						padre->addHijo($5);
						nombreClase=$3;//para poner el ambito a las funciones 
						$$=padre;
					}					
					|Imports reservada_Clase token_Id lKey Cuerpo_clase rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						padre->addHijo($1);
						Nodo* visi = new Nodo("Visibilidad"," ",0,0);
						visi->addHijo(new Nodo("reservada_Publico","publico",yyfila,yycolumna));
						padre->addHijo(visi);						
						//padre->addHijo(new Nodo("reservada_Clase",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$3,yyfila,yycolumna));
						addAmbito($5,$3);//nuevo
						padre->addHijo($5);
						nombreClase=$3;//para poner el ambito a las funciones 
						$$=padre;
					}						
					|Imports Visibilidad reservada_Clase token_Id lKey rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						padre->addHijo($1);
						padre->addHijo($2);
						//padre->addHijo(new Nodo("reservada_Clase",$3,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$4,yyfila,yycolumna));
						nombreClase=$4;//para poner el ambito a las funciones 
						$$=padre;
					}						
					|Visibilidad reservada_Clase token_Id lKey rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						padre->addHijo($1);						
						//padre->addHijo(new Nodo("reservada_Clase",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$3,yyfila,yycolumna));
						nombreClase=$3;//para poner el ambito a las funciones 
						$$=padre;
					}					
					|Imports reservada_Clase token_Id lKey rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						padre->addHijo($1);					
						Nodo* visi = new Nodo("Visibilidad"," ",0,0);
						visi->addHijo(new Nodo("reservada_Publico","publico",yyfila,yycolumna));
						padre->addHijo(visi);
						//padre->addHijo(new Nodo("reservada_Clase",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$3,yyfila,yycolumna));
						nombreClase=$3;//para poner el ambito a las funciones 
						$$=padre;
					}						
					|reservada_Clase token_Id lKey Cuerpo_clase rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						Nodo* visi = new Nodo("Visibilidad"," ",0,0);
						visi->addHijo(new Nodo("reservada_Publico","publico",yyfila,yycolumna));						
						padre->addHijo(visi);						
						//padre->addHijo(new Nodo("reservada_Clase",$1,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$2,yyfila,yycolumna));
						addAmbito($4,$2);//nuevo
						padre->addHijo($4);	
						nombreClase=$2;//para poner el ambito a las funciones 
						$$=padre;
					}						
					|reservada_Clase token_Id lKey rKey
					{
						Nodo* padre = new Nodo("Clase"," ",0,0);
						Nodo* visi = new Nodo("Visibilidad"," ",0,0);
						visi->addHijo(new Nodo("reservada_Publico","publico",yyfila,yycolumna));
						padre->addHijo(visi);
						//padre->addHijo(new Nodo("reservada_Clase",$1,yyfila,yycolumna));
						padre->addHijo(new Nodo("nombre_Clase",$2,yyfila,yycolumna));
						nombreClase=$2;//para poner el ambito a las funciones 
						$$=padre;
					}					
					;
Imports:			Imports reservada_Import token_Id fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Imports"," ",0,0);
						//padre->addHijo($1);						
						//padre->addHijo(new Nodo("reservada_Import",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						$$=padre;
					}	
					|reservada_Import token_Id fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Imports"," ",0,0);					
						//padre->addHijo(new Nodo("reservada_Import",$1,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$2,yyfila,yycolumna));
						$$=padre;
					}						
					;
Visibilidad:		reservada_Publico
					{
						Nodo* padre = new Nodo("reservada_Publico",$1,yyfila,yycolumna);//("Visibilidad"," ",0,0);
						//padre->addHijo(new Nodo("reservada_Publico",$1,yyfila,yycolumna));
						$$=padre;
					}	
					|reservada_Privado
					{
						Nodo* padre = new Nodo("reservada_Privado",$1,yyfila,yycolumna);//("Visibilidad"," ",0,0);
						//padre->addHijo(new Nodo("reservada_Privado",$1,yyfila,yycolumna));
						$$=padre;
					}						
					;
Cuerpo_clase:		Cuerpo_clase Atributo
					{
						Nodo* padre = $1;//new Nodo("Cuerpo_Clase"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}	
					|Cuerpo_clase Funcion
					{
						Nodo* padre = $1;//new Nodo("Cuerpo_Clase"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}						
					/*|Cuerpo_clase Main
					{
						Nodo* padre = new Nodo("Cuerpo_Clase"," ",0,0);
						padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}*/					
					|Atributo
					{
						Nodo* padre = new Nodo("Cuerpo_Clase"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}						
					|Funcion
					{
						Nodo* padre = new Nodo("Cuerpo_Clase"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}						
					|Main
					{
						Nodo* padre = new Nodo("Cuerpo_Clase"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					;
/*Producciones de la Clase*/					
/*Atributo*/
Atributo:			ID_solo Asignacion fin_de_Sentencia
					{
						Nodo* padre = addValor($1,$2);//$1;//new Nodo("Atributo"," ",0,0);
						//padre->addHijo($1);
						////padre->addHijo($2);
						/*for(int i=0;i<$1->no_hijos;i++){
							Nodo* aux = $1->hijos[i];
							if(aux->token=="token_Id")
								aux->childSteal($2);
						}*/
						//padre->childSteal($2);
						$$=padre;
					}	
					|ID_solo fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Atributo"," ",0,0);
						//padre->addHijo($1);
						$$=padre;
					}						
					/*|ID_solo Tamanyo fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Atributo"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}						
					|ID_solo Tamanyo Asignacion_arreglo fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Atributo"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						padre->addHijo($3);
						$$=padre;
					}*/						
					/*|ID_asignado fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Atributo"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}*/						
					;
ID_solo:			ID_solo token_Coma token_Id
					{
						Nodo* padre = $1;//new Nodo("ID_solo"," ",0,0);
						//padre->addHijo($1);
						//padre->addHijo(new Nodo("token_Coma",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						$$=padre;
					}
					|Visibilidad reservada_Var Tipo_dato token_Id
					{
						Nodo* padre = new Nodo("Atributo"," ",0,0);//("ID_solo"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("reservada_Var",$2,yyfila,yycolumna));
						padre->addHijo($3);
						padre->addHijo(new Nodo("token_Id",$4,yyfila,yycolumna));
						$$=padre;
					}					
					|reservada_Var Tipo_dato token_Id
					{
						Nodo* padre = new Nodo("Atributo"," ",0,0);//("ID_solo"," ",0,0);
						//Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						//Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));//(Visibil);
						//padre->addHijo(new Nodo("reservada_Var",$1,yyfila,yycolumna));
						padre->addHijo($2);
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						$$=padre;
					}					
					;
Tipo_dato:			tipo_Int
					{
						Nodo* padre = new Nodo("tipo_int",$1,yyfila,yycolumna);//("Tipo_dato"," ",0,0);
						//padre->addHijo(new Nodo("tipo_int",$1,yyfila,yycolumna));
						$$=padre;
					}
					|tipo_Bool
					{
						Nodo* padre = new Nodo("tipo_Bool",$1,yyfila,yycolumna);//("Tipo_dato"," ",0,0);
						//padre->addHijo(new Nodo("tipo_Bool",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|tipo_Char
					{
						Nodo* padre = new Nodo("tipo_Char",$1,yyfila,yycolumna);//("Tipo_dato"," ",0,0);
						//padre->addHijo(new Nodo("tipo_Char",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|tipo_Double
					{
						Nodo* padre = new Nodo("tipo_Double",$1,yyfila,yycolumna);//("Tipo_dato"," ",0,0);
						//padre->addHijo(new Nodo("tipo_Double",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|tipo_String
					{
						Nodo* padre = new Nodo("tipo_String",$1,yyfila,yycolumna);//("Tipo_dato"," ",0,0);
						//padre->addHijo(new Nodo("tipo_String",$1,yyfila,yycolumna));
						$$=padre;
					}
					|reservada_Void//nuevo
					{
						Nodo* padre = new Nodo("tipo_Void",$1,yyfila,yycolumna);//("Tipo_dato"," ",0,0);
						//padre->addHijo(new Nodo("tipo_Void",$1,yyfila,yycolumna));
						$$=padre;
					}
					;
Tamanyo:			lCorchete Expresion rCorchete
					{
						Nodo* padre = new Nodo("Tanaño"," ",0,0);
						padre->addHijo($2);
						$$=padre;
					}
					|lCorchete Expresion rCorchete lCorchete Expresion rCorchete
					{
						Nodo* padre = new Nodo("Tanaño"," ",0,0);
						padre->addHijo($2);
						padre->addHijo($5);
						$$=padre;
					}					
					|lCorchete Expresion rCorchete lCorchete Expresion rCorchete lCorchete Expresion rCorchete
					{
						Nodo* padre = new Nodo("Tanaño"," ",0,0);
						padre->addHijo($2);
						padre->addHijo($5);
						padre->addHijo($8);
						$$=padre;
					}					
					;
Asignacion:			token_Igual Condicion//Expresion
					{
						Nodo* padre = new Nodo("token_Igual",$1,yyfila,yycolumna);//("Asignacion"," ",0,0);
						//padre->addHijo(new Nodo("token_Igual",$1,yyfila,yycolumna));
						padre->addHijo($2);
						$$=padre;
					}
					;
Asignacion_arreglo:	token_Igual lKey Asignacion_arregloP rKey
					{
						Nodo* padre = new Nodo("Asignacion_arreglo"," ",0,0);
						padre->addHijo(new Nodo("token_Igual",$1,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;						
					}
					;					
Asignacion_arregloP:Valores
					|lKey Valores rKey lKey Valores rKey
					{
						Nodo* padre = new Nodo("Asignacion_arregloP"," ",0,0);
						padre->addHijo($2);
						padre->addHijo($5);
						$$=padre;
					}
					|lKey Valores rKey lKey Valores rKey lKey Valores rKey
					{
						Nodo* padre = new Nodo("Asignacion_arregloP"," ",0,0);
						padre->addHijo($2);
						padre->addHijo($5);
						padre->addHijo($8);
						$$=padre;
					}
					;
Valores:			Valores token_Coma Condicion//Expresion
					{
						Nodo* padre = new Nodo("Valores"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("token_Coma",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Condicion//Expresion
					{
						Nodo* padre = new Nodo("Valores"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}
					;				
/*ID_asignado:		ID_asignado token_Coma token_Id Asignacion
					{
						Nodo* padre = new Nodo("ID_asignado"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("token_Coma",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						padre->addHijo($4);
						$$=padre;
					}
					|Visibilidad reservada_Var Tipo_dato token_Id Asignacion
					{
						Nodo* padre = new Nodo("ID_asignado"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("reservada_Var",$2,yyfila,yycolumna));
						padre->addHijo($3);
						padre->addHijo(new Nodo("token_Id",$4,yyfila,yycolumna));
						padre->addHijo($5);
						$$=padre;
					}
					|reservada_Var Tipo_dato token_Id Asignacion
					{
						Nodo* padre = new Nodo("ID_asignado"," ",0,0);
						padre->addHijo(new Nodo("reservada_Var",$1,yyfila,yycolumna));
						padre->addHijo($2);
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						padre->addHijo($4);
						$$=padre;
					}
					;*/
/*Atributo*/
/*Expresion y Condicion*/					
Expresion:			Expresion mas Expresion
					{
						//Nodo* padre = new Nodo("E"," ",0,0);
						Nodo* padre = new Nodo("mas",$2,yyfila,yycolumna);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("mas",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Expresion menos Expresion
					{
						Nodo* padre = new Nodo("menos",$2,yyfila,yycolumna);//("E"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("menos",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Expresion por Expresion
					{
						Nodo* padre = new Nodo("por",$2,yyfila,yycolumna);//("E"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("por",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Expresion dividido Expresion
					{
						Nodo* padre = new Nodo("dividido",$2,yyfila,yycolumna);//("E"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("dividido",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Expresion elevado Expresion
					{
						Nodo* padre = new Nodo("elevado",$2,yyfila,yycolumna);//("E"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("elevado",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|lParen Expresion rParen
					{
						Nodo* padre = $2;//new Nodo("E"," ",0,0);
						//padre->addHijo(new Nodo("lParen",$1,yyfila,yycolumna));
						//padre->addHijo($2);
						//padre->addHijo(new Nodo("rParen",$3,yyfila,yycolumna));
						$$=padre;
					}
					|token_Real
					{
						Nodo* padre = new Nodo("token_Real",$1,yyfila,yycolumna);//("E"," ",0,0);
						//padre->addHijo(new Nodo("token_Real",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|menos token_Real
					{
						Nodo* padre = new Nodo("token_Real_negativo",$1,yyfila,yycolumna);//("E"," ",0,0);
						//padre->addHijo(new Nodo("token_Real",contenido,yyfila,yycolumna));
						$$=padre;
					}					
					|token_Cadena
					{
						Nodo* padre = new Nodo("token_Cadena",$1,yyfila,yycolumna);//("E"," ",0,0);
						//padre->addHijo(new Nodo("token_Cadena",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|token_Caracter
					{
						Nodo* padre = new Nodo("token_Caracter",$1,yyfila,yycolumna);//("E"," ",0,0);
						//padre->addHijo(new Nodo("token_Caracter",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|ID_acceso//este incluye el llamar una funcion, porque una funcion es un ID con parametros (vacio o no)
					{
						Nodo* padre = $1;//new Nodo("E"," ",0,0);
						//padre->addHijo($1);
						$$=padre;
					}					
				/*	|Condicion
					{
						Nodo* padre = new Nodo("E"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					*/
					|bool_False
					{
						Nodo* padre = new Nodo("bool_False",$1,yyfila,yycolumna);//("E"," ",0,0);
						//padre->addHijo(new Nodo("bool_False",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|bool_True
					{
						Nodo* padre = new Nodo("bool_True",$1,yyfila,yycolumna);//("E"," ",0,0);
						//padre->addHijo(new Nodo("bool_True",$1,yyfila,yycolumna));
						$$=padre;
					}
					;
ID_acceso:			Acceso lParen Valores rParen
					{
						Nodo* padre = $1;//new Nodo("ID_acceso"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($3);
						$$=padre;
					}
					|Acceso lParen rParen
					{
						Nodo* padre = $1;//new Nodo("ID_acceso"," ",0,0);
						//Nodo* hijo = new Nodo("Valores"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(hijo);
						$$=padre;
					}		
					|Acceso
					{
						Nodo* padre = $1;//new Nodo("ID_acceso"," ",0,0);
						//padre->addHijo($1);
						$$=padre;
					}		
					;
Acceso:				/*Acceso token_Punto token_Id
					{
						Nodo* padre = $1;//new Nodo("Acceso"," ",0,0);
						//padre->addHijo($3);
						//padre->addHijo(new Nodo("token_Punto",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						$$=padre;
					}
					|*/token_Id
					{
						Nodo* padre = new Nodo("token_Id",$1,yyfila,yycolumna);//new Nodo("Acceso"," ",0,0);
						//padre->addHijo(new Nodo("token_Id",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|reservada_This token_Punto token_Id
					{
						Nodo* padre = new Nodo("reservada_This",$1,yyfila,yycolumna);//new Nodo("Acceso"," ",0,0);
						//padre->addHijo(new Nodo("reservada_This",$1,yyfila,yycolumna));
						//padre->addHijo(new Nodo("token_Punto",$2,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						$$=padre;
					}					
					;			
Condicion:			Condicion logico_OR Condicion
					{
						Nodo* padre = new Nodo("logico_OR",$2,yyfila,yycolumna);//("Condicion"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("logico_OR",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Condicion logico_NOR Condicion
					{
						Nodo* padre = new Nodo("logico_NOR",$2,yyfila,yycolumna);//("Condicion"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("logico_NOR",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;					
					}
					|Condicion logico_XOR Condicion
					{
						Nodo* padre = new Nodo("logico_XOR",$2,yyfila,yycolumna);//("Condicion"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("logico_XOR",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;				
					}
					|Condicion logico_AND Condicion
					{
						Nodo* padre = new Nodo("logico_AND",$2,yyfila,yycolumna);//("Condicion"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("logico_AND",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;					
					}
					|Condicion logico_NAND Condicion
					{
						Nodo* padre = new Nodo("logico_NAND",$2,yyfila,yycolumna);//("Condicion"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo(new Nodo("logico_NAND",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;				
					}
					|logico_NOT Comparacion 
					{
						Nodo* padre = new Nodo("logico_NOT",$1,yyfila,yycolumna);//("Condicion"," ",0,0);
						//padre->addHijo(new Nodo("logico_NOT",$1,yyfila,yycolumna));
						padre->addHijo($2);
						$$=padre;
					}
					|Comparacion
					{
						Nodo* padre $1;//= new Nodo("Condicion"," ",0,0);
						//padre->addHijo($1);
						$$=padre;
					}
					;
Comparacion:		Expresion Relacional Expresion
					{
						Nodo* padre = $2;//new Nodo("Comparacion"," ",0,0);
						padre->addHijo($1);
						//padre->addHijo($2);
						padre->addHijo($3);
						$$=padre;
					}	
					|Expresion
					{
						Nodo* padre = $1;//new Nodo("Comparacion"," ",0,0);
						//padre->addHijo($1);
						$$=padre;
					}						
					;
Relacional:			relacional_Menor
					{
						Nodo* padre = new Nodo("relacional_Menor",$1,yyfila,yycolumna);//("Relacional"," ",0,0);
						//padre->addHijo(new Nodo("relacional_Menor",$1,yyfila,yycolumna));
						$$=padre;
					}	
					|relacional_Mayor
					{
						Nodo* padre = new Nodo("relacional_Mayor",$1,yyfila,yycolumna);//("Relacional"," ",0,0);
						//padre->addHijo(new Nodo("relacional_Mayor",$1,yyfila,yycolumna));
						$$=padre;
					}						
					|relacional_Igual
					{
						Nodo* padre = new Nodo("relacional_Igual",$1,yyfila,yycolumna);//("Relacional"," ",0,0);
						//padre->addHijo(new Nodo("relacional_Igual",$1,yyfila,yycolumna));
						$$=padre;
					}						
					|relacional_Distinto
					{
						Nodo* padre = new Nodo("relacional_Distinto",$1,yyfila,yycolumna);//("Relacional"," ",0,0);
						//padre->addHijo(new Nodo("relacional_Distinto",$1,yyfila,yycolumna));
						$$=padre;
					}						
					|relacional_Menor_Igual
					{
						Nodo* padre = new Nodo("relacional_Menor_Igual",$1,yyfila,yycolumna);//("Relacional"," ",0,0);
						//padre->addHijo(new Nodo("relacional_Menor_Igual",$1,yyfila,yycolumna));
						$$=padre;
					}						
					|relacional_Mayor_Igual
					{
						Nodo* padre = new Nodo("relacional_Mayor_Igual",$1,yyfila,yycolumna);//("Relacional"," ",0,0);
						//padre->addHijo(new Nodo("relacional_Mayor_Igual",$1,yyfila,yycolumna));
						$$=padre;
					}						
					;				
/*Expresion y Condicion*/		
/*Sentencias de Control*/
//if
If:					sentencia_If lParen Condicion rParen lKey Sentencia rKey Else
					{
						Nodo* padre = new Nodo("sentencia_If",$1,yyfila,yycolumna);//("If"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_If",$1,yyfila,yycolumna));
						padre->addHijo($3);
						padre->addHijo($6);
						padre->addHijo($8);
						$$=padre;
					}	
					|sentencia_If lParen Condicion rParen lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("sentencia_If",$1,yyfila,yycolumna);//("If"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_If",$1,yyfila,yycolumna));
						padre->addHijo($3);
						padre->addHijo($6);
						$$=padre;
					}					
					|sentencia_If lParen Condicion rParen lKey rKey
					{
						Nodo* padre = new Nodo("sentencia_If",$1,yyfila,yycolumna);//("If"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_If",$1,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|sentencia_If lParen Condicion rParen lKey rKey Else
					{
						Nodo* padre = new Nodo("sentencia_If",$1,yyfila,yycolumna);//("If"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_If",$1,yyfila,yycolumna));
						padre->addHijo($3);
						padre->addHijo($7);
						$$=padre;
					}						
					;
Else:				sentencia_Else lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("sentencia_Else",$1,yyfila,yycolumna);//("Else"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_Else",$1,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}	
					|sentencia_Else lKey rKey
					{
						Nodo* padre = new Nodo("sentencia_Else",$1,yyfila,yycolumna);//("Else"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_Else",$1,yyfila,yycolumna));
						$$=padre;
					}						
					;
//for
For:				sentencia_For lParen Declaracion_for token_PyC Condicion token_PyC Paso rParen lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("sentencia_For",$1,yyfila,yycolumna);//("For"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_For",$1,yyfila,yycolumna));
						padre->childSteal($3);//padre->addHijo($3);
						padre->addHijo(new Nodo("token_PyC",$4,yyfila,yycolumna));
						padre->addHijo($5);
						padre->addHijo(new Nodo("token_PyC",$6,yyfila,yycolumna));
						padre->childSteal($7);//padre->addHijo($7);
						padre->addHijo($10);
						$$=padre;
					}
					|sentencia_For lParen Declaracion_for token_PyC Condicion token_PyC Paso rParen lKey rKey
					{
						Nodo* padre = new Nodo("sentencia_For",$1,yyfila,yycolumna);//("For"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_For",$1,yyfila,yycolumna));
						padre->childSteal($3);//padre->addHijo($3);
						padre->addHijo(new Nodo("token_PyC",$4,yyfila,yycolumna));
						padre->addHijo($5);
						padre->addHijo(new Nodo("token_PyC",$6,yyfila,yycolumna));
						padre->childSteal($7);//padre->addHijo($7);
						$$=padre;
					}					
					;
Declaracion_for:	tipo_Int token_Id Asignacion
					{
						Nodo* padre = new Nodo("Declaracion_For"," ",0,0);
						padre->addHijo(new Nodo("tipo_Int",$1,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Acceso Asignacion
					{
						Nodo* padre = new Nodo("Declaracion_For"," ",0,0);
						padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					;
Paso:				Acceso mas_igual Expresion
					{
						Nodo* padre = new Nodo("Paso"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("mas_igual",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					|Acceso menos_igual Expresion
					{
						Nodo* padre = new Nodo("Paso"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("menos_igual",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}			
					|Acceso token_Igual Expresion
					{
						Nodo* padre = new Nodo("Paso"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("token_Igual",$2,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}					
					|More_o_Less
					{
						Nodo* padre = new Nodo("Paso"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}										
					;
More_o_Less:		Acceso mas_mas 
					{
						Nodo* padre = new Nodo("More_o_Less"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("mas_mas",$2,yyfila,yycolumna));
						$$=padre;
					}
					|Acceso menos_menos
					{
						Nodo* padre = new Nodo("More_o_Less"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("menos_menos",$2,yyfila,yycolumna));
						$$=padre;
					}					
					;
//while
While:				sentencia_While lParen Condicion rParen lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("sentencia_While",$1,yyfila,yycolumna);//("While"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_While",$1,yyfila,yycolumna));
						padre->addHijo($3);
						padre->addHijo($6);
						$$=padre;
					}
					|sentencia_While lParen Condicion rParen lKey rKey
					{
						Nodo* padre = new Nodo("sentencia_While",$1,yyfila,yycolumna);//("While"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_While",$1,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}					
					;
//do while
DoWhile:			sentencia_Do lKey Sentencia rKey sentencia_While lParen Condicion rParen fin_de_Sentencia
					{
						Nodo* padre = new Nodo("sentencia_Do",$1,yyfila,yycolumna);//("DoWhile"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_Do",$1,yyfila,yycolumna));
						padre->addHijo($3);
						//padre->addHijo(new Nodo("sentencia_While",$5,yyfila,yycolumna));
						padre->addHijo($7);
						$$=padre;
					}	
					|sentencia_Do lKey rKey sentencia_While lParen Condicion rParen fin_de_Sentencia
					{
						Nodo* padre = new Nodo("sentencia_Do",$1,yyfila,yycolumna);//("DoWhile"," ",0,0);
						//padre->addHijo(new Nodo("sentencia_Do",$1,yyfila,yycolumna));
						//padre->addHijo(new Nodo("sentencia_While",$4,yyfila,yycolumna));
						padre->addHijo($6);
						$$=padre;
					}						
					;
//Sentencia
Sentencia: 			Sentencia Atributo
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);//padre->addHijo($2);
						$$=padre;
					}
					|Sentencia If
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia For
					{
						Nodo* padre = $1;// new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia While
					{
						Nodo* padre = $1;// new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia DoWhile
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia Graficar fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia Imprimir fin_de_Sentencia	
					{
						Nodo* padre = $1;//new Nodo("Sentenciar"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia ID_acceso fin_de_Sentencia//llamada a funcion o metodo
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia More_o_Less fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo($2);
						$$=padre;
					}					
					|Sentencia reservada_Salir fin_de_Sentencia		
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo(new Nodo("reservada_Salir",$2,yyfila,yycolumna));
						$$=padre;
					}					
					|Sentencia reservada_Retorna fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						padre->addHijo(new Nodo("reservada_Retorna",$2,yyfila,yycolumna));
						$$=padre;
					}					
					|Sentencia ID_acceso Asignacion fin_de_Sentencia//Asignacion
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						$2->addHijo($3);
						padre->addHijo($2);
						//padre->addHijo($3);
						$$=padre;
					}					
					|Sentencia reservada_Retorna Condicion/*Expresion*/ fin_de_Sentencia
					{
						Nodo* padre = $1;//new Nodo("Sentencia"," ",0,0);
						//padre->addHijo($1);
						Nodo* hijo = new Nodo("reservada_Retorna",$2,yyfila,yycolumna);
						hijo->addHijo($3);
						padre->addHijo(hijo);
						//padre->addHijo(new Nodo("reservada_Retorna",$2,yyfila,yycolumna));
						//padre->addHijo($3);
						$$=padre;
					}
					|Atributo
					{
						Nodo *padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}
					|If
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|For
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|While
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|DoWhile
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|Graficar
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|Imprimir
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|ID_acceso fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|More_o_Less fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo($1);
						$$=padre;
					}					
					|reservada_Salir fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo(new Nodo("reservada_Salir",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|reservada_Retorna fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						padre->addHijo(new Nodo("reservada_Retorna",$1,yyfila,yycolumna));
						$$=padre;
					}					
					|ID_acceso Asignacion fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						$1->addHijo($2);
						padre->addHijo($1);
						//padre->addHijo($2);
						$$=padre;
					}					
					|reservada_Retorna Condicion/*Expresion*/ fin_de_Sentencia
					{
						Nodo* padre = new Nodo("Sentencia"," ",0,0);
						Nodo* hijo = new Nodo("reservada_Retorna",$1,yyfila,yycolumna);
						hijo->addHijo($2);
						padre->addHijo(hijo);
						//padre->addHijo(new Nodo("reservada_Retorna",$1,yyfila,yycolumna));
						//padre->addHijo($2);
						$$=padre;
					}
					;
Graficar:			nativa_Graficar lParen token_Id rParen
					{
						Nodo* padre = new Nodo("Graficar"," ",0,0);
						padre->addHijo(new Nodo("nativa_Graficar",$1,yyfila,yycolumna));
						padre->addHijo(new Nodo("token_Id",$3,yyfila,yycolumna));
						$$=padre;
					}
					;
Imprimir:			nativa_Print lParen Condicion/*Expresion*/ rParen
					{
						Nodo* padre = new Nodo("Imprimir"," ",0,0);
						padre->addHijo(new Nodo("nativa_Print",$1,yyfila,yycolumna));
						padre->addHijo($3);
						$$=padre;
					}
					;
/*Sentencias de Control*/
/*Funciones y Metodos*/
Funcion:			reservada_Conservar Visibilidad Tipo_dato token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						padre->addHijo($2);
						padre->addHijo($3);
						padre->addHijo(new Nodo("id_Funcion",$4,yyfila,yycolumna));
						//padre->childSteal($5);
						addAmbito($5,$4);//agregar ambito a los parametros de la funcion
						padre->addHijo($5);
						padre->addHijo($7);
						$$=padre;
					}	
					|Visibilidad Tipo_dato token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo($1);
						padre->addHijo($2);
						padre->addHijo(new Nodo("id_Funcion",$3,yyfila,yycolumna));
						addAmbito($4,$3);//agregar ambito a los parametros de la funcion
						padre->addHijo($4);
						padre->addHijo($6);
						$$=padre;
					}							
					|reservada_Conservar Tipo_dato token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						padre->addHijo($2);
						padre->addHijo(new Nodo("id_Funcion",$3,yyfila,yycolumna));
						addAmbito($4,$3);//agregar ambito a los parametros de la funcion
						padre->addHijo($4);
						padre->addHijo($6);
						$$=padre;
					}						
					|reservada_Conservar Visibilidad token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						padre->addHijo($2);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$3,yyfila,yycolumna));
						addAmbito($4,$3);//agregar ambito a los parametros de la funcion
						padre->addHijo($4);
						padre->addHijo($6);
						$$=padre;
					}					
					|Visibilidad token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo($1);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$2,yyfila,yycolumna));
						addAmbito($3,$2);//agregar ambito a los parametros de la funcion
						padre->addHijo($3);
						padre->addHijo($5);
						$$=padre;
					}					
					|reservada_Conservar token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$2,yyfila,yycolumna));
						addAmbito($3,$2);//agregar ambito a los parametros de la funcion
						padre->addHijo($3);
						padre->addHijo($5);
						$$=padre;
					}	
					|token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$1,yyfila,yycolumna));
						addAmbito($2,$1);//agregar ambito a los parametros de la funcion
						padre->addHijo($2);
						padre->addHijo($4);
						$$=padre;
					}						
					|Tipo_dato token_Id Con_sin_parametro lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						padre->addHijo($1);
						padre->addHijo(new Nodo("id_Funcion",$2,yyfila,yycolumna));
						addAmbito($3,$2);//agregar ambito a los parametros de la funcion
						padre->addHijo($3);
						padre->addHijo($5);
						$$=padre;
					}					
					|reservada_Conservar Visibilidad Tipo_dato token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						padre->addHijo($2);
						padre->addHijo($3);
						padre->addHijo(new Nodo("id_Funcion",$4,yyfila,yycolumna));
						addAmbito($5,$4);//agregar ambito a los parametros de la funcion
						padre->addHijo($5);
						$$=padre;
					}					
					|Visibilidad Tipo_dato token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo($1);
						padre->addHijo($2);
						padre->addHijo(new Nodo("id_Funcion",$3,yyfila,yycolumna));
						addAmbito($4,$3);//agregar ambito a los parametros de la funcion
						padre->addHijo($4);
						$$=padre;
					}					
					|reservada_Conservar Tipo_dato token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						padre->addHijo($2);
						padre->addHijo(new Nodo("id_Funcion",$3,yyfila,yycolumna));
						addAmbito($4,$3);//agregar ambito a los parametros de la funcion
						padre->addHijo($4);
						$$=padre;
					}					
					|reservada_Conservar Visibilidad token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						padre->addHijo($2);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$3,yyfila,yycolumna));
						addAmbito($4,$3);//agregar ambito a los parametros de la funcion
						padre->addHijo($4);
						$$=padre;
					}					
					|Visibilidad token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo($1);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$2,yyfila,yycolumna));
						addAmbito($3,$2);//agregar ambito a los parametros de la funcion
						padre->addHijo($3);
						$$=padre;
					}					
					|reservada_Conservar token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						padre->addHijo(new Nodo("reservada_Conservar",$1,yyfila,yycolumna));
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$2,yyfila,yycolumna));
						addAmbito($3,$2);//agregar ambito a los parametros de la funcion
						padre->addHijo($3);
						$$=padre;
					}					
					|token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						Nodo* tip_dat = new Nodo("Tipo_dato"," ",0,0);
						tip_dat->addHijo(new Nodo("tipo_Void","void",yyfila,yycolumna));
						padre->addHijo(tip_dat);
						padre->addHijo(new Nodo("id_Funcion",$1,yyfila,yycolumna));
						addAmbito($2,$1);//agregar ambito a los parametros de la funcion
						padre->addHijo($2);
						$$=padre;
					}					
					|Tipo_dato token_Id Con_sin_parametro lKey  rKey
					{
						Nodo* padre = new Nodo("Funcion"," ",0,0,nombreClase);
						Nodo* Visibil = new Nodo("Visibilidad"," ",0,0);
						Visibil->addHijo(new Nodo("Publico_no_explicito","publico",yyfila,yycolumna));
						padre->addHijo(Visibil);
						padre->addHijo($1);
						padre->addHijo(new Nodo("id_Funcion",$2,yyfila,yycolumna));
						addAmbito($3,$2);//agregar ambito a los parametros de la funcion
						padre->addHijo($3);
						$$=padre;
					}					
					;
Con_sin_parametro:	lParen rParen
					{
						Nodo* padre=nullptr;
						$$=padre;
					}
					|lParen Parametro rParen
					{
						Nodo* padre =$2;// new Nodo("Con_sin_parametro"," ",0,0);
						//padre->addHijo($2);
						$$=padre;
					}
					;
Parametro:			Parametro token_Coma Tipo_dato token_Id
					{
						Nodo* padre =$1;// new Nodo("Parametro"," ",0,0);
						//padre->addHijo($1);
						//padre->addHijo(new Nodo("token_Coma",$2,yyfila,yycolumna));
						padre->addHijo($3);
						padre->addHijo(new Nodo("token_Id",$4,yyfila,yycolumna));
						$$=padre;
					}	
					|Tipo_dato token_Id
					{
						Nodo* padre = new Nodo("Parametro"," ",0,0);
						padre->addHijo($1);
						padre->addHijo(new Nodo("token_Id",$2,yyfila,yycolumna));
						$$=padre;
					}						
					;
/*Funciones y Metodos*/
/*Main*/
Main:				reservada_Main lParen rParen lKey Sentencia rKey
					{
						Nodo* padre = new Nodo("Main"," ",0,0);
						padre->addHijo(new Nodo("reservada_Main",$1,yyfila,yycolumna));
						padre->addHijo($5);
						$$=padre;
					}
					|reservada_Main lParen rParen lKey rKey
					{
						Nodo* padre = new Nodo("Main"," ",0,0);
						padre->addHijo(new Nodo("reservada_Main",$1,yyfila,yycolumna));
						$$=padre;
					}					
					;
/*Main*/
/*Producciones*/
%%

/*Funciones auxiliares*/
Nodo *addValor(Nodo* padre, Nodo* victima){
	for(int i=0;i<padre->no_hijos;i++){
		Nodo* aux = padre->hijos[i];
		if(aux->token=="token_Id")
			aux->childSteal(victima);
	}
	return padre;
}

void addAmbito(Nodo* padre, char* ambito){
	int limite = padre->no_hijos;
	Nodo* aux=nullptr;
	for(int i=0; i<limite; i++){
		aux=padre->hijos[i];
		if(aux==nullptr){
		}
		else if(aux->token=="Atributo"){
			addAmbito(aux,ambito);
		}else if(aux->token=="token_Id")
			aux->ambito=ambito;
	}
}