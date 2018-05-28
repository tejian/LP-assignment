#header
<<
#include <string>
#include <iostream>
using namespace std;

// ==========================AST DATA STRUCTURE===============================
// struct to store information about tokens
typedef struct {
  string kind;
  string text;
} Attrib;

// function to fill token information (predeclaration)
void zzcr_attr(Attrib *attr, int type, char *text);

// fields for AST nodes
#define AST_FIELDS string kind; string text;
#include "ast.h"

// macro to create a new AST node (and function predeclaration)
#define zzcr_ast(as,attr,ttype,textt) as=createASTnode(attr,ttype,textt)
AST* createASTnode(Attrib* attr, int ttype, char *textt);

#define createASTlist #0=new AST;(#0)->kind="list";(#0)->right=NULL;(#0)->down=_sibling;
>>

<<
#include <cstdlib>
#include <cmath>
#include <map>
#include <string>
#include <vector>
// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  if (type == NUM)
  {
      attr->kind = "int";
      attr->text = text;
  }
  else if (type == ID)
  {
      attr->kind = "id";
      attr->text = text;
  }
  else
  {
      attr->kind = text;
      attr->text = "";
  }
}

// function to create a new AST node
AST* createASTnode(Attrib* attr, int type, char* text) {
  AST* as = new AST;
  as->kind = attr->kind; 
  as->text = attr->text;
  as->right = NULL; 
  as->down = NULL;
  return as;
}

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a,int n) {
 AST *c=a->down;
 for (int i=0; c!=NULL && i<n; i++) c=c->right;
 return c;
} 

// ===================================== PRINTING AST =========================================

/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a,string s)
{
  if (a==NULL) return;

  cout<<a->kind;
  if (a->text!="") cout<<"("<<a->text<<")";
  cout<<endl;

  AST *i = a->down;
  while (i!=NULL && i->right!=NULL) {
    cout<<s+"  \\__";
    ASTPrintIndent(i,s+"  |"+string(i->kind.size()+i->text.size(),' '));
    i=i->right;
  }
  
  if (i!=NULL) {
      cout<<s+"  \\__";
      ASTPrintIndent(i,s+"   "+string(i->kind.size()+i->text.size(),' '));
      i=i->right;
  }
}

/// print AST 
void ASTPrint(AST *a)
{
  while (a!=NULL) {
    cout<<" ";
    ASTPrintIndent(a,"");
    a=a->right;
  }
}

// ============================================================

bool compareInt (const string& op, int a, int b)
{
    if (op == ">" ) return a >  b;
    if (op == "<" ) return a <  b;
    if (op == "<=") return a <= b;
    if (op == ">=") return a >= b;
    if (op == "==") return a == b;
    if (op == "!=") return a != b;
    return false;
}

int operateInt (const string& op, int a, int b)
{
    if (op == "+") return a + b;
    if (op == "-") return a - b;
    if (op == "*") return a * b;
    if (op == "/") return a / b;
    return -1;
}

class Item
{
private:
    enum {N,L};
    int m_type;
public:
    vector <Item> m_list;
    int m_num;

    static Item createNum  (int n) 
    { 
        Item temp;
        temp.m_type = N;
        temp.m_num = n;
        return temp;
    }

    static Item createList () 
    {
        Item temp;
        temp.m_type = L;
        return temp;
    }

    bool isNum() { return m_type == N;}
    bool isList() { return m_type == L;}

    string getText ()
    {
        string a;
        if (isNum()) 
            a = to_string (m_num);
        else
        {
            a = "[";
            for (int i = 0; i < m_list.size(); ++i) 
            {
                a = a + m_list[i].getText();
                if (i < m_list.size()-1)
                    a = a + ", ";
            }
            a = a + "]";
            return a;
        }
        return a;
    }

    void concat (Item a)
    {
        if (a.isNum()) return;
        for (Item i : a.m_list)
            m_list.push_back (i);
    }

    Item head()
    {
        return m_list.front();
    }

    void flatten()
    {
        if (isNum()) return;
        vector <Item> b;
        for (Item a : m_list)
        {
            if (a.isNum())
                b.push_back (a);
            else
            {
                a.flatten();
                b.insert (b.begin(), a.m_list.begin(), a.m_list.end());
            }
        }
        m_list = b;
    }

    void pop()
    {
        if (isNum()) return;
        m_list.erase (m_list.begin());
    }

    Item reduce (const string& op)
    {
        Item temp = *this;
        temp.flatten();
        int ans;

        if (temp.m_list.empty()) ans = 0;
        else ans = temp.m_list.front().m_num;

        for (int i = 1; i < temp.m_list.size(); ++i)
            ans = operateInt (op, ans, temp.m_list[i].m_num);

        Item res = createList();
        res.m_list.push_back(createNum(ans));
        return res;
    }

    Item filter (const string& op, const int a)
    {
        Item res = createList();
        for (Item b : m_list)
        {
            if (b.isNum())
            {
                if (compareInt(op, b.m_num, a))
                    res.m_list.push_back (b);
            }
            else
            {
                res.m_list.push_back (b.filter (op, a));
            }
        }
        return res;
    }

    void map (const string& op, const int a)
    {
        for (Item& b : m_list)
        {
            if (b.isNum())
                b.m_num = operateInt (op, b.m_num, a);
            else
                b.map (op, a);
        }
    }

    bool isEmpty()
    {
        return m_list.empty();
    }
};

bool compareListItem (const string& op, const Item& lhs, const Item& rhs)
{
    vector<int> a, b;
    for (const Item& i : lhs.m_list) a.push_back (i.m_num);
    for (const Item& i : rhs.m_list) b.push_back (i.m_num);

    if (op == ">" ) return a >  b;
    if (op == "<" ) return a <  b;
    if (op == "<=") return a <= b;
    if (op == ">=") return a >= b;
    if (op == "==") return a == b;
    if (op == "!=") return a != b;
    return false;
}

map <string, Item> g_symTable;

Item createList (AST* a)
{
    Item l = Item::createList();
    while (a != NULL)
    {
        if (a->kind == "[") 
            l.m_list.push_back (createList (a->down));
        else 
            l.m_list.push_back (Item::createNum (stoi (a->text.c_str())));
        a = a->right;
    }
    return l;
}

Item evalexpr (AST* expr)
{
    Item r;
    if      (expr->kind == "["      ) { r = createList (expr->down);                                                             }
    else if (expr->kind == "lreduce") { r = evalexpr (child (expr, 1)).reduce (expr->down->kind);                                }
    else if (expr->kind == "lfilter") { r = evalexpr (child (expr, 1)).filter (expr->down->kind, stoi (expr->down->down->text)); }
    else if (expr->kind == "lmap"   ) { r = evalexpr (child (expr, 2)); r.map (expr->down->kind, stoi (child (expr, 1)->text));  }
    else if (expr->kind == "head"   ) { r = evalexpr (expr->down).head();                                                        }
    else if (expr->kind == "#"      ) { r = evalexpr (expr->down); r.concat (evalexpr (child (expr, 1)));                        }
    else if (expr->kind == "id"     ) { r = g_symTable[expr->text];                                                              }
    return r;
}

bool evalBoolExpr (AST* expr)
{
    bool res = false;
    if      (expr->kind == "not"  ) { res = not evalBoolExpr (expr->down);                                  }
    else if (expr->kind == "empty") { res = evalexpr (expr->down).isEmpty();                                }
    else if (expr->kind == "and"  ) { res = evalBoolExpr (child (expr,0)) && evalBoolExpr (child (expr,1)); }
    else if (expr->kind == "or"   ) { res = evalBoolExpr (child (expr,0)) || evalBoolExpr (child (expr,1)); }
    else { res = compareListItem (expr->kind, evalexpr (child (expr,0)), evalexpr (child (expr,1)));        }
    return res;
}

void executeInsList (AST* a)
{
    while (a!=NULL)
    {
        if      (a->kind == "print"  ) { cout << evalexpr (a->down).getText() << endl;                          }
        else if (a->kind == "if"     ) { if (evalBoolExpr (child (a,0))) executeInsList (child (a,1)->down);    }
        else if (a->kind == "while"  ) { while (evalBoolExpr (child (a,0))) executeInsList (child (a,1)->down); }
        else if (a->kind == "flatten") { g_symTable[a->down->text].flatten();                                   }
        else if (a->kind == "pop"    ) { g_symTable[a->down->text].pop();                                       }
        else if (a->kind == "="      ) { g_symTable[a->down->text] = evalexpr (child (a,1));                    }
        a = a->right;
    }
}

// ================================= MAIN =============
int main() {
  AST *root = NULL;
  ANTLR(lists(&root), stdin);
  ASTPrint(root);
  executeInsList(root->down);
}
>>

// ======================== GRAMMER RULES ==========================

#lexclass START
#token NUM      "{\-}[0-9]+"

#token ASSIG    "="

#token EQ       "=="
#token NEQ      "!="
#token LT       "<"
#token GT       ">"
#token LTE      "<="
#token GTE      ">="

#token NOT      "not"
#token AND      "and"
#token OR       "or"

#token PLUS     "\+"
#token MINUS    "\-"
#token MUL      "\*"
#token DIV      "\/"

#token HEAD     "head"
#token POP      "pop"
#token FLATTEN  "flatten"
#token LRED     "lreduce"
#token LMAP     "lmap"
#token LFIL     "lfilter"
#token CONCAT   "#"
#token EMPTY    "empty"

#token PRINT    "print"

#token IF       "if"
#token THEN     "then"
#token ENDIF    "endif"

#token WHILE    "while"
#token DO       "do"
#token ENDWHILE "endwhile"

#token LPAR     "\("
#token RPAR     "\)"

#token LSUB     "\["
#token RSUB     "\]"

#token ID     "[a-zA-Z][a-zA-Z0-9]*"
#token SPACE  "[\ \n]"<< zzskip();>>

lists: (list_oper)* <<#0=createASTlist(_sibling);>> ;

list_oper 
        : ID ASSIG^ expr                                  // assignacio
        | PRINT^ expr                                     // print
        | IF^ LPAR! bexpr RPAR! THEN! lists ENDIF!        // if
        | WHILE^ LPAR! bexpr RPAR! DO! lists ENDWHILE!    // while
        | FLATTEN^ ID                                     // flatten a list
        | POP^ LPAR! ID RPAR!
        ;

expr    : LRED^ redOpr ID
        | LFIL^ filOpr ID
        | LMAP^ mapOpr ID
        | HEAD^ LPAR! ID RPAR!   
        | ID (CONCAT^ ID)*      // simply if or it can denote concatanation and i dont know if its correct or not
        | list
        | NUM
        ;

bexpr   : bexpr1 (|OR^ bexpr);
bexpr1  : bAtom (|AND^ bexpr1);
bAtom   : EMPTY^ LPAR! ID RPAR!
        | NOT^ bAtom
        | LPAR^ bexpr RPAR
        | (ID | list) (EQ^ | NEQ^ | LT^ | GT^ | LTE^ | GTE^) (ID | list)
        ;

redOpr  : PLUS | MINUS | MUL | DIV;

filOpr  : (EQ^ | NEQ^ | LT^ | GT^ | LTE^ | GTE^) NUM;

mapOpr  : (redOpr) NUM;

list    : LSUB^ ( | listItem (","! listItem)* ) RSUB! ;

listItem
        : list
        | NUM
        ;

