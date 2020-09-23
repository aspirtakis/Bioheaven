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
extern int maxTrades = 3;



extern int D1percent =30 ;//Percent from Range for Reversals
input bool closing = true;
extern bool EaTrades = true;
extern bool tradesides =true;
extern bool tradetrends =true;
extern bool showIndicators=false;
int distance = 300; // DISTANCE BETWWEN 1st and Second TRADE
int SRbars =100;
        int tp = 10000;

extern int mode = 0;

bool tradeSells =true;
bool tradeBuys = true;
double forbitup,forbitdown;

double maxbuys = 3;
double  maxsells= 3;
double Lots = startLot;
bool trailnow =false;





double adxM15,adxH1,adxH4,adxD1; //ADXs 
double td5 ,tdd4 ,tdd3,td,wd;  //M15/H1/H4/D1/W1//TRENDs Based on MAs 
double ItrendM15, ItrendM30,ItrendH1,ItrendH4,ItrendH42 ,ItrendD1,ItrendW1; // Based on Itrend

double sells,buys,totalTrades,sumsell,sumbuy,sumbasket,lastsellopenprice,lastbuyopenprice;
double freeMargin = AccountFreeMargin();
int directionma ,directionI,CrazyTrend; // TREND DIRECTION SUMMURY 
double downzag,upzig,zigzagrange,zzupFibo23,zzdownFibo23;
double tradableRange,fibboTrend ;

double upfib,downfib;//FIBOS 
double periodbuy,periodsell; //CLOSING PERIOD BASED ON SR
bool closingSells=true;
bool closingBuys=true; 


//ZZ ZEMAFOR 
double periodZemafor = PERIOD_CURRENT;
double ZZ1,ZZ2;
 double Period1=5; 
 double Period2=13; 
 double Period3=34; 
 string Dev_Step_1="1,3";
 string Dev_Step_2="8,5";
 string Dev_Step_3="13,8";
 int Symbol_1_Kod=140;
 int Symbol_2_Kod=141;
 int Symbol_3_Kod=142;


extern double TP=200;//TP (pips)
extern double SL=100;//SL (pips)
extern double TStart=10;//TS Start (pips)
extern double TStop=2;//TS (pips)
extern double TStep=2;//TS Step (pips)
double _sl, _tp, _pip;
int Max_Slippage_pip_For_TakePosition=800;
double PIP;int dg;




/// TODO -
double LotsOptimized()
  {
   double lot=Lots;

   return(lot);
  }
  
  
 void distancesfromD1(){
 
 /// WE CALCULATE THE RANGE ON D1 THAN WE MAKE A RANGE BASED ON PERCENTAGE INPUT 
 /// WE AVOID DIRECTIONAL TRADES WEN THE PRICE IS ON THE RANGE 
        double RD1 = Resistance(PERIOD_H1);
        double SD1 = Support(PERIOD_H1);
        tradeSells = false;
        tradeBuys =false;
        closingSells=true;
        closingBuys=true;
        periodsell=PERIOD_CURRENT; //CLOSING
        periodbuy=PERIOD_CURRENT;//CLSOSING
        periodZemafor =PERIOD_CURRENT;
        trailnow=true;

//WE GET THE D1 RANGE 
        double rangeD1 = MathAbs((NormalizeDouble(((RD1 - SD1)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS))));;
        double avoidDistance = rangeD1 * D1percent / 100  ;//AVOID DISTANCE TO TRADE BASE ON PERCENATAGE
        tradableRange = rangeD1/10; //SHOW IN P
        forbitup = RD1 - avoidDistance*Point;
        forbitdown =SD1 + avoidDistance*Point;

        
         if(Ask >= forbitup ){
         tradeSells = true;
         tradeBuys =false;
         trailnow=false;
         if(directionma == 1 ){
          tradeSells = false;
         
         }
     
        }
        if(Bid <= forbitdown ){
        tradeSells = false;
        tradeBuys =true;
        trailnow=false;
                 if(directionma == 2 ){
          tradeBuys = false;
         
         }

        }
        
                
        if(directionI == 0){
        periodsell=PERIOD_M1;
        periodbuy=PERIOD_M15;
        
        }
        
       if(directionI == 2){
          closeBuyNow(true);
          periodsell=PERIOD_M30;
          
        
        }
       if(directionI == 1){
          closeSellsNow(true);
          periodbuy=PERIOD_M30;
          
        
        }
        
           
  }
  




void CheckForOpen(){

   int    res,res1;
   distancesfromD1();
   ZZ1 =0;
   ZZ2= 0;
//---- get 3 Level ZZ Semafor 

if(sumsell > tp && sells ==2){
closeSellsNow(true);

}
if(sumbuy > tp && buys == 2){
closeBuyNow(true);

}
if(lastbuyopenprice >= Ask && lastbuyopenprice <= upzig){
closeBuyNow(true);
}
if(lastsellopenprice <= Bid && lastsellopenprice >= downzag ){
closeSellsNow(true);
}

 //  if(Volume[0]>1) return;    
 
   ZZ1=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,5,1); //UP
   ZZ2=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,4,1); // DOWN 
/// SAVE LAST ENTRIES
       if(ZZ1 > 0.2){
        upzig = ZZ1;
        }
         if(ZZ2 > 0.2){
         downzag = ZZ2;
        }
 
 //---- go trading only for first tiks of new bar

    
 if(EaTrades == true){
      
//---- buy conditions
  if(tradeBuys == true){ 
     if(ZZ2 > 0.2  && buys < 1 ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,10,0,0,"",MAGICMA,0,Blue);
      return;
     }
      if(ZZ2 > 0.2 && buys == 1 && Ask <= (lastbuyopenprice - distance*Point)  ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,10,0,0,"BUY2",MAGICMA,0,Blue);
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
     }
     

     
            }
     }
  


void closeOrders(){
      RefreshRates();
            for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() ) {
            
            if(OrderType()==OP_BUY && closingBuys == true ) {
            if( OrderProfit() > tp && Ask >= Resistance(periodbuy)  ){             
           
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
            }
            }
           if(OrderType()==OP_SELL && closingSells == true ) {
            if( OrderProfit() > tp && Ask <= Support(periodsell) ){
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
            }
            }
           } 
           
  }
}







void comments() // ON SCREEN PRINTS 
   {
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     double accequity =(AccountEquity()/AccountBalance()*100);
    // Comment(StringFormat("\n\nTRADING=%G\RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\EQUITY=%G\Equitypercent=%G\nTAMEIO=%G\----TARGET-PROFIT=%G\nActiveTF=%G\--Lots=%G\Lots2=%G\nAligator=%G\AligatorBUY=%G\AligatorSELL=%G\nSOUPERTREND=%G\nMATrends=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nTrend-DIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nMODE1-TradeBUys=%G\TradeSells=%G\n\nNormalDST=%G\---TrendDST=%G\SR-Space=%G\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nH1-ADX=%G\nM5-ADX=%G",trading,range,digits,Bid,Ask,eqt,accequity,sumbasket,targetprofit,timeframe,Lots,Lots2,alligtrend,allitradeb,allitrades,supertrend,directionma,td5,tdd,tdd4,tdd3,td,wd,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,distanceSR,sells,buys,maxsells,maxbuys,adx,adxM5));
     Comment(StringFormat("\n\nADX->M15=%G---H1=%G---H4=%G---D1=%G\nFAST-Trends >0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---M5=%G------TrendDirection=%G\nI-Trends   > 0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G---W1=%G------ITrendDirection=%G\nCrazyTrend=%G\n\n--%GTRADES - SELLS=%G ----BUYS=%G------------BasketSells=%G-----BasketBuys=%G----TOTAL=%G---------FMARGIN=%G\nLAST SELL-SIGNAL=%G----LAST-BUYSIGNAL =%G\nTRADABLE RANGE =%G\nTRADESELLS=%G-----TRADEBUYS=%G----Distance%G",adxM15,adxH1,adxH4,adxD1,td5,tdd4,tdd3,wd,directionma,ItrendM15,ItrendH1,ItrendH4,ItrendD1,ItrendW1,directionI,CrazyTrend,totalTrades,sells,buys,sumsell,sumbuy,sumbasket,freeMargin,upzig,downzag,tradableRange,tradeSells,tradeBuys,distance));
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
  if(showIndicators == true) {
  Chk_ADX();
  CheckTrends();
  iTrend();
  CrazyTrends();
  TrendConclusion();
  comments();
  DrawIndicators();
  DevStd();
     mak();

  
  }

  counttrades();
  CheckForOpen();
  closeOrders();
  Trail();
  
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
//double OnTester()
 // {
  // double ret=0.0;
  // return(ret);
 // }
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
double Support(int timeframe)
      {
      double support;
        support = 2000;
        for(int k = 1;k<=SRbars;k++)
        {
         if(support>iLow(Symbol(),timeframe,k))
           support = iLow(Symbol(),timeframe,k);
        } 
        return support;
      }


double Resistance(double timeframe){
         double resistance;
           resistance = 0;  
           for(int k = 1;k<=SRbars;k++)
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

   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,25,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,10,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,2,0,MODE_SMA,PRICE_CLOSE,0);
    if(current_ma3 > current_ma2 && current_ma2 > current_ma1)  {
    td = 1;
    }
    if(current_ma3 < current_ma2 && current_ma2 < current_ma1)  {
    td = 2;
    }
    //w1// M5
   current_wa1 = iMA(NULL,PERIOD_M5,150,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_wa2 = iMA(NULL,PERIOD_M5,75,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_wa3 = iMA(NULL,PERIOD_M5,30,0,MODE_SMA,PRICE_MEDIAN,0);
    if(current_wa3 > current_wa2 && current_wa2 > current_wa1)  {
    wd = 1;
    }
    if(current_wa3 < current_wa2 && current_wa2 < current_wa1)  {
    wd = 2;
    }

   //M15 td5
   current_ma15 = iMA(NULL,PERIOD_M15,50,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,25,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,12,0,MODE_SMA,PRICE_MEDIAN,0);
    if(current_ma35 > current_ma25 && current_ma25 > current_ma15)  {
    td5 = 1;
    }
    if(current_ma35 < current_ma25 && current_ma25 < current_ma15) {
    td5 = 2;
     }
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,25,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,PERIOD_H1,2,0,MODE_SMA,PRICE_MEDIAN,0);
   if(current_d3 > current_d2 && current_d2 > current_d1)  {
    tdd4 = 1;
   }
   if(current_d3 < current_d2 && current_d2 < current_d1)  {
    tdd4 = 2;
   }
    //H4///
   current_ma111 = iMA(NULL,PERIOD_H4,25,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma311 = iMA(NULL,PERIOD_H4,2,0,MODE_SMA,PRICE_CLOSE,0);
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
  
  itM15=iCustom(NULL,0,"iTrend",0,0,0,20,2,13,300,0,0);
  itM151=iCustom(NULL,0,"iTrend",0,0,0,20,2,13,300,1,0);
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
   int counttrades()
     {
       RefreshRates();
       sells=0;
       buys=0;
       totalTrades =0;
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
    adxM15=iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MAIN, 0);
    adxH1 =iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
    adxH4 =iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 0);
    adxD1 =iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN, 0);
 
}


int indicator()
  {
//----

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
    ObjectSet("SupportW1",OBJPROP_COLOR,Orange);
    ObjectCreate("ResistanceW1",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceW1",OBJPROP_COLOR,Orange);
    

   return(0);
  }

void DrawIndicators()
{
RefreshRates();



  ObjectSet("D1FORBITUP",OBJPROP_PRICE1, forbitup);
  ObjectSet("D1FORBITDOWN",OBJPROP_PRICE1, forbitdown);


  ObjectSet("SupportM15",OBJPROP_PRICE1,Support(PERIOD_M15));
  ObjectSet("ResistanceM15",OBJPROP_PRICE1,Resistance(PERIOD_M15));

  ObjectSet("SupportH1",OBJPROP_PRICE1,Support(PERIOD_H1));
  ObjectSet("ResistanceH1",OBJPROP_PRICE1,Resistance(PERIOD_H1));
  
    ObjectSet("SupportH4",OBJPROP_PRICE1,Support(PERIOD_H4));
  ObjectSet("ResistanceH4",OBJPROP_PRICE1,Resistance(PERIOD_H4));
  
  ObjectSet("SupportD1",OBJPROP_PRICE1,Support(PERIOD_D1));
  ObjectSet("ResistanceD1",OBJPROP_PRICE1,Resistance(PERIOD_D1));
  
     
}


   

// GET FIBOS WITH DIRECTIOS 
   double getFiboLevel( double up, double dw, double lev, int direction ){
         double ling = up - dw;
         double pLev = ( ling / 100 ) * lev;
         return ( direction < 0 ) ? NormalizeDouble( up - pLev, Digits ) : NormalizeDouble( dw + pLev, Digits ) ;

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
  
  
  int TrendConclusion()
      {
        directionma =0 ;
      
         if(td5 ==1 && tdd4 ==1 && tdd3 == 1  && wd ==1 ){
         directionma = 1;
         }
         if( td5 ==2 && tdd4 ==2 && tdd3 ==2  && wd ==2 ){
         directionma = 2;
         }
         return directionma;
      }
       
      
int ITrendConclusion()
      {
        directionI =0;
      
         if(  ItrendD1 > 10 && ItrendH4 > 5 && ItrendH1 > 5  && ItrendM15 > 5)
        {
         directionI = 2;
        }
         if(  ItrendD1 < -10 && ItrendH4 < -5 && ItrendH1 < -5  && ItrendM15 < -5 )
        {
         directionI = 1;
        }
        return directionI;
      }
      
int CrazyTrends()
      {
        CrazyTrend =0;
      
         if( (ItrendW1 > 20  &&  ItrendD1 > 10 && ItrendH4 > 8 && ItrendH1 > 7  && ItrendM15 > 7) && (td5 ==1 && tdd4 ==1 && tdd3 == 1 && td == 1 ) )
        {
           CrazyTrend = 2;
        }
         if( (ItrendW1 < -20  &&   ItrendD1 < -10 && ItrendH4 < -10 && ItrendH1 < -10  && ItrendM15 < -10) && ( td5 ==2 && tdd4 ==2 && tdd3 ==2 && td == 2 ) )
        {
          CrazyTrend = 1;
        }
        return CrazyTrend;
      }








void Trail(){

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
//+------------------------------------------------------------------+

void DevStd(){
 int itH1 =iCustom(NULL,PERIOD_CURRENT,"CCI",0,0);
  int itH2 =iCustom(NULL,PERIOD_CURRENT,"istddev",0,0);
  int val=iForce(NULL,0,13,MODE_SMA,PRICE_CLOSE,0);

  int limit;
     int counted_bars=IndicatorCounted();
     Print(val);



}

int mak(){
 
 int lak = iCCI(Symbol(),0,12,PRICE_TYPICAL,0);
 int lok = iCCI(Symbol(),0,20,PRICE_TYPICAL,0);
 int result =5 ;
   if(lak>lok){
result=0;
   }
  // Print(lak);
    //  Print(lok);
          return result;
          

    }
