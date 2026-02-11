//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
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
      trade.PositionClose(_Symbol);
   }
}

void OnTick()
{
      if(TimeCurrent() - lastPrintTime >= 5)
   {
      Print("EA Running... Time: ", TimeCurrent());
      lastPrintTime = TimeCurrent();
   }
   if(IsPositionOpen())
   {
      ManagePosition();
      return;
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

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double riskMoney = balance * RiskPercent / 100.0;

// Gold 0.01 lot ≈ $1 per 1.0 move
double priceDistance = riskMoney;  

double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

// Get minimum stop distance
double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;

if(priceDistance < stopLevel)
   priceDistance = stopLevel + 10 * _Point;

// BUY
if(emaFastPrev < emaSlowPrev && emaFastCurr > emaSlowCurr)
{
   Print("BUY working");
   double sl = ask - priceDistance;
   trade.Buy(LotSize, _Symbol, ask, sl, 0);
   highestProfit = 0;
}

// SELL
if(emaFastPrev > emaSlowPrev && emaFastCurr < emaSlowCurr)
{  
   Print("Sell working");
   double sl = bid + priceDistance;
   trade.Sell(LotSize, _Symbol, bid, sl, 0);
   highestProfit = 0;
}

}

//+------------------------------------------------------------------+
