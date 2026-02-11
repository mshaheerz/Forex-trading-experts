//+------------------------------------------------------------------+
//|                                                 visual_trade.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>
CTrade trade;

input double LotSize = 0.01;
input double RiskPercent = 10;
input double TrailStartUSD = 20;
input double TrailLockUSD = 14;
input int FastEMA = 9;
input int SlowEMA = 21;
input int RSIPeriod = 14;
input double MaxSpread = 50;

double highestProfit = 0;

int emaFastHandle;
int emaSlowHandle;
int rsiHandle;
datetime lastPrintTime = 0;

double emaFastBuffer[];
double emaSlowBuffer[];
double rsiBuffer[];

int OnInit()
{
   emaFastHandle = iMA(_Symbol, PERIOD_CURRENT, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   emaSlowHandle = iMA(_Symbol, PERIOD_CURRENT, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, RSIPeriod, PRICE_CLOSE);

   if(emaFastHandle == INVALID_HANDLE || 
      emaSlowHandle == INVALID_HANDLE || 
      rsiHandle == INVALID_HANDLE)
      return(INIT_FAILED);

   // Show EMA lines on chart
   ChartIndicatorAdd(0,0,emaFastHandle);
   ChartIndicatorAdd(0,0,emaSlowHandle);

   return(INIT_SUCCEEDED);
}

bool IsPositionOpen()
{
   return PositionSelect(_Symbol);
}

void ManagePosition()
{
   if(!PositionSelect(_Symbol))
      return;

   double profit = PositionGetDouble(POSITION_PROFIT);

   if(profit > highestProfit)
      highestProfit = profit;

   if(highestProfit >= TrailStartUSD && profit <= TrailLockUSD)
   {
      Print("Trailing triggered. Closing position.");
      trade.PositionClose(_Symbol);
   }
}

void DrawArrow(string name,color clr,double price)
{
   ObjectCreate(0,name,OBJ_ARROW,0,TimeCurrent(),price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,233);
}

void OnTick()
{
   if(TimeCurrent() - lastPrintTime >= 5)
   {
      Print("EA Running... Time: ", TimeCurrent());
      lastPrintTime = TimeCurrent();
   }

   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > MaxSpread)
      return;

   CopyBuffer(emaFastHandle, 0, 0, 2, emaFastBuffer);
   CopyBuffer(emaSlowHandle, 0, 0, 2, emaSlowBuffer);
   CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer);

   double emaFastCurr = emaFastBuffer[0];
   double emaFastPrev = emaFastBuffer[1];
   double emaSlowCurr = emaSlowBuffer[0];
   double emaSlowPrev = emaSlowBuffer[1];
   double rsi = rsiBuffer[0];

   // Chart Info Panel
   Comment(
      "=== GOLD SCALP EA ===\n",
      "Fast EMA: ", DoubleToString(emaFastCurr,2), "\n",
      "Slow EMA: ", DoubleToString(emaSlowCurr,2), "\n",
      "RSI: ", DoubleToString(rsi,2), "\n",
      "Spread: ", SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), "\n",
      "Highest Profit: ", DoubleToString(highestProfit,2)
   );

   if(IsPositionOpen())
   {
      ManagePosition();
      return;
   }

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * RiskPercent / 100.0;

   double priceDistance = riskMoney;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;

   if(priceDistance < stopLevel)
      priceDistance = stopLevel + 10 * _Point;

   // BUY
   if(emaFastPrev < emaSlowPrev && emaFastCurr > emaSlowCurr)
   {
      Print("BUY working");

      double sl = ask - priceDistance;
      if(trade.Buy(LotSize, _Symbol, ask, sl, 0))
      {
         DrawArrow("Buy_"+TimeToString(TimeCurrent()),clrGreen,ask);
         highestProfit = 0;
      }
   }

   // SELL
   if(emaFastPrev > emaSlowPrev && emaFastCurr < emaSlowCurr)
   {  
      Print("Sell working");

      double sl = bid + priceDistance;
      if(trade.Sell(LotSize, _Symbol, bid, sl, 0))
      {
         DrawArrow("Sell_"+TimeToString(TimeCurrent()),clrRed,bid);
         highestProfit = 0;
      }
   }
}
