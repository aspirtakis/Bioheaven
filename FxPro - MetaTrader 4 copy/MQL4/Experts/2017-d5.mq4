extern string BASICS;
extern int MAGICMA = 993010;
bool trading = true;


extern double Lots  =0.10;
extern bool CutTradesRange = true;
extern bool RangeBasket =true;
extern bool RangeDistance = true;
extern bool MaTrends = false;
extern bool checkADX = false;
extern double RangeDevider=4;
extern double distancePoints=1000 ;
extern double rangedistance = -15;
extern double BasketProfit =50;
double distance;

enum timeframes{ 
   H1=PERIOD_H1, // PERIOD_H1
   H4=PERIOD_H4, // PERIOD_H4
   D1=PERIOD_D1, // PERIOD_D1
   W1=PERIOD_W1, // PERIOD_W1

};
 extern timeframes RangeTF = D1;
 

double timeFrameSRW1 =RangeTF; //RANGE TIMEFRAME


double range1;
double delta =10;
 double Period1            = 5;
 double Period2            = 13;
 double Period3            = 34;
 string Dev_Step_1         ="1,3";
 string Dev_Step_2         ="8,5";
 string Dev_Step_3         ="13,8";
 int Symbol_1_Kod          =140;
 int Symbol_2_Kod          =141;
 int Symbol_3_Kod          =142;


double rangeUPprc  , rangeDNprc ;
double supportH1, resistH1, supportW1, resistW1;

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


//+------------------------------------------------------------------+


void start()
  {
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
  CheckTrends();
  counttrades();
  Chk_ADX();
  SRrange();
  distances();
  cutrange();

   comments();
 CheckForOpen();
 CheckForClose();
 indicator();


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
  
    rdistance(); 
   double ZZ_1, ZZ_2;
   int    res,res1,res2,res3,res4;

//---- go trading only for first tiks of new bar
   if(Volume[0]>1) return;

//---- get 3 Level ZZ Semafor
   
   ZZ_1=iCustom(Symbol(),0,"3_Level_ZZ_Semafor",delta ,Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,5,3);
   ZZ_2=iCustom(Symbol(),0,"3_Level_ZZ_Semafor",delta,Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,4,3);
   

//---- sell conditions
   
   if(ZZ_1 < ZZ_2 && sells == 0  && tradesells == true )  
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"AGAS1",MAGICMA,0,Red);
      return;
     }
        if(ZZ_1 > ZZ_2 && sells == 1  && Bid >= distancesell && tradesells == true )  
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"AGAS-2",MAGICMA,0,Red);
      return;
     }
     
//---- buy conditions
   if(ZZ_1 < ZZ_2 && buys == 0 && tradebuys == true   )  
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"AGAS1",MAGICMA,0,Blue);
      return;
     }
       if(ZZ_1 < ZZ_2 && buys == 1   &&Ask <= distancebuy  && tradebuys == true  )  
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"AGAS2",MAGICMA,0,Blue);
      return;
     }

//----
  }
void  CheckForClose()
{
if(RangeBasket == true){
BasketProfit = range1/RangeDevider;
}

if(sumbasket > BasketProfit)
{
CloseAll();
} 


if(buys >= 1 && sells >= 1 &&  sumbasket >= (BasketProfit/2))
{
CloseAll();
} 


if(buys == 2 && sells == 0 &&  sumbasket >= (BasketProfit/2))
{
CloseAll();
} 
if(buys == 0 && sells == 2 &&  sumbasket >= (BasketProfit/2))
{
CloseAll();
} 



}


void comments()
   {
   int  digits = Digits();
     RefreshRates();
     double eqt= AccountEquity();
     accequity =(AccountEquity()/AccountBalance()*100);
     Comment(StringFormat("\n\nTRADING=%G \DIGITS=%G \BID=%G \ASK=%G \nEQUITY=%G \Equitypercent=%G \R-UP=%G \RDN=%G \RANGE=%G ---DISTANCE=%G \nTARGETBASKET=%G \TAMEIO=%G \nSELLS=%G \BUYS=%G \nTRADESELLS=%G \TRADEBUYS=%G \nTREND=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nH1-ADX=%G\nM15-ADX=%G",trading,digits,Bid,Ask,eqt,accequity,rangeUPprc,rangeDNprc,range1,distance,BasketProfit,sumbasket,sells,buys,tradesells,tradebuys,directionma,td5,tdd,tdd4,tdd3,td,wd,adx,adxM5));
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





void Chk_ADX()
{
if(checkADX == true)
{
 adx=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
 adxM5=iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MAIN, 0);
}
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
   current_ma1 = iMA(NULL,PERIOD_D1,30,0,MODE_EMA,PRICE_CLOSE,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,15,0,MODE_SMA,PRICE_CLOSE,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,5,0,MODE_SMA,PRICE_CLOSE,0);
   
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
   MAdirections();
  }
}

void MAdirections()
{
  directionma =0 ;
  
   if( tdd == 1 && td ==1 && tdd4 ==1 && tdd3 == 1 ){
   directionma = 1;
   }
   if( tdd == 2 && td ==2 && tdd4 ==2  && tdd3 ==2 ){
   directionma = 2;
   }
}


