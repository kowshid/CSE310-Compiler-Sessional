#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <string>
#include <stdlib.h>
#include <iostream>

using namespace std;

class SymbolInfo
{
    string name;
    string type;

public:

    SymbolInfo *nxt;

    SymbolInfo()
    {
        nxt = NULL;
    }

    SymbolInfo(string noun, string kind)
    {
        name = noun;
        type = kind;
        nxt = NULL;
    }

    string getName()
    {
        return name;
    }

    string getType()
    {
        return type;
    }

};


class ScopeTable
{
    SymbolInfo **arr;
    SymbolInfo *parent;
    SymbolInfo *head;
    int size;
    int id;

public:
    ScopeTable *prevScope;

    ScopeTable(int size, int idno)
    {
        this->size = size;

        arr = new SymbolInfo*[size];

        for (int i = 0; i < size; i++)
        {
            arr[i] = new SymbolInfo[size];
        }

        parent = NULL;
        head = NULL;
        id = idno;
        prevScope = NULL;
    }

    ~ScopeTable()
    {
        for (int i = 0; i < size; i++)
        {
            head = arr[i];

            while(head != 0)
            {
                SymbolInfo *temp = head;
                head = head->nxt;

                delete temp;
            }
        }
    }

    int jenkins(string s)
    {
        unsigned long long int h = 0, l = s.length();

        for (int i = 0; i < l; i++)
        {
            h += s[i];
            h += (h << 10);
            h ^= (h >> 6);
        }

        h += (h << 3);
        h ^= (h >> 11);
        h += (h << 15);

        return (h % size);
    }

    bool insert(string noun, string kind)
    {
        SymbolInfo *temp = new SymbolInfo(noun, kind);
        parent = lookUp(noun);

        if (parent)
            return false;

        int hashNo = jenkins(noun);

        if (parent != NULL)
            return false;

        if (arr[hashNo] == NULL)
        {
            arr[hashNo] = temp;
        }

        else
        {
            temp->nxt = arr[hashNo];
            arr[hashNo] = temp;
        }

        return true;
    }

    SymbolInfo* lookUp(string noun)
    {
        int hashNo = jenkins(noun);

        if (arr[hashNo] == NULL)
        {
            cout << "not found" << endl;
            return NULL;
        }

        head = arr[hashNo];

        while (head != NULL)
        {
            if (head->getName() == noun)
            {
                cout << "found" << endl;
                return head;
            }

            else
            {
                parent = head;
                head = head->nxt;
            }
        }

        cout << "not found" << endl;
        return NULL;
    }

    bool Delete(string noun)
    {
        SymbolInfo *temp = lookUp(noun);
        int hashNo = jenkins(noun);

        if (temp == NULL)
        {
            cout << "not del\n";
            return false;
        }

        else
        {
            if (parent == NULL)
            {
                delete temp;
                cout << "del\n";
                arr[hashNo] = 0;

                return true;
            }

            parent->nxt = temp->nxt;
            delete temp;
            return true;
        }
    }

    int getID()
    {
        return id;
    }

    void print()
    {
        for (int i = 0; i < size; i++)
        {
            head = arr[i];
            cout << i << ": ";
            while (head != 0)
            {
                cout <<"<" <<head->getName() << " " << head->getType() <<">";
                head = head->nxt;
            }
            cout << endl;
        }
    }
};

class SymbolTable
{
    ScopeTable *st;
    int id;
    int size;

public:
    SymbolTable(int size)
    {
        this->size = size;
        ScopeTable *temp;
        id = 1;
        temp = new ScopeTable(size, id);
        st = temp;
    }

    void enterScope()
    {
        id++;
        ScopeTable *current = new ScopeTable(size, id);
        current->prevScope = st;
        st = current;
    }

    void removeScope()
    {
        ScopeTable *temp = st;
        st = st->prevScope;
        id--;
        delete temp;
    }

    bool insertSymbol(string noun, string kind)
    {
        return st->insert(noun, kind);
    }

    bool removeSymbol(string noun)
    {
        return st->Delete(noun);
    }

    SymbolInfo* srch(string noun)
    {
        ScopeTable *temp = st;

        while(temp != 0)
        {
            SymbolInfo *tmp = temp->lookUp(noun);
            if(tmp != NULL) return tmp;
            temp = temp->prevScope;
        }

        return NULL;
    }

    void printCur()
    {
        st->print();
    }

    void printAll()
    {
        ScopeTable *temp = st;

        while(temp != 0)
        {
            cout << "scope id: " << temp->getID() << endl;
            temp->print();
            temp = temp->prevScope;
        }
    }
};

int main()
{
    freopen("in2.txt", "r", stdin);
    freopen("out.txt", "w", stdout);

    int size;

    string name, type;
    char c, c1;

    cin >> size;

    SymbolTable table(size);

    while (scanf("%c", &c) != EOF)
    {
        cout << c << endl;

        if (c == 'I')
        {
            cin >> name >> type;
            cout << c << " " << name << " " << type << endl;

            table.insertSymbol(name, type);
        }

        else if (c == 'L')
        {
            cin >> name;
            cout << c << " " << name << endl;

            table.srch(name);
        }

        else if (c == 'D')
        {
            cin >> name;
            cout << c << " " << name << endl;

            table.removeSymbol(name);
        }

        else if (c == 'P')
        {
            cin >> c1;

            if (c1 == 'A')
            {
                table.printAll();
            }

            if (c1 == 'C')
            {
                table.printCur();
            }
        }

        else if (c == 'S')
        {
            table.enterScope();
        }

        else if (c == 'E')
        {
            table.removeScope();
        }

        else
             break;

        cout << endl;
    }

    return 0;
}
