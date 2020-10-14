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

 int MAGICMA = 2214588;
input double startLot= 0.10;
int Slippage;

bool EaTrades = true;
double  RSIUpLevel = 60;
double RSIDnLevel = 40;
 double SRPeriod = PERIOD_D1;
 int SRbars =100; //Range BARS
 int D1percent =20 ;//Percent from Range for Reversals
 
 int minsl = 5000;// SL IN POINTS
 int minslTrend = minsl/2;      //TREND TRADES SL POINTS
 double ModifyDistance = 300; // DISTANCE TO MOVE STOPORDER
 double ModifySet =100;// SETPOIT FROM ZAGS
 extern int PeriodZ = 154;

 bool BreakEnabled =false;
 double BeEnters =100;
 double BePoint = 50;

 bool EACloseOrdersSR=true;
  int mintp =100; //Minmum PROFIT 
 int tp; 
 int CloseSRbars = 100; //SR BARS FOR CLOSE
 int SRsClosingDistance = 200; //DISTANCE FROM SR

string eaMessage = "Ea Idle -Relax and wait ... ";


 bool TrailEnabled =false;
 bool   AllPositions  =true;         
 bool   ProfitTrailing=true;     
 int    TrailingStop  =500;          
 int    TrailingStep  =50;            
 bool   UseSound      =false;     
 string NameFileSound ="expert.wav";  

int distanceDevider=10; // Range Distance DEVIDER


int RSI ;

 double MaPeriodM15A = 300;
 double MaPeriodH1A = 100;
 
extern double MaPeriodH4A = 14;
extern double MaPeriodD1A = 450;
 double MaPeriodW1A = 15;

 double StockasticPeriod = 15;






bool showIndicators=true;
int distance = 3000; // DISTANCE BETWWEN 1st and Second TRADE
int EAmode = 0;
int EARange = 0;
bool tradeSells,tradeBuys;
double forbitup,forbitdown;
double Lots = startLot;
double adxM15,adxH1,adxH4,adxD1; //ADXs 
double td5 ,tdd4 ,tdd3,td,wd;  //M15/H1/H4/D1/W1//TRENDs Based on MAs 
double ItrendM15, ItrendM30,ItrendH1,ItrendH4,ItrendH42 ,ItrendD1,ItrendW1; // Based on Itrend
double sellsstops,buysstops,sells,buys,totalTrades,sumsell,sumbuy,sumbasket,lastsellopenprice,lastbuyopenprice,lastsellstopopenprice,lastbuystopopenprice;
double freeMargin = AccountFreeMargin();
int directionma ,directionI; // TREND DIRECTION SUMMURY 
double downzag,upzig,zigzagrange,zzupFibo23,zzdownFibo23;
double ZZ1,ZZ2;
double tradableRange;
bool closingSells=true;
bool closingBuys=true; 
double periodZemafor = PERIOD_CURRENT;
double stdevperiod = PERIOD_CURRENT;

 double ClosePeriod = PERIOD_CURRENT;
double closeperiodbuy = ClosePeriod;
double closeperiodsell=ClosePeriod; 




 int Max_Slippage_pip_For_TakePosition=800;
 double PIP;int dg;
 double smallTrend,LargeTrend,SuperTrend;

void breakEvenStopLoss() {
double BePoints =  BeEnters;
      for (int i = 0; i < OrdersTotal(); i++){
         int order = OrderSelect(i, SELECT_BY_POS);
         if(OrderMagicNumber() != MAGICMA || OrderSymbol() != Symbol()) continue;

         if (OrderSymbol() == Symbol()){ 
            if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)) {
               double sl = 0;
                 double oldsl ;
               if ((OrderType() == OP_BUY) && (OrderStopLoss() < OrderOpenPrice() && Ask > OrderOpenPrice()+BePoints*Point) ){
                  sl =  OrderOpenPrice()+BePoint*Point;
               }
   
               if ((OrderType() == OP_SELL) && (OrderStopLoss()> OrderOpenPrice() && Bid < OrderOpenPrice()-BePoints*Point)  ){
                  sl = OrderOpenPrice()-BePoint*Point;
               }
               if (sl != 0){
                  OrderModify(OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), 0);
               }
            }
        }
    } 
}


double LotsOptimized()
  {
   double lot=Lots;
   return(lot);
  }
  
  
 void modes(){

        double RD1 = Resistance(SRPeriod,SRbars);
        double SD1 = Support(SRPeriod,SRbars);
   
        EAmode=0;
        EARange=0;

        double rangeD1 = MathAbs((NormalizeDouble(((RD1 - SD1)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS))));;
        double avoidDistance = rangeD1 * D1percent / 100  ;//AVOID DISTANCE TO TRADE BASE ON PERCENATAGE
        tradableRange = rangeD1; //SHOW IN P
       
        forbitup = RD1 - avoidDistance*Point;
        forbitdown =SD1 + avoidDistance*Point;

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
        EAmode=2;
        }
        if(SuperTrend == 1){
        EAmode=1;
        }

   }
   
               


void CheckRanges(){
      tradeBuys=false;
      tradeSells=false;
      BreakEnabled =false;
      TrailEnabled =false;
      closingBuys=true;
      closingSells=true;
      tp=mintp;


  if(EAmode ==0){ 
     tradeBuys=true;
     tradeSells=true;
  
      if(EARange == 1){
        tradeSells=true;
        tradeBuys=false;
      

         }
      if(EARange == 2){
             tradeBuys=true;
             tradeSells=false;

          }
         
         } 
         
  if(EAmode ==1){
         tradeBuys=true;
       if(EARange == 1 || EARange == 2){
      //  BreakEnabled =true;
     //   TrailEnabled =true;
        tradeBuys=false;
        tradeSells=false;
         }
   
         if(sells >0){
         closeSellsNow(true);
         }
         
         } 
 if(EAmode ==2){
 
     tradeSells=true;
 
       if(EARange == 1 || EARange == 2){
           //    BreakEnabled =true;
           //    TrailEnabled =true;
               tradeBuys=false;
               tradeSells=false;
         }
   
         
        if(buys >0){
         closeBuyNow(true);
         }
         } 
}



void CheckForOpen(){
   int    res,res1,res4;
   CheckRanges();
   

if(EAmode == 0){


   if(buys > 1  ){
   closingBuys=false;
   if(sumbuy > tp/2){
   closeBuyNow(true);
   }
   }
   
    if(sells > 1  ){
    closingSells =false;
    if(sumsell > tp/2){
    closeSellsNow(true);
    }
   }


   if(downzag < lastbuystopopenprice-ModifyDistance*Point ){
      RefreshRates();
            for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() ) {  
           if(OrderType()==OP_BUYSTOP ) {
            bool res5=OrderModify(OrderTicket(),downzag+ModifySet*Point,Ask-minsl*Point,0,0,Blue);
    
           }
            }
           } 
}

  if(upzig > lastsellstopopenprice+ModifyDistance*Point ){
  
              for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() ) {  
           if(OrderType()==OP_SELLSTOP ) {
            bool res5=OrderModify(OrderTicket(),upzig-ModifySet*Point,Ask+minsl*Point,0,0,Red);
           }
            }
           }

   }
   
   

  if(tradeBuys == true){ 
     if(ZZ2 > 0.2  && buysstops < 1 && buys < 1 ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUYSTOP,LotsOptimized(),Ask + ModifyDistance*Point,10,Ask-minsl*Point,0,"",MAGICMA,0,Blue);
       eaMessage="Buy Order" ; 
      return;
     }
     
          if(ZZ2 > 0.2  && buysstops < 1 && buys < 2 && Ask < lastbuyopenprice - distance*Point ){
       RefreshRates();
      res1=OrderSend(Symbol(),OP_BUYSTOP,LotsOptimized()*2,Ask + ModifyDistance*Point,10,Ask-minsl*Point,0,"",MAGICMA,0,Blue);
       eaMessage="Buy Order" ; 
      return;
     }
     }    
     
     
 if(tradeSells == true ){   
     if( ZZ1 > 0.2 && sellsstops < 1  && sells < 1 )  {
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELLSTOP,LotsOptimized(),Bid - ModifyDistance *Point,10, Ask+minsl*Point ,0,"",MAGICMA,0,Red);
      return;
     }
     
     if( ZZ1 > 0.2 && sells < 2 && Ask > lastsellopenprice + distance*Point )  {
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELLSTOP,LotsOptimized()*2,Bid - ModifyDistance *Point,10, Ask+minsl*Point ,0,"",MAGICMA,0,Red);
      return;
     }
     }

}


if(EAmode == 1 || EAmode == 2 ){ 

   if(buys >= 1  ){
   closingBuys=false;

   }
   
    if(sells >= 1  ){
    closingSells =false;

   }

     if(  RSI <  RSIDnLevel  && buys < 1 && tradeBuys == true ){
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized()*1.1,Ask,10,Ask-minslTrend*Point,0,"",MAGICMA,0,White);
      return;
     }
     
          if(  RSI <  RSIDnLevel  && buys < 2 && tradeBuys == true && Ask < lastbuyopenprice - distance*Point ){
      res1=OrderSend(Symbol(),OP_BUY,LotsOptimized()*1.5,Ask,10,Ask-minslTrend*Point,0,"",MAGICMA,0,White);
      return;
     }
     

     if( RSI >  RSIUpLevel  && sells < 1 && tradeSells == true )  {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized()*1.1,Bid,10, Ask+minslTrend*Point ,0,"",MAGICMA,0,Yellow);
      return;
     }
     
          if( RSI >  RSIUpLevel  && sells < 2 && tradeSells == true && Ask > lastsellopenprice + distance*Point )  {
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized()*1.5,Bid,10, Ask+minslTrend*Point ,0,"",MAGICMA,0,Yellow);
      return;
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

        if(OrderType()==OP_SELL && closingSells == true ) {
         if( OrderProfit() > tp && Ask <= (Support(closeperiodsell,CloseSRbars)+SRsClosingDistance*Point) ){
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


void comments() { 
string modes;
string rangers;
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     double accequity =(AccountEquity()/AccountBalance()*100);
     double messageEa =StrToDouble(eaMessage);
    // Comment(StringFormat("\n\nTRADING=%G\RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\EQUITY=%G\Equitypercent=%G\nTAMEIO=%G\----TARGET-PROFIT=%G\nActiveTF=%G\--Lots=%G\Lots2=%G\nAligator=%G\AligatorBUY=%G\AligatorSELL=%G\nSOUPERTREND=%G\nMATrends=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nTrend-DIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nMODE1-TradeBUys=%G\TradeSells=%G\n\nNormalDST=%G\---TrendDST=%G\SR-Space=%G\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nH1-ADX=%G\nM5-ADX=%G",trading,range,digits,Bid,Ask,eqt,accequity,sumbasket,targetprofit,timeframe,Lots,Lots2,alligtrend,allitradeb,allitrades,supertrend,directionma,td5,tdd,tdd4,tdd3,td,wd,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,distanceSR,sells,buys,maxsells,maxbuys,adx,adxM5));
     Comment(StringFormat("\n\nADX->M15=%G---H1=%G---H4=%G---D1=%G\nFAST-Trends >0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G---W1=%G\nSmallTrend=%G-----LargeTrend=%G----SUPERTREND=%G\n\n--%GTRADES - SELLS=%G ----BUYS=%G------------BasketSells=%G-----BasketBuys=%G----TOTAL=%G---------FMARGIN=%G\nLAST SELL-SIGNAL=%G----LAST-BUYSIGNAL =%G\nTRADABLE RANGE =%G\nTRADESELLS=%G-----TRADEBUYS=%G----Distance%G\n--CloseSells=%G------CloseBuys=%G-----RSI=%G", adxM15,adxH1,adxH4,adxD1,td5,tdd4,tdd3,td,wd,smallTrend,LargeTrend,SuperTrend,totalTrades,sells,buys,sumsell,sumbuy,sumbasket,freeMargin,upzig,downzag,tradableRange,tradeSells,tradeBuys,distance,closingSells,closingBuys,RSI));
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
  
  int start() 
{
	// We must wait til we have enough of bar data before we call trading routine
	if (iBars(Symbol(),PERIOD_M1) > 3)
		sub_trade();
	else
		Print ("Please wait until enough of bar data has been gathered!");
	
	return (0);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |

//+------------------------------------------------------------------+
void sub_trade()
 
  {

  
  if(Volume[0]>1) return;  
 
     counttrades();
             if(showIndicators == true) {
           comments();
           DrawIndicators();
           DevStd();
           }
           if(EACloseOrdersSR == true){
           closeOrdersSRs();
         }
         if(BreakEnabled == true) {
         breakEvenStopLoss();
         }
         if(TrailEnabled == true){
         TrailNow();
      
         }
  Chk_ADX();
  CheckTrends();
  smallTrends();
  LargeTrends();
  SuperTrends();

  modes();
    
  zzz();
  CheckForOpen();
  

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
   double  current_ma1, current_ma2,sto;
   double  current_wa1, current_wa2, was1to;
   double  current_ma15, current_ma25, ma35sto;
   double  current_ma111, current_ma211,ma3sto;
   double  current_d1, current_d2, d3stoc;
   td=0;
   wd=0;
   td5=0;
   tdd4=0;
   tdd3=0;
   

   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,MaPeriodD1A,0,MODE_SMMA,PRICE_HIGH,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,MaPeriodD1A/2,0,MODE_SMMA,PRICE_CLOSE,0); 
   sto=iStochastic(NULL,PERIOD_W1,StockasticPeriod,3,3,MODE_SMA,0,MODE_MAIN,0);     

    if(current_ma2 > current_ma1 && sto > 50)  {
    td = 1;
    }
    if(current_ma2 < current_ma1 && sto < 50 )  {
    td = 2;
    }
    if ( (current_ma2>current_ma1 && sto<50) || (current_ma2<current_ma1 && sto>50) )
         {
         td=3;
         }
    
    //w1// 
   current_wa1 = iMA(NULL,PERIOD_W1,MaPeriodW1A,0,MODE_EMA,PRICE_HIGH,0);  
   current_wa2 = iMA(NULL,PERIOD_W1,MaPeriodW1A/2,0,MODE_SMA,PRICE_HIGH,0);  
   was1to = iStochastic(NULL,PERIOD_D1,StockasticPeriod,3,3,MODE_SMA,0,MODE_MAIN,0);    
    if(current_wa2 > current_wa1 && was1to > 50)  {
    wd = 1;
    }
      if(current_wa2 < current_wa1 && was1to < 50)  {
    wd = 2;
    }

   //M15 td5
   current_ma15 = iMA(NULL,PERIOD_M15,MaPeriodM15A,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,MaPeriodM15A/2,0,MODE_SMA,PRICE_MEDIAN,0);  
   ma35sto = iStochastic(NULL,PERIOD_H1,StockasticPeriod,3,3,MODE_SMA,0,MODE_MAIN,0);  
    if(current_ma25 > current_ma15 && ma35sto >50)  {
    td5 = 1;
    }
     if(current_ma25 < current_ma15 && ma35sto < 50)  {
    td5 = 2;
    }
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,MaPeriodH1A,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_H1,MaPeriodH1A/2,0,MODE_SMA,PRICE_MEDIAN,0);  
   d3stoc =  iStochastic(NULL,PERIOD_H4,StockasticPeriod,3,3,MODE_SMA,0,MODE_MAIN,0);  
   if(current_d2 > current_d1 && d3stoc > 50)  {
    tdd4 = 1;
   }
   if(current_d2 < current_d1 && d3stoc < 50 )  {
    tdd4 = 2;
   }
    //H4///
   current_ma111 = iMA(NULL,PERIOD_H4,MaPeriodH4A,0,MODE_SMMA,PRICE_HIGH,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,MaPeriodH4A/2,0,MODE_SMMA,PRICE_HIGH,0);  
   ma3sto = iStochastic(NULL,PERIOD_D1,StockasticPeriod,3,3,MODE_SMA,0,MODE_MAIN,0);    
  if(current_ma211 > current_ma111 && ma3sto > 50)  {
    tdd3 = 1;
    }
  if(current_ma211 < current_ma111 && ma3sto < 50)  {
    tdd3 = 2;
    }
    
  return(td5);  //M15
  return(tdd4); //H1
  return(tdd3); //H4
  return(td);   //D1
  return(wd);   //M5
  
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
       sumsell=0;
       sumbuy=0;
       
       
       sells=0;
       buys=0;
       sellsstops=0;
       buysstops=0;
       totalTrades =0;
       lastbuyopenprice=0;
       lastsellopenprice=0;
              lastbuystopopenprice=0;
       lastsellstopopenprice=0;
       
  
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
            
            if(OrderType()==OP_BUYSTOP ) {
            buysstops++;
               lastbuystopopenprice=OrderOpenPrice();
            
            }
            if(OrderType()==OP_SELL   ){
            sum_profitss += OrderProfit()+OrderSwap()+OrderCommission();
            lastsellopenprice=OrderOpenPrice();
            sells++;
            }
            
            if(OrderType()==OP_SELLSTOP   ){
             lastsellstopopenprice=OrderOpenPrice();

            sellsstops++;
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
                     return sellsstops;
           return buysstops;            
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
           
             int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;

    if(OrderSymbol()==Symbol() && closingSellsNow == true )
    {
      switch(type)
      {    
         //Close opened short positions
         case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                         //    break;

         //Close pending orders
         case OP_SELLLIMIT :
         case OP_SELLSTOP  : result = OrderDelete( OrderTicket() );
      }
    
      if(result == false)
      {
         Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
         Sleep(3000);
      } 
    } 
  }
  

           
           
           
  }
  
  void closeBuyNow(bool closingBuysNow){

  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
      if(OrderSymbol()==Symbol() && closingBuysNow == true )
    {
      switch(type)
      {
         //Close opened long positions
         case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          //   break;

         //Close pending orders
         case OP_BUYLIMIT  :
         case OP_BUYSTOP   : result = OrderDelete( OrderTicket() );
      }
    
      if(result == false)
      {
         Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
         Sleep(3000);
      }  
    }
  }

  }
  
  

     


//+------------------------------------------------------------------+

void DevStd(){
 //int itH1 =iCustom(NULL,PERIOD_CURRENT,"CCI",0,0);
 double itH2 =iCustom(NULL,stdevperiod,"istddev",0,0);
// int val=iForce(NULL,0,13,MODE_SMA,PRICE_CLOSE,0);
 
}

int smallTrends(){
smallTrend=0;
 
if(   td5 == 1 && tdd4 ==1   && adxH1 >30){
smallTrend = 1;
}

if(  td5 == 2 && tdd4 == 2  && adxH1 > 30 ){
smallTrend = 2;
}

return smallTrend;

}

  
  
int LargeTrends(){
LargeTrend=0;
if( td == 1 &&   tdd3 == 1   ){
LargeTrend = 1;
}

if( td == 2  && tdd3 == 2   ){
LargeTrend = 2;
}
return LargeTrend;
}


int SuperTrends(){
SuperTrend=0;
if(   td == 1 && tdd3 ==1 && adxH4 > 40 && adxD1 >40 &&  td5 == 1 && tdd4 ==1  && adxH1 >35){
SuperTrend = 1;
}

if(  td == 2 && tdd3 == 2 && adxH4 > 40 && adxD1 >40 &&  td5 == 2 && tdd4 == 2 && adxH1 >35  ){
SuperTrend = 2;
}
return SuperTrend;
}

    
int zzz(){
   ZZ1 =0;
   ZZ2= 0;
   RSI=0;
   
    RSI=iRSI(NULL,PERIOD_CURRENT,14,PRICE_CLOSE,0); //UP

    ZZ1=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",PeriodZ,5,1); //UP
    ZZ2=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",PeriodZ,4,1); // DOWN 
     
   
          if(ZZ1 > 0.2){
  
       upzig=ZZ1;
   
        }
       if(ZZ2 > 0.2){
         downzag = ZZ2;
        }
        
        
        return ZZ1;
        return ZZ2;


    }
    
    

     

    
    
    
void TrailNow()
  {
     for(int i=0; i<OrdersTotal(); i++) 
     {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
        {
           if (AllPositions || OrderSymbol()==Symbol()) 
           {
            TrailingPositions();
           }
        }
     }
  }
   

  void TrailingPositions() 
  {
   double pBid, pAsk, pp;
//----
   pp=MarketInfo(OrderSymbol(), MODE_POINT);
     if (OrderType()==OP_BUY) 
     {
      pBid=MarketInfo(OrderSymbol(), MODE_BID);
        if (!ProfitTrailing || (pBid-OrderOpenPrice())>TrailingStop*pp) 
        {
           if (OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp) 
           {
            ModifyStopLoss(pBid-TrailingStop*pp);
            return;
           }
        }
     }
     if (OrderType()==OP_SELL) 
     {
      pAsk=MarketInfo(OrderSymbol(), MODE_ASK);
        if (!ProfitTrailing || OrderOpenPrice()-pAsk>TrailingStop*pp) 
        {
           if (OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0) 
           {
            ModifyStopLoss(pAsk+TrailingStop*pp);
            return;
           }
        }
     }
  }
  void ModifyStopLoss(double ldStopLoss) 
  {
   bool fm;
   fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
   if (fm && UseSound) PlaySound(NameFileSound);
  }
//+------------------------------------------------------------------+