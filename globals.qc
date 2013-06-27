//SJB all new global/entity variables and prototypes are in this file

//------------------------
//Global variables
//------------------------

float matchmode;  //matchmode 0 1 2 or 3 controls match status
float standardspawn; // TRUE = ordered spawning, FALSE = random spawning
float numplayers; //keeps tally of number of players in the game
float numready;   //number of players in ready mode
float matchtimer; //timer used to time match after timelimit set to 0
float finale;  //set to true after finale messages is displayed

.float ready;  //flag that we are in ready mode for matchmode 1 & 2
.float db_frags, db_kills, db_suicides, db_deaths;
.float kill;

.float team_number, num_players, pant_color;

.float oldteam; //store team value to compare with current team value

//---------------
//moved from client.qc
float intermission_running /* = 0.000 */;
//---------------

//------------------------
//match.qc prototypes
//------------------------

void() CC_ToggleRespawnMode;
void() CC_SetPlayerReady;
void() CC_SetPlayerNotReady;
void() CC_SetAllNotReady;
void() CC_RemoveQuad;
void() CC_RemovePent;
void() CC_RemoveRing;
void() CC_StartCountDown;

void() countdown_think;
void() SetMode1Items;
void() SetMode2Items;
void() timer_think;
void() remove_projectiles;
void(string sname) play_sound;
void() intro_message;

//------------------------
//db_match.qc prototypes
//------------------------

void(entity p, float frag_db, float kill_db, float suicide_db, float death_db) UpdateMatchStats;
void() PrintMatchStats;
void() PrintTeamStats;
void(float value) bprint_spaces;
string(float pteam) find_pants;
void() SpawnMatchOver;
void() MatchOver1;
void() MatchOver2;
void() MatchOver3;
void (entity e) PrintStats;
void (entity team_db, entity p) AddToTeamScore;

//------------------------
//client.qc prototypes
//------------------------

void() execute_changelevel;   //client.qc function
