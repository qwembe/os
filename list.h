#ifndef LIST_H
#define LIST_H

template <typename T>
class Node{
    public:
    T info;
    Node *Next;
    Node *Prev;
};

template <typename T>
class List{
public:
    Node<T> *Head;
    Node<T> *Tail;

    class Iterator{
    friend List<T>;
        Node<T> *P;
    public:

        Iterator(Node<T>* p = NULL): P(p){};

        const T& operator *() const{
            return P -> info;
        };

        T& operator *(){
            return P -> info;
        };

        Iterator& operator ++(){
            P = P -> Next;
            return *this;
        };

        Iterator& operator ++(int){
            Iterator t(*this);
            P = P -> Next;
            return t;
        };

        Iterator& operator --(){
            P = P -> Prev;
            return *this;
        };

        Iterator& operator --(int){
            Iterator t(*this);
            P = P -> Prev;
            return t;
        };

        friend bool operator ==(const Iterator& x, const Iterator& y){
            return x.P == y.P;
        };

        friend bool operator !=(const Iterator& x, const Iterator& y){
            return x.P != y.P;
        };

        friend bool operator ==(int y, const Iterator& x){
            return x.P->info == y;
        };

        friend bool operator !=(int y, const Iterator& x){
            return x.P->info != y;
        };

        friend bool operator ==(const Iterator& x,int y){
            return x.P->info == y;
        };

        friend bool operator !=(const Iterator& x,int y){
            return x.P->info != y;
        };


    };

    Iterator it;
    List():Head(NULL),Tail(NULL){}
        ~List();

    Iterator begin()const{
        return Iterator(Head);
    };

    Iterator end()const{
            return NULL;
        };

    void Show();

    void Add(T info);

    void AddStart(T info);

    void AddEnd(T info);

    void AddIndex(T info,int index);

    void DelStart();

    void DelEnd();

    void DelIndex(int index);
};

#endif // LIST_H
