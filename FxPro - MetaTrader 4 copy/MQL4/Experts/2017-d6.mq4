extern string BASICS;
extern int MAGICMA = 993010;
bool trading = true;

double mode = 0;

extern double Lots  =0.10;
extern bool CutTradesRange = true;
extern bool RangeBasket =true;
extern bool RangeDistance = true;
extern bool zigzagClose = false;
 
 bool agaClosing = true;
 bool MaTrends = true;
 bool checkADX = true;
 extern double RDevider=5;
 double RangeDevider=0;
extern double distancePoints=1000 ;
extern double rangedistance = -15;
extern double BasketProfit =50;
double distance;
  double zag, zig;
extern bool trademodes = true;  
bool closing = true;



 bool  tradebuysnow=false;
      bool tradesellsnow=false;
 
enum timeframes{ 
   H1=PERIOD_H1, // PERIOD_H1
   H4=PERIOD_H4, // PERIOD_H4
   D1=PERIOD_D1, // PERIOD_D1
   W1=PERIOD_W1, // PERIOD_W1

};
 extern timeframes RangeTF = D1;
 

double timeFrameSRW1 =RangeTF; //RANGE TIMEFRAME
   
   int  zdev1 = 24;
   int  zdev2 =10;
 int   zdev3 =6;

double range1;


double rangeUPprc  , rangeDNprc ;
double  supportW1, resistW1;

int numBars =56;
int numBars2 =24;


double sells ,buys,lastsellopenprice,lastbuyopenprice,sumsell,sumbuy;
int sumbasket = 0.00;
bool closebasket = true;

double tradebuys = true;
double tradesells = true;
double accequity; 


double wd,td5,td ,tdd , tdd3,tdd4 ,adx,adxM5,direction; //TRENDs
double timeframe ;
double  directionma ;

double distancebuy;
double distancesell;
double smalltrend =0;


//+------------------------------------------------------------------+


void start()
  {
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
  CheckTrends();

    MAdirections();
  counttrades();
  SRrange();
  distances();
 indicator();

   modes();
     cutrange();
           zigzag();
 CheckForOpen();
 CheckForClose();
 zigzagClosing();
    comments();
  }
  
  
 void zigzagClosing()
  {
  if(zigzagClose ==true)  {
  agaClosing =false;
  if(buys > 0 && sumbasket > 0 && zig > 0)
  {
  closebuy();
  }
  
  if(sells > 0 && sumbasket > 0 && zag > 0)
  {
  closesell();
  }
  

  
  }
  }
  
  
  
  int indicator()
  {
    ObjectCreate("RangeW1up",OBJ_HLINE,0,0,0);
    ObjectCreate("RangeW1dn",OBJ_HLINE,0,0,0);
   return(0);
  }

     
 void cutrange()
   {
   if(CutTradesRange ==true)
   {
   if(mode == 0){
     tradesells =true;
     tradebuys=true;
     
     if(rangeUPprc > rangedistance)
      {
     tradesells =true;
     tradebuys=false;
      } 
         if(rangeDNprc > rangedistance)
      {
     tradesells =false;
     tradebuys=true;
      } 
      
      
      }
      }
      
   }
   
        
 void modes()
   {
   if(trademodes == true)
  {
   tradesells =true;
     tradebuys=true;
      tradebuysnow=false;
       tradesellsnow=false;
       
       
       if(mode == 1 || mode ==2)
       {
       zdev1 = 12;
       zdev2 =5;
       zdev3 =3;
       RangeDevider =RDevider-1;
       }
       if(mode == 0)
       {
       zdev1 = 24;
       zdev2 =10;
       zdev3 =6;
        RangeDevider =RDevider;
       }
  
  if(mode == 1 )
         {
            tradesells =false;
              tradebuys=true;
      
      tradebuysnow = true;
      
          
            }

   if(mode == 2 )
            {
      tradesells =true;
      tradebuys=false;
      
      
      tradesellsnow=true;
      
         }
  }
   }


void zigzag()
{
zig =0;
zag=0;


  zag= iCustom(NULL,0,"ZigZag",zdev1,zdev3,zdev3,2,1); 
  zig= iCustom(NULL,0,"ZigZag",zdev1,zdev3,zdev3,1,1);
}


//------------
   
void rdistance()
{
if(RangeDistance == true)
  {
  distance = (range1 /RangeDevider)*10;
   }
   else
   {
   distance = distancePoints;
   }
}
  
   
   
void CheckForOpen()
  {


//---- go trading only for first tiks of new bar
   if(Volume[0]>1) return;

  rdistance(); 
double res;
//---- sell conditions
   if( zig > 0 && sells == 0  && tradesells == true )  
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"SIDEWAYS1",MAGICMA,0,Red);
      return;
     }
        if(zig > 0  && sells == 1  && Bid >= distancesell && tradesells == true )  
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"SIDEWAYS2",MAGICMA,0,Red);
      return;
     }
      if(mode == 2 && zig > 0  && sells < 2 &&  tradesellsnow == true &&  Bid <= (lastsellopenprice-distance*Point)  )  
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"TREND-1",MAGICMA,0,Red);
      return;
     }
     if(mode == 2 && zig > 0  && sells == 2 &&  Bid <= (lastsellopenprice-distance*Point) && tradesellsnow == true )  
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"TREND-2",MAGICMA,0,Red);
      return;
     }
 
     
     
//---- buy conditions
     if( zag > 0 && buys == 0 && tradebuys == true   )       {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"SIDEWAYS1",MAGICMA,0,Blue);
      return;
     }
       if( zag > 0 && buys == 1   &&Ask <= distancebuy  && tradebuys == true  )       {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"SIDEWAYS2",MAGICMA,0,Blue);
      return;
     }
      if(mode == 1 && zag > 0 && buys < 2  && tradebuysnow == true &&Ask >=  (lastbuyopenprice+distance*Point)  )      {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"TREND-1",MAGICMA,0,Blue);
      return;
     }
      if(mode == 1 && zag > 0 && buys == 2 &&Ask >=  (lastbuyopenprice+distance*Point)  && tradebuysnow == true  )       {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"TREND-2",MAGICMA,0,Blue);
      return;
     }
  }
  
  

void  CheckForClose(){

if(agaClosing == true){
if(RangeBasket == true){
BasketProfit = range1/RangeDevider;
}

if(mode == 0){
if(buys == 1  && sells == 0 &&  sumbasket > BasketProfit &&  zig > 0 )
{
CloseAll();
} 
if(sells == 1 && buys == 0 &&  sumbasket >BasketProfit && zag > 0)
{
CloseAll();
}

 
if(buys >= 1 && sells >= 1 &&  sumbasket >(BasketProfit /2))
{
CloseAll();
} 

///////////EDO ATTENTION
if(buys == 2 && sells == 2 && sumbasket > -100 )
{
CloseAll();
} 

if(sumbasket > BasketProfit)
{
CloseAll();
}

if(buys == 2 && sells == 0 &&  sumbasket >= BasketProfit)
{
CloseAll();
} 
if(buys == 0 && sells == 2 &&  sumbasket >= BasketProfit)
{
CloseAll();
} 

if(buys >= 1 && sells == 2 &&  sumbasket >= (BasketProfit/2))
{
CloseAll();
} 
if(buys == 2 && sells >= 1 &&  sumbasket >=(BasketProfit/2))
{
CloseAll();
} 
}

if(mode == 2 && buys >0 && sumbasket >0)
{
closebuy();
}
if(mode == 1 && sells >0 && sumbasket >0)
{
closesell();
}
if(mode == 1 || mode == 2 && sumbasket >(BasketProfit*4))
{
CloseAll();
}
}
}


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
   
void comments()
   {
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     accequity =(AccountEquity()/AccountBalance()*100);
     Comment(StringFormat("ZIG=%G ZaG=%G \nmode=%G \n\nTRADING=%G \DIGITS=%G \BID=%G \ASK=%G \nEQUITY=%G \Equitypercent=%G \R-UP=%G \RDN=%G \RANGE=%G ---DISTANCE=%G ---DEVIDER=%G \nTARGETBASKET=%G \TAMEIO=%G \nSELLS=%G \BUYS=%G \nTRADESELLS=%G \TRADEBUYS=%G \n\nLongTREND=%G \QuickTrend=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nADX-H4=%G\nADX-H1=%G",zig,zag,mode,trading,digits,Bid,Ask,eqt,accequity,rangeUPprc,rangeDNprc,range1,distance,RangeDevider,BasketProfit,sumbasket,sells,buys,tradesells,tradebuys,directionma,smalltrend,td5,tdd,tdd4,tdd3,td,wd,adx,adxM5));
   }
   
   
  
void SRrange(){
  supportW1 = 3000;
  resistW1 = 0; 
  for(int k = 1;k<=numBars2;k++)
  {  
   if(supportW1>iLow(Symbol(),timeFrameSRW1,k))
     supportW1 = iLow(Symbol(),timeFrameSRW1,k);
   if(resistW1<iHigh(Symbol(),timeFrameSRW1,k))
     resistW1 = iHigh(Symbol(),timeFrameSRW1,k);
  } 
  
 range1 =0;
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
      if(OrderSymbol()==Symbol() )// 
        {
         if(OrderType()==OP_BUY  ) {
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
        } 
        }
 }
 
 
 void distances()
 {
 
      distancebuy  = (lastbuyopenprice-distance*Point);
     distancesell =  (lastsellopenprice+distance*Point);  
 }
 
 
 
 
 
int CloseAll(){ 
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
   for(index = numOfOrders - 1; index >= 0; index--)   {
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
   current_ma15 = iMA(NULL,PERIOD_M15,200,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma25 = iMA(NULL,PERIOD_M15,100,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma35 = iMA(NULL,PERIOD_M15,60,0,MODE_SMA,PRICE_CLOSE,0);
   
   //M30 TDd
   current_ma11 = iMA(NULL,PERIOD_M30,150,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma21 = iMA(NULL,PERIOD_M30,80,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma31 = iMA(NULL,PERIOD_M30,30,0,MODE_EMA,PRICE_CLOSE,0);
   
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,100,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,PERIOD_H1,70,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,PERIOD_H1,20,0,MODE_EMA,PRICE_MEDIAN,0);
   //H4
   current_ma111 = iMA(NULL,PERIOD_H4,50,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma211 = iMA(NULL,PERIOD_H4,25,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma311 = iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,0);
   
   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,80,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,45,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,15,0,MODE_SMA,PRICE_CLOSE,0);
   
      //w1// Td
   current_wa1 = iMA(NULL,PERIOD_W1,25,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_wa2 = iMA(NULL,PERIOD_W1,14,0,MODE_SMA,PRICE_MEDIAN,0);  
   current_wa3 = iMA(NULL,PERIOD_W1,1,0,MODE_SMA,PRICE_MEDIAN,0);
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
   return(wd);   //W1
  
  }
}



void MAdirections(){
if(checkADX == true)
{
 adx=iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 0);
 adxM5=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
}

  directionma =0 ;
   mode = 0;
   smalltrend=0;
  
   if( wd == 1 && td ==1  ){
   directionma = 1;

   }
   
   if( wd == 2 && td ==2  ){
   directionma = 2;

   }
   
   if(  tdd3 ==1 && tdd4 == 1   ){
   smalltrend = 1;
   }
   
   if( tdd3 ==2  && tdd4 ==2    ){
   smalltrend = 2;
   }
   if(smalltrend == 2 && directionma ==2)
   {
   mode =2;
   }
      if(smalltrend == 1 && directionma ==1)
   {
   mode =1;
   }
   
            

}


