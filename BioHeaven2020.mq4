//+------------------------------------------------------------------+
//|                                                    BioHeaven.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern int MAGICMA = 2214588;
input double startLot= 0.10;
int D1percent =25 ;//Percent from Range for Reversals
int maxTrades = 3;
string eaMessage = "Ea Idle -Relax and wait ... ";
double SRPeriod = PERIOD_D1;//FORBIT LEVELS
int SRbars =30;

int tp = 50;//Minium TP in EUROS
int  minsl =25000;//Minium SL in EUROS

int CloseSRbars = 300;
int SRsClosingDistance = 125;//POINTS


bool EaTrades = true;
bool TrailEnabled =false;
bool showIndicators=true;


int distance = 2000; // DISTANCE BETWWEN 1st and Second TRADE
int distanceDevider=3;// DEVIDES RANGE and SETS DISTANCE


int EAmode = 0;
int EARange = 0;

bool tradeSells,tradeBuys;
double forbitup,forbitdown;
double Lots = startLot;
double adxM15,adxH1,adxH4,adxD1; //ADXs 
double td5 ,tdd4 ,tdd3,td,wd;  //M15/H1/H4/D1/W1//TRENDs Based on MAs 
double ItrendM15, ItrendM30,ItrendH1,ItrendH4,ItrendH42 ,ItrendD1,ItrendW1; // Based on Itrend
double sells,buys,totalTrades,sumsell,sumbuy,sumbasket,lastsellopenprice,lastbuyopenprice;
double freeMargin = AccountFreeMargin();
int directionma ,directionI; // TREND DIRECTION SUMMURY 
double downzag,upzig,zigzagrange,zzupFibo23,zzdownFibo23,ZZ1,ZZ2;;
double tradableRange;
bool closingSells=true;
bool closingBuys=true; 
double periodZemafor = PERIOD_CURRENT;
extern double stdevperiod = PERIOD_H4;

 double closeperiodbuy = PERIOD_CURRENT;
 double closeperiodsell=PERIOD_CURRENT; 

//TRAIL
bool trailnow =false;
 double TP=200;//TP (pips)
 double SL=100;//SL (pips)
 double TStart=90;//TS Start (pips)
 double TStop=80;//TS (pips)
 double TStep=30;//TS Step (pips)

 int Max_Slippage_pip_For_TakePosition=800;
 double PIP;int dg;
 double smallTrend,LargeTrend,SuperTrend;
 



/// TODO -
double LotsOptimized()
  {
   double lot=Lots;

   return(lot);
  }
  
  
 void distancesfromSRs(){
 
 tradeSells = false;
 tradeBuys =false;
 closingSells=true;
 closingBuys=true; 
    periodZemafor = PERIOD_CURRENT;
 
        eaMessage="Checking SRs" + SRPeriod;
        double RD1 = Resistance(SRPeriod,SRbars);
        double SD1 = Support(SRPeriod,SRbars);
   
        EAmode=0;
        EARange=0;

        double rangeD1 = MathAbs((NormalizeDouble(((RD1 - SD1)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS))));;
        double avoidDistance = rangeD1 * D1percent / 100  ;//AVOID DISTANCE TO TRADE BASE ON PERCENATAGE
        tradableRange = rangeD1; //SHOW IN P
       
        forbitup = RD1 - avoidDistance*Point;
        forbitdown =SD1 + avoidDistance*Point;
        closeperiodbuy = PERIOD_CURRENT;
        closeperiodsell=PERIOD_CURRENT; 
        distance = rangeD1 / distanceDevider;

        if(Ask >= forbitup ){
         EARange=1;
         
  
        }     
        if(Bid <= forbitdown ){
        EARange=2;
        }
        
        
        if(LargeTrend == 1){
        EAmode=1;
        }
        if(LargeTrend == 2){
        EAmode=2;
        }
        
        if(SuperTrend == 2){
        EAmode=3;
        }
        if(SuperTrend == 1){
        EAmode=4;
        }
        

  
  
  if(EAmode == 0 ){
  tradeSells =true;
  tradeBuys = true;
  periodZemafor = PERIOD_H4;
  closeperiodbuy = PERIOD_CURRENT;
  closeperiodsell=PERIOD_CURRENT; 

 
     if(EARange == 1){
      tradeBuys= false;
      tradeSells= true;
     closeperiodsell=PERIOD_H4; 
   }
   if(EARange == 2){
      tradeBuys=true;
      tradeSells=false;
      closeperiodbuy = PERIOD_H4;
   }

}
        
if(EAmode == 1 ){

  tradeSells =false;
  tradeBuys = true;
   if(EARange == 1){
         tradeBuys=false;
         tradeSells=true;
         closeperiodbuy = PERIOD_M5;
         closeperiodsell=PERIOD_H4; 
       

   }


   }
   
if(EAmode ==2 ){ //TRENDING DOWN 
  tradeSells =true;
  tradeBuys = false;


  
   if(EARange == 2  ){//RANGE DOWN 
        tradeSells=false;
        closingSells=true;
        closeperiodbuy = PERIOD_H4;
        closeperiodsell=PERIOD_M5; 
        

   }
   

 
  
}

comments();
        
        
    
        
        }
   
               
int smallTrends(){
smallTrend=0;
 
if(   td5 == 1 && tdd4 ==1  && adxH1 >28){
smallTrend = 1;
}

if(  td5 == 2 && tdd4 == 2 && adxH1 >28 ){
smallTrend = 2;
}

return smallTrend;

}

  
  
int LargeTrends(){
LargeTrend=0;
if(   td == 1 && tdd3 ==1  && adxD1 >30){
LargeTrend = 1;
}

if(  td == 2 && tdd3 == 2  && adxD1 >30 ){
LargeTrend = 2;
}
return LargeTrend;
}


int SuperTrends(){
SuperTrend=0;
if(   td == 1 && tdd3 ==1 && adxH4 > 40 && adxD1 >40 &&  td5 == 1 && tdd4 ==1 && adxM15 > 40 && adxH1 >40){
SuperTrend = 1;
}

if(  td == 2 && tdd3 == 2 && adxH4 > 40 && adxD1 >40 &&  td5 == 2 && tdd4 == 2 && adxM15 > 40 && adxH1 >40  ){
SuperTrend = 2;
}
return SuperTrend;
}



void closeEmergency(){

   if(sumsell > 10 && sells > 1){

   closeSellsNow(true);
   closeSellsNow(true);
   
   }
      if(sumbuy > 10 && buys > 1){

      closeBuyNow(true);
          closeBuyNow(true);

   
   }

if(sumbuy < minsl && EAmode == 2 && smallTrend ==2)
{
closeBuyNow(true);
}

if(sumsell < minsl && EAmode == 1 && smallTrend ==1)
{
closeSellsNow(true);
}
}



void CheckForOpen(){

   int    res,res1;

   
 eaMessage="Checking To Open Trades" ; 
 


   
   

    if(sells >= 2) {
 closingSells=false;
 if(sumsell > tp ){
 closeSellsNow(true);
  closeSellsNow(true);
   closeSellsNow(true);
 }
 }
 
  if(buys >= 2) {
 closingBuys=false;
 if(sumbuy > tp ){
 closeBuyNow(true);
  closeBuyNow(true);
   closeBuyNow(true);
 }
 }
    
 if(EaTrades == true){
 
        if(SuperTrend == 1  && buys < 2 && EARange == 0  ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,10,0,0,"",MAGICMA,0,Blue);
       eaMessage="Buy Order" ; 
      return;
     }
     
                if( SuperTrend ==2 && sells < 2 && EARange == 0 )  {
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,10,0,0,"",MAGICMA,0,Red);
      return;
     }  
//---- buy conditions
  if(tradeBuys == true){ 
  

  
     if(ZZ2 > 0.2  && buys < 1 ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,10,0,0,"",MAGICMA,0,Blue);
       eaMessage="Buy Order" ; 
      return;
     }
      if(ZZ2 > 0.2 && buys == 1 && Ask <= (lastbuyopenprice - distance*Point)  ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,10,0,0,"BUY2",MAGICMA,0,Blue);
           eaMessage="Sell Order" ; 
      return;
     }
     
           if(ZZ2 > 0.2 && buys == 2 && Ask <= (lastbuyopenprice - distance*Point)  ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,10,0,0,"BUY2",MAGICMA,0,Blue);
           eaMessage="Sell Order" ; 
      return;
     }
     }

    
  //---- sell conditions       
 if(tradeSells == true ){   

     if( ZZ1 > 0.2 && sells < 1  )  {
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,10,0,0,"",MAGICMA,0,Red);
      return;
     }
     if( ZZ1 > 0.2  && sells == 1 && Bid >= (lastsellopenprice + distance*Point)  ){
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,10,0,0,"SELL2",MAGICMA,0,Red);
      return;
     }
     
          if( ZZ1 > 0.2  && sells == 2 && Bid >= (lastsellopenprice + distance*Point)  ){
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,10,0,0,"SELL2",MAGICMA,0,Red);
      return;
     }
     
     
     
     }
     

     
            }
     }
  


void closeOrdersSRs(){
      RefreshRates();

            for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() ) {
            
           if(OrderType()==OP_BUY && closingBuys == true ) {
           if( OrderProfit() > tp && Ask >= ( Resistance(closeperiodbuy,CloseSRbars)-SRsClosingDistance*Point)  ){             
           
              OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
            }
           }
            
                        if(OrderType()==OP_BUY && closingBuys == true ) {
            if( OrderProfit() < -minsl && Ask <= ( Support(closeperiodbuy,CloseSRbars)+SRsClosingDistance*Point)  ){             
           
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
            }
            }
           if(OrderType()==OP_SELL && closingSells == true ) {
            if( OrderProfit() > tp && Ask <= (Support(closeperiodsell,CloseSRbars)+SRsClosingDistance*Point) ){
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
            }
            }
                       if(OrderType()==OP_SELL && closingSells == true ) {
            if( OrderProfit() < -minsl && Ask >= (Resistance(closeperiodsell,CloseSRbars)-SRsClosingDistance*Point) ){
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
            }
            }
           } 
           
  }
}


// GET FIBOS WITH DIRECTIOS 
   double getFiboLevel( double up, double dw, double lev, int direction ){
         double ling = up - dw;
         double pLev = ( ling / 100 ) * lev;
         return ( direction < 0 ) ? NormalizeDouble( up - pLev, Digits ) : NormalizeDouble( dw + pLev, Digits ) ;

}

void closeOrdersonFibbo(){  //NOT WORKS NEED WORK 
      RefreshRates();
      
      Print("CLOSESELL AT "+ getFiboLevel(lastsellopenprice,upzig,100,-1));
         Print("CLOSEBUYS AT "+ getFiboLevel(lastbuyopenprice,downzag,100,1));

            for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() ) {
            
            if(OrderType()==OP_BUY && closingBuys == true ) {
            if( OrderProfit() > tp && Ask >= ( getFiboLevel(lastbuyopenprice,downzag,100,1) )){           //SRsClosingDistance*Point)    
           
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
            }
            }
           if(OrderType()==OP_SELL && closingSells == true ) {
            if( OrderProfit() > tp && Ask <= ( getFiboLevel(lastsellopenprice,upzig,100,-1)) ){
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
            }
            }
           } 
           
  }
}



void breakEvenStopLoss() {
      for (int i = 0; i < OrdersTotal(); i++){
         int order = OrderSelect(i, SELECT_BY_POS);
         if( OrderSymbol() != Symbol()) continue;
              double sls = 0;


         if (OrderSymbol() == Symbol()){ 
         
               if ((OrderType() == OP_SELL) && (OrderStopLoss() < OrderOpenPrice())&& OrderProfit() > 10 ){
                  sls =  OrderOpenPrice()-60*Point ;
               }
       
          
               if ((OrderType() == OP_BUY) && (OrderStopLoss() < OrderOpenPrice()) && OrderProfit() > 10 ){
                  sls =  OrderOpenPrice()+60*Point ;
               }

         
               
               if (sls != 0){
                  OrderModify(OrderTicket(), OrderOpenPrice(), sls, OrderTakeProfit(), 0);
               }
            
        }
    } 
}

void comments() // ON SCREEN PRINTS 
   {
   
string modes;
string rangers;
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     double accequity =(AccountEquity()/AccountBalance()*100);
     double messageEa =StrToDouble(eaMessage);
    // Comment(StringFormat("\n\nTRADING=%G\RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\EQUITY=%G\Equitypercent=%G\nTAMEIO=%G\----TARGET-PROFIT=%G\nActiveTF=%G\--Lots=%G\Lots2=%G\nAligator=%G\AligatorBUY=%G\AligatorSELL=%G\nSOUPERTREND=%G\nMATrends=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nTrend-DIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nMODE1-TradeBUys=%G\TradeSells=%G\n\nNormalDST=%G\---TrendDST=%G\SR-Space=%G\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nH1-ADX=%G\nM5-ADX=%G",trading,range,digits,Bid,Ask,eqt,accequity,sumbasket,targetprofit,timeframe,Lots,Lots2,alligtrend,allitradeb,allitrades,supertrend,directionma,td5,tdd,tdd4,tdd3,td,wd,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,distanceSR,sells,buys,maxsells,maxbuys,adx,adxM5));
     Comment(StringFormat("\n\nADX->M15=%G---H1=%G---H4=%G---D1=%G\nFAST-Trends >0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G\nSmallTrend=%G-----LargeTrend=%G----SUPERTREND=%G\n\n--%GTRADES - SELLS=%G ----BUYS=%G------------BasketSells=%G-----BasketBuys=%G----TOTAL=%G---------FMARGIN=%G\nLAST SELL-SIGNAL=%G----LAST-BUYSIGNAL =%G\nTRADABLE RANGE =%G\nTRADESELLS=%G-----TRADEBUYS=%G----Distance%G\n--CloseSells=%G------CloseBuys=%G", adxM15,adxH1,adxH4,adxD1,td5,tdd4,tdd3,td,smallTrend,LargeTrend,SuperTrend,totalTrades,sells,buys,sumsell,sumbuy,sumbasket,freeMargin,upzig,downzag,tradableRange,tradeSells,tradeBuys,distance,closingSells,closingBuys));
     ObjectSetText("EA-MESSAGE", eaMessage, 10, "Arial", Red);

if(EARange == 1){
rangers = "TOP RANGE  > MARKET CLOSE TO SUPPORT";
}
if(EARange == 2){
rangers = "BOTTOM RANGE   > MARKET CLOSE TO RESISTANCE";
}
if(EARange == 0){
rangers = "MIDLE RANGE  > MARKET ON TRADING RANGE";
}


if(EAmode == 2){
modes = "MODE 2  > MARKET ON DOWN TREND";
}
if(EAmode == 1){
modes = "MODE 1  > MARKET ON UP TREND";
}


if(EAmode == 3){
modes = "MODE 3  > MARKET ON SUPER DOWN TREND";
}
if(EAmode == 4){
modes = "MODE 4  > MARKET ON SUPER UP TREND";
}

if(EAmode == 0){
modes = "MODE 0  > MARKET NO TREND";
}




     ObjectSetText("EA-MODE",modes, 10, "Arial", Yellow);
     ObjectSetText("EA-Range",rangers, 10, "Arial", White);

 
   }


int OnInit()
  {
indicator();
counttrades();
   PIP=Point();dg=1;
  if(Digits==3 || Digits==5) PIP*=10; dg=10;
  if(Digits<=2 || Digits==4) PIP*=1; dg=10; 

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 
  {
  if(Volume[0]>1) return;  
    Chk_ADX();
  CheckTrends();
  zzz();
  smallTrends();
  LargeTrends();
  SuperTrends();
  counttrades();
  distancesfromSRs();
  closeOrdersSRs();
  //  closeEmergency();
  CheckForOpen();
  
  if(showIndicators == true) {
  comments();
  DrawIndicators();
  DevStd();
  }
  
  Trail();

  //closeOrdersonFibbo();




  
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
   double ret=0.0;
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   
  }


  // SUPPORT && RESISTANCE 
double Support(int timeframe, int bars)
      {
      double support;
        support = 2000;
        for(int k = 1;k<=bars;k++)
        {
         if(support>iLow(Symbol(),timeframe,k))
           support = iLow(Symbol(),timeframe,k);
        } 
        return support;
      }


double Resistance(double timeframe,int bars){
         double resistance;
           resistance = 0;  
           for(int k = 1;k<=bars;k++)
           {
            if(resistance<iHigh(Symbol(),timeframe,k))
              resistance = iHigh(Symbol(),timeframe,k);
           } 
           return resistance;
}
//////



int CheckTrends(){
   double  current_ma1, current_ma2, current_ma3;
   double  current_wa1, current_wa2, current_wa3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
   td=0;
   wd=0;
   td5=0;
   tdd4=0;
   tdd3=0;
   

   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,110,0,MODE_EMA,PRICE_OPEN,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,60,0,MODE_SMA,PRICE_OPEN,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,15,0,MODE_SMA,PRICE_OPEN,0);
    if(current_ma3 > current_ma2 && current_ma2 > current_ma1)  {
    td = 1;
    }
    if(current_ma3 < current_ma2 && current_ma2 < current_ma1)  {
    td = 2;
    }
    //w1// 
   current_wa1 = iMA(NULL,PERIOD_W1,150,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_wa2 = iMA(NULL,PERIOD_W1,75,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_wa3 = iMA(NULL,PERIOD_W1,30,0,MODE_SMA,PRICE_MEDIAN,0);
    if(current_wa3 > current_wa2 && current_wa2 > current_wa1)  {
    wd = 1;
    }
    if(current_wa3 < current_wa2 && current_wa2 < current_wa1)  {
    wd = 2;
    }

   //M15 td5
   current_ma15 = iMA(NULL,PERIOD_M15,600,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,300,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,150,0,MODE_SMA,PRICE_MEDIAN,0);
    if(current_ma35 > current_ma25 && current_ma25 > current_ma15)  {
    td5 = 1;
    }
    if(current_ma35 < current_ma25 && current_ma25 < current_ma15) {
    td5 = 2;
     }
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,100,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_H1,50,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_MEDIAN,0);
   if(current_d3 > current_d2 && current_d2 > current_d1)  {
    tdd4 = 1;
   }
   if(current_d3 < current_d2 && current_d2 < current_d1)  {
    tdd4 = 2;
   }
    //H4///
   current_ma111 = iMA(NULL,PERIOD_H4,400,0,MODE_SMA,PRICE_OPEN,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,200,0,MODE_SMA,PRICE_OPEN,0);  
   current_ma311 = iMA(NULL,PERIOD_H4,50,0,MODE_SMA,PRICE_OPEN,0);
  if(current_ma311 > current_ma211 && current_ma211 > current_ma111)  {
    tdd3 = 1;
    }
  if(current_ma311 < current_ma211 && current_ma211 < current_ma111)  {
    tdd3 = 2;
    }
    
  return(td5);  //M15
  return(tdd4); //H1
  return(tdd3); //H4
  return(td);   //D1
  return(wd);   //M5
  
}


 void iTrend()
   {

  double itM15,itM151,itH1,itH11,itH4,itH41,itD1,itD11,itW1,itW11;
  ItrendM15=0;
  ItrendH1=0;
  ItrendH4=0;
  ItrendD1=0;
  ItrendW1=0;
  
  itM15=iCustom(NULL,0,"iTrend",0,0,0,20,2,13,150,0,0);
  itM151=iCustom(NULL,0,"iTrend",0,0,0,20,2,13,150,1,0);
  ItrendM15 = itM15 + itM151*1000;
  
  itH1 =iCustom(NULL,PERIOD_H1,"iTrend",0,0,0,20,2,13,300,0,0);
  itH11 =iCustom(NULL,PERIOD_H1,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendH1 = itH1 + itH11*1000;
  
  
  
  itH4 =iCustom(NULL,PERIOD_H4,"iTrend",0,0,0,20,2,13,300,0,0);
  itH41 =iCustom(NULL,PERIOD_H4,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendH4 = itH4 + itH41*1000;
  
  itD1 =iCustom(NULL,PERIOD_D1,"iTrend",0,0,0,20,2,13,300,0,0);
  itD11 =iCustom(NULL,PERIOD_D1,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendD1 = itD1 + itD11*1000;

  itW1 =iCustom(NULL,PERIOD_W1,"iTrend",0,0,0,20,2,13,300,0,0);
  itW11 =iCustom(NULL,PERIOD_W1,"iTrend",0,0,0,20,2,13,300,1,0);
  ItrendW1 = itW1 + itW11*1000;
  
 }





  
//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
   int counttrades(){


       double sum_profits =0;
       double sum_profitss =0;
       double sum_lots =0;
       double sum_lotsb= 0;
       double ord_num = 0;
       double asumlot = 0;
       int num = 0;
       int  summer =0;
       
       
       sells=0;
       buys=0;
       totalTrades =0;
       lastbuyopenprice=0;
       lastsellopenprice=0;
       
  
    for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() )// 
           {
            if(OrderType()==OP_BUY ) {
            lastbuyopenprice=OrderOpenPrice();
            sum_profits += OrderProfit()+OrderSwap()+OrderCommission();
            buys++;
            }
            if(OrderType()==OP_SELL   ){
            sum_profitss += OrderProfit()+OrderSwap()+OrderCommission();
            lastsellopenprice=OrderOpenPrice();
            sells++;
            }
           sumsell = sum_profitss; 
           sumbuy = sum_profits; 
           summer = sum_profitss + sum_profits;   
           sumbasket = summer;
           totalTrades = sells+buys;
           } 
           }
           return sumsell;
           return sumbuy;
           return sumbasket;
           return totalTrades;
           return sells;
           return buys;           
    }
    
    
    
void Chk_ADX(){
    adxM15=iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MAIN, 1);
    adxH1 =iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 1);
    adxH4 =iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 1);
    adxD1 =iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN, 0);
 
}


int indicator()
  {
//----   

   ObjectCreate("EA-Range", OBJ_LABEL, 0, 0, 0, 0); 
   ObjectSet("EA-Range", OBJPROP_XDISTANCE, 50);
   ObjectSet("EA-Range", OBJPROP_YDISTANCE, 300);

   ObjectCreate("EA-MESSAGE", OBJ_LABEL, 0, 0, 0, 0); 
   ObjectSet("EA-MESSAGE", OBJPROP_XDISTANCE, 50);
   ObjectSet("EA-MESSAGE", OBJPROP_YDISTANCE, 200);
   
   ObjectCreate("EA-MODE", OBJ_LABEL, 0, 0, 0, 0); 
   ObjectSet("EA-MODE", OBJPROP_XDISTANCE, 50);
   ObjectSet("EA-MODE", OBJPROP_YDISTANCE, 400);

    ObjectCreate("D1FORBITUP",OBJ_HLINE,0,0,0);
    ObjectSet("D1FORBITUP",OBJPROP_COLOR,Green);
    ObjectCreate("D1FORBITDOWN",OBJ_HLINE,0,0,0);
    ObjectSet("D1FORBITDOWN",OBJPROP_COLOR,Green);
    
    
    ObjectCreate("SupportM15",OBJ_HLINE,0,0,0);
    ObjectSet("SupportM15",OBJPROP_COLOR,White);
    ObjectCreate("ResistanceM15",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceM15",OBJPROP_COLOR,White);
    
    ObjectCreate("SupportH1",OBJ_HLINE,0,0,0);
    ObjectSet("SupportH1",OBJPROP_COLOR,Yellow);
    
    ObjectCreate("ResistanceH1",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceH1",OBJPROP_COLOR,Yellow);
    
    ObjectCreate("SupportH4",OBJ_HLINE,0,0,0);
    ObjectSet("SupportH4",OBJPROP_COLOR,Orange);
    ObjectCreate("ResistanceH4",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceH4",OBJPROP_COLOR,Orange);
    
    ObjectCreate("SupportD1",OBJ_HLINE,0,0,0);
    ObjectSet("SupportD1",OBJPROP_COLOR,Red);
    ObjectCreate("ResistanceD1",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceD1",OBJPROP_COLOR,Red);
    
    ObjectCreate("SupportW1",OBJ_HLINE,0,0,0);
    ObjectSet("SupportW1",OBJPROP_COLOR,Pink);
    ObjectCreate("ResistanceW1",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceW1",OBJPROP_COLOR,Pink);
    

   return(0);
  }

void DrawIndicators()
{
RefreshRates();



  ObjectSet("D1FORBITUP",OBJPROP_PRICE1, forbitup);
  ObjectSet("D1FORBITDOWN",OBJPROP_PRICE1, forbitdown);


  ObjectSet("SupportM15",OBJPROP_PRICE1,Support(PERIOD_M15,CloseSRbars));
  ObjectSet("ResistanceM15",OBJPROP_PRICE1,Resistance(PERIOD_M15,CloseSRbars));

  ObjectSet("SupportH1",OBJPROP_PRICE1,Support(PERIOD_H1,CloseSRbars));
  ObjectSet("ResistanceH1",OBJPROP_PRICE1,Resistance(PERIOD_H1,CloseSRbars));
  
    ObjectSet("SupportH4",OBJPROP_PRICE1,Support(PERIOD_H4,CloseSRbars));
  ObjectSet("ResistanceH4",OBJPROP_PRICE1,Resistance(PERIOD_H4,CloseSRbars));
  
  ObjectSet("SupportD1",OBJPROP_PRICE1,Support(PERIOD_D1,SRbars));
  ObjectSet("ResistanceD1",OBJPROP_PRICE1,Resistance(PERIOD_D1,SRbars));
  
    ObjectSet("SupportW1",OBJPROP_PRICE1,Support(PERIOD_W1,SRbars));
  ObjectSet("ResistanceW1",OBJPROP_PRICE1,Resistance(PERIOD_W1,SRbars));
  
     
}


   




void closeSellsNow(bool closingSellsNow){

RefreshRates();

            for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol()  ) {
            
           if(OrderType()==OP_SELL && closingSellsNow == true ) 
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
            
            }
           } 
           
  }
  
  void closeBuyNow(bool closingBuysNow){

 RefreshRates();
            for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() ) {
            
            if(OrderType()==OP_BUY && closingBuysNow == true ) {           
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
            }

           } 
           
  }
  }
  
  

     


void Trail(){
if(TrailEnabled == true){

if(trailnow == true ){
for(int i=0; i<=OrdersTotal()-1; i++)         
     {
      if (!OrderSelect(i,SELECT_BY_POS) )continue;
         if(OrderSymbol()!=Symbol())continue;

     }

bool r;
  double STL=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
  double trail=MathMax(TStop*PIP,STL),TSstart=TStart*PIP;
  double jump =MathMax(TStep,0.1)*PIP;
  double TSLB= Bid-trail; double TSLS=Ask+trail;

  for(int i=0; i<=OrdersTotal()-1; i++)         
     {
      if (!OrderSelect(i,SELECT_BY_POS) )continue;
         if(OrderSymbol()!=Symbol())continue;

           double theTP=OrderTakeProfit();
           double OOP= OrderOpenPrice();
           double theSL=OrderStopLoss();
           int OT=OrderTicket();
                    
            if (OrderType()==OP_BUY)
            { 
              if(theTP!=NormalizeDouble(OOP+TP*PIP,Digits) && theSL!=NormalizeDouble(OOP-SL*PIP,Digits) && OOP!=0 && TP!=0 && SL!=0)
              if(OrderModify(OT,OOP,NormalizeDouble(OOP-SL*PIP,Digits),NormalizeDouble(OOP+TP*PIP,Digits),0,clrNONE))continue;

              if(TStop!=0 && TSLB-OOP>=TSstart && theSL+jump <=TSLB)
              r= OrderModify(OT,OOP,TSLB,theTP,0,Green); 
             }
            if (OrderType()==OP_SELL)
            { 
              if(theTP!=NormalizeDouble(OOP-TP*PIP,Digits) && theSL!=NormalizeDouble(OOP+SL*PIP,Digits) && OOP!=0 && TP!=0 && SL!=0)
              if(OrderModify(OT,OOP,NormalizeDouble(OOP+SL*PIP,Digits),NormalizeDouble(OOP-TP*PIP,Digits),0,clrNONE))continue;

              if(TStop!=0 && OOP-TSLS>=TSstart && (theSL-jump >=TSLS||theSL==0))
              r= OrderModify(OT,OOP,TSLS,theTP,0,Red); 
            }
             
     } 
     }  
     }
  }
//+------------------------------------------------------------------+

void DevStd(){
 //int itH1 =iCustom(NULL,PERIOD_CURRENT,"CCI",0,0);
 int itH2 =iCustom(NULL,stdevperiod,"istddev",0,0);
// int val=iForce(NULL,0,13,MODE_SMA,PRICE_CLOSE,0);
 
}


    
 int zzz(){
   ZZ1 =0;
   ZZ2= 0;
     ZZ1=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",0,5,1); //UP
     ZZ2=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",0,4,1); // DOWN 
       if(ZZ1 > 0.2){
        upzig = ZZ1;
        }
         if(ZZ2 > 0.2){
         downzag = ZZ2;
        }
        return ZZ1;
        return ZZ2;

    }
   
