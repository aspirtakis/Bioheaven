extern string BASICS;
extern int MAGICMA = 993010;
extern bool trading = true;
extern string DISTANCES;
extern double startDistance=300; 
extern double DistRetrace = 1000; // APO TO TRAPEZI DISTANCE 
extern string CHECKS_TO_ENTER;


 
extern bool ChkSR_Dist = false;
extern bool Chg_OnADX = true;
extern double TarBasketafter = 0;
extern double EquityClose = 300;
extern double closeFastEquity = 105;
extern string RISK;
extern double StartLot =0.01;
extern double maxorders = 6;
extern double refact = 2000;
extern bool tradesides = true;
extern bool tradetrends = true;
extern bool BreakOn =true;
extern bool EquityLots =true;             //LOTS PER ACCOUTN EQUITY
extern bool TradeonAligator = true;     //TRADE STO MODE 0 ONLY WITH ALIGATOR
extern bool AligMaxs =true;    
double depth =50;        //CHECK PATOUS GIA GIRISMATA


double distanceSR;

bool  OnlyTrailAfterProfit=true;   // Trailing Stop will only trail when order is profitable
bool  trailMan =false; 
int   TrailingStop;   
 bool useTrail =false;
 int   StartTrail=2000; 
 bool trailALL =false; 

double supportH1, resistH1, supportH4, resistH4,supportW1, resistW1;
double timeFrameSRH1 =PERIOD_H1;
int numBars =96;
double timeFrameSRW1 =PERIOD_W1;
int numBars2 =12;

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
double downzagM,upzigM;
double timeframe ;
double  directionma ,directionI ;

    string fiboValue0  ;
      string fiboValue23 ;
      string fiboValue38;
      string fiboValue50 ;
      string fiboValue61;
      string fiboValue100 ;
    

int indicator()
  {
//----
    ObjectCreate("lineSupportH1",OBJ_HLINE,0,0,0);
    ObjectSet("lineSupportH1",OBJPROP_COLOR,Yellow);
    ObjectCreate("lineResistH1",OBJ_HLINE,0,0,0);
    ObjectSet("lineResistH1",OBJPROP_COLOR,Yellow);
    
    ObjectCreate("TRADERZagDN",OBJ_HLINE,0,0,0);
    ObjectSet("TRADERZagDN",OBJPROP_COLOR,Blue);
    ObjectCreate("TRADERZagUP",OBJ_HLINE,0,0,0);
    ObjectSet("TRADERZagUP",OBJPROP_COLOR,Blue);
    
    ObjectCreate("ZigZagD1up",OBJ_HLINE,0,0,0);
    ObjectSet("ZigZagD1up",OBJPROP_COLOR,Pink);
    ObjectCreate("ZigZagD1dn",OBJ_HLINE,0,0,0);
    ObjectSet("ZigZagD1dn",OBJPROP_COLOR,Pink);
    
    
    
    ObjectCreate("RangeW1up",OBJ_HLINE,0,0,0);
    ObjectSet("RangeW1up",OBJPROP_COLOR,Red);
    ObjectCreate("RangeW1dn",OBJ_HLINE,0,0,0);
    ObjectSet("RangeW1dn",OBJPROP_COLOR,Red);
   return(0);
  }
  
  
  
  
  void SRrange()
{

  supportW1 = 2000;
  resistW1 = 0; 
   range1 =0;
   
  for(int k = 1;k<=numBars2;k++)
  {
     if(supportW1>iLow(Symbol(),timeFrameSRW1,k))
     supportW1 = iLow(Symbol(),timeFrameSRW1,k);
   if(resistW1<iHigh(Symbol(),timeFrameSRW1,k))
     resistW1 = iHigh(Symbol(),timeFrameSRW1,k);

  } 
  //Print("S-W1",supportW1,"R-W1",resistW1);

 rangeUPprc =0.0;
   rangeDNprc =0.0;
  range1 = (resistW1-supportW1)*10000;
   double rangeUP = (Ask-resistW1)*10000;
    double rangeDN = (supportW1-Bid)*10000;
    
        rangeUPprc  =(rangeUP/range1*100);
      rangeDNprc  =(rangeDN/range1*100);
      ObjectSet("RangeW1up",OBJPROP_PRICE1,resistW1);
  ObjectSet("RangeW1dn",OBJPROP_PRICE1,supportW1);
}

void comments()
   {
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     accequity =(AccountEquity()/AccountBalance()*100);
     Comment(StringFormat("TRADING=%G\nDIGITS=%G\BID=%G\ASK=%G\EQUITY=%G\Equitypercent=%G\nTAMEIO=%G\--TARGET-PROFIT=%G\nActiveTF=%G\--Lots=%G\Lots2=%G\nAligator=%G\AligatorBUY=%G\AligatorSELL=%G\nSOUPERTREND=%G\RANGE=%G\R-UP=%G\R-DOWN=%G\n\nMATrends=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nTrend-DIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nMODE1-TradeBUys=%G\TradeSells=%G\n\nNormalDST=%G\---TrendDST=%G\SR-Space=%G\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nH1-ADX=%G\nM5-ADX=%G",trading,digits,Bid,Ask,eqt,accequity,sumbasket,targetprofit,timeframe,Lots,Lots2,alligtrend,allitradeb,allitrades,supertrend,range1,rangeUPprc,rangeDNprc,directionma,td5,tdd,tdd4,tdd3,td,wd,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,distanceSR,sells,buys,maxsells,maxbuys,adx,adxM5));
   }


void Chk_ADX()
{
 adx=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
 adxM5=iADX(NULL, PERIOD_M5, 14, PRICE_CLOSE, MODE_MAIN, 0);
}

void Distances()
   { 
   distance = startDistance;
   trenddistance =startDistance/2;
   distanceSR = startDistance/3;
   
 if (ChkSR_Dist == true){
     distancebuymin  = (lastbuyopenprice-distance*Point);
     distancesellmin =  (lastsellopenprice+distance*Point);
    
     //distancebuy = (supportH1+distanceSR*Point);
    //distancesell = (resistH1-distanceSR*Point) ;
        
     distancebuy = (supportH1+distanceSR*Point);
    distancesell = (resistH1-distanceSR*Point) ;
   
     distancebuyp  = (lastbuyopenprice+trenddistance*Point);
     distancesellp = (lastsellopenprice-trenddistance*Point);
     

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


void Modes(){
   mode = 0 ;
   if(direction > 0 ){
  mode = 1;
  } 
  }
  
  
void OnTick ()
    { 
      SRrange();
    indicator();
     BalanceLots();
     counttrades();
     CheckTrends();
     alligators();
     souperT();
     
     Chk_ADX();
     ADX_change();
     
     zigzag();
     zigzagM();
     //pivots();
     

     MAdirections();
     fixDirection();
  
     Modes(); 
     modesfixs();

     breaks();
     trails();
     SupportResistance();
     Chk_ALIGMAXS();
     Distances();
     CloseOrders();
     CheckForOpen();
     comments();    
  }
  
 
void modesfixs(){
  if (mode == 1){
   maxbuys = maxorders*2;
   maxsells=maxorders*2;
   tradesells=false;
   tradebuys = false;
   BreakEnabled =true;
   
 if(direction ==2) {
   tradebuys = false;
   tradesells=true;
    }
    
 if(direction ==1  )  {
        tradebuys = true;
         tradesells=false;
          } 
  }
  
 if (mode == 0){  
      BreakEnabled=false;
      tradesells=true;
      tradebuys = true;
      maxbuys = maxorders/2;
      maxsells=maxorders/2;  
                
}
}

void Chk_ALIGMAXS(){
   if(AligMaxs == true){
       if(Ask > upzigM-(DistRetrace*Point))
       {   
       if(alligtrend == 1 && td == 2 && tdd3 == 2 )
            {
             maxbuys = maxorders;
              maxsells=1;
            }
       if(alligtrend == 2  && td == 1 && tdd3 == 1 )
          {
           maxbuys =1;
          maxsells= maxorders;
           }
            }
     if(Bid < downzagM+(DistRetrace*Point))     {    
      if(alligtrend == 1 && td == 2 && tdd3 == 2 )  {
      maxbuys = maxorders;
      maxsells=1;
      }
      if(alligtrend == 2  && td == 1 && tdd3 == 1 ) {
      maxbuys =1;
      maxsells= maxorders;
      }
      }
     }
}


void ADX_change(){
  if(Chg_OnADX == false){ 
   refactor = refact;
   timeframe = 0;
   targetprofit = Lots*refactor;
   }
   
if(Chg_OnADX == true){ 
   refactor = refact;
   timeframe = 0;
  if(adx >= 60 ){
   refactor = refact*2;
     if(mode == 1){
        timeframe = 15;
     }
     if(mode == 0){
        timeframe = 60;
     }
   }
   
 if(adx > 30 && adx <= 59 ){
      refactor = refact;
      if(mode == 1){
        timeframe = 15;
     }
      if(mode == 0){
        timeframe = 30;
     }
   }
   
 if(adx < 29){
   refactor = refact/4; 
     if(mode == 1){
        timeframe = 60;
     }
     if(mode == 0){
        timeframe = 15;
     }
    }
   targetprofit = Lots*refactor;
}

}

     
void CheckForOpen()
  {
if(trading == true){
  breakeven =  breakevenS; //POSO NA PAREi
  breakevengain =  breakevengainS ; ///POTE NA MPEI 
  if(Volume[0]>1) return;
   int    res;
   
   ////////////////////////MODE 0 PLAGIO ///////////////
  if(mode == 0 && tradesides == true){ 
      BreakEnabled=false;
     ////---- sell conditions
     if( buys < maxbuys && buys == 0 && alligtrend == 1 )
     {
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
     
     
     if( sells < maxsells  && sells == 0 && alligtrend ==2) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-1S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  &&  sells ==1  && Bid >= distancesell && allitrades ==2 && Bid > distancesellmin ) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-2S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  &&  sells >=2  &&  Bid >= distancesell && allitrades ==2 && Bid > distancesellmin) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"MODE-0-3S",MAGICMA,0,Red);
     return;
     }

     }
////////////////////////MODE 1  -TREND FOLLOW 
    if(mode == 1 && tradetrends == true){ 
     breaks();
     ////---- sell conditions
     if(tradebuys == true && buys < maxbuys  && buys == 0)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-1-BUY1",MAGICMA,0,Blue);
     return;
     }
     
      if( tradebuys == true && buys < maxbuys && buys >= 1 &&  ((Ask < distancebuy && Ask < distancebuymin ) || (Ask > distancebuyp) ) )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"MODE-1-BUY2",MAGICMA,0,Blue);
     return;
     }
     
    
     if( tradesells == true && sells < maxsells  && sells == 0 ) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-1-SELL1",MAGICMA,0,Red);
     return;
     }
           if(tradesells == true && sells < maxsells   && sells >=1  && ((Bid > distancesell && Bid > distancesellmin) || (Bid < distancesellp))) //
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"MODE-1-SELL2",MAGICMA,0,Red);
     return;
     }
     }
         if(mode == 3 ){ 
    
     ////---- sell conditions
     if(tradebuys == true && buys < maxbuys  && buys == 0)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-1-BUY1",MAGICMA,0,Blue);
     return;
     }
     
      if( tradebuys == true && buys < maxbuys && buys >= 1 &&  ((Ask < distancebuy && Ask < distancebuymin ) || (Ask > distancebuyp) ) )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"MODE-1-BUY2",MAGICMA,0,Blue);
     return;
     }
     
    
     if( tradesells == true && sells < maxsells  && sells == 0 ) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-1-SELL1",MAGICMA,0,Red);
     return;
     }
           if(tradesells == true && sells < maxsells   && sells >=1  && ((Bid > distancesell && Bid > distancesellmin) || (Bid < distancesellp))) //
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"MODE-1-SELL2",MAGICMA,0,Red);
     return;
     }
     }
     
     }
  }
  
  
void breaks()
  {
       souperT();
       breakevenS = trenddistance; //POSO NA PAREi
       breakevengainS =trenddistance*2; ///POTE NA MPEI 
  
         breakeven =  breakevenS; //POSO NA PAREi
          breakevengain =  breakevengainS ; ///POTE NA MPEI 
    
    BreakEnabled=false;
   if(mode == 1 ){ 
      if((buys == 1 || sells ==1 ) ){
     breakeven = 400; //POSO NA PAREi
     breakevengain =600; ///POTE NA MPEI 
     BreakEnabled=true;
     Breakeven();
     
     maxbuys = maxorders;
     maxsells=maxorders;
     }
     if((buys >= 2 || sells >=2 ) ){
     breakeven = 500; //POSO NA PAREi
     breakevengain = 1000; ///POTE NA MPEI 
     BreakEnabled=true;
     Breakeven();
     maxbuys = maxorders;
     maxsells=maxorders;
     }
         if((buys >= 3 || sells >=3 ) ){
     breakeven = 50; //POSO NA PAREi
     breakevengain = 150; ///POTE NA MPEI 
     BreakEnabled=true;
     Breakeven();
     maxbuys = maxorders*2;
     maxsells=maxorders*2;
     }
     if((buys >= 5 || sells >=5 ) && accequity > 120 ){
     BreakEnabled=true;
     breakeven = 2500; //POSO NA PAREi
     breakevengain =4000; ///POTE NA MPEI 
     Breakeven();
     maxbuys = maxorders*3;
     maxsells=maxorders*3;
     }
    if((buys >= 7 || sells >=7 ) && accequity > 150 ){
     BreakEnabled=true;
     breakeven = 4000; //POSO NA PAREi
     breakevengain =5000; ///POTE NA MPEI 
     Breakeven();
     maxbuys = maxorders*8;
     maxsells=maxorders*8;
     }

   if(buys < 3 || sells <3 ){
    BreakEnabled=false;
    Breakeven();
  }
  }
  }


//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
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
 
int CloseAll()
{ 
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


  
void CloseOrders()
   {
      closebasket =false;
      closing =false;
      
   if(mode== 0){
    closebasket =false;
      closing =false;
   if(sumbasket > targetprofit)   {
   closebasket = true ;
        CloseAll();
   }

     if (buys <= TarBasketafter && sells <=TarBasketafter) {
       if(sumbuy >= targetprofit)
            {
        closing =true;
        closebuy();
            }
       if(sumsell >= targetprofit)
           {
         closing =true;
         closesell();
           }
      }
      
   if((buys <=2 && sells <=2)||(buys <=2 && sells <=2)&& sumbasket >0)
      {
     if(sumbuy > targetprofit/2 && upzig < downzag )
     {
      //  closing =true;
      //  closebuy();
     }
     if(sumsell > targetprofit/2 && upzig > downzag )
     {
        // closing =true;
        // closesell();
     }
      }     
  }
  
  if(mode ==1 )
      {
     if(accequity >= EquityClose)
      {
           closebasket = true ;
                CloseAll();
      }
   if(direction == 1 && sells > 0 && accequity >= closeFastEquity)
             {
     closebasket = true ;
          CloseAll();
            }         
   if(direction == 2 && buys  > 0 && accequity >= closeFastEquity)
                      {
    closebasket = true ;
         CloseAll();
            }
            
     if (direction == 2 && sumbuy > -5 )
     {
           closing =true;
           closebuy();
     }  
       if (direction == 1 && sumsell > -5 )
     {
          closing =true;
          closesell();
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
  

int Breakeven(){
if(BreakOn == true){
   if(BreakEnabled == true){
   double total = -1;
   int i =0;
   total=OrdersTotal();
   if(total>0){
      for(i=0;i<total;i++){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() ){
            if(OrderType()==OP_BUY ){
               if(NormalizeDouble((Bid-OrderOpenPrice()),Digits)>=NormalizeDouble(breakevengain*Point,Digits)){
                  if((NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),Digits)<NormalizeDouble(breakeven*Point,Digits))||OrderStopLoss()==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+breakeven*Point,Digits),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
            }
            else{
               if(NormalizeDouble((OrderOpenPrice()-Ask),Digits)>=NormalizeDouble(breakevengain*Point,Digits)){
                  if((NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),Digits)<NormalizeDouble(breakeven*Point,Digits))||OrderStopLoss()==0){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-breakeven*Point,Digits),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
   }
   
}
}
   
   /// CLOSING ALL BUYS 
void closebuy(){
   if(closing == true){
   int total=-1;
   int i =0;
   total=OrdersTotal();
      if(total>0){
         for(i=0;i<total;i++){
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber() == MAGICMA ){
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
            }
         }
    }
      }
}

//CLOSING ALL SELLS 
void closesell(){
if(closing == true){
int total=-1;
int i =0;
   total=OrdersTotal();
   if(total>0){
      for(i=0;i<total;i++){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol()  && OrderType()==OP_SELL && OrderMagicNumber() == MAGICMA){
            OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
         }
      }
   }
   }
   }
   

int CheckTrends()
   {
  if(MaTrends == true){
   double  current_ma1, current_ma2, current_ma3;
   double  current_wa1, current_wa2, current_wa3;
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
   
      //w1// Td
   current_wa1 = iMA(NULL,PERIOD_W1,25,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_wa2 = iMA(NULL,PERIOD_W1,10,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_wa3 = iMA(NULL,PERIOD_W1,2,0,MODE_SMA,PRICE_MEDIAN,0);

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
    return(wd);   //D1
  }
}

void MAdirections()
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


void SupportResistance()
{
  supportH1 = 2000;
  resistH1 = 0;  
  for(int k = 1;k<=numBars;k++)
  {
   if(supportH1>iLow(Symbol(),timeFrameSRH1,k))
     supportH1 = iLow(Symbol(),timeFrameSRH1,k);
   if(resistH1<iHigh(Symbol(),timeFrameSRH1,k))
     resistH1 = iHigh(Symbol(),timeFrameSRH1,k);
  } 
  ObjectSet("lineSupportH1",OBJPROP_PRICE1,supportH1);
  ObjectSet("lineResistH1",OBJPROP_PRICE1,resistH1);
  

}

void zigzag()
      {  
      

       int n, i;
         i=0;
         while(n<2)
      {
    if(upzig>0) downzag=upzig;
    upzig=iCustom(NULL,0,"ZigZag",depth,0, i);
     if(upzig>0) n+=1;
     i++;
   } 
   
  ObjectSet("TRADERZagUP",OBJPROP_PRICE1,upzig);
  ObjectSet("TRADERZagDN",OBJPROP_PRICE1,downzag);
 // Print(upzig,"--dn",downzag);
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
  ObjectSet("ZigZagD1dn",OBJPROP_PRICE1,upzigM);
  ObjectSet("ZigZagD1up",OBJPROP_PRICE1,downzagM);
   } 
 
 
 void pivots()
 {
       int fibHigh = iHighest(Symbol(),PERIOD_H1,MODE_HIGH,WindowFirstVisibleBar()-1,1);
     int fibLow  = iLowest(Symbol(),PERIOD_H1,MODE_LOW,WindowFirstVisibleBar()-1,1);
     datetime highTime = Time[fibHigh];
     datetime lowTime  = Time[fibLow];
     
    //  if(fibHigh>fibLow){
      WindowRedraw();
      ObjectCreate("XIT_FIBOUP",OBJ_FIBO,0,highTime,High[fibHigh],lowTime,Low[fibLow]);
      color levelColorDown = Green;
    //  }
     // else{
    //  WindowRedraw();
      ObjectCreate("XIT_FIBODN",OBJ_FIBO,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
     color levelColorUp = Red;
   //   }
      
      double fiboPrice1=ObjectGet("XIT_FIBOUP",OBJPROP_PRICE1);
      double fiboPrice2=ObjectGet("XIT_FIBODN",OBJPROP_PRICE2);
      double fiboPriceDiff = fiboPrice2-fiboPrice1;
      
       fiboValue0 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.0,Digits);
       fiboValue23 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.236,Digits);
       fiboValue38 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.382,Digits);
       fiboValue50 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.50,Digits);
       fiboValue61 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.618,Digits);
       fiboValue100 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.0,Digits);
 
     ObjectSet("XIT_FIBO",OBJPROP_FIBOLEVELS,6);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+0,0.0);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+1,0.236);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+2,0.382);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+3,0.50);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+4,0.618);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+5,1.0);

     
     ObjectSet("XIT_FIBOUP",OBJPROP_LEVELCOLOR,levelColorUp);
     ObjectSet("XIT_FIBOUP",OBJPROP_LEVELWIDTH,1);
     ObjectSet("XIT_FIBOUP",OBJPROP_LEVELSTYLE,STYLE_DASHDOTDOT);
     ObjectSetFiboDescription( "XIT_FIBOUP", 0,fiboValue0+" --> 0.0%"); 
     ObjectSetFiboDescription( "XIT_FIBOUP", 1,fiboValue23+" --> 23.6%"); 
     ObjectSetFiboDescription( "XIT_FIBOUP", 2,fiboValue38+" --> 38.2%"); 
     ObjectSetFiboDescription( "XIT_FIBOUP", 3,fiboValue50+" --> 50.0%");
     ObjectSetFiboDescription( "XIT_FIBOUP", 4,fiboValue61+" --> 61.8%");
     ObjectSetFiboDescription( "XIT_FIBOUP", 5,fiboValue100+" --> 100.0%");
   

   return(0);
 
 }
 
void BalanceLots(){
  
  if (EquityLots == false)
      {
      Lots = StartLot;
      Lots2=StartLot*2;
      }

if (EquityLots == true){
  if(AccountEquity() >= 200 && AccountEquity() <= 1000)
   {
   Lots = StartLot;
   Lots2=StartLot*2;

   }
  if(AccountEquity() >= 1000 &&AccountEquity() <= 2000)
   {
   Lots = StartLot*2;
      Lots2=StartLot*4;
   }
  if(AccountEquity() >= 3000 && AccountEquity() <= 4000)
   {
   Lots = StartLot*3;
       Lots2=StartLot*6;
   }
  if(AccountEquity() >= 4000 && AccountEquity() <= 5000)
   {
   Lots = StartLot*4;
         Lots2=StartLot*8;
    }
  if(AccountEquity() >= 5000 && AccountEquity() <= 6000)
   {
   Lots = StartLot*5;
      Lots2 = StartLot*10;
   }
  if(AccountEquity() >= 6000 && AccountEquity() <= 7000)
   {
     Lots = StartLot*6;
        Lots2 = StartLot*12;
    }
  if(AccountEquity() >= 10000 && AccountEquity() <= 15000 )
  {
    Lots = StartLot*10;
    Lots2 = StartLot*20;
  }
    if(AccountEquity() >= 15000 && AccountEquity() <= 20000 )
  {
    Lots = StartLot*15;
        Lots2 = StartLot*30;
  }
      if(AccountEquity() >= 20000 && AccountEquity() <= 30000 )
  {
    Lots = StartLot*20;
        Lots2 = StartLot*40;
  }
  
   if(AccountEquity() >= 30000 && AccountEquity() <= 50000 )
  {
    Lots = StartLot*25;
        Lots2 = StartLot*50;
  }
     if(AccountEquity() >= 50000  )
  {
    Lots = StartLot*30;
    Lots2 = StartLot*60;
 
  }
  
  }
  return(Lots);
  return(Lots2);

}


/////// ALIGATOR DIRECTION CHECK
 void alligators(){
   allitrades =0;
    allitradeb =0;
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
 if (TradeonAligator == true){
     allitrades =0;
     allitradeb =0;
  if(lip > teeth && teeth > jaw){
    allitrades = 0;
    allitradeb = 1;  
  }
  if(jaw > teeth && teeth > lip){
    allitrades = 2;
     allitradeb = 0; 
  }
  }
   if (TradeonAligator == false){
    allitrades =2;
    allitradeb =1;
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
  
void trails()
  {
  if(useTrail == true)
  {
      trailMan = false;
       if(trailALL == false){
  
     if(mode ==1 && (buys >3 || sells >3) && sumbasket > targetprofit*2){
     if((td == 2 && tdd3 ==2 && td5 ==1 && alligtrend ==1)||(td ==1 && tdd3 ==1 && td5==2 && alligtrend ==2)){
        TrailingStop = StartTrail;
         trailMan = true;
         trailingStopManager() ;
     }
     }
     if(mode ==1 && (buys ==6 || sells ==6) && sumbasket > targetprofit*4){
     TrailingStop = StartTrail;
     trailMan = true;
     trailingStopManager() ;
     }
     }  
     if(trailALL == true)
     {
      TrailingStop = StartTrail;
     trailMan = true;
     trailingStopManager() ;
     } 
  }
  }
  
void trailingStopManager() 
{
if(trailMan == true){

   int cnt, total = OrdersTotal();

   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if (TrailingStop > 0 )
      {
         if (OrderType()==OP_BUY)
         {
            if ((MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()>Point*TrailingStop) || OnlyTrailAfterProfit==false)
            {
               if (OrderStopLoss()<MarketInfo(OrderSymbol(),MODE_BID)-Point*TrailingStop)
                  OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(OrderSymbol(),MODE_BID)-Point*TrailingStop,OrderTakeProfit(),0,Green); 
            }
         }
         else if (OrderType()==OP_SELL)
         {
            if ((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)>Point*TrailingStop) || OnlyTrailAfterProfit==false)
            {
               if ((OrderStopLoss()>(MarketInfo(OrderSymbol(),MODE_ASK)+Point*TrailingStop)) || (OrderStopLoss()==0))
                  OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(OrderSymbol(),MODE_ASK)+Point*TrailingStop,OrderTakeProfit(),0,Red); 
            }
         }
      }  
   }
}
}


