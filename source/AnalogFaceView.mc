using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as Monitor;
using Toybox.Math as Math;


class AnalogFaceView extends Ui.WatchFace {

    var lowPowerMode = true;	
    var customFont   = null;
    var customFont65 = null;
    var customFont75 = null;
    var heart80   = null;
    	
    function initialize() {
        WatchFace.initialize();
    }
    	
    // Load your resources here
    function onLayout(dc) {
    	customFont   = WatchUi.loadResource(Rez.Fonts.trebuchetMS_50);  
    	customFont65 = WatchUi.loadResource(Rez.Fonts.trebuchetMS_65);
    	customFont75 = WatchUi.loadResource(Rez.Fonts.trebuchetMS_75); 
    	heart80      = WatchUi.loadResource(Rez.Drawables.redHeart80);  
    }
    
    function onUpdate(dc) {
		
        View.onUpdate(dc);    
        var width      = dc.getWidth();
        var height     = dc.getHeight();
        var halfHeight = height/2;
        var halfWidth  = width/2;          
        var clockTime  = Sys.getClockTime();
        var hour;
        var min;
        var sec;        
 
       	// Show clock hour numbers
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);

   	    dc.drawText(halfWidth, -11, customFont, ""+12, Gfx.TEXT_JUSTIFY_CENTER);
       	dc.drawText(halfWidth, halfHeight + 65 , customFont, ""+6, Gfx.TEXT_JUSTIFY_CENTER);
       	dc.drawText(0, halfHeight - 28, customFont, ""+9, Gfx.TEXT_JUSTIFY_LEFT);
       	dc.drawText(width + 2 , halfHeight - 28, customFont, ""+3, Gfx.TEXT_JUSTIFY_RIGHT);      
        
        // Show day back ground
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(130, 42, 60, 50);

	    // Show clock hands
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);  

        hour = ( ( ( clockTime.hour % 12 ) * 60 ) + clockTime.min );
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
        min = ( clockTime.min / 60.0) * Math.PI * 2;
        sec = ( clockTime.sec / 60.0) * Math.PI * 2;
				        
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);     
        drawHand(dc, halfWidth, halfHeight, min, halfHeight, halfHeight*0.1); 
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);        
        drawHand(dc, halfWidth, halfHeight, min, halfHeight*0.9, 7);
 
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        drawHand(dc, halfWidth, halfHeight, hour, 75, 10);         
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);         
        drawHand(dc, halfWidth, halfHeight, hour, 68, 7);
	                
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);         
		dc.fillCircle(halfWidth, halfHeight, 5.5);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT); 
		dc.fillCircle(halfWidth, halfHeight, 2);

		if(lowPowerMode)
 		{                
        	dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);         
        	drawSecHand(dc, halfWidth, halfHeight, sec, 110, 3); 
        	drawSecHand(dc, halfWidth, halfHeight, sec, -17, 3);                      
			dc.fillCircle(halfWidth, halfHeight, 4);                         
		} 		
	
	    // Show heartrate
	    //dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	    dc.drawBitmap(halfWidth - 40, halfHeight, heart80);
	    
	    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);	   
	    var HRH=Monitor.getHeartRateHistory(1, true);
	    var heartRate = 0;	    	
		if(HRH!=null) 
		{
			heartRate = HRH.next();
		}
		 	
		dc.drawText(halfWidth, halfHeight - 3 ,customFont75, ""+heartRate.heartRate, Gfx.TEXT_JUSTIFY_CENTER);
		
		//Show battery status
		var myStats = Sys.getSystemStats();
        var battery = myStats.battery;        
        if (battery > 45.0 ) 
        {
            dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        }
        else if ( battery <= 45.0 && battery > 15.0 )
        {           
            dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
        }   
        else if ( battery <= 15.0 )
        {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        }        
        dc.drawRectangle(25, 53, 78, 28);
        dc.drawRectangle(26, 54, 76, 26);
		dc.drawRectangle(27, 55, 74, 24);
		dc.fillRectangle(103, 61, 5, 12);
        dc.fillRectangle(30, 58, 68*battery/100, 18);       
		 
        //Show day      
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        var dateInfo = Calendar.info(Time.now(), Time.FORMAT_MEDIUM);
        dc.drawText(160, 29 , customFont75, ""+dateInfo.day, Gfx.TEXT_JUSTIFY_CENTER);        		                
    }
    
	function drawHand(dc, x, y, angle, length, width)
	{
        //var coords = [ [0,0], [-width, -(length)*1/3], [-(width*1/4), -(length)*9/10],[-(width*1/4), -length], [0, -length], [0, -(length*8/10)], [-(width*3/4), -(length*1/3)], [0, -(length*2/10)],[(width*3/4), -(length*1/3)], [0, -(length*8/10)],[0, -length],[(width*1/4), -length],[(width*1/4), -(length)*9/10],[width, -(length)*1/3]];
        var coords = [ [0,0], [-width, -(length)*1/3], [-width, -length * 0.9], [0, -length], [width, -length*0.9], [width, -length*1/3] ];
        var result = new [coords.size()];
		var centerX = x;
		var centerY = y;
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		for (var i = 0; i < coords.size(); i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX+x, centerY+y];
        }
        dc.fillPolygon(result);
	}    
    	

    function drawSecHand(dc, x, y, angle, length, width)
    {
        var coords = [[width, 0], [width, -length], [-width, -length], [-width, 0]];
        var result = new [coords.size()];
		var centerX = x;
		var centerY = y;
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		for (var i = 0; i < coords.size(); i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX+x, centerY+y];
        }
        dc.fillPolygon(result);
    }

    function onExitSleep() {
    lowPowerMode = true;
    Ui.requestUpdate();     
    }

    function onEnterSleep() {
    lowPowerMode = false;
    Ui.requestUpdate();     
    }
    

}
