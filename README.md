# 📥 METATRADER 5 INSTALLATION GUIDE
## Step-by-Step Instructions for Installing the Multi-Strategy EA

---

## 🎯 METHOD 1: SIMPLE INSTALLATION (RECOMMENDED)

### **STEP 1: Download the EA File**
- You have the file: `MultiStrategy_EA.mq5`
- Save it to your Desktop or Downloads folder

### **STEP 2: Open MetaTrader 5**
- Launch your MT5 platform
- Make sure you're logged into your trading account

### **STEP 3: Open Data Folder**
- In MT5, click **File** (top menu)
- Click **Open Data Folder**
- A Windows Explorer window will open

### **STEP 4: Navigate to Experts Folder**
In the opened window, follow this path:
```
MQL5 → Experts
```
- Double-click on **MQL5** folder
- Then double-click on **Experts** folder

### **STEP 5: Copy the EA File**
- **Copy** the `MultiStrategy_EA.mq5` file
- **Paste** it into the **Experts** folder you just opened

### **STEP 6: Compile the EA**
Two options:

**Option A (Automatic):**
- Close and reopen MT5
- The EA will compile automatically

**Option B (Manual):**
- Press **F4** on your keyboard (opens MetaEditor)
- In MetaEditor, find `MultiStrategy_EA.mq5` in the Navigator panel (left side)
- Right-click on it → Click **Compile**
- Look for "0 errors" at the bottom
- Close MetaEditor

### **STEP 7: Attach EA to Chart**
- In MT5, open a chart (any currency pair, e.g., EUR/USD)
- In the **Navigator** panel (left side), expand **Expert Advisors**
- Find **MultiStrategy_EA**
- **Drag and drop** it onto your chart

### **STEP 8: Configure Settings**
A settings window will appear:

**Common Tab:**
- ✅ Check "Allow live trading"
- ✅ Check "Allow DLL imports" (if available)

**Inputs Tab:**
- Set your preferred risk settings
- Default settings are good to start
- Click **OK**

### **STEP 9: Enable AutoTrading**
- Look at the top toolbar in MT5
- Click the **"AutoTrading"** button (looks like a play button or triangle)
- It should turn GREEN when active
- You'll see a smiley face 😊 in the top-right corner of your chart

---

## 🎯 METHOD 2: DRAG & DROP INSTALLATION

### **Quick Method:**
1. Open MT5
2. Press **F4** to open MetaEditor
3. In MetaEditor, click **File → Open Data Folder**
4. Navigate to **MQL5 → Experts**
5. Simply **drag the .mq5 file** directly into this folder
6. Go back to MetaEditor
7. Press **F7** or click **Compile**
8. Close MetaEditor
9. The EA will appear in MT5 Navigator panel

---

## ⚙️ DETAILED CONFIGURATION

### **After EA is Attached to Chart:**

The settings window has multiple tabs. Here's what to configure:

### **📋 INPUTS TAB (Most Important)**

```
=== RISK MANAGEMENT ===
RiskPercent = 2.0          ← Start with 2% risk per trade
MaxDailyLoss = 15.0        ← Your $15 daily stop
TakeProfitPips = 50        ← Target profit (pips)
StopLossPips = 25          ← Maximum loss per trade (pips)
MagicNumber = 123456       ← Unique identifier (keep default)

=== STRATEGY TOGGLES ===
UseStrategy1_MA_Cross = true      ← Turn ON/OFF
UseStrategy2_RSI_BB = true        ← Turn ON/OFF
UseStrategy3_MACD_Trend = true    ← Turn ON/OFF

=== MOVING AVERAGE SETTINGS ===
FastMA_Period = 10         ← Fast MA (default 10)
SlowMA_Period = 30         ← Slow MA (default 30)

=== RSI SETTINGS ===
RSI_Period = 14           ← Standard RSI
RSI_Oversold = 30         ← Buy zone
RSI_Overbought = 70       ← Sell zone

=== BOLLINGER BANDS ===
BB_Period = 20            ← BB period
BB_Deviation = 2.0        ← Standard deviation

=== MACD SETTINGS ===
MACD_Fast = 12           ← Fast EMA
MACD_Slow = 26           ← Slow EMA
MACD_Signal = 9          ← Signal line

=== VISUAL SETTINGS ===
BuyArrowColor = Lime      ← Buy signal arrow color
SellArrowColor = Red      ← Sell signal arrow color
InfoTextColor = White     ← Dashboard text color
```

### **📋 COMMON TAB**

```
✅ Allow live trading             ← MUST BE CHECKED
✅ Allow DLL imports              ← Check if available
✅ Allow imports of external experts  ← Optional
Position: (optional)              ← Leave empty or set specific
Stop Loss: 0                      ← EA handles this
Take Profit: 0                    ← EA handles this
```

---

## ✅ VERIFICATION - IS IT WORKING?

### **Check 1: Visual Confirmation**
You should see on your chart:
- **Information panel** in top-left corner showing:
  - Balance
  - Equity
  - Daily P/L
  - Win rate
  - etc.

### **Check 2: Expert Advisors Tab**
- At the bottom of MT5, click **"Toolbox"** tab
- Click **"Experts"** sub-tab
- You should see messages like:
  ```
  Multi-Strategy EA Initialized Successfully!
  Strategies Active: MA Cross | RSI+BB | MACD Trend
  ```

### **Check 3: AutoTrading Status**
- Top-right corner of chart shows: 😊 (smiley face)
- If you see: 😐 (neutral face) → AutoTrading is OFF
- Click the AutoTrading button in toolbar to turn ON

### **Check 4: No Errors**
In the Experts tab, there should be NO red error messages

---

## 🔧 TROUBLESHOOTING

### **Problem: EA Not in Navigator Panel**

**Solution:**
1. Press **F4** to open MetaEditor
2. Navigate to **Experts** folder
3. Find `MultiStrategy_EA.mq5`
4. Right-click → **Compile**
5. Check for "0 errors, 0 warnings"
6. Close MetaEditor
7. Restart MT5

---

### **Problem: "Expert Advisor is not allowed to trade"**

**Solution:**
1. Right-click on chart → **Expert Advisors → Properties**
2. Go to **Common** tab
3. ✅ Check **"Allow live trading"**
4. Click **OK**
5. Click **AutoTrading** button in toolbar (should be GREEN)

---

### **Problem: No Dashboard Visible**

**Solution:**
1. The chart might be too zoomed out
2. Press **Ctrl + Mouse Wheel** to zoom in
3. Check top-left corner of chart
4. If still not visible, remove and re-attach EA

---

### **Problem: "Cannot open file" Error**

**Solution:**
1. Make sure file has **.mq5** extension (not .txt or .mq5.txt)
2. File must be in correct folder: `MQL5\Experts`
3. Try copying file again
4. Restart MT5

---

### **Problem: EA Opens Trades Immediately**

**Solution:**
This is normal IF:
- Market conditions match strategy signals
- Multiple strategies confirm the signal

If you want to test first:
1. Remove EA from live chart
2. Use **Strategy Tester** (see below)

---

## 🧪 TESTING BEFORE LIVE TRADING

### **How to Backtest the EA:**

1. In MT5, press **Ctrl + R** (opens Strategy Tester)

2. **Settings Tab:**
   - Expert Advisor: **MultiStrategy_EA**
   - Symbol: **EURUSD** (or your choice)
   - Period: **H1** (1 hour)
   - Date: Last **3 months**
   - Execution: **Every tick based on real ticks**

3. Click **"Start"** button

4. **Review Results:**
   - Check **Profit Factor** (should be > 1.5)
   - Check **Win Rate** (aim for > 60%)
   - Check **Max Drawdown** (should be reasonable)
   - Check **Total Profit**

5. **Optimization (Optional):**
   - Go to **Settings** tab
   - Check parameters you want to optimize
   - Click **"Start"** in **Optimization** tab
   - Find best parameter combination

---

## 📊 DEMO TESTING (RECOMMENDED)

### **Before Going Live:**

1. **Open Demo Account** in MT5
   - File → Open an Account → Select broker → Demo

2. **Attach EA to demo chart**

3. **Run for 1-2 weeks** to verify:
   - EA trades correctly
   - Risk management works
   - Daily loss limit functions
   - You're comfortable with results

4. **Only then** use on live account

---

## 🎯 FINAL CHECKLIST BEFORE GOING LIVE

Before trading real money, verify:

✅ EA compiled with 0 errors
✅ Attached to correct chart
✅ AutoTrading enabled (green button)
✅ Settings configured (risk %, loss limit)
✅ Backtested successfully
✅ Tested on demo account
✅ You understand how it works
✅ Broker allows EA trading
✅ Sufficient account balance
✅ You're comfortable with the risk

---

## 💡 RECOMMENDED SETUP

### **Best Chart Configuration:**

**Currency Pair:** EUR/USD, GBP/USD, or USD/JPY
**Timeframe:** H1 (1 hour) or M15 (15 minutes)
**Chart Type:** Candlesticks

### **Optimal Broker Requirements:**

- Low spreads (< 2 pips for majors)
- Fast execution (< 100ms)
- Allows Expert Advisors
- Reliable server uptime
- Good customer support

### **Computer/VPS Setup:**

**For 24/7 Trading:**
- Use VPS (Virtual Private Server)
- Stable internet connection
- MT5 never closes

**For Part-Time Trading:**
- Trade during active market hours
- European session: 8 AM - 12 PM GMT
- US session: 1 PM - 5 PM GMT

---

## 📞 QUICK REFERENCE

### **Common Keyboard Shortcuts:**

- **F4** = Open MetaEditor
- **Ctrl + R** = Open Strategy Tester
- **Ctrl + O** = Open Options/Settings
- **Ctrl + N** = Open Navigator panel
- **F1** = Help

### **AutoTrading Button Locations:**

**Toolbar:** Top of MT5 window
- Look for triangular "play" button
- Or button that says "Algo Trading"

**Chart Corner:** Top-right of each chart
- 😊 = EA active and trading allowed
- 😐 = EA disabled or trading not allowed

---

## ⚠️ IMPORTANT REMINDERS

1. **Never risk more than you can afford to lose**
2. **Start with small lot sizes** (0.01 or 0.02)
3. **Monitor the EA** regularly, especially first few days
4. **Respect the daily loss limit** - don't override it
5. **Keep MT5 running** for the EA to work (or use VPS)
6. **Check broker compatibility** before trading

---

## 🎓 LEARNING RESOURCES

### **Understanding the Dashboard:**

When EA is running, you'll see:

```
=== MULTI-STRATEGY EA ===
Balance: $1,000.00        ← Your account balance
Equity: $1,025.00         ← Current account value
Daily P/L: $25.00         ← Today's profit/loss (GREEN = profit, RED = loss)
Loss Limit: $40.00 remaining  ← Distance to $15 loss limit
Total Trades: 10          ← Trades since EA started
Win Rate: 70.0%           ← Winning percentage
Last: BUY: MA Cross BUY | RSI+BB BUY  ← Last signal details
Expected Profit: $100.00  ← What you'll make if TP hits
Current P/L: $15.50       ← Current open position profit
```

### **Understanding the Arrows:**

- 🟢 **UP ARROW (Green)** = BUY trade was opened here
- 🔴 **DOWN ARROW (Red)** = SELL trade was opened here

---

## 🎉 YOU'RE READY!

Once you see the dashboard and AutoTrading is green, your EA is fully operational!

**Tips for First Day:**
1. Watch it for first few hours
2. Check if signals make sense
3. Verify trades match your expectations
4. Confirm stop loss and take profit are set correctly
5. Monitor the daily P/L counter

**Good luck and happy trading! 🚀📈**

---

*If you encounter any issues not covered here, check the MT5 journal (Toolbox → Journal tab) for detailed error messages.*
