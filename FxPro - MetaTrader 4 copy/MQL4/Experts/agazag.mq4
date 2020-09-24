//+------------------------------------------------------------------+
//|                                                       agazag.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

   double downzag, upzig;
   double Lots = 0.01;
   double MAGICMA = 334343;
   
   
int  buys =0;
int sells =0;
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





void start()
  {
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
        zigzag();
       CheckOpenTrades();
     
  }

void zigzag()
{  
    int n, i;
i=0;
while(n<2)
{
   if(upzig>0) downzag=upzig;
  // upzig=iCustom(NULL, 0, "ZigZag", 0, i);
   if(upzig>0) n+=1;
   i++;
} 
   Print("ZAG--",downzag,"-ZIG--",upzig); 
}


void CheckOpenTrades()
{
int res,res1;

     if(upzig > downzag)
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"1StTradeBUY",MAGICMA,0,Blue);
     return;
     }
     if(upzig < downzag) 
     {
      res1=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"1StTradeSELL",MAGICMA,0,Red);
     return;
     }


  }

  

