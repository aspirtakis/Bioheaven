//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define  NL "\n"
extern int MAGICMA = 993010;
extern double maxorders = 5;
double maxsells = maxorders;
double maxbuys = maxorders;

  int message;


double sells ,buys,lastsellopenprice,lastbuyopenprice,sumsell,sumbuy;
extern double distance =100;
int sumbasket = 0.00;

extern double Lots =0.01;
double Lots2;
extern double refactor = 2000;
double targetprofit = Lots*refactor;

bool tradesides = true;
bool tradetrends = true;

     double distancebuy;
 double distancesell;

 
 double distancebuysos =  distance;
 double distancesellsos =  distance;
 
 bool closebasket = false;
 double mode = 0; 
 double tradebuys = false;
 double tradesells = false;
 double accequity; 
 double td5,td ,tdd , tdd3,tdd4 ,adx,direction; //TRENDS
 int ExtCountedBars=0;
 
 bool BreakEnabled =false;
 int breakeven = distancebuysos-5; //POSO NA PAREi
 int breakevengain =distancebuysos; ///POTE NA MPEI 
 

bool closing =true ;
double TargetBasket = targetprofit/3 ;
double downzag,upzig;


void zigzag()
{  
    int n, i;
i=0;
while(n<2)
{
   if(upzig>0) downzag=upzig;
   upzig=iCustom(NULL,0, "ZigZag", 0, i);
   if(upzig>0) n+=1;
   i++;
} 
}

void modesfixs()
{
if (mode == 1){

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
   BreakEnabled=false;
      tradesells=true;
      tradebuys = true;
}
}

   void OnTick()
  { 
   if(Bars<100 || IsTradeAllowed()==false) return;
     RefreshRates();
     counttrades();
     zigzag();
     CheckTrends();
     fixDirection();
    Modes(); 
    modesfixs();
   distancebuy  = (lastbuyopenprice-distance*Point);
   distancesell =  (lastsellopenprice+distance*Point);
   Lots2=Lots*2;
    comments();
        
    CheckForOpen();

  }

  void Modes()
  {
  mode = 0 ;
  
  if(direction > 0 )
  {
  mode = 1;
  } 
  }
  
    

  
  void CheckForOpen()
  {
   if(Volume[0]>1) return;
   int    res;
      CloseOrders();
     ////////////////////////MODE 0 PLAGIO 
  if(mode == 0 && tradesides == true){ 
      BreakEnabled=false;
   
      
     ////---- sell conditions
     if( buys < maxbuys && upzig > downzag && buys == 0 )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-0-1B",MAGICMA,0,Blue);
     return;
     }
       if( buys < maxbuys && upzig > downzag && buys >= 1 && Ask < distancebuy )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"MODE-0-2B",MAGICMA,0,Blue);
     return;
     }
   
     if( sells < maxsells && upzig < downzag && sells == 0) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-0-1S",MAGICMA,0,Red);
     return;
     }
      if(sells < maxsells  && upzig < downzag && sells >=1  && Bid> distancesell) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"MODE-0-2S",MAGICMA,0,Red);
     return;
     }
     
     }
////////////////////////MODE 0  -TREND FOLLOW 
        
  if(mode == 1 && tradetrends == true){ 
  
     if((buys >= 3 || sells >=3 ) ){
    BreakEnabled=true;
     Breakeven();
  }
   if(buys < 3 || sells <3 ){
   BreakEnabled=false;
    Breakeven();
  }

     ////---- sell conditions

     if(tradebuys == true && buys < maxbuys && upzig > downzag && buys == 0 )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-1-BUY1",MAGICMA,0,Blue);
     return;
     }
       if( tradebuys == true && buys < maxbuys && upzig > downzag && buys >= 1 &&  (Ask < distancebuy ||Ask > lastbuyopenprice+distancebuysos*Point))
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MODE-1-BUY2",MAGICMA,0,Blue);
     return;
     }
   
     if( tradesells == true && sells < maxsells && upzig < downzag && sells == 0) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-1-SELL1",MAGICMA,0,Red);
     return;
     }
      if(tradesells == true && sells < maxsells  && upzig < downzag && sells >=1  && (Bid > distancesell ||Bid < lastsellopenprice-distancesellsos*Point)) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MODE-1-SELL2",MAGICMA,0,Red);
     return;
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
   if((buys >=4 || sells >= 4) && sumbasket > -5 )
   { 
     closebasket = true ;
   }
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
   if(accequity >= 200)
                      {
        closebasket = true ;
            }
      }
     CloseAll();
   }

int CheckTrends()
   {
   double  current_ma1, current_ma2, current_ma3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma11, current_ma21, current_ma31 ;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
   adx=iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 0);
       //M5 TDd
   current_ma11 = iMA(NULL,PERIOD_M5,200,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma21 = iMA(NULL,PERIOD_M5,50,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma31 = iMA(NULL,PERIOD_M5,21,0,MODE_EMA,PRICE_CLOSE,0);
   //M15 TDd
   current_ma15 = iMA(NULL,PERIOD_M15,100,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,30,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,21,0,MODE_SMA,PRICE_CLOSE,0);
   
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_M30,100,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_M30,25,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,PERIOD_M30,10,0,MODE_EMA,PRICE_MEDIAN,0);
   //H4
   current_ma111 = iMA(NULL,PERIOD_H4,200,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,50,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma311 = iMA(NULL,PERIOD_H4,21,0,MODE_SMA,PRICE_CLOSE,0);
   
   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,50,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,25,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,10,0,MODE_SMA,PRICE_MEDIAN,0);

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

    
  return(tdd);  //M5
  return(td5);  //M15
  return(tdd4); //H1
  return(tdd3); //H4
  return(td);   //D1
}
void comments()
   {

   int  digits = Digits();
        RefreshRates();
        
     

     double eqt= AccountEquity();
     accequity =(AccountEquity()/AccountBalance()*100);
     

     Comment(StringFormat("DIGITS=%G\BID=%G\ASK=%G\n--TRENDS--M5=%G\M15=%G\H1=%G\H4=%G\D1=%G\nNextBUy=%G\NextSell=%G\nTradeBUys=%G\TradeSells=%G\distance=%G\n\nBASKET=%G\->TARGETBASKET=%G\n\n\n\n\n\n\n\n\n\n\nSELLS=%G\BUS=%G\nEQUITY=%G\nEquitypercent=%G\nTREND-DIRECTION=%G\nMODE=%G\nADX=%G",digits,Bid,Ask,tdd,td5,tdd4,tdd3,td,distancebuy,distancesell,tradebuys,tradesells,distance,sumbasket,targetprofit,sells,buys,eqt,accequity,direction,mode,adx));
   }


int fixDirection()///TREND DIRECTION

   {   
   direction =0;
   if(tdd == 1 && td5 ==1 && tdd4 ==1 )
   
   direction = 1;
  
   if( tdd == 2 && td5 ==2 && tdd4 ==2   )

   direction = 2;

  

}
  

  





int Breakeven(){
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
   
   void itrend()
   {



    }
   
   
