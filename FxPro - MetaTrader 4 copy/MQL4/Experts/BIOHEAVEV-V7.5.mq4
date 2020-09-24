extern string BASICS;
 int MAGICMA = 0;
extern bool trading = true;
extern string DISTANCES;
extern double startDistance=300; 
extern double DistRetrace = 1000;  
extern string CHECKS_TO_ENTER;
extern bool EAcloses = true;
extern bool EAtrails = false;
extern bool ChkSR_Dist = false;
extern bool Chg_OnADX = true;
 double EquityCloseM1 = 300;
 double EquityCloseM0 = 101;
extern double closeFastEquity = 105;
extern string RISK;
extern double StartLot =0.01;
extern double maxorders = 6;
extern double refact = 1000;
extern bool tradesides = true;
extern bool tradetrends = true;
extern bool BreakOn =true;
extern bool EquityLots =true;             //LOTS PER ACCOUTN EQUITY
extern bool TradeonAligator = true;     //TRADE STO MODE 0 ONLY WITH ALIGATOR
extern bool AligMaxs =true;    
double depth =22;        //CHECK PATOUS GIA GIRISMATA
double distanceSR;
extern int TrailingStop=100;
extern int TrailingStep=50;

string delta =10;
  double Period1            = 5;
double Period2            = 13;
double Period3            = 34;

string Dev_Step_1         ="1.3";
string Dev_Step_2         ="8.5";
string Dev_Step_3         ="13.8";

int Symbol_1_Kod          =140;
int Symbol_2_Kod          =141;
int Symbol_3_Kod          =142;

bool  OnlyTrailAfterProfit=true;   // Trailing Stop will only trail when order is profitable
bool  trailMan =false; 
 


double supportH1, resistH1, supportH4, resistH4,supportW1, resistW1;
double timeFrameSRH1 =PERIOD_H1;
int numBars =56;
double timeFrameSRW1 =PERIOD_D1;
int numBars2 =8;

double range1, rangeUPprc  , rangeDNprc ;
double  allitrades , allitradeb ;
double trenddistance ;
double supertrend =0 ;
int breakevenS  ;      // POSO NA PAREi
int breakevengainS  ;  // POTE NA MPEI 
int distance  ;
double refactor;
double alligtrend = 0;
double maxsells ;
double maxbuys ;
double sells ,buys,lastsellopenprice,lastbuyopenprice,sumsell,sumbuy;
int sumbasket = 0.00;
double Lots, Lots2;
double targetprofit =0;
double distancebuy;
double distancesell;
double distancebuymin;
double distancesellmin;
double distancebuyp;
double distancesellp;
double distancebuypmin;
double distancesellpmin;
bool closebasket = false;
double mode ; 
double tradebuys = false;
double tradesells = false;
double accequity; 
bool MaTrends = true;
double wd,td5,td ,tdd , tdd3,tdd4 ,adx,adxM5,direction; //TRENDs
bool BreakEnabled =false;
int breakeven = breakevenS; //POSO NA PAREi
int breakevengain = breakevengainS; ///POTE NA MPEI 
bool closing =true ;
double downzag,upzig;
double downzag3,upzig3;
double downzagM,upzigM;
double timeframe ;
double  directionma ,directionI ;







int init()
{
MAGICMA =11;
if(Symbol() == "AUDUSD-")
{
MAGICMA = 10;
}
if(Symbol() == "EURUSD-")
{
MAGICMA = 44;
}
if(Symbol() == "USDCAD-")
{
MAGICMA = 55;
}
if(Symbol() == "GBPUSD-")
{
MAGICMA = 993010;
}

}

  
  




void comments()   {
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     accequity =(AccountEquity()/AccountBalance()*100);
     Comment(StringFormat("MAGICMA=%G\TRADING=%G\nDIGITS=%G\BID=%G\ASK=%G\EQUITY=%G\Equitypercent=%G\n\nTAMEIO=%G\--TARGET-PROFIT=%G\nActiveTF=%G\--Lots=%G\Lots2=%G\nAligator=%G\AligatorBUY=%G\AligatorSELL=%G\nSOUPERTREND=%G\n\nRANGE=%G\R-UP=%G\R-DOWN=%G\n\nMATrends=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nTrend-DIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nMODE1-TradeBUys=%G\TradeSells=%G\n\nNormalDST=%G\---TrendDST=%G\SR-Space=%G\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nH1-ADX=%G\nM5-ADX=%G",MAGICMA,trading,digits,Bid,Ask,eqt,accequity,sumbasket,targetprofit,timeframe,Lots,Lots2,alligtrend,allitradeb,allitrades,supertrend,range1,rangeUPprc,rangeDNprc,directionma,td5,tdd,tdd4,tdd3,td,wd,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,distanceSR,sells,buys,maxsells,maxbuys,adx,adxM5));
   }



void Modes(){
             mode = 0 ;
          if(direction ==1 ){
            mode = 1;
       } 
          if(direction ==2 ){
          mode = 1;
             } 
 }
  
  
 void OnTick ()
    { 
     CheckTrends();
     MAdirections();
     fixDirection();
     
     modeDirection();
     Modes(); 
     counttrades();

     Distances();

     
     CloseOrders();
     CheckForOpen();
     comments();    
  }
  
 
void modeDirection(){

  if (mode == 1){
   maxbuys = maxorders*2;
   maxsells=maxorders*2;
   tradesells=false;
   tradebuys = false;
   
   
  if(direction ==2) {
     tradebuys = false;
      tradesells=true;
         }
    
  if(direction ==1  )  {
        tradebuys = true;
         tradesells=false;
          } 
  }
  
  if(mode == 0){  
      BreakEnabled=false;
      tradesells=true;
      tradebuys = true;
      maxbuys = maxorders/2;
      maxsells=maxorders/2;  
                
}
}





     
void CheckForOpen()  {
if(trading == true){
  Lots = StartLot;
  Lots2=StartLot*2;
  int    res;
   ////////////////////////MODE 0 PLAGIO ///////////////
  if(mode == 0 && tradesides == true){ 
  allitrades = 2;
  allitradeb = 1;

     ////---- sell conditions
     if( buys < maxbuys  && buys == 0 && allitradeb == 1 )     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-0-1B",MAGICMA,0,Blue);
     return;
     }
       if( buys < maxbuys  && buys == 1 && Ask <= distancebuy  && allitradeb ==1 && Ask < distancebuymin )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-0-2B",MAGICMA,0,Blue);
     return;
     }
          if( buys < maxbuys  && buys >= 2 && Ask <= distancebuy  && allitradeb ==1 && Ask < distancebuymin)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"MODE-0-3B",MAGICMA,0,Blue);
     return;
     }
     
     
     
     if( sells < maxsells && sells == 0 && allitrades ==2) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-1S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells   && sells ==1  && Bid >= distancesell && allitrades ==2 && Bid > distancesellmin ) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-2S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  && sells >=2  &&  Bid >= distancesell && allitrades ==2 && Bid > distancesellmin) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"MODE-0-3S",MAGICMA,0,Red);
     return;
     }

     }
////////////////////////MODE 1  -TREND FOLLOW 
    if(mode == 1 && tradetrends == true){ 
     ////---- sell conditions
     if(tradebuys == true && buys < maxbuys && buys == 0)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-1-BUY1",MAGICMA,0,Blue);
     return;
     }
      if( tradebuys == true && buys < maxbuys && buys >= 1 &&  ((Ask < distancebuy && Ask < distancebuymin ) || (Ask > distancebuyp) ) )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-1-BUY2",MAGICMA,0,Blue);
     return;
     }
     if( tradesells == true && sells < maxsells  && sells == 0 ) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-1-SELL1",MAGICMA,0,Red);
     return;
     }
           if(tradesells == true && sells < maxsells   && sells >=1  && ((Bid > distancesell && Bid > distancesellmin) || (Bid < distancesellp))) //
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-1-SELL2",MAGICMA,0,Red);
     return;
     }
     }

     }
  }
 
int counttrades()
  {
    RefreshRates();
    buys=0;
    sells=0;
    lastbuyopenprice=0;
    lastsellopenprice=0;
    double sum_profits =0;
    double sum_profitss =0;
    double sum_lots =0;
    double sum_lotsb= 0;
    double ord_num = 0;
    double asumlot = 0;
    int num = 0;
  int  summer =0;
    sumbasket =0;

 for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol()&& OrderMagicNumber() == MAGICMA )// 
        {
         if(OrderType()==OP_BUY && OrderMagicNumber() == MAGICMA ) {
         lastbuyopenprice=OrderOpenPrice();
         sum_profits += OrderProfit()+OrderSwap()+OrderCommission();
         buys++;
         }
         if(OrderType()==OP_SELL && OrderMagicNumber() == MAGICMA  ){
         sum_profitss += OrderProfit()+OrderSwap()+OrderCommission();
         lastsellopenprice=OrderOpenPrice();
         sells++;
         }
        sumsell = sum_profitss; 
        sumbuy = sum_profits; 
        summer = sum_profitss + sum_profits;   
        sumbasket = summer;
        } 
        }
 }
 
int CloseAll(){ 
   if(EAcloses == true){
          if (closebasket ==true ){
                int numOfOrders = OrdersTotal();
                int FirstOrderType = 0;
    for (int index = 0; index < OrdersTotal(); index++)   
     {
       OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
       if (OrderSymbol() == Symbol()&& OrderMagicNumber() == MAGICMA)        {
         FirstOrderType = OrderType();
         break;
       }
     }   
   for(index = numOfOrders - 1; index >= 0; index--)
   {
      OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA)
            switch (OrderType())
      {
         case OP_BUY: 
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 0, Red))
            break;
         case OP_SELL:
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 0, Red))
            break;

         case OP_BUYLIMIT: 
         case OP_SELLLIMIT:
         case OP_BUYSTOP: 
         case OP_SELLSTOP:
            if (!OrderDelete(OrderTicket()))
            break;
      }
   }

  }
}
}


  
void CloseOrders()
   {
   targetprofit=Lots*refact;
   
      closebasket =false;
      closing =false;
      
   if(mode== 0){
      closebasket =false;
      closing =false;
      
               if(sumbasket >= targetprofit)   {
        closebasket = true ;
             CloseAll();
   }    

   if(buys ==1 && sells == 1 && sumbasket > 5 )     {
    closebasket = true ;
         CloseAll();
    
    
   }
      if(buys >1 && sells >= 1 && sumbasket > 5 )     {
    closebasket = true ;
         CloseAll();
    
   }
       if(((buys ==2 && sells == 1) || (buys ==1 && sells == 2)) && sumbasket > 5 )     {
    //  closebasket = true ;
         //  CloseAll();
       
   }
    if((buys >=2 && sells >= 2) && sumbasket >= 5 )     {
      closebasket = true ;
       CloseAll();
       
   }

   
  }
  
  if(mode ==1 )      {
      closebasket =false;
      closing =false;
         if((buys > 10  || sells >10 )&& sumbasket >= targetprofit)   {
        closebasket = true ;
             CloseAll();
   } 
      
   if(direction == 1 && sells > 0 && sumbasket >= 10)             {
     closebasket = true ;
          CloseAll();
            }         
   if(direction == 2 && buys  > 0 && sumbasket >= 10 )                      {
    closebasket = true ;
         CloseAll();
            }                      
      }
   }
   
int fixDirection()  {   
   direction = 0 ;
 if( MaTrends == true){
   if(directionma == 2)  {
   direction =2;
   } 
  if(directionma == 1){
   direction =1;
   }
   }
}
  





   


int CheckTrends()   {
  if(MaTrends == true){
   double  current_ma1, current_ma2, current_ma3;
   double  current_wa1, current_wa2, current_wa3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma11, current_ma21, current_ma31 ;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
   //M15 TDd
   current_ma15 = iMA(NULL,PERIOD_M15,100,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,60,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,10,0,MODE_SMA,PRICE_CLOSE,0);
       //M30 TDd
   current_ma11 = iMA(NULL,PERIOD_M30,150,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma21 = iMA(NULL,PERIOD_M30,70,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma31 = iMA(NULL,PERIOD_M30,20,0,MODE_EMA,PRICE_CLOSE,0);
   
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,100,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_H1,50,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,PERIOD_H1,10,0,MODE_EMA,PRICE_MEDIAN,0);
   //H4
   current_ma111 = iMA(NULL,PERIOD_H4,100,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,70,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma311 = iMA(NULL,PERIOD_H4,20,0,MODE_SMA,PRICE_MEDIAN,0);
   
   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,36,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,12,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,5,0,MODE_SMA,PRICE_MEDIAN,0);
   
      //w1// Td
   current_wa1 = iMA(NULL,PERIOD_W1,50,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_wa2 = iMA(NULL,PERIOD_W1,20,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_wa3 = iMA(NULL,PERIOD_W1,5,0,MODE_SMA,PRICE_MEDIAN,0);

     //D1///
    if(current_ma3 > current_ma2 && current_ma2 > current_ma1)  {
    td = 1;
    }
    if(current_ma3 < current_ma2 && current_ma2 < current_ma1)  {
    td = 2;
    }
         //W1///
    if(current_wa3 > current_wa2 && current_wa2 > current_wa1)  {
    wd = 1;
    }
    if(current_wa3 < current_wa2 && current_wa2 < current_wa1)  {
    wd = 2;
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
  return(wd);   //W1
  }
      
}

void MAdirections(){
  directionma =0 ;
   if( tdd == 1 && td ==1  && tdd4 ==1 && tdd3 == 1 ){
   directionma = 1;  }
   if(tdd ==2  && td ==1  && tdd4 ==2  && tdd3 ==2 ){
   directionma = 2; }
}

 





void Distances()   { 
   distance = startDistance;
   trenddistance =startDistance/2;
   distanceSR = startDistance/3;
   
 if (ChkSR_Dist == true){
    if(mode == 0 ) {
     distancebuymin  = (lastbuyopenprice-distance*Point);
     distancesellmin =  (lastsellopenprice+distance*Point);
     distancebuy = (supportH1+distanceSR*Point);
    distancesell = (resistH1-distanceSR*Point) ;
     distancebuyp  = (lastbuyopenprice+trenddistance*Point);
     distancesellp = (lastsellopenprice-trenddistance*Point);
     }
     
   if(mode == 1 ) {
     distancebuymin  = (lastbuyopenprice-distance*Point);
     distancesellmin =  (lastsellopenprice+distance*Point);
     distancebuy  = (lastbuyopenprice-distance*Point);
     distancesell =  (lastsellopenprice+distance*Point);  
     distancebuyp  = (lastbuyopenprice+trenddistance*Point);
     distancesellp = (lastsellopenprice-trenddistance*Point);
     }
     }
     
 if (ChkSR_Dist == false){
     distancebuymin  = (lastbuyopenprice-distance*Point);
     distancesellmin =  (lastsellopenprice+distance*Point);
     distancebuy  = (lastbuyopenprice-distance*Point);
     distancesell =  (lastsellopenprice+distance*Point);  
     distancebuyp  = (lastbuyopenprice+trenddistance*Point);
     distancesellp = (lastsellopenprice-trenddistance*Point);
     }  
}




