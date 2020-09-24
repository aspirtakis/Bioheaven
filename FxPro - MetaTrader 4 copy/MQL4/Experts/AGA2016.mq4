#define SLIPPAGE              3
#define NO_ERROR              1
#define AT_LEAST_ONE_FAILED   2

extern int MAGICMA = 993010;

extern bool tradesells =true;
extern bool tradebuys = true;
extern double maxsells = 20;
extern double maxbuys = 20;
extern double distancebuy = 500;
extern double distancesell = 500;
double Lots  =0.02;
extern double refactor = 0.02 ;
///DISTANCES ARE ON POINTS 
extern bool closing =true ;
 double targetprofit = 12;
 double lossprofit = 7;
extern bool closeBasket =false ;
extern double TargetBasket = 30;
extern bool ZZClose =true ;
extern bool BreakEnabled =true;
extern int breakeven = 5; //POSO NA PAREi
extern int breakevengain =10; ///POTE NA MPEI 

double Lots1,Lots2sell,Lots2buy,Lots4,Lots5,Lots6,Lots7,SosSelllot,SosBuylot;
double lastbdistance;
double lastsdistance;
int direction = 0;

double Period1            = 5;
double Period2            = 8;
double Period3            = 16;
string Dev_Step_1         ="1.3";
string Dev_Step_2         ="8.5";
string Dev_Step_3         ="21.12";
int Symbol_1_Kod          =140;
int Symbol_2_Kod          =141;
int Symbol_3_Kod          =142;

double mode= 1;
int asumlot;
double td5,td ,tdd , tdd3,tdd4 ,adx; //TRENDS
double ordbasketprice;
double desirebasket1;
double lastordtype;

double  buys =0;
double buystosave=0;
double sells =0;
double allorders =0;
int sumbasket     ;
double  sum_profits,  sum_profitss;
int sumbuy ,sumsell;
double sumbasketlot;
double sumbasketlot2;
double sumlotssell =0.0;
double sumlotsbuy =0.0;
double  sellindprofit = 0;
double  buyindprofit = 0;
double ordercountermagic = 0;
double lastselllot,lastbuylot;
bool sosnowbuy =false, sosnowsell =false;
double  sum_profitbuy=0,  sum_profitsell =0,  lastbuyopenprice=0, lastsellopenprice=0;
 int distancebuyonloss =distancebuy;
 int distancesellonloss =distancesell;



void start()
  {
   if(Bars<100 || IsTradeAllowed()==false) return;
    CheckForOpen();
    Breakeven();

  }
//+--

void CheckForClose()
{
if(buys ==1 && sells == 1 && sumbasket >= 5)
{
closesell();
closebuy();
}
if(sumbuy>= targetprofit)
{

closebuy();
}
if(sumsell >= targetprofit)
{
closesell();

}
if(sumbuy <= -lossprofit)
{

closebuy();
}
if(sumsell <= -lossprofit)
{
closesell();

}

}


void CheckForOpen()
  {
     if(Volume[0]>1) return;
   RefreshRates();
       counttrades();
       
           CheckTrends();

       CheckForClose();
      

  
   double ZZ_1, ZZ_2;
   ZZ_1=iCustom(Symbol(),0,"3_Level_ZZ_Semafor",Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,5,3);
   ZZ_2=iCustom(Symbol(),0,"3_Level_ZZ_Semafor",Period1,Period2,Period3,Dev_Step_1,Dev_Step_2,Dev_Step_3,Symbol_1_Kod,Symbol_2_Kod,Symbol_3_Kod,4,3);


   int    res;
     ////---- sell conditions
    Comment(StringFormat("DistanceSELL=%G\DistanceBUY =%G\nLAST-BUY=%G\LAST-SELL=%G\nSUMBASKET=%G\TARGETBASKET=%G\nmaxSells=%G\MaxBuys=%G\nSUMSELLS =%G\SUMBUYS=%d\SELLS=%G\BUYS=%G\n\nMODE=%d\--TrSELLS=%G\--TrBUYS=%G\n\n\LOTSSELL=%G\LOTBUY=%G\nnLASTSLOT=%G\LASTBUYLOT=%G\LastTYPE=%G\nBSKLOT=%G\BSKLOT2=%G\n\nLot=%G\SOSLOTBUY=%G\SOSLOTSELL=%G\LOT2BUY=%G\LOT2SELL=%G\nD1=%G\M15=%G\H1=%G\H4=%G\ADX=%G\DIRECTION=%G",distancesell,distancebuy,lastbdistance,lastsdistance,sumbasket,targetprofit,maxsells,maxbuys,sumsell,sumbuy,sells,buys,mode,tradesells,tradebuys,sumlotssell,sumlotsbuy,lastselllot,lastbuylot,lastordtype,sumbasketlot,sumbasketlot2,Lots,SosBuylot,SosSelllot,Lots2buy,Lots2sell,td,td5,tdd4,tdd3,adx,direction));
 
      if(  buys  == 0 && buys < maxbuys  && ZZ_1 < ZZ_2 )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"1StTradeBUY",MAGICMA,0,Blue);
      return;
     }
      if( sells == 0  && sells < maxsells  && ZZ_1 > ZZ_2 )  
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"1StTradeSELL",MAGICMA,0,Red);
      return;
     }

     
  }

int CheckTrends()
   {
   RefreshRates();
   double  current_ma1, current_ma2, current_ma3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma11, current_ma21, current_ma31 ;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
   
   adx=iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MAIN, 0);
   
   //D1// Td
   current_ma1 = iMA(NULL,PERIOD_D1,200,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma2 = iMA(NULL,PERIOD_D1,50,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma3 = iMA(NULL,PERIOD_D1,21,0,MODE_EMA,PRICE_MEDIAN,0);
   
   //M5 TDd
   current_ma11 = iMA(NULL,5,200,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma21 = iMA(NULL,5,50,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma31 = iMA(NULL,5,21,0,MODE_EMA,PRICE_MEDIAN,0);
   
   //M15 TDd
   current_ma15 = iMA(NULL,15,200,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma25 = iMA(NULL,15,50,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma35 = iMA(NULL,15,21,0,MODE_EMA,PRICE_MEDIAN,0);
   
   //M30 TD3
    current_d1 = iMA(NULL,60,200,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d2 = iMA(NULL,60,50,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_d3 = iMA(NULL,60,21,0,MODE_EMA,PRICE_MEDIAN,0);
   current_ma111 = iMA(NULL,240,200,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma211 = iMA(NULL,240,50,0,MODE_EMA,PRICE_MEDIAN,0);  
   current_ma311 = iMA(NULL,240,21,0,MODE_EMA,PRICE_MEDIAN,0);

   //D1///
   if(current_ma3 > current_ma2 && current_ma2 > current_ma1)  {
    td = 1;
    }
    if(current_ma3 < current_ma2 && current_ma2 < current_ma1)  {
    td = 2;
    }
  ///M5//
  if(current_ma31 > current_ma21 && current_ma21 > current_ma11)  {
    tdd = 1;
    }
  if(current_ma31 < current_ma21 && current_ma21 < current_ma11)  {
    tdd = 2;
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
  return(td5);
  return(td);
  return(tdd);
  return(tdd3);
  return(tdd4);

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
    sum_profits =0;
    sum_profitss =0;
    double sum_lots =0;
    double sum_lotsb= 0;
    sumlotsbuy = 0.0;
    sumlotssell = 0.0;
    double ord_num = 0;
    sumbasketlot =0;
    sumbasketlot2 =0;
    double asumlot = 0;
    int num = 0;
    lastbuylot=0;
    lastselllot=0;
    allorders=0;
    ordbasketprice=0;

   
 for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() )// && OrderMagicNumber() == MAGICMA
   
        {
       
         if(OrderType()==OP_BUY ) {
         lastbuyopenprice=OrderOpenPrice();
         lastbuylot = OrderLots();
         sum_profits += OrderProfit()+OrderSwap()+OrderCommission();
         sum_lotsb += OrderLots(); 
         buyindprofit= OrderProfit()+OrderSwap()+OrderCommission();
         buys++;
         }

         if(OrderType()==OP_SELL   ){
         sum_profitss += OrderProfit()+OrderSwap()+OrderCommission();
         lastsellopenprice=OrderOpenPrice();
         sells++;
         lastselllot = OrderLots();
         sum_lots += OrderLots();
         sellindprofit = OrderProfit()+OrderSwap()+OrderCommission();
         }
         
        lastordtype=OrderType();
        allorders++;
        ordercountermagic = buys+sells;
        sumsell = sum_profitss; 
        sumbuy = sum_profits; 
        sumlotssell = sum_lots;
        sumlotsbuy = sum_lotsb;  
        asumlot = sumlotsbuy - sumlotssell; 
        int summer = sum_profitss + sum_profits;   
        sumbasket = summer;
        string sumlotssell =DoubleToStr(sum_lots,5);
        string sumlotsbuy =DoubleToStr(sum_lotsb,5);  
        sumbasketlot =DoubleToStr(asumlot,2);
        sumbasketlot2 =DoubleToStr(asumlot,2);
        int sumord = buys-sells; 
        } 

        

        }
 }


 
void SRrange()
{

  supportW1 = 2000;
  resistW1 = 0; 

   double timeFrameSRW1 =PERIOD_W1;
 
  for(int k = 1;k<=numBars2;k++)
  {
     
     if(supportW1>iLow(Symbol(),timeFrameSRW1,k))
     supportW1 = iLow(Symbol(),timeFrameSRW1,k);
   if(resistW1<iHigh(Symbol(),timeFrameSRW1,k))
     resistW1 = iHigh(Symbol(),timeFrameSRW1,k);

  } 
  //Print("S-W1",supportW1,"R-W1",resistW1);
double range1 =0;
 rangeUPprc =0.0;
   rangeDNprc =0.0;
  range1 = (resistW1-supportW1)*10000;
   double rangeUP = (Ask-resistW1)*10000;
    double rangeDN = (supportW1-Bid)*10000;
        rangeUPprc  =(rangeUP/range1*100);
      rangeDNprc  =(rangeDN/range1*100);
      ObjectSet("ZigZagD1dn2",OBJPROP_PRICE1,resistW1);
  ObjectSet("ZigZagD1dn22",OBJPROP_PRICE1,supportW1);
  
}


int Breakeven()
{
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
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber() == MAGICMA){
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
   
   

int CloseAll()
{ 
   bool rv = NO_ERROR;
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
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), SLIPPAGE, Red))
               rv = AT_LEAST_ONE_FAILED;
            break;

         case OP_SELL:
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), SLIPPAGE, Red))
               rv = AT_LEAST_ONE_FAILED;
            break;

         case OP_BUYLIMIT: 
         case OP_SELLLIMIT:
         case OP_BUYSTOP: 
         case OP_SELLSTOP:
            if (!OrderDelete(OrderTicket()))
               rv = AT_LEAST_ONE_FAILED;
            break;
      }
   }

   return(rv);
}
///ok11