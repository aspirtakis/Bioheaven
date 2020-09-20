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
input double startLot= 0.10;
extern int maxTrades = 3;


 int Break_Even_After_X_Pips = 10;
 bool useMagicNumber = true;

input bool closing = true;
     bool closingSells=true;
     bool closingBuys=true; 
        int tp = 10;
extern bool trading = true;
extern int mode = 0;
extern bool tradesides =true;
extern bool tradetrends =true;
bool tradeSells =true;
bool tradeBuys = true;

double maxbuys = 3;
double  maxsells= 3;
double Lots = startLot;
int distance = 1000; // DISTANCE BETWWEN TRADES
int D1percent = 40 ;//Percent to avoid Trades from D1 SRs

 double Period1=5; 
 double Period2=13; 
 double Period3=34; 
 string Dev_Step_1="1,3";
 string Dev_Step_2="8,5";
 string Dev_Step_3="13,8";
 int Symbol_1_Kod=140;
 int Symbol_2_Kod=141;
 int Symbol_3_Kod=142;


double adxM15,adxH1,adxH4,adxD1; //ADXs 
double td5 ,tdd4 ,tdd3,td,wd;  //M15/H1/H4/D1/W1//TRENDs Based on MAs 
double ItrendM15, ItrendM30,ItrendH1,ItrendH4,ItrendH42 ,ItrendD1,ItrendW1; // Based on Itrend
int SRbars =150;
double sells,buys,totalTrades,sumsell,sumbuy,sumbasket,lastsellopenprice,lastbuyopenprice;

double freeMargin = AccountFreeMargin();
int directionma ,directionI; // TREND DIRECTION SUMMURY 
double downzag,upzig,zigzagrange,zzupFibo23,zzdownFibo23;

double tradableRange,fibboTrend ;
double FibHigh,FibLow,FibRetrace382, FibRetrace50, FibRetrace618,FibExtend1382, FibExtend618; //RETRACE FIBBOS BASED ON RANGE 
double upfib,downfib;//FIBOS 
double RD1,SD1;
double periodbuy,periodsell; //CLOSING PERIOD BASED ON SR
bool closingSellsNow =false ;
bool closingBuysNow = false;
double periodZemafor = PERIOD_CURRENT;




/// TODO -
double LotsOptimized()
  {
   double lot=Lots;

   return(lot);
  }
  
  
 void distancesfromD1(){
 
 /// WE CALCULATE THE RANGE ON D1 THAN WE MAKE A RANGE BASED ON PERCENTAGE INPUT 
 /// WE AVOID DIRECTIONAL TRADES WEN THE PRICE IS ON THE RANGE 
 
        tradeSells = true;
        tradeBuys =true;
        closingSells=true;
        closingBuys=true;
        closingSellsNow=false;
        closingBuysNow=false;
        periodsell=PERIOD_CURRENT; //CLOSING
        periodbuy=PERIOD_CURRENT;//CLSOSING
        periodZemafor =PERIOD_CURRENT;
        
        
         RD1 = Resistance(PERIOD_D1);
         SD1 = Support(PERIOD_D1);
 
        double rangeD1 = MathAbs((NormalizeDouble(((RD1 - SD1)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS))));;
        double avoidDistance = rangeD1 * D1percent / 100  ;
        
       if(directionma ==0){
//PLAGIO

           distance = rangeD1 / 3;
            
         if(Ask >= (RD1 - avoidDistance*Point) ){
         tradeSells = true;
         closingSells=false;
         tradeBuys =false;
         closingBuys=true;
         periodbuy=PERIOD_M1;
         periodsell=PERIOD_H4;
         distance = rangeD1 / 6;
     
        }
        if(Bid <= (SD1 + avoidDistance*Point) ){
        tradeSells = false;
        closingSells=true;
        tradeBuys =true;
       closingBuys=false;
        periodsell=PERIOD_M1;
        periodbuy=PERIOD_H4;
        distance = rangeD1 / 6;
        }
        
     
  
     } 
  
     if(directionma == 2){
         tradeSells = true;
         closingSells=false;
         tradeBuys =false;
         closingBuysNow=true;
         periodsell=PERIOD_H1;
         periodbuy=PERIOD_M1;
         distance=1000;
         periodZemafor=PERIOD_M15;
   
   
  } 
  if(directionma == 1){
         tradeSells = false;
         closingSellsNow=true;
         closingSells=true;
         tradeBuys =true;
         closingBuys=false;
         periodbuy=PERIOD_H1;
         periodsell=PERIOD_M1;
         distance=1000;
         periodZemafor=PERIOD_M15;
  
  }
        

            
  }
  





void CheckForOpen(){
   double ZZ1 =0;
   double ZZ2= 0;
  // double ZZ1,ZZ2;

   int    res,res1;
         closeOrdersNow();
         
         if(sumbuy > 30 && buys == 1 ){
        AdjustStopLoss();
         
         }
        if( sumsell > 30 && sells == 1 ){
        AdjustStopLoss();
         
         }
         
 
         if(sumbasket > 2 && buys > 1 && sells > 1)
         {
          closingBuysNow =true;
          closingSellsNow = true;
         
         }



//---- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
      distancesfromD1();
   
      //  Print("LAStSELL"+(lastsellopenprice+distance*Point) );
      //  Print("LAStBUY"+(lastbuyopenprice-distance*Point));

 

//---- get 3 Level ZZ Semafor
   
   ZZ1=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,5,1); //UP
   ZZ2=iCustom(Symbol(),periodZemafor,"3_Level_ZZ_Semafor",Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,4,1); // DOWN 

  //     if(ZZ1 > 0.2){
   //     upzig = ZZ1;
  //      }
 //        if(ZZ2 > 0.2){
  //       downzag = ZZ2;
  //      }
  // zigzagrange= MathAbs((NormalizeDouble(((upzig - downzag)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS)))/1);;
       

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
         
 if(tradeSells == true){     
//---- sell conditions
     if( ZZ1 > 0.2 && sells < 1  )  {
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Ask,10,0,0,"",MAGICMA,0,Red);
      return;
     }
     if( ZZ1 > 0.2  && sells == 1 && Bid >= (lastsellopenprice + distance*Point)  ){
       RefreshRates();
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Ask,10,0,0,"SELL2",MAGICMA,0,Red);
      return;
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

void closeOrdersNow(){

RefreshRates();

            for(int i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol() ) {
            
            if(OrderType()==OP_BUY && closingBuysNow == true ) {           
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
            
            }
           if(OrderType()==OP_SELL && closingSellsNow == true ) 
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
            
            }
            
           } 
           
  }

   
   
   


int TrendConclusion()
      {
        directionma =0 ;
      
         if(td5 ==1 && tdd4 ==1 && tdd3 == 1  ){
         directionma = 1;
         }
         if( td5 ==2 && tdd4 ==2 && tdd3 ==2 ){
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
     Comment(StringFormat("\n\nADX->M15=%G---H1=%G---H4=%G---D1=%G\nTRENDS >0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G---W1=%G------TrendDirection=%G\nI-Trends > 0=SIDE 1=UP 2=DOWN----->-M15=%G---H1=%G---H4=%G---D1=%G---W1=%G------TrendDirection=%G\nFIBOTREND=%G\n\n%G--TRADES - SELLS=%G ----BUYS=%G------------BasketSells=%G-----BasketBuys=%G----TOTAL=%G---------FMARGIN=%G\nLAST LOW ENTRIE=%G----LAST HIGH ENTRIE=%G---ZIGZAG-RANGE=%G\nTRADABLE RANGE =%G\nTRADESELLS=%G-----TRADEBUYS=%G----Distance%G",adxM15,adxH1,adxH4,adxD1,td5,tdd4,tdd3,td,wd,directionma,ItrendM15,ItrendH1,ItrendH4,ItrendD1,ItrendW1,directionI,fibboTrend,totalTrades,sells,buys,sumsell,sumbuy,sumbasket,freeMargin,upzig,downzag,zigzagrange,tradableRange,tradeSells,tradeBuys,distance));
   }


int OnInit()
  {
//indicator();
counttrades();
   if(Digits == 5)
   {
      Break_Even_After_X_Pips = Break_Even_After_X_Pips * 10;
   }

  
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
  //Chk_ADX();
  CheckTrends();
 // iTrend();
  TrendConclusion();
 
  comments();
 // DrawIndicators();

    
  counttrades();
  CheckForOpen();
  closeOrders();
  
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
    ObjectCreate("SupportM15",OBJ_HLINE,0,0,0);
    ObjectSet("SupportM15",OBJPROP_COLOR,Blue);
    ObjectCreate("ResistanceM15",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceM15",OBJPROP_COLOR,Blue);
    
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
    
    ObjectCreate("SupportW1",OBJ_HLINE,0,0,0);
    ObjectSet("SupportW1",OBJPROP_COLOR,Orange);
    ObjectCreate("ResistanceW1",OBJ_HLINE,0,0,0);
    ObjectSet("ResistanceW1",OBJPROP_COLOR,Orange);
    

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
    adxH1=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
    adxH4=iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 0);
    adxD1=iADX(NULL, PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN, 0);
 
}




void DrawIndicators()
{
RefreshRates();

  ObjectSet("SupportM15",OBJPROP_PRICE1,Support(PERIOD_M15));
  ObjectSet("ResistanceM15",OBJPROP_PRICE1,Resistance(PERIOD_M15));

  ObjectSet("SupportH1",OBJPROP_PRICE1,Support(PERIOD_H1));
  ObjectSet("ResistanceH1",OBJPROP_PRICE1,Resistance(PERIOD_H1));
  
  ObjectSet("SupportD1",OBJPROP_PRICE1,Support(PERIOD_D1));
  ObjectSet("ResistanceD1",OBJPROP_PRICE1,Resistance(PERIOD_D1));
  
     
}

 void iTrend()
   {
  directionI =0;
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

   
/// CLOSING ALL BUYS 
// GET FIBOS WITH DIRECTIOS BASED ON 2 PARAMETERS
   double getFiboLevel( double up, double dw, double lev, int direction ){
         double ling = up - dw;
         double pLev = ( ling / 100 ) * lev;
         return ( direction < 0 ) ? NormalizeDouble( up - pLev, Digits ) : NormalizeDouble( dw + pLev, Digits ) ;

}



void AdjustStopLoss()
{
double traillockbuy ,traillocksell;



traillocksell= Ask + 100*Point;
traillockbuy= Bid - 100*Point;

Print(traillockbuy);
Print(traillocksell);

   for(int cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(useMagicNumber == true)
      {
         if (OrderMagicNumber()==MAGICMA && OrderStopLoss() != OrderOpenPrice())
         {
           
            
                if(OrderType()==OP_SELL && OrderProfit() >  5){
                  OrderModify(OrderTicket(),OrderOpenPrice(),traillocksell,OrderTakeProfit(),0,Red);
               }
               if(OrderType()==OP_BUY && OrderProfit() >  5){
                  OrderModify(OrderTicket(),OrderOpenPrice(),traillockbuy,OrderTakeProfit(),0,Blue);
               }  
                   
         
      }
      }
      else if(useMagicNumber == false)
      {
         if(OrderStopLoss() != OrderOpenPrice())
         {         
            if(( OrderProfit() - OrderCommission() ) / OrderLots() / MarketInfo( OrderSymbol(), MODE_TICKVALUE ) >= Break_Even_After_X_Pips)
            {
               if(OrderType()==OP_SELL){
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),traillocksell,0,Red);
               }
               if(OrderType()==OP_BUY){
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),traillockbuy,0,Blue);
               }  
            }                       
         }
      }
   }
}