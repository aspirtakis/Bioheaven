//#define SLIPPAGE              3
#define NO_ERROR              1
#define AT_LEAST_ONE_FAILED   2

extern int MAGICMA = 993010;
 
 extern double distance = 70;
 extern double Lots  =0.01;
 
bool tradesells =true;
bool tradebuys = true;
 extern double maxorders = 5;
double maxsells = maxorders;
double maxbuys = maxorders;

 
 double targetprofit = Lots*600;
 
 double distancebuy =  distance;
 double distancesell =  distance;
 double Lots2  =Lots*2;



///DISTANCES ARE ON POINTS 
 bool closing =true ;

 double TargetBasket = targetprofit/3 ;


bool BreakEnabled =false;
int breakeven =distancebuy/2; //POSO NA PAREi
int breakevengain =distancebuy; ///POTE NA MPEI 
 
bool sosbuy = false;
bool sossell = false;

double Lots1,Lots2sell,Lots2buy,Lots4,Lots5,Lots6,Lots7,SosSelllot,SosBuylot;
double lastbdistance;
double lastsdistance;
int direction = 0;
double downzag,upzig;
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
double  sum_profitbuy=0,  sum_profitsell =0,  lastbuyopenprice=0, lastsellopenprice=0;


void breaks()
{
if(buys == 4 && sells == 4 )
{
BreakEnabled = true;

}
if(buys < 4 && sells < 4 )
{
BreakEnabled = false;

}
}


void maxtrades()
{

if(direction == 1 )
 {
  maxsells = 3;
 maxbuys = 5;
 
 }
   if(direction == 2 )
 {
  maxsells = 5;
 maxbuys = 3;
 }
 else  if(direction == 0)
 
 {
  maxsells = maxsells;
 maxbuys = maxbuys;
 }

}


void start()
  {
  
   if(Bars<100 || IsTradeAllowed()==false) return;
   zigzag();

   counttrades();
    CheckForOpen();
    CheckForClose();
  }


int CheckForClose()
{
if (sells <= 2 && buys <=2){
closing =true;
if(sumbuy >= targetprofit)
{
closebuy();
}
if(sumsell >= targetprofit)
{
closesell();

}
}


if (sells >= 3 || buys >= 3){
    if(sumbasket > TargetBasket )
    {
    closing =true;
    closebuy();
    closesell();
    }
}
else
{
closing = false ;
}

}

void Sos()
{
if (buys >= 4 && sells <= 4){
sossell = true;
sosbuy = false;
}
if (buys <= 4 && sells >= 4){
sossell = false;
sosbuy = true;

}
else 
{
sosbuy = false;
sossell=false;
}



}
 
 
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
  // Print("ZAG--",downzag,"-ZIG--",upzig); 
}



void CheckForOpen()
  {
     if(Volume[0]>1) return;
   RefreshRates();
   int    res;
   

  
     ////---- sell conditions
    Comment(StringFormat("DistanceSELL=%G\DistanceBUY =%G\nLAST-BUY=%G\LAST-SELL=%G\nSUMBASKET=%G\TARGETBASKET=%G\TARGETPROFIT=%G\nSUMSELLS =%G\SUMBUYS=%d\SELLS=%G\BUYS=%G\n\nTrSELLS=%G\--TrBUYS=%G\n\n\LOTSSELL=%G\LOTBUY=%G\nnLASTSLOT=%G\LASTBUYLOT=%G\LastTYPE=%G\nBSKLOT=%G\BSKLOT2=%G\n\nLot=%G\SOSLOTBUY=%G\SOSLOTSELL=%G\LOT2BUY=%G\LOT2SELL=%G\nD1=%G\M15=%G\H1=%G\H4=%G\ADX=%G\DIRECTION=%G",distancesell,distancebuy,lastbdistance,lastsdistance,sumbasket,TargetBasket,targetprofit,sumsell,sumbuy,sells,buys,maxsells,maxbuys,sumlotssell,sumlotsbuy,lastselllot,lastbuylot,lastordtype,sumbasketlot,sumbasketlot2,Lots,SosBuylot,SosSelllot,Lots2buy,Lots2sell,td,td5,tdd4,tdd3,adx,direction));
 
     if(tradebuys == true && buys < maxbuys && upzig > downzag && buys == 0 )
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"1StTradeBUY",MAGICMA,0,Blue);
     return;
     }
       if(sosbuy == false && tradebuys == true && buys < maxbuys && upzig > downzag && buys >= 1 && (Ask < lastbuyopenprice-distancebuy*Point ))
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"2StTradeBUY",MAGICMA,0,Blue);
     return;
     }
 
          if(sosbuy == true && tradebuys == true && buys < maxbuys && upzig > downzag && buys >= 1 &&  (Ask < lastbuyopenprice-distancebuy*Point ||Ask > lastbuyopenprice+distancebuy*Point))
     {
      res=OrderSend(Symbol(),OP_BUY,Lots2,Ask,3,0,0,"2StTradeBUY",MAGICMA,0,Blue);
     return;
     }
     
    

     if(tradesells == true && sells < maxsells && upzig < downzag && sells == 0) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"1StTradeSELL",MAGICMA,0,Red);
     return;
     }
      if(sossell == false && tradesells == true && sells < maxsells  && upzig < downzag && sells >=1  && (Bid > lastsellopenprice+distancesell*Point)) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"2StTradeSELL",MAGICMA,0,Red);
     return;
     }

     if(sossell == true && tradesells == true && sells < maxsells  && upzig < downzag && sells >=1  &&  (Bid > lastsellopenprice+distancesell*Point ||Bid < lastsellopenprice-distancesell*Point)) 
     {
      res=OrderSend(Symbol(),OP_SELL,Lots2,Bid,3,0,0,"2StTradeSELL",MAGICMA,0,Red);
     return;
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
      if(OrderSymbol()==Symbol()&& OrderMagicNumber() == MAGICMA )// 
   
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
   RefreshRates();
   double  current_ma1, current_ma2, current_ma3;
   double  current_ma15, current_ma25, current_ma35;
   double  current_ma11, current_ma21, current_ma31 ;
   double  current_ma111, current_ma211, current_ma311;
   double  current_d1, current_d2, current_d3;
   
   
   adx=iADX(NULL, PERIOD_H4, 14, PRICE_CLOSE, MODE_MAIN, 0);
   
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
  return(td5);//M15
  return(td);//D1
  return(tdd);//M5
  return(tdd3);//H4
  return(tdd4);//H1

}
void fixDirection()///TREND DIRECTION
{

if( td ==1  && tdd3 ==1   )
{
direction = 1;
}
if( td ==2   && tdd3 ==2    )
{
direction = 2;
}
else {
direction =0;
}

}