#include <iostream>
#include <cstdlib>
#include "list.cpp"

using namespace std;

int main()
{
    List <int> lst;


    //List <int> :: Iterator it;
    for(auto &Elem: lst){
            Elem--;
        }

    List <int> l;


    //List <int> :: Iterator it;
    for(int i = 0; i < 10; i++){
            l.AddEnd(i*i);
        }

    l.AddStart(1234);
    l.AddEnd(4321);

    for(auto &Elem: l){
            cout << Elem << endl;
    }

    l.AddIndex(777,5);
    l.AddIndex(666,12);

    for(auto &Elem: l){
            cout << Elem << endl;
    }

    cout << "Deletting ..." << endl;

    l.DelStart();
    l.DelEnd();
    l.DelEnd();
    for(auto &Elem: l){
            cout << Elem << endl;
    }
    l.DelIndex(5);
    for(auto &Elem: l){
            cout << Elem << endl;
    }

    cout << "Deletting  all ..." << endl;

	//delete &l;


    cout << "Sucsess!" << endl;
}
