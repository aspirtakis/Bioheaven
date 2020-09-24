#property show_inputs
//#property show_confirm


extern double StopBuyPrice = 1.00000;
extern double Lots = 0.10;
extern int Slippage   = 3;
extern int Stop_Loss  = 0;
extern int Take_Profit = 0;


   //global
double Poin;

//+-------------------------------------------------+
//| script "Open new Buy Stop NonLag Basket Orders" |
//+-------------------------------------------------+
void start(){
  
   
   
   int    slippage;
   
      
   
   
   double take_profit1;
   double stop_loss1;
   
  

   
   
   if (Point == 0.00001) Poin = 0.0001; 
   else if (Point == 0.001) Poin = 0.01; 
   else Poin = Point; 

   
   
   slippage = Slippage*Poin;
   
      
  
    
    
   
    stop_loss1 = StopBuyPrice - Stop_Loss * Poin;
    
    
    take_profit1 = StopBuyPrice + Take_Profit * Poin; 
    
   
   int tick = OrderSend(Symbol(),OP_BUYSTOP,Lots,StopBuyPrice,slippage,stop_loss1,take_profit1,"NonLag Basket",11699,0,CLR_NONE);
   
  
//----
   
  }
//+------------------------------------------------------------------+