%optionv noyywrap

%{
    #include <iostream>
    #include <vector>
    #include <map>
    #include <string>
    #include <cstdlib>
    #include <fstream>

    using namespace std;

    //Map for store months
    map<string,int> months;

    //Inserting elements in the map
    months.insert(pair<string,int>("enero",1));
    months.insert(pair<string,int>("febrero",2));
    months.insert(pair<string,int>("marzo",3));
    months.insert(pair<string,int>("abril",4));
    months.insert(pair<string,int>("mayo",5));
    months.insert(pair<string,int>("junio",6));
    months.insert(pair<string,int>("julio",7));
    months.insert(pair<string,int>("agosto",8));
    months.insert(pair<string,int>("septiembre",9));
    months.insert(pair<string,int>("octubre",10));
    months.insert(pair<string,int>("noviembre",11));
    months.insert(pair<string,int>("diciembre",12));

    struct Date{ //Struct for representing dates
        unsigned int year = 2022;
        unsigned int month;
        unsigned int day; 
    }

    //For store the last read date
    Date current_date;


    struct Match{ //Struc for representing a match
        string Team1; //String to represents teams of the match
        string Team2;
        unsigned int score1; //Int to represent scorings
        unsigned int score2;
        Date date; //Date of the match
        string group; //Group where the match were played. Can be empty
        string stadium; //Where the match has benn played
    }

    struct Team{ //Struct to represent a team
        string name;
        vector<*Match> matches; //Pointers to matches that were played by this team
    }
%}

digit   [0-9]
upper   [A-Z]
lower   [a-z]
number  ({digit}+)
special_char    .
blank_space     \b

/*Regular expressions for dates*/
day     ("Lunes"|"Martes"|"Miércoles"|"Jueves"|"Viernes"|"Sábado"|"Domingo")
month   ("enero"|"febrero"|"marzo"|"abril"|"mayo"|"junio"|"julio"|"agosto"|"septiembre"|"octubre"|"noviembre"|"diciembre")
date    ({day}\b{number}\b"de"\b{month})

/*Regular expressions for not empty strings*/
word    (({mayus}|{special_char}){lower}*{special_char}*{lower*})
comp_word   ({word}(\b{word})+)
string  ({word}|{comp_word})

group   ("(Grupo"\b{upper}"")
stadium (""{string}"")

/*Delimiters*/
init_date   ("<p><strong>")
end_date    ("</strong></p>")
init_match  (("\<p\>"{number}":"{number}"."\b)|("\<br\>"))
end_match   (("\<br\>")|("\</p\>"))

%%
