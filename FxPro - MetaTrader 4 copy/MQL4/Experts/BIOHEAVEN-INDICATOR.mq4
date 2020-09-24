extern string BASICS;





 
extern bool useTrail =false;
extern int   StartTrail=2000; 
extern bool trailALL =false;

 bool      OnlyTrailAfterProfit=true;    // Trailing Stop will only trail when order is profitable
 bool      trailMan =false; 
 int       TrailingStop;    

extern bool checkWekly = false;
extern bool MaTrends = true;

extern double refact = 2000;
extern bool tradesides = true;
extern bool tradetrends = true;
extern bool BreakOn =true;
extern bool balancelots =true;
extern bool TradeonAligator = true;//TRADE STO MODE 0 ONLY WITH ALIGATOR
extern bool AligMaxs =true;//CHECK PATOUS GIA GIRISMATA
extern bool Savefirst =true;

 double  allitrades =2;
 double allitradeb =1;
 double adxM5=0;
 

int MACD_level=500; //(1-12) [low works for GBPUSD], high works for others.
int gap=1;


int      trend=0,last_trend=0, pending_time, ticket, total, pace, tp_cnt;
bool     sell_flag, buy_flag, find_highest=false, find_lowest=false;
double   MACD_Strength=0;

double trenddistance ;
double supertrend =0 ;
int breakevenS  ; //POSO NA PAREi
int breakevengainS  ; ///POTE NA MPEI 
int distance  ;
double refactor;
 double alligtrend = 0;
double range =0;
double maxsells ;
double maxbuys ;
int message;
double sells ,buys,lastsellopenprice,lastbuyopenprice,sumsell,sumbuy;
int sumbasket = 0.00;
double Lots2;
double targetprofit =0;
double distancebuy;
double distancesell;
double distancebuyp;
double distancesellp;
bool closebasket = false;
 double mode = 0; 
 double tradebuys = false;
 double tradesells = false;
 double accequity; 
 double td5,td ,tdd , tdd3,tdd4 ,adx,direction; //TRENDS





double downzag,upzig;
double downzagM,upzigM;
double timeframe ;
double Lots;
double MyTrend;
 double  directionma ,directionI ;



void comments()
   {
   int  digits = Digits();
        RefreshRates();
     double eqt= AccountEquity();
     accequity =(AccountEquity()/AccountBalance()*100);
     Comment(StringFormat("RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\n\nAligator=%G\nSOUPERTREND=%G\nMATRENDS=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\nDIRECTION-=%G\nMODE=%G\nH1-ADX=%G\nM5-ADX=%G",range,digits,Bid,Ask,alligtrend,supertrend,directionma,td5,tdd,tdd4,tdd3,td,direction,mode,adx,adxM5));
   }




void Modes(){
  mode = 0 ;
  if(direction > 0 )
  {
  mode = 1;
  } 
  }



void souperT()
{
   supertrend = 0;
   if(alligtrend == 1 && tdd3 ==1 && td ==1 && tdd4 == 1 && adx >40) 
   {
   supertrend = 1;
   }
   if(alligtrend == 2 && tdd3 ==2 && td ==2 && tdd4 == 2 && adx >40) 
   {
   supertrend = 2;
   }
}




void ProfitAdx()
   {
   adx=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
   adxM5=iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, MODE_MAIN, 0);
} 





int fixDirection()///TREND DIRECTION

   {   
   direction = 0 ;
  if( MaTrends == true){
   if(directionma == 2)
   {
   direction =2;
   }
    if(directionma == 1)
   {
   direction =1;
   }
   }
}
  

   

int CheckTrends()
   {
    if(MaTrends == true){
   double  current_ma1, current_ma2, current_ma3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma11, current_ma21, current_ma31 ;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
  
   //M15 TDd
   current_ma15 = iMA(NULL,PERIOD_M15,300,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,150,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,80,0,MODE_SMA,PRICE_CLOSE,0);
       //M30 TDd
   current_ma11 = iMA(NULL,PERIOD_M30,200,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma21 = iMA(NULL,PERIOD_M30,50,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma31 = iMA(NULL,PERIOD_M30,21,0,MODE_EMA,PRICE_CLOSE,0);
   
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,200,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_H1,100,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,PERIOD_H1,50,0,MODE_EMA,PRICE_MEDIAN,0);
   //H4
   current_ma111 = iMA(NULL,PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,70,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma311 = iMA(NULL,PERIOD_H4,30,0,MODE_SMA,PRICE_CLOSE,0);
   
   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,50,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,25,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,10,0,MODE_SMA,PRICE_CLOSE,0);

      //D1///
    if(current_ma3 > current_ma2 && current_ma2 > current_ma1)  {
    td = 1;
    }
    if(current_ma3 < current_ma2 && current_ma2 < current_ma1)  {
    td = 2;
    }
    //M15///  
    if(current_ma35 > current_ma25 && current_ma25 > current_ma15)  {
    td5 = 1;
    }
    if(current_ma35 < current_ma25 && current_ma25 < current_ma15) {
    td5 = 2;
     }
   //H1//
   if(current_d3 > current_d2 && current_d2 > current_d1)  {
    tdd4 = 1;
   }
   if(current_d3 < current_d2 && current_d2 < current_d1)  {
    tdd4 = 2;
   }
    //H4///
  if(current_ma311 > current_ma211 && current_ma211 > current_ma111)  {
    tdd3 = 1;
    }
  if(current_ma311 < current_ma211 && current_ma211 < current_ma111)  {
    tdd3 = 2;
    }
          ///M5//
    if(current_ma31 > current_ma21 && current_ma21 > current_ma11)  {
    tdd = 1;
    }
    if(current_ma31 < current_ma21 && current_ma21 < current_ma11)  {
    tdd = 2;
    }
  return(tdd);  //M30
  return(td5);  //M15
  return(tdd4); //H1
  return(tdd3); //H4
  return(td);   //D1

  }
}

void fixdirections()
{
  directionma =0 ;
  directionI =0;

   if(tdd == 1 && td ==1 && tdd4 ==1 && tdd3 == 1 ){
   directionma = 1;
   }
   if( tdd == 2 && td ==2 && tdd4 ==2  && tdd3 ==2 ){
   directionma = 2;
   }

}

 void alligators(){

   alligtrend = 0;

 double jaw =iAlligator(NULL,PERIOD_M5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
 double teeth=iAlligator(NULL,PERIOD_M5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double lip=iAlligator(NULL,PERIOD_M5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);

 if(lip > teeth && teeth > jaw){
  alligtrend = 1 ;
  }
  if(jaw > teeth && teeth > lip){
  alligtrend = 2 ;

  }
 }
 
 
void zigzag()
      {  
       ProfitAdx();
       int n, i;
         i=0;
         while(n<2)
      {
    if(upzig>0) downzag=upzig;
    upzig=iCustom(NULL,timeframe,"ZigZag", 0, i);
     if(upzig>0) n+=1;
     i++;
   } 
   }
     
void zigzagM()
      {  
       int n, i;
         i=0;
         while(n<2)
      {
    if(upzigM>0) downzagM=upzigM;
    upzigM=iCustom(NULL,PERIOD_D1, "ZigZag",0, i);
     if(upzigM>0) n+=1;
     i++;
   } 
   range = (upzigM - downzagM)/Point;
   } 
 

 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void OnTick(){
    string  Fx__Symbol;
    string  Symbol_Ray[]={"EURUSD","USDJPY","GBPUSD","USDCHF","AUDUSD","USDCAD"};
    for(int i=0; i<ArraySize(Symbol_Ray); i++){
        Fx__Symbol=Symbol_Ray[i];
        if(IsTesting()){Fx__Symbol=Symbol(); i=9999;}
     CheckTrends();
     alligators();
     zigzag();
     zigzagM();
     fixdirections();
     fixDirection();
     Modes();
     comments();   
}   }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~