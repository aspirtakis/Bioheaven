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
double adxM15,adxH1,adxH4,adxD1; //ADXs 
double wd,td5,td ,tdd , tdd3,tdd4;  //TRENDs
int SRbars =56;
double sells,buys,totalTrades,sumsell,sumbuy,sumbasket;
extern int MAGICMA = 11;
  
  








void comments() // ON SCREEN PRINTS 
   {
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     double accequity =(AccountEquity()/AccountBalance()*100);
    // Comment(StringFormat("\n\nTRADING=%G\RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\EQUITY=%G\Equitypercent=%G\nTAMEIO=%G\----TARGET-PROFIT=%G\nActiveTF=%G\--Lots=%G\Lots2=%G\nAligator=%G\AligatorBUY=%G\AligatorSELL=%G\nSOUPERTREND=%G\nMATrends=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nTrend-DIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nMODE1-TradeBUys=%G\TradeSells=%G\n\nNormalDST=%G\---TrendDST=%G\SR-Space=%G\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nH1-ADX=%G\nM5-ADX=%G",trading,range,digits,Bid,Ask,eqt,accequity,sumbasket,targetprofit,timeframe,Lots,Lots2,alligtrend,allitradeb,allitrades,supertrend,directionma,td5,tdd,tdd4,tdd3,td,wd,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,trenddistance,distanceSR,sells,buys,maxsells,maxbuys,adx,adxM5));
    Comment(StringFormat("\n\nADX->M15=%G---H1=%G---H4=%G---D1=%G\nTRENDS >0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G---W1=%G\n%G--TRADES - SELLS=%G ----BUYS=%G------------BasketSells=%G-----BasketBuys=%G----TOTAL=%G",adxM15,adxH1,adxH4,adxD1,td5,tdd4,tdd3,td,wd,totalTrades,sells,buys,sumsell,sumbuy,sumbasket));
   
   
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
   double  current_ma11, current_ma21, current_ma31 ;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
   
   //M15 TDd
   current_ma15 = iMA(NULL,PERIOD_M15,300,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,150,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,80,0,MODE_SMA,PRICE_CLOSE,0);
   
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
    
  return(td5);  //M15
  return(tdd);  //M30
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
