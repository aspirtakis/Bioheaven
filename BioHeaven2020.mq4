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

extern int MAGICMA = 11;
extern int startLot=0.10;
extern int maxTrades = 3;


double adxM15,adxH1,adxH4,adxD1; //ADXs 
double td5 ,tdd4 ,tdd3,td,wd;  //M15/H1/H4/D1/W1//TRENDs Based on MAs 
double ItrendM15, ItrendM30,ItrendH1,ItrendH4,ItrendH42 ,ItrendD1,ItrendW1; // Based on Itrend
int SRbars =300;
double sells,buys,totalTrades,sumsell,sumbuy,sumbasket;
double freeMargin = AccountFreeMargin();
int directionma ,directionI; // TREND DIRECTION SUMMURY 
double downzag,upzig,zigzagrange,zzupFibo23,zzdownFibo23;

double tradableRange,fibboTrend ;
double FibRetrace382, FibRetrace50, FibRetrace618,FibExtend1382, FibExtend618; //RETRACE FIBBOS BASED ON RANGE 












///CACLULATE ETNTRIES WITH ZIGZAG
void Zags()
      {  
       int n, i;
         i=0;
         while(n<2)
      {
    if(upzig>0) downzag=upzig;
    upzig=iCustom(NULL,PERIOD_CURRENT,"BioZagFibbo", 0, i);
     if(upzig>0) n+=1;
     i++;
   } 
   zigzagrange= MathAbs((NormalizeDouble(((upzig - downzag)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS)))/1);;
         
           zzupFibo23 =( DoubleToString( getFiboLevel( upzig, downzag, 23.6, 1 ) ) );
           zzdownFibo23=( DoubleToString( getFiboLevel( upzig, downzag, 23.6, -1 ) ) );    
      
   }
   
   
   
   //CALCULATE FIBOS 
   double getFiboLevel( double up, double dw, double lev, int direction ){
   double ling = up - dw;
   double pLev = ( ling / 100 ) * lev;
   return ( direction < 0 ) ? NormalizeDouble( up - pLev, Digits ) : NormalizeDouble( dw + pLev, Digits ) ;

}


   void Fibbos()//RETRACE FIBOS FROM INDICATOR
      {  
      
    double FibHigh=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 0, 0);
    double FibLow=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 1, 0);
    double FibTrend=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 2, 0);
    double FibRetrace382=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 3, 0);
    double FibRetrace50=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 4, 0);
    double FibRetrace618=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 5, 0);
    double FibExtend1382=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 6, 0);
    double FibExtend618=iCustom(NULL,PERIOD_CURRENT,"IH_Fibo", 7, 0);
    
    double DiffPips = MathAbs((NormalizeDouble(((FibHigh - FibLow)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS)))/1);
          tradableRange = DiffPips;  
          fibboTrend=FibTrend;            
    }

     

int TrendConclusion()
{
  directionma =0 ;

   if(td ==1 && tdd4 ==1 && tdd3 == 1 ){
   directionma = 1;
   }
   if( td ==2 && tdd4 ==2 && tdd3 ==2 ){
   directionma = 2;
   }
   return directionma;
}

void ITrendConclusion()
{
  directionI =0;

   if(ItrendW1 > 2 && ItrendD1 > 5 && ItrendH4 > 6 && ItrendH1 > 7  && ItrendM15 >15)
  {
   directionI = 1;
  }
   if( ItrendW1 < 2 && ItrendD1 < -5 && ItrendH4 < -6 && ItrendH1 < -7  && ItrendM15 < -15 )
  {
   directionI = 2;
  }
}




void comments() // ON SCREEN PRINTS 
   {
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     double accequity =(AccountEquity()/AccountBalance()*100);
    // Comment(StringFormat("\n\nTRADING=%G\RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\EQUITY=%G\Equitypercent=%G\nTAMEIO=%G\----TARGET-PROFIT=%G\nActiveTF=%G\--Lots=%G\Lots2=%G\nAligator=%G\AligatorBUY=%G\AligatorSELL=%G\nSOUPERTREND=%G\nMATrends=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nTrend-DIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nMODE1-TradeBUys=%G\TradeSells=%G\n\nNormalDST=%G\---TrendDST=%G\SR-Space=%G\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nH1-ADX=%G\nM5-ADX=%G",trading,range,digits,Bid,Ask,eqt,accequity,sumbasket,targetprofit,timeframe,Lots,Lots2,alligtrend,allitradeb,allitrades,supertrend,directionma,td5,tdd,tdd4,tdd3,td,wd,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,distanceSR,sells,buys,maxsells,maxbuys,adx,adxM5));
     Comment(StringFormat("\n\nADX->M15=%G---H1=%G---H4=%G---D1=%G\nTRENDS >0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G---W1=%G------TrendDirection=%G\nI-Trends > 0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G---W1=%G------TrendDirection=%G\nFIBOTREND=%G\n\n%G--TRADES - SELLS=%G ----BUYS=%G------------BasketSells=%G-----BasketBuys=%G----TOTAL=%G---------FMARGIN=%G\nLAST LOW ENTRIE=%G----LAST HIGH ENTRIE=%G---ZIGZAG-RANGE=%G\nTRADABLE RANGE =%G",adxM15,adxH1,adxH4,adxD1,td5,tdd4,tdd3,td,wd,directionma,ItrendM15,ItrendH1,ItrendH4,ItrendD1,ItrendW1,directionI,fibboTrend,totalTrades,sells,buys,sumsell,sumbuy,sumbasket,freeMargin,upzig,downzag,zigzagrange,tradableRange));
   }


int OnInit()
  {
//--- Initializing Indicator TRAPEZIA
indicator();
counttrades();
   
//---
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
  Chk_ADX();
  CheckTrends();
  comments();
  DrawIndicators();
  counttrades();
  TrendConclusion();
  iTrend();
  Zags();
  Fibbos();
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
//---
   
  }
//+------------------------------------------------------------------+


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


double Resistance(double timeframe)
{
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

int CheckTrends()
   {
   
   double  current_ma1, current_ma2, current_ma3;
   double  current_wa1, current_wa2, current_wa3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;

   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,50,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,25,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,10,0,MODE_SMA,PRICE_CLOSE,0);
    if(current_ma3 > current_ma2 && current_ma2 > current_ma1)  {
    td = 1;
    }
    if(current_ma3 < current_ma2 && current_ma2 < current_ma1)  {
    td = 2;
    }
    
    
         
    //w1// wd
   current_wa1 = iMA(NULL,PERIOD_W1,25,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_wa2 = iMA(NULL,PERIOD_W1,10,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_wa3 = iMA(NULL,PERIOD_W1,2,0,MODE_SMA,PRICE_MEDIAN,0);
    if(current_wa3 > current_wa2 && current_wa2 > current_wa1)  {
    wd = 1;
    }
    if(current_wa3 < current_wa2 && current_wa2 < current_wa1)  {
    wd = 2;
    }
    
    
   
   //M15 td5
   current_ma15 = iMA(NULL,PERIOD_M15,300,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,150,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,80,0,MODE_SMA,PRICE_CLOSE,0);
    if(current_ma35 > current_ma25 && current_ma25 > current_ma15)  {
    td5 = 1;
    }
    if(current_ma35 < current_ma25 && current_ma25 < current_ma15) {
    td5 = 2;
     }
     
     
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,200,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_H1,100,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,PERIOD_H1,50,0,MODE_EMA,PRICE_MEDIAN,0);
   if(current_d3 > current_d2 && current_d2 > current_d1)  {
    tdd4 = 1;
   }
   if(current_d3 < current_d2 && current_d2 < current_d1)  {
    tdd4 = 2;
   }
    
    
    //H4///
   current_ma111 = iMA(NULL,PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,70,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma311 = iMA(NULL,PERIOD_H4,30,0,MODE_SMA,PRICE_CLOSE,0);
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
  return(wd);   //W1
  
}

int indicator()
  {
//----
    ObjectCreate("SupportH1",OBJ_HLINE,0,0,0);
    ObjectSet("SupportH1",OBJPROP_COLOR,Pink);
    ObjectCreate("ResistanceH1",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceH1",OBJPROP_COLOR,Pink);
    ObjectCreate("SupportH4",OBJ_HLINE,0,0,0);
    ObjectSet("SupportH4",OBJPROP_COLOR,Yellow);
    ObjectCreate("ResistanceH4",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceH4",OBJPROP_COLOR,Yellow);
    ObjectCreate("SupportD1",OBJ_HLINE,0,0,0);
    ObjectSet("SupportD1",OBJPROP_COLOR,Red);
    ObjectCreate("ResistanceD1",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceD1",OBJPROP_COLOR,Red);
   return(0);
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
       double lastbuyopenprice=0;
       double lastsellopenprice=0;
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
    
      void Chk_ADX()
{
 adxM15=iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MAIN, 0);
 adxH1=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
 adxH4=iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 0);
 adxD1=iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN, 0);
 
}



void DrawIndicators()
{
RefreshRates();

  ObjectSet("SupportH1",OBJPROP_PRICE1,Support(PERIOD_H1));
  ObjectSet("ResistanceH1",OBJPROP_PRICE1,Resistance(PERIOD_H1));
  ObjectSet("SupportD1",OBJPROP_PRICE1,Support(PERIOD_D1));
  ObjectSet("ResistanceD1",OBJPROP_PRICE1,Resistance(PERIOD_D1));
     
}

 void iTrend()
   {
  RefreshRates();
  directionI =0;
  double itM15,itM151,itH1,itH11,itH4,itH41,i,itD1,itD11,itW1,itW11;
  
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

