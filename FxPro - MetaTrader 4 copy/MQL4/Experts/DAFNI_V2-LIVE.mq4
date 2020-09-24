
extern int MAGICMA = 993010;
extern bool trading = true;
extern bool ChangeModes = true;
double mode = 0;
extern double Lots  =0.10;
extern double refactor = 3;

extern bool CutTradesRange = true;
extern double rangedistance= 20;
extern double distancePoints=1000 ;

extern bool EAclosing = true;
extern double BasketProfit =50;
extern bool closeLoss = true;
extern double loss = 300;
extern bool autoDistance =true;



 bool closing = false;

 double  breakevengain = 5;
 double breakeven =50;

double distance;
int zag, zig;
int zaga, ziga;



 extern double RangeDevider =2 ;
 
enum timeframes{ 
   H1=PERIOD_H1, // PERIOD_H1
   H4=PERIOD_H4, // PERIOD_H4
   D1=PERIOD_D1, // PERIOD_D1
   W1=PERIOD_W1, // PERIOD_W1
   MN1=PERIOD_MN1, // PERIOD_MN1

};
 extern timeframes RangeTF =D1;
 
double timeFrameSRW1 =RangeTF; //RANGE TIMEFRAME



   
double  zdev1 = 24;
double  zdev2 =10;
double   zdev3 =6;

double range1;
double rangeUPprc  , rangeDNprc ;
double  supportW1, resistW1;
int numBars =100;
int numBars2 =50;

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
double curdistancebuy;
double curdistancesell;
double smalltrend =0;


void start()
  {
  RefreshRates();
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
  counttrades();
  CheckTrends();
 MAdirections();
  
SRrange();
  distances();
  zigzag();
modes();
    cutrange();
    indicator();
 CheckForOpen();
 CheckForClose();

    comments();
 
  }
  
  
  
  int indicator()
  {
    ObjectCreate("RangeW1up",OBJ_HLINE,0,0,0);
    ObjectCreate("RangeW1dn",OBJ_HLINE,0,0,0);
   return(0);
  }

     

   
   
        
  
 void cutrange()
   {
   
   if( autoDistance == true)
   {
   distance = (range1 / RangeDevider)*10;
   
   }
      if( autoDistance == false)
   {
   distance = distancePoints;
   
   }
   
   if(CutTradesRange ==true)   {
   if(mode == 0){
     tradesells =true;
     tradebuys=true;
     
     if(rangeUPprc > -rangedistance)
      {
     tradesells =true;
     tradebuys=false;
      } 
     if(rangeDNprc > -rangedistance)
      {
     tradesells =false;
     tradebuys=true;
      }
      }
      }
   }
   
   
   void modes()
   {
      if(mode == 2){
      tradebuys = false;
      tradesells=true;
            }
      if(mode == 1)
            {
         tradebuys = true;
            tradesells=false;
            }
   }
   
void zigzag()
{
RefreshRates();
zig =0;
zag=0;
double ZOG=0;
//double ZOG3=0;

  //zag= iCustom(NULL,0,"ZigZag",40,20,3,2,1); 
 // zig= iCustom(NULL,0,"ZigZag",40,20,3,1,1);
  ZOG=iCustom(NULL,0,"PZ_PivotPoints",1,1);
  //  ZOG3=iCustom(NULL,0,"iExposure",1,1);
  
  /// zag= iCustom(NULL,0,"Channel_aga",2,1); 
///  zig= iCustom(NULL,0,"Channel_aga",1,1);
  
      zag= iCustom(NULL,0,"3_Level_aga",4,1); 
  zig= iCustom(NULL,0,"3_Level_aga",5,1);


}  




void CheckForOpen()  {
  if(Volume[0]>1) return;
  if(trading = true)  {

   double res;
 
   

   if( zig > 0 && sells == 0  && tradesells == true )       {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"SIDEWAYS1",MAGICMA,0,Red);
      return;
     }
        if(zig > 0  && sells == 1  && Bid >= distancesell && tradesells == true )       {
      res=OrderSend(Symbol(),OP_SELL,(Lots*refactor),Bid,3,0,0,"SIDEWAYS2",MAGICMA,0,Red);
      return;
     }
     

     if( zag > 0 && buys == 0 && tradebuys == true  )       {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"SIDEWAYS1",MAGICMA,0,Blue);
      return;
     }
       if( zag > 0 && buys == 1   &&Ask <= distancebuy  && tradebuys == true  )       {
      res=OrderSend(Symbol(),OP_BUY,(Lots*refactor),Ask,3,0,0,"SIDEWAYS2",MAGICMA,0,Blue);
      return;
     }
     }
  }
  
  

void  CheckForClose(){
if(EAclosing == true){
closing = false;
closebasket =false;

 if(sells == 1 && zag > 0 && sumsell > BasketProfit) {
 closing = true;
 closesell();
  closing = false;
 }
  if(buys == 1 && zig > 0 && sumbuy > BasketProfit) {
   closing = true;
   closebuy();
    closing = false;
 }
 
  if(sells > 1  && sumsell > BasketProfit) {
 closing = true;
 closesell();
  closing = false;
 }
  if(buys > 1 && sumbuy > BasketProfit) {
   closing = true;
   closebuy();
    closing = false;
 }
 
   if(sells == 1  && buys == 1 && sumbasket > 0) {
// closebasket = true ;
 //CloseAll();
 //closebasket =false;
 }

 
 
if (closeLoss == true) {
closing = false;
closebasket =false;

if(sumbasket < -loss)
{
 closebasket = true ;
 CloseAll();
 closebasket =false;
}

}


}

}





void closebuy(){
   if (closing ==true ){
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
     

         case OP_BUYLIMIT: 
         case OP_BUYSTOP: 

            if (!OrderDelete(OrderTicket()))
            break;
      }
   }

  }

}

void closesell(){
   if (closing ==true ){
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
      
         case OP_SELL:
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 0, Red))
            break;


         case OP_SELLLIMIT:

         case OP_SELLSTOP:
            if (!OrderDelete(OrderTicket()))
            break;
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
     Comment(StringFormat("ZIG=%G ZaG=%G \nmode=%G \n\nTRADING=%G \DIGITS=%G \BID=%G \ASK=%G \nEQUITY=%G \Equitypercent=%G \R-UP=%G \RDN=%G \RANGE=%G ---DISTANCE=%G ---DEVIDER=%G \nTARGETBASKET=%G \TAMEIO=%G \nSELLS=%G \BUYS=%G \nTRADESELLS=%G \TRADEBUYS=%G \nDISTANCESELL =%G \DISTANCEBUY =%G \n\nLongTREND=%G \QuickTrend=%G\nM15=%G\M30=%G\H1=%G\H4=%G\D1=%G\W1=%G\nADX-H4=%G\nADX-H1=%G",zig,zag,mode,trading,digits,Bid,Ask,eqt,accequity,rangeUPprc,rangeDNprc,range1,distance,RangeDevider,BasketProfit,sumbasket,sells,buys,tradesells,tradebuys,curdistancesell,curdistancebuy,directionma,smalltrend,td5,tdd,tdd4,tdd3,td,wd,adx,adxM5));
   }
   
   
   
  int Breakeven(){
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
 curdistancebuy=0;
  curdistancesell=0;
 
      distancebuy  = (lastbuyopenprice-distance*Point);
      distancesell =  (lastsellopenprice+distance*Point);  
      curdistancebuy  = (Ask -lastbuyopenprice)*100000;
      curdistancesell =  (lastsellopenprice-Bid)*100000;  
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



   

int CheckTrends()
   {

   double  current_ma1, current_ma2, current_ma3;
   double  current_wa1, current_wa2, current_wa3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma11, current_ma21, current_ma31 ;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
   //M15 TDd
   current_ma15 = iMA(NULL,PERIOD_M15,200,0,MODE_SMA,PRICE_CLOSE,3);  
   current_ma25 = iMA(NULL,PERIOD_M15,100,0,MODE_SMA,PRICE_CLOSE,3);  
   current_ma35 = iMA(NULL,PERIOD_M15,60,0,MODE_SMA,PRICE_CLOSE,3);
   
   //M30 TDd
   current_ma11 = iMA(NULL,PERIOD_M30,150,0,MODE_EMA,PRICE_CLOSE,2);  
   current_ma21 = iMA(NULL,PERIOD_M30,80,0,MODE_EMA,PRICE_CLOSE,2);  
   current_ma31 = iMA(NULL,PERIOD_M30,30,0,MODE_EMA,PRICE_CLOSE,2);
   
   ///H1 TD3
   current_d1 = iMA(NULL,PERIOD_H1,20,0,MODE_EMA,PRICE_MEDIAN,3);  
   current_d2 = iMA(NULL,PERIOD_H1,12,0,MODE_EMA,PRICE_MEDIAN,3);  
   current_d3 = iMA(NULL,PERIOD_H1,1,0,MODE_EMA,PRICE_MEDIAN,3);
   //H4
   current_ma111 = iMA(NULL,PERIOD_H4,150,0,MODE_EMA,PRICE_CLOSE,2);  
   current_ma211 = iMA(NULL,PERIOD_H4,50,0,MODE_SMA,PRICE_CLOSE,2);  
   current_ma311 = iMA(NULL,PERIOD_H4,20,0,MODE_SMA,PRICE_CLOSE,2);
   
   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,80,0,MODE_EMA,PRICE_CLOSE,1);  
   current_ma2 = iMA(NULL,PERIOD_D1,45,0,MODE_SMA,PRICE_CLOSE,1);  
   current_ma3 = iMA(NULL,PERIOD_D1,15,0,MODE_SMA,PRICE_CLOSE,1);
   
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





void MAdirections(){

 adx=iADX(NULL, PERIOD_M30, 14, PRICE_CLOSE, MODE_MAIN, 1);
 adxM5=iADX(NULL, PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 1);

  directionma =0 ;
   mode = 0;
   smalltrend=0;
  
   if( wd == 1 && td ==1  && tdd4 == 1  ){
   directionma = 1;
   }
   
   if( wd == 2 && td ==2 && tdd4 == 2  ){
   directionma = 2;
   }
   
   
   if(  tdd3 ==1 && tdd == 1  && td5==1 && adxM5 >25 && adx >25 ){
   smalltrend = 1;
   }
   
   if( tdd3 ==2  && tdd ==2  && td5 ==2 && adxM5 >25 && adx >25 ){
   smalltrend = 2;
   }
   
   
   if(ChangeModes == true)
   {
   if(smalltrend == 2 ){
   mode =2;
   }
      if(smalltrend == 1 ) {
   mode =1;
   }
   }
            

}


