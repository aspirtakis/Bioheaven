//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extern int MAGICMA = 993010;
extern bool trading = true;
extern double Lots =0.01;
extern double maxorders = 4;
extern double startDistance=500;
extern bool checkWekly = false;
extern bool MaTrends = true;
extern bool ItrendTrends =true;
extern double refact = 2000;
extern bool tradesides = true;
extern bool tradetrends = true;
extern bool BreakOn =true;

 int breakevenS = startDistance/2; //POSO NA PAREi
int breakevengainS =startDistance; ///POTE NA MPEI 

double distance  ;

double refactor;

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

 double distancebuysos ;
 double distancesellsos ;
 
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
double timeframe = 0;

double MyTrend;
double ItrendM15, ItrendM30,ItrendH1, ItrendH4,ItrendH42  ,ItrendD1;
 double  directionma ,directionI ;


 void OnTick()
  { 
       RefreshRates();
   if(Bars<100 || IsTradeAllowed()==false) return;
    adx=iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 0);

     counttrades();
     CheckTrends();
     itrend();
     fixdirections();
     ProfitAdx();
     fixDirection();

     Modes(); 
     modesfixs();
     zigzag();
   //  zigzagM();
    weeklysCheck();
     Lots2=Lots*2;
     CheckForOpen();
     comments();    
  }



void zigzag()
      {  
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
    upzigM=iCustom(NULL,PERIOD_D1, "ZigZag", 0, i);
     if(upzigM>0) n+=1;
     i++;
   } 
 //  Print(upzigM ,"---",downzagM);
   }
   
 void weeklysCheck()//CHECKING WEEKLY ZIG ZAG AND STOPS TRADING 
   {
   if(checkWekly == true)
   {
     trading =true;
     range = (upzigM - downzagM)/Point;

    if((buys >=3 || sells >=3 ) && mode == 1)
    {
     if(Ask > upzigM-(distance*Point))
     {    trading =false;
     }
     if(Bid < downzagM+(distance*Point))
     {    trading =false;
     }
    }
     if((buys >=6 || sells >=6 ) && mode == 1)
    {
     if(Ask > upzigM-((distance*2)*Point))
     {    trading =false;
     }
     if(Bid < downzagM+((distance*2)*Point))
     {    trading =false;
     }
    }
    }
   }

void modesfixs()
   {
   timeframe = 0;
   if (mode == 1){
     timeframe = 15;
     maxbuys = maxorders*2;
     maxsells=maxorders*2;
     distancebuysos = startDistance/2;
     distancesellsos=startDistance/2;
   tradesells=false;
   tradebuys = false;
   
   if(direction ==2)
   {
   tradebuys = false;
   tradesells=true;
   }
   if(direction ==1)
   {
   tradebuys = true;
   tradesells=false;
   } 
}

  
if (mode == 0){
   timeframe = 0;
   BreakEnabled=false;
      tradesells=true;
      tradebuys = true;
      maxbuys = maxorders/2;
      maxsells=maxorders/2;         
}
}


void ProfitAdx()
   {
   refactor = refact;
   timeframe = 0;
   if(adx > 40 ){
   refactor = refact*2;
    timeframe = 60;
   }
   if(adx > 26 || adx <= 39 ){
   refactor = refact;
   timeframe =30;
   }
   if(adx < 25)
   {
   refactor = refact/4; 
   timeframe =15;
    }
   targetprofit = Lots*refactor;
}

  void Modes(){
  mode = 0 ;
  if(direction > 0 )
  {
  mode = 1;
  } 
  }
  
   
  void CheckForOpen()
  {
  if(trading == true){
  breakeven =  breakevenS; //POSO NA PAREi
  breakevengain =  breakevengainS ; ///POTE NA MPEI 
  
     distance=startDistance;
     distancebuy  = (lastbuyopenprice-distance*Point);
     distancesell =  (lastsellopenprice+distance*Point);
     distancebuyp  = (lastbuyopenprice+distancebuysos*Point);
     distancesellp =  (lastsellopenprice-distancesellsos*Point);
  
   if(Volume[0]>1) return;
   int    res;
   CloseOrders();
   
     ////////////////////////MODE 0 PLAGIO ///////////////
  if(mode == 0 && tradesides == true){ 
      BreakEnabled=false;
     ////---- sell conditions
     if( buys < maxbuys && upzig > downzag && buys == 0 )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-0-1B",MAGICMA,0,Blue);
     return;
     }
       if( buys < maxbuys && upzig > downzag && buys == 1 && Ask < distancebuy )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-0-2B",MAGICMA,0,Blue);
     return;
     }
          if( buys < maxbuys && upzig > downzag && buys >= 2 && Ask < distancebuy )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"MODE-0-2B",MAGICMA,0,Blue);
     return;
     }
     
   
     if( sells < maxsells && upzig < downzag && sells == 0) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-1S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  && upzig < downzag && sells ==1  && Bid > distancesell) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-2S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  && upzig < downzag && sells >=2  && Bid > distancesell) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"MODE-0-2S",MAGICMA,0,Red);
     return;
     }
     
     }
////////////////////////MODE 0  -TREND FOLLOW 
    if(mode == 1 && tradetrends == true){ 
    breaks();

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

  if(mode == 1 && tradetrends == true){ 
    breakeven =  breakevenS; //POSO NA PAREi
    breakevengain =  breakevengainS ; ///POTE NA MPEI 
  
     if((buys >= 3 || sells >=3 ) && sumbasket >0){
     BreakEnabled=true;
     Breakeven();
     maxbuys = maxorders*2;
     maxsells=maxorders*2;
     }
     if((buys >= 6 || sells >=6 ) && accequity > 120 ){
     BreakEnabled=true;
     breakeven = 800; //POSO NA PAREi
     breakevengain =1000; ///POTE NA MPEI 
     Breakeven();
     breakeven = 50; //POSO NA PAREi
     breakevengain =100; ///POTE NA MPEI 
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
      }
      
   if(mode ==1 )
      {
   if(accequity >= 300)
                      {
    // closebasket = true ;
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
     Comment(StringFormat("TrADING=%G\RANGE=%G\DIGITS=%G\BID=%G\ASK=%G\ZAGTF=%G\n\nI-TREND=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\nMATRENDS=%G\nMAs--M15=%G\M30=%G\H1=%G\H4=%G\D1=%G\nDIRECTION-=%G\nMODE=%G\n\nNextBUy=%G\NextSell=%G\nTradeBUys=%G\TradeSells=%G\Distance=%G\n\nBASKET=%G\->TARGETBASKET=%G\n\n\n\n\n\n\n\n\n\n\nSELLS=%G\BUS=%G\nMAXSELLS=%G\MAXBUS=%G\nEQUITY=%G\nEquitypercent=%G\nADX=%G",trading,range,digits,Bid,Ask,timeframe,directionI,ItrendM15,ItrendM30,ItrendH1,ItrendH4,ItrendD1,directionma,td5,tdd,tdd4,tdd3,td,direction,mode,distancebuy,distancesell,tradebuys,tradesells,distance,sumbasket,targetprofit,sells,buys,maxsells,maxbuys,eqt,accequity,adx));
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


 void atr()
 {
  double mak =   iSAR(NULL,0,0.02,0.2,0);
  double nik =   iSAR(NULL,0,0.02,0.2,0);
  Print (mak,"---/",nik);
  
  }
 
 
