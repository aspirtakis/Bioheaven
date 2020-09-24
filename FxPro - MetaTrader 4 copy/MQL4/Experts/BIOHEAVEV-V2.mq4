//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern int MAGICMA = 993010;
extern bool trading = true;
extern double closeFastEquity = 105;
extern double EquityClose = 300;
extern double DistRetrace = 1000;
extern double StartLot =0.01;
extern double maxorders = 4;
extern double startDistance=500;
extern bool checkWekly = false;
extern bool MaTrends = true;
extern bool ItrendTrends =false;
extern double refact = 2000;
extern bool tradesides = true;
extern bool tradetrends = true;
extern bool BreakOn =true;
extern bool balancelots =true;

extern bool TradeonAligator = true;//TRADE STO MODE 0 ONLY WITH ALIGATOR
extern bool AligMaxs =true;//CHECK PATOUS GIA GIRISMATA

 double  allitrades =2;
 double allitradeb =1;
 

extern int MACD_level=500; //(1-12) [low works for GBPUSD], high works for others.
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
 int ExtCountedBars=0;
 bool BreakEnabled =false;

 int breakeven = breakevenS; //POSO NA PAREi
 int breakevengain = breakevengainS; ///POTE NA MPEI 
bool closing =true ;
double TargetBasket = targetprofit/3 ;
double downzag,upzig;
double downzagM,upzigM;
double timeframe ;
double Lots;
double MyTrend;
double ItrendM15, ItrendM30,ItrendH1, ItrendH4,ItrendH42  ,ItrendD1;
 double  directionma ,directionI ;


 void OnTick()
  { 
       RefreshRates();
   if(Bars<100 || IsTradeAllowed()==false) return;
     distance=startDistance;
     trenddistance=startDistance/2;
     BalanceLots();
       pr();
     counttrades();
     CheckTrends();
     itrend();
     alligators();
     fixdirections();
     fixDirection();
     souperT();
     Modes(); 
     modesfixs();
     zigzag();
     zigzagM();
     weeklysCheck();
     breaks();
     ProfitAdx();
     CheckForOpen();
     comments();    
  }


void Modes(){
  mode = 0 ;
  if(direction > 0 )
  {
  mode = 1;
  } 
  }


 void weeklysCheck()//CHECKING WEEKLY ZIG ZAG AND STOPS TRADING 
   {
   if(checkWekly == true)
   {
     trading =true;
    if((buys >=3 || sells >=3 ) && mode == 1)
    {
     if(Ask > upzigM-(DistRetrace*Point))
     {    trading =false;
     }
     if(Bid < downzagM+(DistRetrace*Point))
     {    trading =false;
     }
    }
     if((buys >=6 || sells >=6 ) && mode == 1)
    {
     if(Ask > upzigM-((DistRetrace*2)*Point))
     {    trading =false;
     }
     if(Bid < downzagM+((DistRetrace*2)*Point))
     {    trading =false;
     }
    }
    }
   }


void souperT()

{
   supertrend = 0;
   if(alligtrend == 1 && tdd3 ==1 && td ==1 && tdd4 == 1 && adx >55) 
   {
   supertrend = 1;
   }
   if(alligtrend == 2 && tdd3 ==2 && td ==2 && tdd4 == 2 && adx >55) 
   {
   supertrend = 2;
   }
}

void modesfixs()
   {
if (mode == 1){

   maxbuys = maxorders*2;
   maxsells=maxorders*2;
   tradesells=false;
   tradebuys = false;
   BreakEnabled =true;
   
   if(direction ==2)
   {
   tradebuys = false;
   tradesells=true;
     if(alligtrend == 2 && adx > 30)
     {
     trenddistance = startDistance/3;
     }
     
    }
   if(direction ==1  )
      {
        tradebuys = true;
         tradesells=false;
        if(alligtrend == 1 && adx > 30)
         {
          trenddistance = startDistance/3;
          }
   } 
   if(supertrend ==1)
   {
       tradebuys = true;
         tradesells=false;
          trenddistance = startDistance/4;
             timeframe = 5;
               BreakEnabled =false;
   }
    if(supertrend ==2)
   {
    tradebuys = false;
    tradesells=true;
    trenddistance = startDistance/4;
    timeframe = 5;
    BreakEnabled = false;
   }
  }

  
if (mode == 0){
      BreakEnabled=false;
      tradesells=true;
      tradebuys = true;
      maxbuys = maxorders/2;
      maxsells=maxorders/2;  
     
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
     if(Bid < downzagM+(DistRetrace*Point))
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
     }           
}
}


void ProfitAdx()
   {
   adx=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
   refactor = refact;
   timeframe = 0;
   if(adx >= 45 ){
   refactor = refact*2;
   if(mode == 1){
        timeframe = 5;
     }
        if(mode == 0){
        timeframe = 60;
     }
   }
   if(adx > 26 && adx <= 44 ){
       refactor = refact;
      if(mode == 1){
        timeframe = 15;
     }
         if(mode == 0){
        timeframe = 15;
     }
   }
   if(adx < 20)   {
   refactor = refact/4; 
        if(mode == 1){
        timeframe = 60;
     }
        if(mode == 0){
        timeframe = 5;
     }
    }
   targetprofit = Lots*refactor;
}

     
void CheckForOpen()
  {
  if(trading == true){
  breakeven =  breakevenS; //POSO NA PAREi
  breakevengain =  breakevengainS ; ///POTE NA MPEI 
  if(Volume[0]>1) return;
   int    res;
    CloseOrders();
    distancebuy  = (lastbuyopenprice-distance*Point);
    distancesell =  (lastsellopenprice+distance*Point);
     ////////////////////////MODE 0 PLAGIO ///////////////
  if(mode == 0 && tradesides == true){ 
      BreakEnabled=false;
     ////---- sell conditions
     if( buys < maxbuys && upzig > downzag && buys == 0 && alligtrend == 1 )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-0-1B",MAGICMA,0,Blue);
     return;
     }
       if( buys < maxbuys && upzig > downzag && buys == 1 && Ask < distancebuy  && allitradeb ==1)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-0-2B",MAGICMA,0,Blue);
     return;
     }
          if( buys < maxbuys && upzig > downzag && buys >= 2 && Ask < distancebuy  && allitradeb ==1)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"MODE-0-2B",MAGICMA,0,Blue);
     return;
     }
     
     if( sells < maxsells && upzig < downzag && sells == 0 && alligtrend ==2) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-1S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  && upzig < downzag && sells ==1  && Bid > distancesell && allitrades ==2 ) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-2S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  && upzig < downzag && sells >=2  &&  Bid > distancesell && allitrades ==2 ) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"MODE-0-2S",MAGICMA,0,Red);
     return;
     }

     }
////////////////////////MODE 0  -TREND FOLLOW 
    if(mode == 1 && tradetrends == true){ 
     breaks();
     distancebuyp  = (lastbuyopenprice+trenddistance*Point);
     distancesellp = (lastsellopenprice-trenddistance*Point);
    
     ////---- sell conditions
     if(tradebuys == true && buys < maxbuys && upzig > downzag && buys == 0 )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-1-BUY1",MAGICMA,0,Blue);
     return;
     }
       if( tradebuys == true && buys < maxbuys && upzig > downzag && buys >= 1 &&  (Ask < distancebuy || Ask > distancebuyp))
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"MODE-1-BUY2",MAGICMA,0,Blue);
     return;
     }
     if( tradesells == true && sells < maxsells && upzig < downzag && sells == 0) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-1-SELL1",MAGICMA,0,Red);
     return;
     }
      if(tradesells == true && sells < maxsells  && upzig < downzag && sells >=1  && (Bid > distancesell || Bid < distancesellp)) //
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
   breakevenS = trenddistance/2; //POSO NA PAREi
  breakevengainS =trenddistance; ///POTE NA MPEI 
  
    breakeven =  breakevenS; //POSO NA PAREi
    breakevengain =  breakevengainS ; ///POTE NA MPEI 
    BreakEnabled=false;
    if(Volume[0]>1) return;
    
   if(mode == 1 ){ 
     if((buys >= 3 || sells >=3 ) ){
     BreakEnabled=true;
     Breakeven();
     maxbuys = maxorders*2;
     maxsells=maxorders*2;
     }
     if((buys >= 6 || sells >=6 ) && accequity > 120 ){
     BreakEnabled=true;
     breakeven = startDistance*5; //POSO NA PAREi
     breakevengain =startDistance*6; ///POTE NA MPEI 
     Breakeven();
     maxbuys = maxorders*4;
     maxsells=maxorders*4;
     }
    if((buys >= 12 || sells >=12 ) && accequity > 150 ){
     BreakEnabled=true;
     breakeven = 5; //POSO NA PAREi
     breakevengain =10; ///POTE NA MPEI 
     Breakeven();
     maxbuys = maxorders*8;
     maxsells=maxorders*8;
     breakeven = 1800; //POSO NA PAREi
     breakevengain =2000; ///POTE NA MPEI 
     Breakeven();
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
        int summer = sum_profitss + sum_profits;   
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


  
int CloseOrders()
   {
      closebasket =false;
      closing =false;
      
   if(mode== 0){
   if(sumbasket > targetprofit)
   {
   closebasket = true ;
   }
   if(sumbasket < targetprofit){
            closebasket =false;
   }
   if(accequity >= 105)
   {
           closebasket = true ;
   }
  // if((buys >=4 || sells >= 4) && sumbasket > -5 )
   //{ 
   //  closebasket = true ;
  // }
   if (sells <= 2 && buys <=2){
      closing =true;
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
    if (sells == 1 || buys ==1){
      closing =true;
      if(sumbuy >= targetprofit/2)
            {
          closing =true;
          closebuy();
            }
       if(sumsell >= targetprofit/2)
           {
          closing =true;
          closesell();
           }
      }
      }
      
   if(mode ==1 )
      {
     if(accequity >= EquityClose)
      {
           closebasket = true ;
      }
   if(direction == 1 && sells >0 && accequity >= closeFastEquity)
             {
     closebasket = true ;
            }         
   if(direction == 2 && buys  >0 && accequity >= closeFastEquity)
                      {
    closebasket = true ;
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
     CloseAll();
   }


void comments()
   {
   int  digits = Digits();
        RefreshRates();
     double eqt= AccountEquity();
     accequity =(AccountEquity()/AccountBalance()*100);
     Comment(StringFormat("TRADING=%G\RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\ZAGTF=%G\n\nAligator=%G\SuperTrend=%G\nI-TREND=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\nMATRENDS=%G\nMAs--M15=%G\M30=%G\H1=%G\H4=%G\D1=%G\nDIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nTradeBUys=%G\TradeSells=%G\PlagioDistance=%G\Trendistance=%G\n\nBASKET=%G\->TARGETBASKET=%G\n\n\n\n\n\n\n\n\n\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nEQUITY=%G\nEquitypercent=%G\nH1-ADX=%G",trading,range,digits,Bid,Ask,timeframe,alligtrend,supertrend,directionI,ItrendM15,ItrendM30,ItrendH1,ItrendH4,ItrendD1,directionma,td5,tdd,tdd4,tdd3,td,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,sumbasket,targetprofit,sells,buys,maxsells,maxbuys,eqt,accequity,adx));
   }


int fixDirection()///TREND DIRECTION

   {   
   direction = 0 ;
   
   if(ItrendTrends == true && MaTrends == true){
   if(directionI == 2 && directionma == 2)
   {
   direction =2 ;
   }
   if(directionI == 1 && directionma == 1)
   {
   direction =1 ;
   }
   }
   
   if(ItrendTrends == true && MaTrends == false){
   if(directionI == 2)
   {
   direction =2;
   }
   if(directionI == 1)
   {
   direction =1;
   }
   }
   
   if(ItrendTrends == false && MaTrends == true){
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
               OrderClose(OrderTicket(),OrderLots(),Bid,0);
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
            OrderClose(OrderTicket(),OrderLots(),Ask,0);
         }
      }
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

   if(tdd == 1 && td5 ==1 && tdd4 ==1 && tdd3 == 1 ){
   directionma = 1;
   }
   if( tdd == 2 && td5 ==2 && tdd4 ==2  && tdd3 ==2 ){
   directionma = 2;
   }
   if(ItrendD1 > 5 && ItrendH4 > 6 && ItrendH1 > 7 && ItrendM30 > 10 && ItrendM15 >15)
  {
   directionI = 1;
  }
   if(ItrendD1 < -5 && ItrendH4 < -6 && ItrendH1 < -7 && ItrendM30 < -10 && ItrendM15 < -15 )
  {
   directionI = 2;
  }
}


  void itrend()
   {
  if( ItrendTrends == true){
  RefreshRates();
  directionI =0;
  double itM15,itM151,itM30,itM301,itH1,itH11,itH4,itH41,itD1,itD11;
  
  itM15=iCustom(NULL,0,"iTrend",0,0,0,20,2,13,300,0,0);
  itM151=iCustom(NULL,0,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendM15 = itM15 + itM151*1000;
  
  itM30=iCustom(NULL,PERIOD_M30,"iTrend",0,0,0,20,2,13,300,0,0);
  itM301=iCustom(NULL,PERIOD_M30,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendM30 = itM30 + itM301*1000;
  
  itH1 =iCustom(NULL,PERIOD_H1,"iTrend",0,0,0,20,2,13,300,0,0);
  itH11 =iCustom(NULL,PERIOD_H1,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendH1 = itH1 + itH11*1000;
  
  itH4 =iCustom(NULL,PERIOD_H4,"iTrend",0,0,0,20,2,13,300,0,0);
  itH41 =iCustom(NULL,PERIOD_H4,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendH4 = itH4 + itH41*1000;
  
  itD1 =iCustom(NULL,PERIOD_D1,"iTrend",0,0,0,20,2,13,300,0,0);
  itD11 =iCustom(NULL,PERIOD_D1,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendD1 = itD1 + itD11*1000;

  }
 }


 void alligators()
 {
 allitrades =2;
 allitradeb =1;
 if (TradeonAligator == true){
 alligtrend = 0;
 double jaw =iAlligator(NULL,5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
 double teeth=iAlligator(NULL,5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
 double lip=iAlligator(NULL,5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
 
  if(lip > teeth && teeth > jaw){
  alligtrend = 1 ;
  }
    if(jaw > teeth && teeth > lip){
  alligtrend = 2 ;
  }

  allitrades = alligtrend;
  allitradeb = alligtrend;

  
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
    upzig=iCustom(NULL,0,"ZigZag", 0, i);
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
   //Print(upzigM ,"---",downzagM);
   } 
 
void BalanceLots(){
     Lots = StartLot;
     Lots2 =StartLot*2;

if (balancelots == true){
  if(AccountEquity() >= 200 && AccountEquity() <= 1000)
   {
   Lots = StartLot;
   }
  if(AccountEquity() >= 1000 &&AccountEquity() <= 2000)
   {
   Lots = StartLot*2;
   }
  if(AccountEquity() >= 3000 && AccountEquity() <= 4000)
   {
   Lots = StartLot*3;
   }
  if(AccountEquity() >= 4000 && AccountEquity() <= 5000)
   {
   Lots = StartLot*4;
    }
  if(AccountEquity() >= 5000 && AccountEquity() <= 6000)
   {
   Lots = StartLot*5;
   }
  if(AccountEquity() >= 6000 && AccountEquity() <= 7000)
   {
     Lots = StartLot*6;
    }
  if(AccountEquity() >= 10000 && AccountEquity() <= 15000 )
  {
    Lots = StartLot*10;
  }
    if(AccountEquity() >= 15000 && AccountEquity() <= 20000 )
  {
    Lots = StartLot*15;
  }
      if(AccountEquity() >= 20000 && AccountEquity() <= 30000 )
  {
    Lots = StartLot*20;
  }
  
   if(AccountEquity() >= 30000 && AccountEquity() <= 50000 )
  {
    Lots = StartLot*25;
  }
     if(AccountEquity() >= 50000  )
  {
    Lots = StartLot*30;
  }
  
  Lots2 =Lots*2;
  
  }
  
}


//+------------------------------------------------------------------+
//| MACD function derives the value of MACD with default settings    |
//+------------------------------------------------------------------+
int best_deal()
  {
   double MACDSignal1,MACDSignal2;
   
   MACDSignal2=iMA(NULL,0,MACD_level,0,MODE_EMA,Close[0],0)-iMA(NULL,0,MACD_level+1,0,MODE_EMA,Close[0],0);
   MACDSignal1=iMA(NULL,0,MACD_level,0,MODE_EMA,Close[gap],gap)-iMA(NULL,0,MACD_level+1,0,MODE_EMA,Close[gap],gap);

   if ((find_highest && Close[0]>OrderOpenPrice()+Point*5) && MACDSignal2<MACDSignal1)
     { find_highest=false; return (1); } 
   
   else if ((find_lowest && Close[0]<OrderOpenPrice()-Point*5) && MACDSignal2>MACDSignal1)
     { find_lowest=false; return (1); } 
  
   return (0);
  }
//+--------------------------------------------------------------------------------+
int MACD_Direction ()
  {
   double MACDSignal1,MACDSignal2,ind_buffer1[100], Signal1, Signal2;
   
   MACDSignal2=iMA(NULL,0,100,0,MODE_EMA,Close[0],0)-iMA(NULL,0,MACD_level,0,MODE_EMA,Close[0],0);
   MACDSignal1=iMA(NULL,0,100,0,MODE_EMA,Close[gap],gap)-iMA(NULL,0,MACD_level,0,MODE_EMA,Close[gap],gap);

   MACD_Strength=MACDSignal2-MACDSignal1; if (MACD_Strength<0) MACD_Strength=MACD_Strength*(-1);

   if(MACDSignal1<0) return (-1); 
   if(MACDSignal1>0) return (1); 
   else return (0);  
  }
  
  void pr()
  {

  //Print("MACD-DIRECTION",MACD_Direction());
 // Print("SIGNAL",best_deal());
  }