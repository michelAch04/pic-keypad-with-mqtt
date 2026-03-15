package b4a.example;


import anywheresoftware.b4a.B4AMenuItem;
import android.app.Activity;
import android.os.Bundle;
import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.B4AActivity;
import anywheresoftware.b4a.ObjectWrapper;
import anywheresoftware.b4a.objects.ActivityWrapper;
import java.lang.reflect.InvocationTargetException;
import anywheresoftware.b4a.B4AUncaughtException;
import anywheresoftware.b4a.debug.*;
import java.lang.ref.WeakReference;

public class main extends Activity implements B4AActivity{
	public static main mostCurrent;
	static boolean afterFirstLayout;
	static boolean isFirst = true;
    private static boolean processGlobalsRun = false;
	BALayout layout;
	public static BA processBA;
	BA activityBA;
    ActivityWrapper _activity;
    java.util.ArrayList<B4AMenuItem> menuItems;
	public static final boolean fullScreen = false;
	public static final boolean includeTitle = true;
    public static WeakReference<Activity> previousOne;
    public static boolean dontPause;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        mostCurrent = this;
		if (processBA == null) {
			processBA = new BA(this.getApplicationContext(), null, null, "b4a.example", "b4a.example.main");
			processBA.loadHtSubs(this.getClass());
	        float deviceScale = getApplicationContext().getResources().getDisplayMetrics().density;
	        BALayout.setDeviceScale(deviceScale);
            
		}
		else if (previousOne != null) {
			Activity p = previousOne.get();
			if (p != null && p != this) {
                BA.LogInfo("Killing previous instance (main).");
				p.finish();
			}
		}
        processBA.setActivityPaused(true);
        processBA.runHook("oncreate", this, null);
		if (!includeTitle) {
        	this.getWindow().requestFeature(android.view.Window.FEATURE_NO_TITLE);
        }
        if (fullScreen) {
        	getWindow().setFlags(android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN,   
        			android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
		
        processBA.sharedProcessBA.activityBA = null;
		layout = new BALayout(this);
		setContentView(layout);
		afterFirstLayout = false;
        WaitForLayout wl = new WaitForLayout();
        if (anywheresoftware.b4a.objects.ServiceHelper.StarterHelper.startFromActivity(this, processBA, wl, false))
		    BA.handler.postDelayed(wl, 5);

	}
	static class WaitForLayout implements Runnable {
		public void run() {
			if (afterFirstLayout)
				return;
			if (mostCurrent == null)
				return;
            
			if (mostCurrent.layout.getWidth() == 0) {
				BA.handler.postDelayed(this, 5);
				return;
			}
			mostCurrent.layout.getLayoutParams().height = mostCurrent.layout.getHeight();
			mostCurrent.layout.getLayoutParams().width = mostCurrent.layout.getWidth();
			afterFirstLayout = true;
			mostCurrent.afterFirstLayout();
		}
	}
	private void afterFirstLayout() {
        if (this != mostCurrent)
			return;
		activityBA = new BA(this, layout, processBA, "b4a.example", "b4a.example.main");
        
        processBA.sharedProcessBA.activityBA = new java.lang.ref.WeakReference<BA>(activityBA);
        anywheresoftware.b4a.objects.ViewWrapper.lastId = 0;
        _activity = new ActivityWrapper(activityBA, "activity");
        anywheresoftware.b4a.Msgbox.isDismissing = false;
        if (BA.isShellModeRuntimeCheck(processBA)) {
			if (isFirst)
				processBA.raiseEvent2(null, true, "SHELL", false);
			processBA.raiseEvent2(null, true, "CREATE", true, "b4a.example.main", processBA, activityBA, _activity, anywheresoftware.b4a.keywords.Common.Density, mostCurrent);
			_activity.reinitializeForShell(activityBA, "activity");
		}
        initializeProcessGlobals();		
        initializeGlobals();
        
        BA.LogInfo("** Activity (main) Create, isFirst = " + isFirst + " **");
        processBA.raiseEvent2(null, true, "activity_create", false, isFirst);
		isFirst = false;
		if (this != mostCurrent)
			return;
        processBA.setActivityPaused(false);
        BA.LogInfo("** Activity (main) Resume **");
        processBA.raiseEvent(null, "activity_resume");
        if (android.os.Build.VERSION.SDK_INT >= 11) {
			try {
				android.app.Activity.class.getMethod("invalidateOptionsMenu").invoke(this,(Object[]) null);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

	}
	public void addMenuItem(B4AMenuItem item) {
		if (menuItems == null)
			menuItems = new java.util.ArrayList<B4AMenuItem>();
		menuItems.add(item);
	}
	@Override
	public boolean onCreateOptionsMenu(android.view.Menu menu) {
		super.onCreateOptionsMenu(menu);
        try {
            if (processBA.subExists("activity_actionbarhomeclick")) {
                Class.forName("android.app.ActionBar").getMethod("setHomeButtonEnabled", boolean.class).invoke(
                    getClass().getMethod("getActionBar").invoke(this), true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (processBA.runHook("oncreateoptionsmenu", this, new Object[] {menu}))
            return true;
		if (menuItems == null)
			return false;
		for (B4AMenuItem bmi : menuItems) {
			android.view.MenuItem mi = menu.add(bmi.title);
			if (bmi.drawable != null)
				mi.setIcon(bmi.drawable);
            if (android.os.Build.VERSION.SDK_INT >= 11) {
				try {
                    if (bmi.addToBar) {
				        android.view.MenuItem.class.getMethod("setShowAsAction", int.class).invoke(mi, 1);
                    }
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			mi.setOnMenuItemClickListener(new B4AMenuItemsClickListener(bmi.eventName.toLowerCase(BA.cul)));
		}
        
		return true;
	}   
 @Override
 public boolean onOptionsItemSelected(android.view.MenuItem item) {
    if (item.getItemId() == 16908332) {
        processBA.raiseEvent(null, "activity_actionbarhomeclick");
        return true;
    }
    else
        return super.onOptionsItemSelected(item); 
}
@Override
 public boolean onPrepareOptionsMenu(android.view.Menu menu) {
    super.onPrepareOptionsMenu(menu);
    processBA.runHook("onprepareoptionsmenu", this, new Object[] {menu});
    return true;
    
 }
 protected void onStart() {
    super.onStart();
    processBA.runHook("onstart", this, null);
}
 protected void onStop() {
    super.onStop();
    processBA.runHook("onstop", this, null);
}
    public void onWindowFocusChanged(boolean hasFocus) {
       super.onWindowFocusChanged(hasFocus);
       if (processBA.subExists("activity_windowfocuschanged"))
           processBA.raiseEvent2(null, true, "activity_windowfocuschanged", false, hasFocus);
    }
	private class B4AMenuItemsClickListener implements android.view.MenuItem.OnMenuItemClickListener {
		private final String eventName;
		public B4AMenuItemsClickListener(String eventName) {
			this.eventName = eventName;
		}
		public boolean onMenuItemClick(android.view.MenuItem item) {
			processBA.raiseEventFromUI(item.getTitle(), eventName + "_click");
			return true;
		}
	}
    public static Class<?> getObject() {
		return main.class;
	}
    private Boolean onKeySubExist = null;
    private Boolean onKeyUpSubExist = null;
	@Override
	public boolean onKeyDown(int keyCode, android.view.KeyEvent event) {
        if (processBA.runHook("onkeydown", this, new Object[] {keyCode, event}))
            return true;
		if (onKeySubExist == null)
			onKeySubExist = processBA.subExists("activity_keypress");
		if (onKeySubExist) {
			if (keyCode == anywheresoftware.b4a.keywords.constants.KeyCodes.KEYCODE_BACK &&
					android.os.Build.VERSION.SDK_INT >= 18) {
				HandleKeyDelayed hk = new HandleKeyDelayed();
				hk.kc = keyCode;
				BA.handler.post(hk);
				return true;
			}
			else {
				boolean res = new HandleKeyDelayed().runDirectly(keyCode);
				if (res)
					return true;
			}
		}
		return super.onKeyDown(keyCode, event);
	}
	private class HandleKeyDelayed implements Runnable {
		int kc;
		public void run() {
			runDirectly(kc);
		}
		public boolean runDirectly(int keyCode) {
			Boolean res =  (Boolean)processBA.raiseEvent2(_activity, false, "activity_keypress", false, keyCode);
			if (res == null || res == true) {
                return true;
            }
            else if (keyCode == anywheresoftware.b4a.keywords.constants.KeyCodes.KEYCODE_BACK) {
				finish();
				return true;
			}
            return false;
		}
		
	}
    @Override
	public boolean onKeyUp(int keyCode, android.view.KeyEvent event) {
        if (processBA.runHook("onkeyup", this, new Object[] {keyCode, event}))
            return true;
		if (onKeyUpSubExist == null)
			onKeyUpSubExist = processBA.subExists("activity_keyup");
		if (onKeyUpSubExist) {
			Boolean res =  (Boolean)processBA.raiseEvent2(_activity, false, "activity_keyup", false, keyCode);
			if (res == null || res == true)
				return true;
		}
		return super.onKeyUp(keyCode, event);
	}
	@Override
	public void onNewIntent(android.content.Intent intent) {
        super.onNewIntent(intent);
		this.setIntent(intent);
        processBA.runHook("onnewintent", this, new Object[] {intent});
	}
    @Override 
	public void onPause() {
		super.onPause();
        if (_activity == null)
            return;
        if (this != mostCurrent)
			return;
		anywheresoftware.b4a.Msgbox.dismiss(true);
        if (!dontPause)
            BA.LogInfo("** Activity (main) Pause, UserClosed = " + activityBA.activity.isFinishing() + " **");
        else
            BA.LogInfo("** Activity (main) Pause event (activity is not paused). **");
        if (mostCurrent != null)
            processBA.raiseEvent2(_activity, true, "activity_pause", false, activityBA.activity.isFinishing());		
        if (!dontPause) {
            processBA.setActivityPaused(true);
            mostCurrent = null;
        }

        if (!activityBA.activity.isFinishing())
			previousOne = new WeakReference<Activity>(this);
        anywheresoftware.b4a.Msgbox.isDismissing = false;
        processBA.runHook("onpause", this, null);
	}

	@Override
	public void onDestroy() {
        super.onDestroy();
		previousOne = null;
        processBA.runHook("ondestroy", this, null);
	}
    @Override 
	public void onResume() {
		super.onResume();
        mostCurrent = this;
        anywheresoftware.b4a.Msgbox.isDismissing = false;
        if (activityBA != null) { //will be null during activity create (which waits for AfterLayout).
        	ResumeMessage rm = new ResumeMessage(mostCurrent);
        	BA.handler.post(rm);
        }
        processBA.runHook("onresume", this, null);
	}
    private static class ResumeMessage implements Runnable {
    	private final WeakReference<Activity> activity;
    	public ResumeMessage(Activity activity) {
    		this.activity = new WeakReference<Activity>(activity);
    	}
		public void run() {
            main mc = mostCurrent;
			if (mc == null || mc != activity.get())
				return;
			processBA.setActivityPaused(false);
            BA.LogInfo("** Activity (main) Resume **");
            if (mc != mostCurrent)
                return;
		    processBA.raiseEvent(mc._activity, "activity_resume", (Object[])null);
		}
    }
	@Override
	protected void onActivityResult(int requestCode, int resultCode,
	      android.content.Intent data) {
		processBA.onActivityResult(requestCode, resultCode, data);
        processBA.runHook("onactivityresult", this, new Object[] {requestCode, resultCode});
	}
	private static void initializeGlobals() {
		processBA.raiseEvent2(null, true, "globals", false, (Object[])null);
	}
    public void onRequestPermissionsResult(int requestCode,
        String permissions[], int[] grantResults) {
        for (int i = 0;i < permissions.length;i++) {
            Object[] o = new Object[] {permissions[i], grantResults[i] == 0};
            processBA.raiseEventFromDifferentThread(null,null, 0, "activity_permissionresult", true, o);
        }
            
    }

public anywheresoftware.b4a.keywords.Common __c = null;
public static anywheresoftware.b4j.objects.MqttAsyncClientWrapper _mqtt = null;
public static String _broker_url = "";
public static String _client_id = "";
public static String _topic_ascii = "";
public anywheresoftware.b4a.objects.LabelWrapper _lblconnectionstatus = null;
public anywheresoftware.b4a.objects.EditTextWrapper _txtcharacters = null;
public anywheresoftware.b4a.objects.ButtonWrapper _btnclear = null;
public anywheresoftware.b4a.objects.PanelWrapper _pnlmatrix = null;
public anywheresoftware.b4a.objects.PanelWrapper[][] _matrixcells = null;
public static int _cell_size = 0;
public static int _cell_margin = 0;
public static int _currentascii = 0;
public b4a.example.starter _starter = null;

public static boolean isAnyActivityVisible() {
    boolean vis = false;
vis = vis | (main.mostCurrent != null);
return vis;}
public static String  _activity_create(boolean _firsttime) throws Exception{
 //BA.debugLineNum = 44;BA.debugLine="Sub Activity_Create(FirstTime As Boolean)";
 //BA.debugLineNum = 48;BA.debugLine="CreateUI";
_createui();
 //BA.debugLineNum = 51;BA.debugLine="SetupMQTT";
_setupmqtt();
 //BA.debugLineNum = 54;BA.debugLine="UpdateDisplay(currentASCII)";
_updatedisplay(_currentascii);
 //BA.debugLineNum = 55;BA.debugLine="End Sub";
return "";
}
public static String  _activity_pause(boolean _userclosed) throws Exception{
 //BA.debugLineNum = 64;BA.debugLine="Sub Activity_Pause (UserClosed As Boolean)";
 //BA.debugLineNum = 66;BA.debugLine="If UserClosed Then";
if (_userclosed) { 
 //BA.debugLineNum = 67;BA.debugLine="If mqtt.Connected Then";
if (_mqtt.getConnected()) { 
 //BA.debugLineNum = 68;BA.debugLine="mqtt.Close";
_mqtt.Close();
 };
 };
 //BA.debugLineNum = 71;BA.debugLine="End Sub";
return "";
}
public static String  _activity_resume() throws Exception{
 //BA.debugLineNum = 57;BA.debugLine="Sub Activity_Resume";
 //BA.debugLineNum = 59;BA.debugLine="If mqtt.Connected = False Then";
if (_mqtt.getConnected()==anywheresoftware.b4a.keywords.Common.False) { 
 //BA.debugLineNum = 60;BA.debugLine="ConnectMQTT";
_connectmqtt();
 };
 //BA.debugLineNum = 62;BA.debugLine="End Sub";
return "";
}
public static String  _btnclear_click() throws Exception{
int _col = 0;
int _row = 0;
 //BA.debugLineNum = 159;BA.debugLine="Sub btnClear_Click";
 //BA.debugLineNum = 161;BA.debugLine="txtCharacters.Text = \"\"";
mostCurrent._txtcharacters.setText(BA.ObjectToCharSequence(""));
 //BA.debugLineNum = 164;BA.debugLine="For col = 0 To 4";
{
final int step2 = 1;
final int limit2 = (int) (4);
_col = (int) (0) ;
for (;_col <= limit2 ;_col = _col + step2 ) {
 //BA.debugLineNum = 165;BA.debugLine="For row = 0 To 6";
{
final int step3 = 1;
final int limit3 = (int) (6);
_row = (int) (0) ;
for (;_row <= limit3 ;_row = _row + step3 ) {
 //BA.debugLineNum = 166;BA.debugLine="matrixCells(col, row).Color = Colors.Black";
mostCurrent._matrixcells[_col][_row].setColor(anywheresoftware.b4a.keywords.Common.Colors.Black);
 }
};
 }
};
 //BA.debugLineNum = 170;BA.debugLine="Log(\"Display cleared\")";
anywheresoftware.b4a.keywords.Common.LogImpl("71835019","Display cleared",0);
 //BA.debugLineNum = 171;BA.debugLine="End Sub";
return "";
}
public static String  _connectmqtt() throws Exception{
 //BA.debugLineNum = 185;BA.debugLine="Sub ConnectMQTT";
 //BA.debugLineNum = 186;BA.debugLine="Try";
try { //BA.debugLineNum = 187;BA.debugLine="lblConnectionStatus.Text = \"Connecting to MQTT..";
mostCurrent._lblconnectionstatus.setText(BA.ObjectToCharSequence("Connecting to MQTT..."));
 //BA.debugLineNum = 188;BA.debugLine="lblConnectionStatus.Color = Colors.RGB(255, 165,";
mostCurrent._lblconnectionstatus.setColor(anywheresoftware.b4a.keywords.Common.Colors.RGB((int) (255),(int) (165),(int) (0)));
 //BA.debugLineNum = 190;BA.debugLine="mqtt.Connect";
_mqtt.Connect();
 } 
       catch (Exception e6) {
			processBA.setLastException(e6); //BA.debugLineNum = 193;BA.debugLine="Log(\"MQTT Connection Error: \" & LastException)";
anywheresoftware.b4a.keywords.Common.LogImpl("7917512","MQTT Connection Error: "+BA.ObjectToString(anywheresoftware.b4a.keywords.Common.LastException(mostCurrent.activityBA)),0);
 //BA.debugLineNum = 194;BA.debugLine="lblConnectionStatus.Text = \"Connection Failed\"";
mostCurrent._lblconnectionstatus.setText(BA.ObjectToCharSequence("Connection Failed"));
 //BA.debugLineNum = 195;BA.debugLine="lblConnectionStatus.Color = Colors.Red";
mostCurrent._lblconnectionstatus.setColor(anywheresoftware.b4a.keywords.Common.Colors.Red);
 };
 //BA.debugLineNum = 197;BA.debugLine="End Sub";
return "";
}
public static String  _createui() throws Exception{
int _screenwidth = 0;
int _screenheight = 0;
int _matrixstarty = 0;
int _matrixwidth = 0;
int _matrixheight = 0;
int _matrixx = 0;
int _col = 0;
int _row = 0;
anywheresoftware.b4a.objects.PanelWrapper _cell = null;
int _cellx = 0;
int _celly = 0;
 //BA.debugLineNum = 77;BA.debugLine="Sub CreateUI";
 //BA.debugLineNum = 79;BA.debugLine="Activity.Color = Colors.RGB(240, 240, 240)";
mostCurrent._activity.setColor(anywheresoftware.b4a.keywords.Common.Colors.RGB((int) (240),(int) (240),(int) (240)));
 //BA.debugLineNum = 82;BA.debugLine="Dim screenWidth As Int = 100%x";
_screenwidth = anywheresoftware.b4a.keywords.Common.PerXToCurrent((float) (100),mostCurrent.activityBA);
 //BA.debugLineNum = 83;BA.debugLine="Dim screenHeight As Int = 100%y";
_screenheight = anywheresoftware.b4a.keywords.Common.PerYToCurrent((float) (100),mostCurrent.activityBA);
 //BA.debugLineNum = 88;BA.debugLine="lblConnectionStatus.Initialize(\"lblConnectionStat";
mostCurrent._lblconnectionstatus.Initialize(mostCurrent.activityBA,"lblConnectionStatus");
 //BA.debugLineNum = 89;BA.debugLine="lblConnectionStatus.Text = \"Disconnected\"";
mostCurrent._lblconnectionstatus.setText(BA.ObjectToCharSequence("Disconnected"));
 //BA.debugLineNum = 90;BA.debugLine="lblConnectionStatus.TextSize = 14";
mostCurrent._lblconnectionstatus.setTextSize((float) (14));
 //BA.debugLineNum = 91;BA.debugLine="lblConnectionStatus.TextColor = Colors.White";
mostCurrent._lblconnectionstatus.setTextColor(anywheresoftware.b4a.keywords.Common.Colors.White);
 //BA.debugLineNum = 92;BA.debugLine="lblConnectionStatus.Color = Colors.Red";
mostCurrent._lblconnectionstatus.setColor(anywheresoftware.b4a.keywords.Common.Colors.Red);
 //BA.debugLineNum = 93;BA.debugLine="lblConnectionStatus.Gravity = Gravity.CENTER";
mostCurrent._lblconnectionstatus.setGravity(anywheresoftware.b4a.keywords.Common.Gravity.CENTER);
 //BA.debugLineNum = 94;BA.debugLine="Activity.AddView(lblConnectionStatus, 0, 0, scree";
mostCurrent._activity.AddView((android.view.View)(mostCurrent._lblconnectionstatus.getObject()),(int) (0),(int) (0),_screenwidth,anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (40)));
 //BA.debugLineNum = 103;BA.debugLine="txtCharacters.Initialize(\"txtCharacters\")";
mostCurrent._txtcharacters.Initialize(mostCurrent.activityBA,"txtCharacters");
 //BA.debugLineNum = 104;BA.debugLine="txtCharacters.Text = \"\"";
mostCurrent._txtcharacters.setText(BA.ObjectToCharSequence(""));
 //BA.debugLineNum = 105;BA.debugLine="txtCharacters.TextSize = 20";
mostCurrent._txtcharacters.setTextSize((float) (20));
 //BA.debugLineNum = 106;BA.debugLine="txtCharacters.TextColor = Colors.Black";
mostCurrent._txtcharacters.setTextColor(anywheresoftware.b4a.keywords.Common.Colors.Black);
 //BA.debugLineNum = 107;BA.debugLine="txtCharacters.Gravity = Gravity.LEFT + Gravity.CE";
mostCurrent._txtcharacters.setGravity((int) (anywheresoftware.b4a.keywords.Common.Gravity.LEFT+anywheresoftware.b4a.keywords.Common.Gravity.CENTER_VERTICAL));
 //BA.debugLineNum = 108;BA.debugLine="txtCharacters.Hint = \"Characters will appear here";
mostCurrent._txtcharacters.setHint("Characters will appear here...");
 //BA.debugLineNum = 109;BA.debugLine="txtCharacters.InputType = txtCharacters.INPUT_TYP";
mostCurrent._txtcharacters.setInputType(mostCurrent._txtcharacters.INPUT_TYPE_NONE);
 //BA.debugLineNum = 110;BA.debugLine="Activity.AddView(txtCharacters, 10dip, 50dip, scr";
mostCurrent._activity.AddView((android.view.View)(mostCurrent._txtcharacters.getObject()),anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (10)),anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (50)),(int) (_screenwidth-anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (20))),anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (60)));
 //BA.debugLineNum = 115;BA.debugLine="btnClear.Initialize(\"btnClear\")";
mostCurrent._btnclear.Initialize(mostCurrent.activityBA,"btnClear");
 //BA.debugLineNum = 116;BA.debugLine="btnClear.Text = \"CLEAR\"";
mostCurrent._btnclear.setText(BA.ObjectToCharSequence("CLEAR"));
 //BA.debugLineNum = 117;BA.debugLine="btnClear.TextSize = 16";
mostCurrent._btnclear.setTextSize((float) (16));
 //BA.debugLineNum = 118;BA.debugLine="btnClear.Color = Colors.RGB(220, 53, 69)  'Red bu";
mostCurrent._btnclear.setColor(anywheresoftware.b4a.keywords.Common.Colors.RGB((int) (220),(int) (53),(int) (69)));
 //BA.debugLineNum = 119;BA.debugLine="btnClear.TextColor = Colors.White";
mostCurrent._btnclear.setTextColor(anywheresoftware.b4a.keywords.Common.Colors.White);
 //BA.debugLineNum = 120;BA.debugLine="Activity.AddView(btnClear, 10dip, 120dip, screenW";
mostCurrent._activity.AddView((android.view.View)(mostCurrent._btnclear.getObject()),anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (10)),anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (120)),(int) (_screenwidth-anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (20))),anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (50)));
 //BA.debugLineNum = 125;BA.debugLine="pnlMatrix.Initialize(\"pnlMatrix\")";
mostCurrent._pnlmatrix.Initialize(mostCurrent.activityBA,"pnlMatrix");
 //BA.debugLineNum = 126;BA.debugLine="pnlMatrix.Color = Colors.RGB(50, 50, 50)  'Dark g";
mostCurrent._pnlmatrix.setColor(anywheresoftware.b4a.keywords.Common.Colors.RGB((int) (50),(int) (50),(int) (50)));
 //BA.debugLineNum = 129;BA.debugLine="Dim matrixStartY As Int = 180dip";
_matrixstarty = anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (180));
 //BA.debugLineNum = 130;BA.debugLine="Dim matrixWidth As Int = Min(screenWidth - 40dip,";
_matrixwidth = (int) (anywheresoftware.b4a.keywords.Common.Min(_screenwidth-anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (40)),anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (400))));
 //BA.debugLineNum = 131;BA.debugLine="Dim matrixHeight As Int = matrixWidth * 7 / 5  'M";
_matrixheight = (int) (_matrixwidth*7/(double)5);
 //BA.debugLineNum = 133;BA.debugLine="CELL_SIZE = (matrixWidth - (6 * CELL_MARGIN)) / 5";
_cell_size = (int) ((_matrixwidth-(6*_cell_margin))/(double)5);
 //BA.debugLineNum = 136;BA.debugLine="Dim matrixX As Int = (screenWidth - matrixWidth)";
_matrixx = (int) ((_screenwidth-_matrixwidth)/(double)2);
 //BA.debugLineNum = 137;BA.debugLine="Activity.AddView(pnlMatrix, matrixX, matrixStartY";
mostCurrent._activity.AddView((android.view.View)(mostCurrent._pnlmatrix.getObject()),_matrixx,_matrixstarty,_matrixwidth,_matrixheight);
 //BA.debugLineNum = 140;BA.debugLine="For col = 0 To 4";
{
final int step33 = 1;
final int limit33 = (int) (4);
_col = (int) (0) ;
for (;_col <= limit33 ;_col = _col + step33 ) {
 //BA.debugLineNum = 141;BA.debugLine="For row = 0 To 6";
{
final int step34 = 1;
final int limit34 = (int) (6);
_row = (int) (0) ;
for (;_row <= limit34 ;_row = _row + step34 ) {
 //BA.debugLineNum = 142;BA.debugLine="Dim cell As Panel";
_cell = new anywheresoftware.b4a.objects.PanelWrapper();
 //BA.debugLineNum = 143;BA.debugLine="cell.Initialize(\"\")";
_cell.Initialize(mostCurrent.activityBA,"");
 //BA.debugLineNum = 144;BA.debugLine="cell.Color = Colors.Black  'LED OFF";
_cell.setColor(anywheresoftware.b4a.keywords.Common.Colors.Black);
 //BA.debugLineNum = 146;BA.debugLine="Dim cellX As Int = col * (CELL_SIZE + CELL_MARG";
_cellx = (int) (_col*(_cell_size+_cell_margin)+_cell_margin);
 //BA.debugLineNum = 147;BA.debugLine="Dim cellY As Int = row * (CELL_SIZE + CELL_MARG";
_celly = (int) (_row*(_cell_size+_cell_margin)+_cell_margin);
 //BA.debugLineNum = 149;BA.debugLine="pnlMatrix.AddView(cell, cellX, cellY, CELL_SIZE";
mostCurrent._pnlmatrix.AddView((android.view.View)(_cell.getObject()),_cellx,_celly,_cell_size,_cell_size);
 //BA.debugLineNum = 150;BA.debugLine="matrixCells(col, row) = cell";
mostCurrent._matrixcells[_col][_row] = _cell;
 }
};
 }
};
 //BA.debugLineNum = 153;BA.debugLine="End Sub";
return "";
}
public static byte[]  _getfontdata(int _asciicode) throws Exception{
byte[] _fontdata = null;
 //BA.debugLineNum = 296;BA.debugLine="Sub GetFontData(asciiCode As Int) As Byte()";
 //BA.debugLineNum = 299;BA.debugLine="Dim fontData() As Byte";
_fontdata = new byte[(int) (0)];
;
 //BA.debugLineNum = 301;BA.debugLine="Select asciiCode";
switch (_asciicode) {
case 42: {
 //BA.debugLineNum = 303;BA.debugLine="fontData = Array As Byte(0x14, 0x08, 0x3E, 0x08";
_fontdata = new byte[]{(byte) (((int)0x14)),(byte) (((int)0x08)),(byte) (((int)0x3e)),(byte) (((int)0x08)),(byte) (((int)0x14))};
 break; }
case 43: {
 //BA.debugLineNum = 305;BA.debugLine="fontData = Array As Byte(0x08, 0x08, 0x3E, 0x08";
_fontdata = new byte[]{(byte) (((int)0x08)),(byte) (((int)0x08)),(byte) (((int)0x3e)),(byte) (((int)0x08)),(byte) (((int)0x08))};
 break; }
case 45: {
 //BA.debugLineNum = 307;BA.debugLine="fontData = Array As Byte(0x08, 0x08, 0x08, 0x08";
_fontdata = new byte[]{(byte) (((int)0x08)),(byte) (((int)0x08)),(byte) (((int)0x08)),(byte) (((int)0x08)),(byte) (((int)0x08))};
 break; }
case 47: {
 //BA.debugLineNum = 309;BA.debugLine="fontData = Array As Byte(0x20, 0x10, 0x08, 0x04";
_fontdata = new byte[]{(byte) (((int)0x20)),(byte) (((int)0x10)),(byte) (((int)0x08)),(byte) (((int)0x04)),(byte) (((int)0x02))};
 break; }
case 65: {
 //BA.debugLineNum = 311;BA.debugLine="fontData = Array As Byte(0x7C, 0x12, 0x11, 0x12";
_fontdata = new byte[]{(byte) (((int)0x7c)),(byte) (((int)0x12)),(byte) (((int)0x11)),(byte) (((int)0x12)),(byte) (((int)0x7c))};
 break; }
case 66: {
 //BA.debugLineNum = 313;BA.debugLine="fontData = Array As Byte(0x7F, 0x49, 0x49, 0x49";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x49)),(byte) (((int)0x49)),(byte) (((int)0x49)),(byte) (((int)0x36))};
 break; }
case 67: {
 //BA.debugLineNum = 315;BA.debugLine="fontData = Array As Byte(0x3E, 0x41, 0x41, 0x41";
_fontdata = new byte[]{(byte) (((int)0x3e)),(byte) (((int)0x41)),(byte) (((int)0x41)),(byte) (((int)0x41)),(byte) (((int)0x22))};
 break; }
case 68: {
 //BA.debugLineNum = 317;BA.debugLine="fontData = Array As Byte(0x7F, 0x41, 0x41, 0x22";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x41)),(byte) (((int)0x41)),(byte) (((int)0x22)),(byte) (((int)0x1c))};
 break; }
case 69: {
 //BA.debugLineNum = 319;BA.debugLine="fontData = Array As Byte(0x7F, 0x49, 0x49, 0x49";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x49)),(byte) (((int)0x49)),(byte) (((int)0x49)),(byte) (((int)0x41))};
 break; }
case 70: {
 //BA.debugLineNum = 321;BA.debugLine="fontData = Array As Byte(0x7F, 0x09, 0x09, 0x09";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x09)),(byte) (((int)0x09)),(byte) (((int)0x09)),(byte) (((int)0x01))};
 break; }
case 71: {
 //BA.debugLineNum = 323;BA.debugLine="fontData = Array As Byte(0x3E, 0x41, 0x49, 0x49";
_fontdata = new byte[]{(byte) (((int)0x3e)),(byte) (((int)0x41)),(byte) (((int)0x49)),(byte) (((int)0x49)),(byte) (((int)0x7a))};
 break; }
case 72: {
 //BA.debugLineNum = 325;BA.debugLine="fontData = Array As Byte(0x7F, 0x08, 0x08, 0x08";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x08)),(byte) (((int)0x08)),(byte) (((int)0x08)),(byte) (((int)0x7f))};
 break; }
case 73: {
 //BA.debugLineNum = 327;BA.debugLine="fontData = Array As Byte(0x00, 0x41, 0x7F, 0x41";
_fontdata = new byte[]{(byte) (((int)0x00)),(byte) (((int)0x41)),(byte) (((int)0x7f)),(byte) (((int)0x41)),(byte) (((int)0x00))};
 break; }
case 74: {
 //BA.debugLineNum = 329;BA.debugLine="fontData = Array As Byte(0x20, 0x40, 0x41, 0x3F";
_fontdata = new byte[]{(byte) (((int)0x20)),(byte) (((int)0x40)),(byte) (((int)0x41)),(byte) (((int)0x3f)),(byte) (((int)0x01))};
 break; }
case 75: {
 //BA.debugLineNum = 331;BA.debugLine="fontData = Array As Byte(0x7F, 0x08, 0x14, 0x22";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x08)),(byte) (((int)0x14)),(byte) (((int)0x22)),(byte) (((int)0x41))};
 break; }
case 76: {
 //BA.debugLineNum = 333;BA.debugLine="fontData = Array As Byte(0x7F, 0x40, 0x40, 0x40";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x40)),(byte) (((int)0x40)),(byte) (((int)0x40)),(byte) (((int)0x40))};
 break; }
case 77: {
 //BA.debugLineNum = 335;BA.debugLine="fontData = Array As Byte(0x7F, 0x02, 0x0C, 0x02";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x02)),(byte) (((int)0x0c)),(byte) (((int)0x02)),(byte) (((int)0x7f))};
 break; }
case 78: {
 //BA.debugLineNum = 337;BA.debugLine="fontData = Array As Byte(0x7F, 0x04, 0x08, 0x10";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x04)),(byte) (((int)0x08)),(byte) (((int)0x10)),(byte) (((int)0x7f))};
 break; }
case 79: {
 //BA.debugLineNum = 339;BA.debugLine="fontData = Array As Byte(0x3E, 0x41, 0x41, 0x41";
_fontdata = new byte[]{(byte) (((int)0x3e)),(byte) (((int)0x41)),(byte) (((int)0x41)),(byte) (((int)0x41)),(byte) (((int)0x3e))};
 break; }
case 80: {
 //BA.debugLineNum = 341;BA.debugLine="fontData = Array As Byte(0x7F, 0x09, 0x09, 0x09";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x09)),(byte) (((int)0x09)),(byte) (((int)0x09)),(byte) (((int)0x06))};
 break; }
case 81: {
 //BA.debugLineNum = 343;BA.debugLine="fontData = Array As Byte(0x3E, 0x41, 0x51, 0x21";
_fontdata = new byte[]{(byte) (((int)0x3e)),(byte) (((int)0x41)),(byte) (((int)0x51)),(byte) (((int)0x21)),(byte) (((int)0x5e))};
 break; }
case 82: {
 //BA.debugLineNum = 345;BA.debugLine="fontData = Array As Byte(0x7F, 0x09, 0x19, 0x29";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x09)),(byte) (((int)0x19)),(byte) (((int)0x29)),(byte) (((int)0x46))};
 break; }
case 83: {
 //BA.debugLineNum = 347;BA.debugLine="fontData = Array As Byte(0x46, 0x49, 0x49, 0x49";
_fontdata = new byte[]{(byte) (((int)0x46)),(byte) (((int)0x49)),(byte) (((int)0x49)),(byte) (((int)0x49)),(byte) (((int)0x31))};
 break; }
case 84: {
 //BA.debugLineNum = 349;BA.debugLine="fontData = Array As Byte(0x01, 0x01, 0x7F, 0x01";
_fontdata = new byte[]{(byte) (((int)0x01)),(byte) (((int)0x01)),(byte) (((int)0x7f)),(byte) (((int)0x01)),(byte) (((int)0x01))};
 break; }
case 85: {
 //BA.debugLineNum = 351;BA.debugLine="fontData = Array As Byte(0x3F, 0x40, 0x40, 0x40";
_fontdata = new byte[]{(byte) (((int)0x3f)),(byte) (((int)0x40)),(byte) (((int)0x40)),(byte) (((int)0x40)),(byte) (((int)0x3f))};
 break; }
case 86: {
 //BA.debugLineNum = 353;BA.debugLine="fontData = Array As Byte(0x1F, 0x20, 0x40, 0x20";
_fontdata = new byte[]{(byte) (((int)0x1f)),(byte) (((int)0x20)),(byte) (((int)0x40)),(byte) (((int)0x20)),(byte) (((int)0x1f))};
 break; }
case 87: {
 //BA.debugLineNum = 355;BA.debugLine="fontData = Array As Byte(0x3F, 0x40, 0x38, 0x40";
_fontdata = new byte[]{(byte) (((int)0x3f)),(byte) (((int)0x40)),(byte) (((int)0x38)),(byte) (((int)0x40)),(byte) (((int)0x3f))};
 break; }
case 88: {
 //BA.debugLineNum = 357;BA.debugLine="fontData = Array As Byte(0x63, 0x14, 0x08, 0x14";
_fontdata = new byte[]{(byte) (((int)0x63)),(byte) (((int)0x14)),(byte) (((int)0x08)),(byte) (((int)0x14)),(byte) (((int)0x63))};
 break; }
case 89: {
 //BA.debugLineNum = 359;BA.debugLine="fontData = Array As Byte(0x07, 0x08, 0x70, 0x08";
_fontdata = new byte[]{(byte) (((int)0x07)),(byte) (((int)0x08)),(byte) (((int)0x70)),(byte) (((int)0x08)),(byte) (((int)0x07))};
 break; }
case 90: {
 //BA.debugLineNum = 361;BA.debugLine="fontData = Array As Byte(0x61, 0x51, 0x49, 0x45";
_fontdata = new byte[]{(byte) (((int)0x61)),(byte) (((int)0x51)),(byte) (((int)0x49)),(byte) (((int)0x45)),(byte) (((int)0x43))};
 break; }
case 97: {
 //BA.debugLineNum = 363;BA.debugLine="fontData = Array As Byte(0x20, 0x54, 0x54, 0x54";
_fontdata = new byte[]{(byte) (((int)0x20)),(byte) (((int)0x54)),(byte) (((int)0x54)),(byte) (((int)0x54)),(byte) (((int)0x78))};
 break; }
case 98: {
 //BA.debugLineNum = 365;BA.debugLine="fontData = Array As Byte(0x7F, 0x48, 0x44, 0x44";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x48)),(byte) (((int)0x44)),(byte) (((int)0x44)),(byte) (((int)0x38))};
 break; }
case 99: {
 //BA.debugLineNum = 367;BA.debugLine="fontData = Array As Byte(0x38, 0x44, 0x44, 0x44";
_fontdata = new byte[]{(byte) (((int)0x38)),(byte) (((int)0x44)),(byte) (((int)0x44)),(byte) (((int)0x44)),(byte) (((int)0x20))};
 break; }
case 100: {
 //BA.debugLineNum = 369;BA.debugLine="fontData = Array As Byte(0x38, 0x44, 0x44, 0x48";
_fontdata = new byte[]{(byte) (((int)0x38)),(byte) (((int)0x44)),(byte) (((int)0x44)),(byte) (((int)0x48)),(byte) (((int)0x7f))};
 break; }
case 101: {
 //BA.debugLineNum = 371;BA.debugLine="fontData = Array As Byte(0x38, 0x54, 0x54, 0x54";
_fontdata = new byte[]{(byte) (((int)0x38)),(byte) (((int)0x54)),(byte) (((int)0x54)),(byte) (((int)0x54)),(byte) (((int)0x18))};
 break; }
case 102: {
 //BA.debugLineNum = 373;BA.debugLine="fontData = Array As Byte(0x08, 0x7E, 0x09, 0x01";
_fontdata = new byte[]{(byte) (((int)0x08)),(byte) (((int)0x7e)),(byte) (((int)0x09)),(byte) (((int)0x01)),(byte) (((int)0x02))};
 break; }
case 103: {
 //BA.debugLineNum = 375;BA.debugLine="fontData = Array As Byte(0x0C, 0x52, 0x52, 0x52";
_fontdata = new byte[]{(byte) (((int)0x0c)),(byte) (((int)0x52)),(byte) (((int)0x52)),(byte) (((int)0x52)),(byte) (((int)0x3e))};
 break; }
case 104: {
 //BA.debugLineNum = 377;BA.debugLine="fontData = Array As Byte(0x7F, 0x08, 0x04, 0x04";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x08)),(byte) (((int)0x04)),(byte) (((int)0x04)),(byte) (((int)0x78))};
 break; }
case 105: {
 //BA.debugLineNum = 379;BA.debugLine="fontData = Array As Byte(0x00, 0x44, 0x7D, 0x40";
_fontdata = new byte[]{(byte) (((int)0x00)),(byte) (((int)0x44)),(byte) (((int)0x7d)),(byte) (((int)0x40)),(byte) (((int)0x00))};
 break; }
case 106: {
 //BA.debugLineNum = 381;BA.debugLine="fontData = Array As Byte(0x20, 0x40, 0x44, 0x3D";
_fontdata = new byte[]{(byte) (((int)0x20)),(byte) (((int)0x40)),(byte) (((int)0x44)),(byte) (((int)0x3d)),(byte) (((int)0x00))};
 break; }
case 107: {
 //BA.debugLineNum = 383;BA.debugLine="fontData = Array As Byte(0x7F, 0x10, 0x28, 0x44";
_fontdata = new byte[]{(byte) (((int)0x7f)),(byte) (((int)0x10)),(byte) (((int)0x28)),(byte) (((int)0x44)),(byte) (((int)0x00))};
 break; }
case 108: {
 //BA.debugLineNum = 385;BA.debugLine="fontData = Array As Byte(0x00, 0x41, 0x7F, 0x40";
_fontdata = new byte[]{(byte) (((int)0x00)),(byte) (((int)0x41)),(byte) (((int)0x7f)),(byte) (((int)0x40)),(byte) (((int)0x00))};
 break; }
case 109: {
 //BA.debugLineNum = 387;BA.debugLine="fontData = Array As Byte(0x7C, 0x04, 0x18, 0x04";
_fontdata = new byte[]{(byte) (((int)0x7c)),(byte) (((int)0x04)),(byte) (((int)0x18)),(byte) (((int)0x04)),(byte) (((int)0x78))};
 break; }
case 110: {
 //BA.debugLineNum = 389;BA.debugLine="fontData = Array As Byte(0x7C, 0x08, 0x04, 0x04";
_fontdata = new byte[]{(byte) (((int)0x7c)),(byte) (((int)0x08)),(byte) (((int)0x04)),(byte) (((int)0x04)),(byte) (((int)0x78))};
 break; }
case 111: {
 //BA.debugLineNum = 391;BA.debugLine="fontData = Array As Byte(0x38, 0x44, 0x44, 0x44";
_fontdata = new byte[]{(byte) (((int)0x38)),(byte) (((int)0x44)),(byte) (((int)0x44)),(byte) (((int)0x44)),(byte) (((int)0x38))};
 break; }
case 112: {
 //BA.debugLineNum = 393;BA.debugLine="fontData = Array As Byte(0x7C, 0x14, 0x14, 0x14";
_fontdata = new byte[]{(byte) (((int)0x7c)),(byte) (((int)0x14)),(byte) (((int)0x14)),(byte) (((int)0x14)),(byte) (((int)0x08))};
 break; }
case 113: {
 //BA.debugLineNum = 395;BA.debugLine="fontData = Array As Byte(0x08, 0x14, 0x14, 0x18";
_fontdata = new byte[]{(byte) (((int)0x08)),(byte) (((int)0x14)),(byte) (((int)0x14)),(byte) (((int)0x18)),(byte) (((int)0x7c))};
 break; }
case 114: {
 //BA.debugLineNum = 397;BA.debugLine="fontData = Array As Byte(0x7C, 0x08, 0x04, 0x04";
_fontdata = new byte[]{(byte) (((int)0x7c)),(byte) (((int)0x08)),(byte) (((int)0x04)),(byte) (((int)0x04)),(byte) (((int)0x08))};
 break; }
case 115: {
 //BA.debugLineNum = 399;BA.debugLine="fontData = Array As Byte(0x48, 0x54, 0x54, 0x54";
_fontdata = new byte[]{(byte) (((int)0x48)),(byte) (((int)0x54)),(byte) (((int)0x54)),(byte) (((int)0x54)),(byte) (((int)0x20))};
 break; }
case 116: {
 //BA.debugLineNum = 401;BA.debugLine="fontData = Array As Byte(0x04, 0x3F, 0x44, 0x40";
_fontdata = new byte[]{(byte) (((int)0x04)),(byte) (((int)0x3f)),(byte) (((int)0x44)),(byte) (((int)0x40)),(byte) (((int)0x20))};
 break; }
case 117: {
 //BA.debugLineNum = 403;BA.debugLine="fontData = Array As Byte(0x3C, 0x40, 0x40, 0x20";
_fontdata = new byte[]{(byte) (((int)0x3c)),(byte) (((int)0x40)),(byte) (((int)0x40)),(byte) (((int)0x20)),(byte) (((int)0x7c))};
 break; }
case 118: {
 //BA.debugLineNum = 405;BA.debugLine="fontData = Array As Byte(0x1C, 0x20, 0x40, 0x20";
_fontdata = new byte[]{(byte) (((int)0x1c)),(byte) (((int)0x20)),(byte) (((int)0x40)),(byte) (((int)0x20)),(byte) (((int)0x1c))};
 break; }
case 119: {
 //BA.debugLineNum = 407;BA.debugLine="fontData = Array As Byte(0x3C, 0x40, 0x30, 0x40";
_fontdata = new byte[]{(byte) (((int)0x3c)),(byte) (((int)0x40)),(byte) (((int)0x30)),(byte) (((int)0x40)),(byte) (((int)0x3c))};
 break; }
case 120: {
 //BA.debugLineNum = 409;BA.debugLine="fontData = Array As Byte(0x44, 0x28, 0x10, 0x28";
_fontdata = new byte[]{(byte) (((int)0x44)),(byte) (((int)0x28)),(byte) (((int)0x10)),(byte) (((int)0x28)),(byte) (((int)0x44))};
 break; }
case 121: {
 //BA.debugLineNum = 411;BA.debugLine="fontData = Array As Byte(0x0C, 0x50, 0x50, 0x50";
_fontdata = new byte[]{(byte) (((int)0x0c)),(byte) (((int)0x50)),(byte) (((int)0x50)),(byte) (((int)0x50)),(byte) (((int)0x3c))};
 break; }
case 122: {
 //BA.debugLineNum = 413;BA.debugLine="fontData = Array As Byte(0x44, 0x64, 0x54, 0x4C";
_fontdata = new byte[]{(byte) (((int)0x44)),(byte) (((int)0x64)),(byte) (((int)0x54)),(byte) (((int)0x4c)),(byte) (((int)0x44))};
 break; }
default: {
 //BA.debugLineNum = 416;BA.debugLine="fontData = Array As Byte(0x00, 0x00, 0x00, 0x00";
_fontdata = new byte[]{(byte) (((int)0x00)),(byte) (((int)0x00)),(byte) (((int)0x00)),(byte) (((int)0x00)),(byte) (((int)0x00))};
 break; }
}
;
 //BA.debugLineNum = 419;BA.debugLine="Return fontData";
if (true) return _fontdata;
 //BA.debugLineNum = 420;BA.debugLine="End Sub";
return null;
}
public static String  _globals() throws Exception{
 //BA.debugLineNum = 28;BA.debugLine="Sub Globals";
 //BA.debugLineNum = 30;BA.debugLine="Private lblConnectionStatus As Label";
mostCurrent._lblconnectionstatus = new anywheresoftware.b4a.objects.LabelWrapper();
 //BA.debugLineNum = 31;BA.debugLine="Private txtCharacters As EditText  'CHANGED: From";
mostCurrent._txtcharacters = new anywheresoftware.b4a.objects.EditTextWrapper();
 //BA.debugLineNum = 32;BA.debugLine="Private btnClear As Button  'NEW: Clear button";
mostCurrent._btnclear = new anywheresoftware.b4a.objects.ButtonWrapper();
 //BA.debugLineNum = 33;BA.debugLine="Private pnlMatrix As Panel";
mostCurrent._pnlmatrix = new anywheresoftware.b4a.objects.PanelWrapper();
 //BA.debugLineNum = 36;BA.debugLine="Private matrixCells(5, 7) As Panel  'Column, Row";
mostCurrent._matrixcells = new anywheresoftware.b4a.objects.PanelWrapper[(int) (5)][];
{
int d0 = mostCurrent._matrixcells.length;
int d1 = (int) (7);
for (int i0 = 0;i0 < d0;i0++) {
mostCurrent._matrixcells[i0] = new anywheresoftware.b4a.objects.PanelWrapper[d1];
for (int i1 = 0;i1 < d1;i1++) {
mostCurrent._matrixcells[i0][i1] = new anywheresoftware.b4a.objects.PanelWrapper();
}
}
}
;
 //BA.debugLineNum = 37;BA.debugLine="Private CELL_SIZE As Int";
_cell_size = 0;
 //BA.debugLineNum = 38;BA.debugLine="Private CELL_MARGIN As Int = 2";
_cell_margin = (int) (2);
 //BA.debugLineNum = 41;BA.debugLine="Private currentASCII As Int = 97  'Default 'a'";
_currentascii = (int) (97);
 //BA.debugLineNum = 42;BA.debugLine="End Sub";
return "";
}
public static String  _mqtt_connected(boolean _success) throws Exception{
 //BA.debugLineNum = 203;BA.debugLine="Sub mqtt_Connected (Success As Boolean)";
 //BA.debugLineNum = 204;BA.debugLine="If Success Then";
if (_success) { 
 //BA.debugLineNum = 205;BA.debugLine="Log(\"MQTT Connected Successfully\")";
anywheresoftware.b4a.keywords.Common.LogImpl("7983042","MQTT Connected Successfully",0);
 //BA.debugLineNum = 206;BA.debugLine="lblConnectionStatus.Text = \"Connected to \" & BRO";
mostCurrent._lblconnectionstatus.setText(BA.ObjectToCharSequence("Connected to "+_broker_url));
 //BA.debugLineNum = 207;BA.debugLine="lblConnectionStatus.Color = Colors.Green";
mostCurrent._lblconnectionstatus.setColor(anywheresoftware.b4a.keywords.Common.Colors.Green);
 //BA.debugLineNum = 210;BA.debugLine="mqtt.Subscribe(TOPIC_ASCII, 0)  'QoS 0";
_mqtt.Subscribe(_topic_ascii,(int) (0));
 //BA.debugLineNum = 211;BA.debugLine="Log(\"Subscribed to topic: \" & TOPIC_ASCII)";
anywheresoftware.b4a.keywords.Common.LogImpl("7983048","Subscribed to topic: "+_topic_ascii,0);
 }else {
 //BA.debugLineNum = 213;BA.debugLine="Log(\"MQTT Connection Failed\")";
anywheresoftware.b4a.keywords.Common.LogImpl("7983050","MQTT Connection Failed",0);
 //BA.debugLineNum = 214;BA.debugLine="lblConnectionStatus.Text = \"Connection Failed\"";
mostCurrent._lblconnectionstatus.setText(BA.ObjectToCharSequence("Connection Failed"));
 //BA.debugLineNum = 215;BA.debugLine="lblConnectionStatus.Color = Colors.Red";
mostCurrent._lblconnectionstatus.setColor(anywheresoftware.b4a.keywords.Common.Colors.Red);
 };
 //BA.debugLineNum = 217;BA.debugLine="End Sub";
return "";
}
public static String  _mqtt_disconnected() throws Exception{
 //BA.debugLineNum = 240;BA.debugLine="Sub mqtt_Disconnected";
 //BA.debugLineNum = 241;BA.debugLine="Log(\"MQTT Disconnected\")";
anywheresoftware.b4a.keywords.Common.LogImpl("71114113","MQTT Disconnected",0);
 //BA.debugLineNum = 242;BA.debugLine="lblConnectionStatus.Text = \"Disconnected\"";
mostCurrent._lblconnectionstatus.setText(BA.ObjectToCharSequence("Disconnected"));
 //BA.debugLineNum = 243;BA.debugLine="lblConnectionStatus.Color = Colors.Red";
mostCurrent._lblconnectionstatus.setColor(anywheresoftware.b4a.keywords.Common.Colors.Red);
 //BA.debugLineNum = 244;BA.debugLine="End Sub";
return "";
}
public static String  _mqtt_messagearrived(String _topic,byte[] _payload) throws Exception{
String _payloadstr = "";
int _asciicode = 0;
 //BA.debugLineNum = 219;BA.debugLine="Sub mqtt_MessageArrived (Topic As String, Payload(";
 //BA.debugLineNum = 221;BA.debugLine="Dim payloadStr As String = BytesToString(Payload,";
_payloadstr = anywheresoftware.b4a.keywords.Common.BytesToString(_payload,(int) (0),_payload.length,"UTF8");
 //BA.debugLineNum = 223;BA.debugLine="Log(\"Message received on topic: \" & Topic)";
anywheresoftware.b4a.keywords.Common.LogImpl("71048580","Message received on topic: "+_topic,0);
 //BA.debugLineNum = 224;BA.debugLine="Log(\"Payload: \" & payloadStr)";
anywheresoftware.b4a.keywords.Common.LogImpl("71048581","Payload: "+_payloadstr,0);
 //BA.debugLineNum = 227;BA.debugLine="Dim asciiCode As Int = payloadStr";
_asciicode = (int)(Double.parseDouble(_payloadstr));
 //BA.debugLineNum = 230;BA.debugLine="If asciiCode >= 42 AND asciiCode <= 122 Then";
if (_asciicode>=42 && _asciicode<=122) { 
 //BA.debugLineNum = 232;BA.debugLine="UpdateDisplay(asciiCode)";
_updatedisplay(_asciicode);
 }else {
 //BA.debugLineNum = 236;BA.debugLine="Log(\"Invalid ASCII code received: \" & asciiCode)";
anywheresoftware.b4a.keywords.Common.LogImpl("71048593","Invalid ASCII code received: "+BA.NumberToString(_asciicode),0);
 };
 //BA.debugLineNum = 238;BA.debugLine="End Sub";
return "";
}

public static void initializeProcessGlobals() {
    
    if (main.processGlobalsRun == false) {
	    main.processGlobalsRun = true;
		try {
		        main._process_globals();
starter._process_globals();
		
        } catch (Exception e) {
			throw new RuntimeException(e);
		}
    }
}public static String  _process_globals() throws Exception{
 //BA.debugLineNum = 16;BA.debugLine="Sub Process_Globals";
 //BA.debugLineNum = 18;BA.debugLine="Private mqtt As MqttClient";
_mqtt = new anywheresoftware.b4j.objects.MqttAsyncClientWrapper();
 //BA.debugLineNum = 21;BA.debugLine="Private BROKER_URL As String = \"tcp://broker.emqx";
_broker_url = "tcp://broker.emqx.io:1883";
 //BA.debugLineNum = 22;BA.debugLine="Private CLIENT_ID As String = \"Android_Keypad_Dis";
_client_id = "Android_Keypad_Display";
 //BA.debugLineNum = 23;BA.debugLine="Private TOPIC_ASCII As String = \"lab_micro_usek/a";
_topic_ascii = "lab_micro_usek/ascii";
 //BA.debugLineNum = 26;BA.debugLine="End Sub";
return "";
}
public static String  _setupmqtt() throws Exception{
 //BA.debugLineNum = 177;BA.debugLine="Sub SetupMQTT";
 //BA.debugLineNum = 179;BA.debugLine="mqtt.Initialize(\"mqtt\", BROKER_URL, CLIENT_ID)";
_mqtt.Initialize(processBA,"mqtt",_broker_url,_client_id);
 //BA.debugLineNum = 182;BA.debugLine="ConnectMQTT";
_connectmqtt();
 //BA.debugLineNum = 183;BA.debugLine="End Sub";
return "";
}
public static String  _updatedisplay(int _asciicode) throws Exception{
String _charvalue = "";
 //BA.debugLineNum = 250;BA.debugLine="Sub UpdateDisplay(asciiCode As Int)";
 //BA.debugLineNum = 252;BA.debugLine="currentASCII = asciiCode";
_currentascii = _asciicode;
 //BA.debugLineNum = 257;BA.debugLine="Dim charValue As String = Chr(asciiCode)";
_charvalue = BA.ObjectToString(anywheresoftware.b4a.keywords.Common.Chr(_asciicode));
 //BA.debugLineNum = 258;BA.debugLine="txtCharacters.Text = txtCharacters.Text & charVal";
mostCurrent._txtcharacters.setText(BA.ObjectToCharSequence(mostCurrent._txtcharacters.getText()+_charvalue));
 //BA.debugLineNum = 261;BA.debugLine="UpdateMatrix(asciiCode)";
_updatematrix(_asciicode);
 //BA.debugLineNum = 262;BA.debugLine="End Sub";
return "";
}
public static String  _updatematrix(int _asciicode) throws Exception{
byte[] _fontdata = null;
int _col = 0;
byte _columnbyte = (byte)0;
int _row = 0;
int _bitvalue = 0;
 //BA.debugLineNum = 264;BA.debugLine="Sub UpdateMatrix(asciiCode As Int)";
 //BA.debugLineNum = 266;BA.debugLine="Dim fontData() As Byte = GetFontData(asciiCode)";
_fontdata = _getfontdata(_asciicode);
 //BA.debugLineNum = 269;BA.debugLine="For col = 0 To 4";
{
final int step2 = 1;
final int limit2 = (int) (4);
_col = (int) (0) ;
for (;_col <= limit2 ;_col = _col + step2 ) {
 //BA.debugLineNum = 270;BA.debugLine="Dim columnByte As Byte = fontData(col)";
_columnbyte = _fontdata[_col];
 //BA.debugLineNum = 273;BA.debugLine="For row = 0 To 6";
{
final int step4 = 1;
final int limit4 = (int) (6);
_row = (int) (0) ;
for (;_row <= limit4 ;_row = _row + step4 ) {
 //BA.debugLineNum = 275;BA.debugLine="Dim bitValue As Int = Bit.And(columnByte, Power";
_bitvalue = anywheresoftware.b4a.keywords.Common.Bit.And((int) (_columnbyte),(int) (anywheresoftware.b4a.keywords.Common.Power(2,_row)));
 //BA.debugLineNum = 277;BA.debugLine="If bitValue <> 0 Then";
if (_bitvalue!=0) { 
 //BA.debugLineNum = 279;BA.debugLine="matrixCells(col, row).Color = Colors.RGB(0, 25";
mostCurrent._matrixcells[_col][_row].setColor(anywheresoftware.b4a.keywords.Common.Colors.RGB((int) (0),(int) (255),(int) (0)));
 }else {
 //BA.debugLineNum = 282;BA.debugLine="matrixCells(col, row).Color = Colors.Black";
mostCurrent._matrixcells[_col][_row].setColor(anywheresoftware.b4a.keywords.Common.Colors.Black);
 };
 }
};
 }
};
 //BA.debugLineNum = 286;BA.debugLine="End Sub";
return "";
}
}
