%option noyywrap
%option c++
%option debug
%{
    #include <iostream>
    #include <vector>
    #include <map>
    #include <string>
    #include <cstdlib>
    #include <fstream>
    #include <string>

    using namespace std;

    //Map for store months
    map<string,int> months={
    {"enero",1},
    {"febrero",2},
    {"marzo",3},
    {"abril",4},
    {"mayo",5},
    {"junio",6},
    {"julio",7},
    {"agosto",8},
    {"septiembre",9},
    {"octubre",10},
    {"noviembre",11},
    {"diciembre",12}
    };

    struct Date{ //Struct for representing dates
        unsigned int year = 2022;
        unsigned int month;
        unsigned int day; 
        string week_day;
    };

    //For store the last read date
    Date current_date;


    struct Match{ //Struc for representing a match
        string team1; //String to represents teams of the match
        string team2;
        unsigned int score1; //Int to represent scorings
        unsigned int score2;
        Date date; //Date of the match
        string group; //Group where the match were played. Can be empty
        string stadium; //Where the match has benn played
    };

    struct Team{ //Struct to represent a team
        string name;
        vector<Match> matches; //Pointers to matches that were played by this team
    };

    vector<Team> teams; //Vector that stores all teams
    vector<Match> matches; //Vector that stores all matches

    string chain;
    ifstream yyin;
%}

digit   [0-9]
upper   [A-Z]
lower   ([a-z]|"ñ"|"Ñ")
number  ({digit}+)
upper_accent    ("Á"|"É"|"Í"|"Ó"|"Ú")
lower_accent    ("á"|"é"|"í"|"ó"|"ú")
blank_space     (" ")
separator       {blank_space}|{blank_space}"\n"|"\n"{blank_space}
hyphen  (" - "|"-"|" -"|" -")

day     (("Lunes")|("Martes")|("Miércoles")|("Jueves")|("Viernes")|("Sábado")|("Domingo"))
month   ("enero"|"febrero"|"marzo"|"abril"|"mayo"|"junio"|"julio"|"agosto"|"septiembre"|"octubre"|"noviembre"|"diciembre")
date    ({day}" "{number}" de "{month})

word    (({upper}|{upper_accent}|{lower}|{lower_accent})(({lower}*{lower_accent}{lower}*)|{lower}*))
comp_word   ({word}({separator}{word})+)
string  ({word}|{comp_word})

group   ({separator}"(Grupo "{upper}") "|{separator}*)
stadium ("(Estadio "{string}")"|"(Estadio "{number}+")")

hour    ({number}":"{number}".")

init_date   ("<p><strong>")
end_date    ("</strong></p>")
marker_match2  ("<br>")
marker_match3  ("</p>")
init_match     ({hour})
end_match      ({marker_match2}|{marker_match3})

%%

{init_date}{date}{end_date} {
    chain = string(YYText());
    string delimiter = "<p><strong>";
    unsigned int init_to_cut = delimiter.size();
    delimiter = "</strong></p>";
    unsigned int end_to_cut = chain.size() - delimiter.size() - init_to_cut + 1;
    string sub_chain = chain.substr(init_to_cut - 1, end_to_cut); //Until the end

    int stop1 = sub_chain.find_first_of(" ");
    current_date.week_day = sub_chain.substr(0, stop1- 1);

    int stop2 = sub_chain.find_first_of(" ", stop1 + 1);
    current_date.day = stoi(sub_chain.substr(stop1 + 1, stop2 - stop1 - 1));

    stop1 = stop2 + 3; //Add 3 because of "de "
    current_date.month = months[sub_chain.substr(stop1 + 1, -1)];
}

{init_match}{separator}{string}{separator}{number}{hyphen}{string}{separator}{number}{group}{stadium}{end_match} {
    chain = string(YYText());
    cout << chain << endl;
    Team team_to_add;
    Match match_to_add;

    //Setting the date
    match_to_add.date = current_date;

    //Getting first team
    int stop1 = chain.find_first_of(" ");
    int stop2 = chain.find_first_of("-"); 
    string subchain1 = chain.substr(stop1 + 1, stop2 - stop1 - 2);

    stop1 = subchain1.find_last_of(" ");
    match_to_add.team1 = subchain1.substr(0, stop1);

    //Getting score of the first team
    match_to_add.score1 = stoi(subchain1.substr(stop1+1, stop2 - stop1));

    //Getting second team
    stop1 = chain.find_first_of("-");
    stop2 = chain.find_first_of("(");
    subchain1 = chain.substr(stop1 + 2, stop2 - (stop1 + 3));
 
    stop1 = subchain1.find_last_of(" ");
    match_to_add.team2 = subchain1.substr(0, stop1);

    //Getting score of the second team
    match_to_add.score2 = stoi(subchain1.substr(stop1+1, stop2 - stop1 - 1));

    //Getting group
    stop1 = chain.find("(G");

    if(stop1 != -1){
        stop2 = chain.find_first_of(")");
        match_to_add.group = chain.substr(stop1 + 1, stop2 - stop1 - 1);
    }
    else{
        match_to_add.group = ""; //No group phase
    }

    //Getting stadium
    stop1 = chain.find_last_of("(");
    stop2 = chain.find_last_of(")");

    match_to_add.stadium = chain.substr(stop1 + 1, stop2 - stop1 - 1);

    //Adding match to the array
    matches.push_back(match_to_add);

     //Adding team to the array of teams
    bool add = true;

    cout << "Team1: " << match_to_add.team1 << endl;

    for(int i = 0; i < teams.size(); i++){
        if(teams[i].name == match_to_add.team1){
            add = false;
            teams[i].matches.push_back(match_to_add);
            break;
        }
    }

    if(add){
        team_to_add.name = match_to_add.team1;
        team_to_add.matches.push_back(match_to_add);
        teams.push_back(team_to_add);
        team_to_add.matches.clear(); //Deleting this match
    }

    //Adding second team to the array of teams
    add = true;

    cout << "Team2: " << match_to_add.team2 << endl;

    for(int i = 0; i < teams.size(); i++){
        if(teams[i].name == match_to_add.team2){
            add = false;
            teams[i].matches.push_back(match_to_add);
            break;
        }
    }

    if(add){
        team_to_add.name = match_to_add.team2;
        team_to_add.matches.push_back(match_to_add);
        teams.push_back(team_to_add);
        team_to_add.matches.clear();
    }

}

%%

//Function to print menu
void print_menu(){
    cout << endl << "=================== Wordl Cup Qatar 2022 Stats ===================" << endl;
    cout << "Choose one of the following options: " << endl;
    cout << "1) Show teams list" << endl;
    cout << "2) Search matches by team" << endl;
    cout << "3) Search matches by date" << endl;
    cout << "4) Search match" << endl;
    cout << "5) Clean bash" << endl;
    cout << "6) Exit" << endl << endl;
}

//Function to print match information
void print_match(Match match){
    cout << match.team1 << " " << match.score1 << " - " << match.score2 << " " << match.team2;

    if(match.group != "" | match.group != " "){
        cout << "\t" << match.group;
    }

    cout << "\t" << match.stadium << endl;
}

//Main function
int main(int argc, char *argv[]){
    char choosen = '0'; 

    yyin.open("data.html");
    if(!yyin){
        cout << "FATAL ERROR: couldn't get data from main page" << endl;
        return -1;
    }

    //Using lex
    yyFlexLexer input_strean(&yyin,0);
    input_strean.yylex();
    system("clear");


    //Users interaction
    do{
        print_menu();
        cin >> choosen; //Election of the user

        switch(choosen){
            case '1':
                {
                cout << "=================== Teams list ===================" << endl;
                for(int i=0; i < teams.size(); i++){
                    cout << i+1 << ")\t" << teams[i].name << endl;
                }
                cout << endl;
            break;
                }

            case '2':
                {
                cout << "Insert team name (Uppercase sensitive): ";
                string input;
                getline(cin, input);
                getline(cin,input);

                Team team_to_show;
                bool not_found = true;

                for(int i=0; i < teams.size(); i++){
                    if(input == teams[i].name){
                        not_found = false;
                        team_to_show = teams[i];
                        break;
                    }
                }

                if(not_found){
                    cout << "Team not found!" << endl;
                }
                else{
                    cout << "=================== " << team_to_show.name << " matches ===================" << endl;
                    for(int i = 0; i < team_to_show.matches.size(); i++){
                        cout << i << ")\t";
                        print_match(team_to_show.matches[i]);
                    }
                }
            break;
                }

            case '3':
                {
                cout << "Insert date (Format DD MM): ";
                string day, month;

                cin >> day;
                cin >> month;

                bool printed = false;

                for(int i = 0; i < matches.size(); i++){
                    if(matches[i].date.month == stoi(month)){
                        if(matches[i].date.day == stoi(day)){
                            cout << i << ")\t";
                            print_match(matches[i]);
                            printed = true;
                        }
                    }
                }

                if(!printed){
                    cout << "Not found matches on the given date!" << endl;
                }

            break;
                }

            case '4':
                {
                cout << "Insert match (Local Visitor DD MM): ";
                string team1, team2, day, month;

                cin >> team1;
                cin >> team2;
                cin >> day;
                cin >> month;

                bool printed = false;

                for(int i = 0; i < matches.size(); i++){
                    if(matches[i].team1 == team1){
                        if(matches[i].team2 == team2){
                            if(matches[i].date.month == stoi(month)){
                                if(matches[i].date.day == stoi(day)){
                                    print_match(matches[i]);
                                    printed = true;
                                    break;
                                }
                            }
                        }
                    }
                }

                if(!printed){
                    cout << "Match not played!" << endl;
                }

            break;
                }

            case '5':
                {
                system("clear");
            break;
                }
            case '6':
                {
                cout << "Thanks for using our app!" << endl;
                cout << "Made by:" << endl;
                cout << "\tClara Bolivar Peláez\t@clarabolivar (github.com/clarabolivar)" << endl;
                cout << "\tJavier Gómez López\t@javi5454 (github.com/Javi5454)" << endl;
                cout << "\tSoledad Ruiz Gómez\t@sunage11 (github.com/sunage11)" << endl;
            break;
                }

            default:
                {
                cout << "Option not found!" << endl;
            break;
                }
        }
    }while(choosen != '6');

    return 0;
}