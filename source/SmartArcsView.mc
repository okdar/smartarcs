/*
    This file is part of SmartArcs Origin watch face.
    https://github.com/okdar/smartarcs

    SmartArcs Origin is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SmartArcs Origin is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SmartArcs Origin. If not, see <https://www.gnu.org/licenses/gpl.html>.
*/

using Toybox.Activity;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Position;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

class SmartArcsView extends WatchUi.WatchFace {

    //TRYING TO KEEP AS MUCH PRE-COMPUTED VALUES AS POSSIBLE IN MEMORY TO SAVE CPU UTILIZATION
    //AND HOPEFULLY PROLONG BATTERY LIFE. PRE-COMPUTED VARIABLES DON'T NEED TO BE COMPUTED
    //AGAIN AND AGAND ON EACH SCREEN UPDATE. THAT'S THE REASON FOR LONG LIST OF GLOBAL VARIABLES.

    //global variables
    var isAwake = false;
    var curClip;
    var fullScreenRefresh;
    var offscreenBuffer;
    var offSettingFlag = -999;
    var font = Graphics.FONT_TINY;
    var needComputeConstants;
    var lastMeasuredHR;
    var powerSaverDrawn = false;

    //global variables for pre-computation
    var screenWidth;
    var screenRadius;
    var arcRadius;
    var twoPI = Math.PI * 2;
    var dualTimeLocationY;
    var dualTimeTimeY;
    var dualTimeAmPmY;
    var dualTimeOneLinerY;
    var dualTimeOneLinerAmPmY;
    var dualTimeHourOffset;
    var dualTimeMinOffset;
    var eventNameY;
    var dateAt6Y;
    var ticks = null;
    var hourHandLength;
    var minuteHandLength;
    var secondHandLength;
    var handsTailLength;
    var fontHeight;
    var startPowerSaverMin;
    var endPowerSaverMin;
    var screenResolutionRatio;
    var powerSaverIconRatio;
	var sunriseStartAngle = 0;
	var sunriseEndAngle = 0;
	var sunsetStartAngle = 0;
	var sunsetEndAngle = 0;

    //user settings
    var bgColor;
    var handsColor;
    var handsOutlineColor;
    var secondHandColor;
    var hourHandWidth;
    var minuteHandWidth;
    var showSecondHand;
    var secondHandWidth;
    var battery100Color;
    var battery30Color;
    var battery15Color;
    var notificationColor;
    var bluetoothColor;
    var dndColor;
    var alarmColor;
    var eventColor;
    var dualTimeColor;
    var dateColor;
    var ticksColor;
    var ticks1MinWidth;
    var ticks5MinWidth;
    var ticks15MinWidth;
    var eventName;
    var eventDate;
    var dualTimeOffset;
    var dualTimeUTC;
    var dualTimeLocation;
    var useBatterySecondHandColor;
    var oneColor;
    var handsOnTop;
    var showBatteryIndicator;
    var datePosition;
    var dateFormat;
    var arcsStyle;
    var arcPenWidth;
    var hrColor;
    var hrRefreshInterval;
    var powerSaver;
    var powerSaverRefreshInterval;
    var powerSaverIconColor;
    var sunriseColor;
    var sunsetColor;

    function initialize() {
        loadUserSettings();
        WatchFace.initialize();
        fullScreenRefresh = true;
    }

    //load resources here
    function onLayout(dc) {
        //if this device supports BufferedBitmap, allocate the buffers we use for drawing
        if (Toybox.Graphics has :BufferedBitmap) {
            //Allocate a full screen size buffer to draw the background image of the watchface.
            //This is used to facilitate blanking the second hand during partial updates of the display
            offscreenBuffer = new Graphics.BufferedBitmap({
                :width => dc.getWidth(),
                :height => dc.getHeight()
            });
        } else {
            offscreenBuffer = null;
        }

        curClip = null;
    }

    //called when this View is brought to the foreground. Restore
    //the state of this View and prepare it to be shown. This includes
    //loading resources into memory.
    function onShow() {
    }

    //update the view
    function onUpdate(dc) {
        var clockTime = System.getClockTime();

		//refresh whole screen before drawing power saver icon
        if (powerSaver && shouldPowerSave() && !isAwake && powerSaverDrawn) {
            //should be screen refreshed in given intervals?
            if (powerSaverRefreshInterval == -999 || !(clockTime.min % powerSaverRefreshInterval == 0)) {
                return;
            }
        }

        powerSaverDrawn = false;

        var deviceSettings = System.getDeviceSettings();

        //compute what does not need to be computed on each update
        if (needComputeConstants) {
            computeConstants(dc);
        }

		//recompute sunrise/sunset constants every hour - to address new location when traveling
		if (clockTime.min == 0) {
			computeSunConstants();
		}

		var today = Time.today();

        //we always want to refresh the full screen when we get a regular onUpdate call.
        fullScreenRefresh = true;

        var targetDc = null;
        if (offscreenBuffer != null) {
            dc.clearClip();
            curClip = null;
            //if we have an offscreen buffer that we are using to draw the background,
            //set the draw context of that buffer as our target.
            targetDc = offscreenBuffer.getDc();
        } else {
            targetDc = dc;
        }

        //clear the screen
        targetDc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        targetDc.fillCircle(screenRadius, screenRadius, screenRadius + 2);

        if (showBatteryIndicator) {
            drawBattery(targetDc);
        }
        if (notificationColor != offSettingFlag) {
            drawNotifications(targetDc, deviceSettings.notificationCount);
        }
        if (bluetoothColor != offSettingFlag) {
            drawBluetooth(targetDc, deviceSettings.phoneConnected);
        }
        if (dndColor != offSettingFlag) {
            drawDoNotDisturb(targetDc, deviceSettings.doNotDisturb);
        }
        if (alarmColor != offSettingFlag) {
            drawAlarms(targetDc, deviceSettings.alarmCount);
        }

    	drawSun(targetDc);

        if (ticks != null) {
            drawTicks(targetDc);
        }

        if (!handsOnTop) {
            drawHands(targetDc, clockTime);
        }

        if (eventColor != offSettingFlag) {
            //compute days to event
            var eventDateMoment = new Time.Moment(eventDate);
            var daysToEvent = (eventDateMoment.value() - today.value()) / Gregorian.SECONDS_PER_DAY.toFloat();

            if (daysToEvent < 0) {
                //hide event when it is over
                eventColor = offSettingFlag;
                Application.getApp().setProperty("eventColor", offSettingFlag);
            } else {
                drawEvent(targetDc, eventName, daysToEvent.toNumber());
            }
        }

        if (dualTimeColor != offSettingFlag) {
            drawDualTime(targetDc, clockTime, deviceSettings.is24Hour);
        }

        if (dateColor != offSettingFlag) {
            drawDate(targetDc, today);
        }

        if (handsOnTop) {
            drawHands(targetDc, clockTime);
        }

        if (isAwake && showSecondHand == 1) {
            drawSecondHand(targetDc, clockTime);
        }

        //output the offscreen buffers to the main display if required.
        drawBackground(dc);

        if (powerSaver && shouldPowerSave() && !isAwake) {
            drawPowerSaverIcon(dc);
            return;
        }

        if ((Toybox.WatchUi.WatchFace has :onPartialUpdate) && (hrColor != offSettingFlag || showSecondHand == 2)) {
            onPartialUpdate(dc);
        }

        fullScreenRefresh = false;
    }

    //called when this View is removed from the screen. Save the state
    //of this View here. This includes freeing resources from memory.
    function onHide() {
    }

    //the user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        isAwake = true;
    }

    //terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        isAwake = false;
        requestUpdate();
    }

    function loadUserSettings() {
        var app = Application.getApp();

        oneColor = app.getProperty("oneColor");
        if (oneColor == offSettingFlag) {
            battery100Color = app.getProperty("battery100Color");
            battery30Color = app.getProperty("battery30Color");
            battery15Color = app.getProperty("battery15Color");
            notificationColor = app.getProperty("notificationColor");
            bluetoothColor = app.getProperty("bluetoothColor");
            dndColor = app.getProperty("dndColor");
            alarmColor = app.getProperty("alarmColor");
            secondHandColor = app.getProperty("secondHandColor");
    		sunriseColor = app.getProperty("sunriseColor");
			sunsetColor = app.getProperty("sunsetColor");
        } else {
            notificationColor = oneColor;
            bluetoothColor = oneColor;
            dndColor = oneColor;
            alarmColor = oneColor;
            secondHandColor = oneColor;
    		sunriseColor = oneColor;
			sunsetColor = oneColor;
        }
        bgColor = app.getProperty("bgColor");
        ticksColor = app.getProperty("ticksColor");
        if (ticksColor != offSettingFlag) {
            ticks1MinWidth = app.getProperty("ticks1MinWidth");
            ticks5MinWidth = app.getProperty("ticks5MinWidth");
            ticks15MinWidth = app.getProperty("ticks15MinWidth");
        }
        handsColor = app.getProperty("handsColor");
        handsOutlineColor = app.getProperty("handsOutlineColor");
        hourHandWidth = app.getProperty("hourHandWidth");
        minuteHandWidth = app.getProperty("minuteHandWidth");
        showSecondHand = app.getProperty("showSecondHand");
        if (showSecondHand > 0) {
            secondHandWidth = app.getProperty("secondHandWidth");
        }
        eventColor = app.getProperty("eventColor");
        dualTimeColor = app.getProperty("dualTimeColor");
        dateColor = app.getProperty("dateColor");
        hrColor = app.getProperty("hrColor");
        arcsStyle = app.getProperty("arcsStyle");

        useBatterySecondHandColor = app.getProperty("useBatterySecondHandColor");

        if (eventColor != offSettingFlag) {
            eventName = app.getProperty("eventName");
            eventDate = app.getProperty("eventDate");
        }

        if (dualTimeColor != offSettingFlag) {
            dualTimeOffset = app.getProperty("dualTimeOffset");
            dualTimeLocation = app.getProperty("dualTimeLocation");
            dualTimeUTC = app.getProperty("dualTimeUTCOffset");
        }

        if (dateColor != offSettingFlag) {
            datePosition = app.getProperty("datePosition");
            dateFormat = app.getProperty("dateFormat");
        }

        if (hrColor != offSettingFlag) {
            hrRefreshInterval = app.getProperty("hrRefreshInterval");
            if (datePosition == 9) {
                datePosition = 3;
            }
        }

        handsOnTop = app.getProperty("handsOnTop");

        showBatteryIndicator = app.getProperty("showBatteryIndicator");

        var power = app.getProperty("powerSaver");
        if (power == 1) {
        	powerSaver = false;
    	} else {
    		powerSaver = true;
            var powerSaverBeginning;
            var powerSaverEnd;
            if (power == 2) {
                powerSaverBeginning = app.getProperty("powerSaverBeginning");
                powerSaverEnd = app.getProperty("powerSaverEnd");
            } else {
                powerSaverBeginning = "00:00";
                powerSaverEnd = "23:59";
            }
            startPowerSaverMin = parsePowerSaverTime(powerSaverBeginning);
            if (startPowerSaverMin == -1) {
                powerSaver = false;
            } else {
                endPowerSaverMin = parsePowerSaverTime(powerSaverEnd);
                if (endPowerSaverMin == -1) {
                    powerSaver = false;
                }
            }
        }
		powerSaverRefreshInterval = app.getProperty("powerSaverRefreshInterval");
		powerSaverIconColor = app.getProperty("powerSaverIconColor");

        //ensure that constants will be pre-computed
        needComputeConstants = true;
        
        //ensure that screen will be refreshed when settings are changed 
    	powerSaverDrawn = false;   	
    }

    //pre-compute values which don't need to be computed on each update
    function computeConstants(dc) {
        screenWidth = dc.getWidth();
        screenRadius = screenWidth / 2;

        //computes hand lenght for watches with different screen resolution than 240x240
        var screenResolutionRatio = screenWidth / 240.0;
        hourHandLength = (60 * screenResolutionRatio).toNumber();
        minuteHandLength = (90 * screenResolutionRatio).toNumber();
        secondHandLength = (100 * screenResolutionRatio).toNumber();
        handsTailLength = (15 * screenResolutionRatio).toNumber();
        
        powerSaverIconRatio = 1.0 * screenResolutionRatio; //big icon
        if (powerSaverRefreshInterval != -999) {
            powerSaverIconRatio = 0.6 * screenResolutionRatio; //small icon
        }

        if (!((ticksColor == offSettingFlag) ||
            (ticksColor != offSettingFlag && ticks1MinWidth == 0 && ticks5MinWidth == 0 && ticks15MinWidth == 0))) {
            //array of ticks coordinates
            computeTicks();
        }

        //Y coordinates of time infos
        var fontAscent = Graphics.getFontAscent(font);
        fontHeight = Graphics.getFontHeight(font);
        dualTimeLocationY = screenWidth - (2 * fontHeight) - 32;
        dualTimeTimeY = screenWidth - (2 * fontHeight) - 30 + fontAscent;
        dualTimeAmPmY = screenWidth - fontHeight - 30 + fontAscent - Graphics.getFontHeight(Graphics.FONT_XTINY) - 1;
        dualTimeOneLinerY = screenWidth - fontHeight - 70;
        dualTimeOneLinerAmPmY = screenWidth - 70 - Graphics.getFontHeight(Graphics.FONT_XTINY) - 1;
        eventNameY = 35 + fontAscent;
        dateAt6Y = screenWidth - fontHeight - 30;

        //dual time offsets
        if (dualTimeColor != offSettingFlag) {
            var minusPos = dualTimeOffset.find("-");
            var semiColPos = dualTimeOffset.find(":");
            if (semiColPos != null) {
                dualTimeHourOffset = dualTimeOffset.toNumber();
                if (dualTimeHourOffset == null) {
                    dualTimeHourOffset = 0;
                }
                dualTimeMinOffset = dualTimeOffset.substring(semiColPos + 1, dualTimeOffset.length()).toNumber();
                if (dualTimeHourOffset == null) {
                    dualTimeMinOffset = 0;
                }
                if (minusPos == 0 && dualTimeHourOffset == 0) {
                    dualTimeMinOffset = dualTimeMinOffset * (-1);
                }
            } else {
                dualTimeHourOffset = dualTimeOffset.toNumber();
                if (dualTimeHourOffset == null) {
                    dualTimeHourOffset = 0;
                }
                dualTimeMinOffset = 0;
            }
            if (dualTimeHourOffset.abs() > 23) {
                dualTimeHourOffset = dualTimeHourOffset % 24;
            }
            if (dualTimeMinOffset > 59) {
                dualTimeMinOffset = dualTimeMinOffset % 60;
            }
            if (dualTimeHourOffset < 0) {
                dualTimeMinOffset = dualTimeMinOffset * (-1);
            }
        }

        if (arcsStyle == 2) {
            arcPenWidth = screenRadius;
        } else {
            arcPenWidth = 10;
        }
        arcRadius = screenRadius - (arcPenWidth / 2);

		computeSunConstants();

        //constants pre-computed, doesn't need to be computed again
        needComputeConstants = false;
    }

    function parsePowerSaverTime(time) {
        var pos = time.find(":");
        if (pos != null) {
            var hour = time.substring(0, pos).toNumber();
            var min = time.substring(pos + 1, time.length()).toNumber();
            if (hour != null && min != null) {
                return (hour * 60) + min;
            } else {
                return -1;
            }
        } else {
            return -1;
        }
    }

    function computeTicks() {
        var angle;
        ticks = new [16];
        //to save the memory compute only a quarter of the ticks, the rest will be mirrored.
        //I believe it will still save some CPU utilization
        for (var i = 0; i < 16; i++) {
            angle = i * twoPI / 60.0;
            if ((i % 15) == 0) { //quarter tick
                if (ticks15MinWidth > 0) {
                    ticks[i] = computeTickRectangle(angle, 20, ticks15MinWidth);
                }
            } else if ((i % 5) == 0) { //5-minute tick
                if (ticks5MinWidth > 0) {
                    ticks[i] = computeTickRectangle(angle, 20, ticks5MinWidth);
                }
            } else if (ticks1MinWidth > 0) { //1-minute tick
                ticks[i] = computeTickRectangle(angle, 10, ticks1MinWidth);
            }
        }
    }

    function computeTickRectangle(angle, length, width) {
        var halfWidth = width / 2;
        var coords = [[-halfWidth, screenRadius], [-halfWidth, screenRadius - length], [halfWidth, screenRadius - length], [halfWidth, screenRadius]];
        return computeRectangle(coords, angle);
    }

    function computeRectangle(coords, angle) {
        var rect = new [4];
        var x;
        var y;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        //transform coordinates
        for (var i = 0; i < 4; i++) {
            x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;
            rect[i] = [screenRadius + x, screenRadius + y];
        }

        return rect;
    }

    function drawBattery(dc) {
        var batStat = System.getSystemStats().battery;
        dc.setPenWidth(arcPenWidth);
        if (oneColor != offSettingFlag) {
            dc.setColor(oneColor, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 180, 180 - 0.9 * batStat);
        } else {
            if (batStat > 30) {
                dc.setColor(battery100Color, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 180, 180 - 0.9 * batStat);
                dc.setColor(battery30Color, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 180, 153);
                dc.setColor(battery15Color, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 180, 166.5);
            } else if (batStat <= 30 && batStat > 15){
                dc.setColor(battery30Color, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 180, 180 - 0.9 * batStat);
                dc.setColor(battery15Color, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 180, 166.5);
            } else {
                dc.setColor(battery15Color, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 180, 180 - 0.9 * batStat);
            }
        }
    }

    function drawNotifications(dc, notifications) {
        if (notifications > 0) {
            drawItems(dc, notifications, 90, notificationColor);
        }
    }

    function drawBluetooth(dc, phoneConnected) {
        if (phoneConnected) {
            dc.setColor(bluetoothColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(arcPenWidth);
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 0, -30);
        }
    }

    function drawDoNotDisturb(dc, doNotDisturb) {
        if (doNotDisturb) {
            dc.setColor(dndColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(arcPenWidth);
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_COUNTER_CLOCKWISE, 270, -60);
        }
    }

    function drawAlarms(dc, alarms) {
        if (alarms > 0) {
            drawItems(dc, alarms, 270, alarmColor);
        }
    }

    function drawItems(dc, count, angle, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(arcPenWidth);
        if (count < 11) {
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, angle, angle - 30 - ((count - 1) * 6));
        } else {
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, angle, angle - 90);
        }
    }

    function drawTicks(dc) {
        var coord = new [4];
        dc.setColor(ticksColor, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 16; i++) {
        	//30-45 ticks
            if (ticks[i] != null) {
                dc.fillPolygon(ticks[i]);
            }

            //mirror pre-computed ticks
            if (i >= 0 && i <= 15 && ticks[i] != null) {
            	//15-30 ticks
                for (var j = 0; j < 4; j++) {
                    coord[j] = [screenWidth - ticks[i][j][0], ticks[i][j][1]];
                }
                dc.fillPolygon(coord);

				//45-60 ticks
                for (var j = 0; j < 4; j++) {
                    coord[j] = [ticks[i][j][0], screenWidth - ticks[i][j][1]];
                }
                dc.fillPolygon(coord);

				//0-15 ticks
                for (var j = 0; j < 4; j++) {
                    coord[j] = [screenWidth - ticks[i][j][0], screenWidth - ticks[i][j][1]];
                }
                dc.fillPolygon(coord);
            }
        }
    }

    function drawHands(dc, clockTime) {
        var hourAngle, minAngle;

        //draw hour hand
        hourAngle = ((clockTime.hour % 12) * 60.0) + clockTime.min;
        hourAngle = hourAngle / (12 * 60.0) * Math.PI * 2;
        if (handsOutlineColor != offSettingFlag) {
            drawHand(dc, handsOutlineColor, computeHandRectangle(hourAngle, hourHandLength + 2, handsTailLength + 2, hourHandWidth + 4));
        }
        drawHand(dc, handsColor, computeHandRectangle(hourAngle, hourHandLength, handsTailLength, hourHandWidth));

        //draw minute hand
        minAngle = (clockTime.min / 60.0) * Math.PI * 2;
        if (handsOutlineColor != offSettingFlag) {
            drawHand(dc, handsOutlineColor, computeHandRectangle(minAngle, minuteHandLength + 2, handsTailLength + 2, minuteHandWidth + 4));
        }
        drawHand(dc, handsColor, computeHandRectangle(minAngle, minuteHandLength, handsTailLength, minuteHandWidth));

        //draw bullet
        var bulletRadius = hourHandWidth > minuteHandWidth ? hourHandWidth / 2 : minuteHandWidth / 2;
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenRadius, screenRadius, bulletRadius + 1);
        if (showSecondHand == 2) {
            dc.setPenWidth(secondHandWidth);
            dc.setColor(getSecondHandColor(), Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(screenRadius, screenRadius, bulletRadius + 2);
        } else {
            dc.setPenWidth(bulletRadius);
            dc.setColor(handsColor,Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(screenRadius, screenRadius, bulletRadius + 2);
        }
    }

    function drawSecondHand(dc, clockTime) {
        var secAngle;
        var secondHandColor = getSecondHandColor();

        //if we are out of sleep mode, draw the second hand directly in the full update method.
        secAngle = (clockTime.sec / 60.0) * Math.PI * 2;
        if (handsOutlineColor != offSettingFlag) {
            drawHand(dc, handsOutlineColor, computeHandRectangle(secAngle, secondHandLength + 2, handsTailLength + 2, secondHandWidth + 4));
        }
        drawHand(dc, secondHandColor, computeHandRectangle(secAngle, secondHandLength, handsTailLength, secondHandWidth));

        //draw center bullet
        var bulletRadius = hourHandWidth > minuteHandWidth ? hourHandWidth / 2 : minuteHandWidth / 2;
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenRadius, screenRadius, bulletRadius + 1);
        dc.setPenWidth(secondHandWidth);
        dc.setColor(secondHandColor, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(screenRadius, screenRadius, bulletRadius + 2);
    }

    function drawHand(dc, color, coords) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(coords);
    }

    function computeHandRectangle(angle, handLength, tailLength, width) {
        var halfWidth = width / 2;
        var coords = [[-halfWidth, tailLength], [-halfWidth, -handLength], [halfWidth, -handLength], [halfWidth, tailLength]];
        return computeRectangle(coords, angle);
    }

    function getSecondHandColor() {
        var color;
        if (oneColor != offSettingFlag) {
            color = oneColor;
        } else if (useBatterySecondHandColor) {
            var batStat = System.getSystemStats().battery;
            if (batStat > 30) {
                color = battery100Color;
            } else if (batStat <= 30 && batStat > 15) {
                color = battery30Color;
            } else {
                color = battery15Color;
            }
        } else {
            color = secondHandColor;
        }

        return color;
    }

    //Handle the partial update event
    function onPartialUpdate(dc) {
		//refresh whole screen before drawing power saver icon
        if (powerSaver && shouldPowerSave() && !isAwake && powerSaverDrawn) {
    		return;
    	}

        powerSaverDrawn = false;

        var refreshHR = false;
        var clockSeconds = System.getClockTime().sec;

        //should be HR refreshed?
        if (hrColor != offSettingFlag) {
            if (hrRefreshInterval == 1) {
                refreshHR = true;
            } else if (clockSeconds % hrRefreshInterval == 0) {
                refreshHR = true;
            }
        }

        //if we're not doing a full screen refresh we need to re-draw the background
        //before drawing the updated second hand position. Note this will only re-draw
        //the background in the area specified by the previously computed clipping region.
        if(!fullScreenRefresh) {
            drawBackground(dc);
        }

        if (showSecondHand == 2) {
            var secAngle = (clockSeconds / 60.0) * Math.PI * 2;
            var secondHandPoints = computeHandRectangle(secAngle, secondHandLength, handsTailLength, secondHandWidth);

            //update the cliping rectangle to the new location of the second hand.
            curClip = getBoundingBox(secondHandPoints);

            var bboxWidth = curClip[1][0] - curClip[0][0] + 1;
            var bboxHeight = curClip[1][1] - curClip[0][1] + 1;
            //merge clip boundaries with HR area
            if (hrColor != offSettingFlag) {
                if (curClip[0][0] > 30) {
                    bboxWidth = (curClip[0][0] - 30) + bboxWidth;
                    curClip[0][0] = 30;
                }
                if (curClip[0][1] > (screenRadius - (fontHeight / 2))) {
                    curClip[0][1] = screenRadius - (fontHeight / 2);
                    bboxHeight = curClip[1][1] - curClip[0][1];
                }
                if (curClip[1][1] < (screenRadius + (fontHeight / 2))) {
                    bboxHeight = (screenRadius + (fontHeight / 2)) - curClip[0][1];
                }
            }
            dc.setClip(curClip[0][0], curClip[0][1], bboxWidth, bboxHeight);

            if (hrColor != offSettingFlag) {
                drawHR(dc, refreshHR);
            }

            //draw the second hand to the screen.
            dc.setColor(getSecondHandColor(), Graphics.COLOR_TRANSPARENT);
            //debug rectangle
            //dc.drawRectangle(curClip[0][0], curClip[0][1], bboxWidth, bboxHeight);
            dc.fillPolygon(secondHandPoints);

            //draw center bullet
            var bulletRadius = hourHandWidth > minuteHandWidth ? hourHandWidth / 2 : minuteHandWidth / 2;
            dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(screenRadius, screenRadius, bulletRadius + 1);
        }

        //draw HR
        if (hrColor != offSettingFlag && showSecondHand != 2) {
            drawHR(dc, refreshHR);
        }

        if (powerSaver && shouldPowerSave() && !isAwake) {
            requestUpdate();
        }
    }

    //Draw the watch face background
    //onUpdate uses this method to transfer newly rendered Buffered Bitmaps
    //to the main display.
    //onPartialUpdate uses this to blank the second hand from the previous
    //second before outputing the new one.
    function drawBackground(dc) {
        //If we have an offscreen buffer that has been written to
        //draw it to the screen.
        if( null != offscreenBuffer ) {
            dc.drawBitmap(0, 0, offscreenBuffer);
        }
    }

    //Compute a bounding box from the passed in points
    function getBoundingBox( points ) {
        var min = [9999,9999];
        var max = [0,0];

        for (var i = 0; i < points.size(); ++i) {
            if(points[i][0] < min[0]) {
                min[0] = points[i][0];
            }
            if(points[i][1] < min[1]) {
                min[1] = points[i][1];
            }
            if(points[i][0] > max[0]) {
                max[0] = points[i][0];
            }
            if(points[i][1] > max[1]) {
                max[1] = points[i][1];
            }
        }

        return [min, max];
    }

    function drawEvent(dc, eventName, daysToEvent) {
        dc.setColor(eventColor, Graphics.COLOR_TRANSPARENT);
        if (daysToEvent > 0) {
            dc.drawText(screenRadius, 35, font, daysToEvent, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(screenRadius, eventNameY, font, eventName, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(screenRadius, eventNameY, font, eventName, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawDualTime(dc, clockTime, is24Hour) {
        var dualTime;
        var suffix12Hour = "";
        var dayPrefix = "";
        var utcLocalOffset = 0;

        if (dualTimeUTC) {
            utcLocalOffset = clockTime.timeZoneOffset / 3600;
        }

        var dualHour = clockTime.hour + dualTimeHourOffset - utcLocalOffset;
        var dualMin = clockTime.min + dualTimeMinOffset;

        //compute dual hour and min
        if (dualMin > 59) {
            dualMin = dualMin - 60;
            dualHour++;
        } else if (dualMin < 0) {
            dualMin = dualMin + 60;
            dualHour--;
        }
        if (dualHour > 23) {
            dualHour = dualHour - 24;
            dayPrefix = "+";
        } else if (dualHour < 0) {
            dualHour = dualHour + 24;
            dayPrefix = "-";
        }

        //12-hour format conversion
        if (!is24Hour) {
            if (dualHour > 12) {
                dualHour = dualHour - 12;
                suffix12Hour = " PM";
            } else if (dualHour == 12) {
                suffix12Hour = " PM";
            } else {
                suffix12Hour = " AM";
            }
        }

        dc.setColor(dualTimeColor, Graphics.COLOR_TRANSPARENT);
        if (datePosition != 6 || dateColor == offSettingFlag) {
            //draw dual time at 6 position
            dc.drawText(screenRadius, dualTimeLocationY, font, dualTimeLocation, Graphics.TEXT_JUSTIFY_CENTER);
            dualTime = Lang.format("$1$$2$:$3$", [dayPrefix, dualHour, dualMin.format("%02d")]);
            if (is24Hour) {
                dc.drawText(screenRadius, dualTimeTimeY, font, dualTime, Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                //X position fine tuning for 12-hour format
                var xShift = 50;
                if (dualHour < 10 && dayPrefix.equals("")) {
                    xShift = 38;
                } else if ((dualHour >= 10 && dayPrefix.equals("")) || (dualHour < 10 && !dayPrefix.equals(""))) {
                    xShift = 44;
                }
                dc.drawText(screenRadius - xShift, dualTimeTimeY, font, dualTime, Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(screenRadius + xShift, dualTimeAmPmY, Graphics.FONT_XTINY, suffix12Hour, Graphics.TEXT_JUSTIFY_RIGHT);
            }
        } else {
            if (is24Hour) {
                //24-hour format -> 6 characters for location
                var location = dualTimeLocation.substring(0, 6);
                dualTime = Lang.format("$1$$2$:$3$ $4$", [dayPrefix, dualHour, dualMin.format("%02d"), location]);
                dc.drawText(screenRadius, dualTimeOneLinerY, font, dualTime, Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                //12-hour format -> AM/PM position fine-tuning
                dualTime = Lang.format("$1$$2$:$3$", [dayPrefix, dualHour, dualMin.format("%02d")]);
                var loc = dualTimeLocation.substring(0, 4);
                var xShift = 9;
                if (dualHour < 10 && dayPrefix.equals("")) {
                    xShift = 33;
                    loc = dualTimeLocation.substring(0, 6);
                } else if ((dualHour >= 10 && dayPrefix.equals("")) || (dualHour < 10 && !dayPrefix.equals(""))) {
                    xShift = 21;
                    loc = dualTimeLocation.substring(0, 5);
                }
                dc.drawText(43, dualTimeOneLinerY, font, dualTime, Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(screenRadius - xShift, dualTimeOneLinerAmPmY, Graphics.FONT_XTINY, suffix12Hour, Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(screenRadius + 77, dualTimeOneLinerY, font, loc, Graphics.TEXT_JUSTIFY_RIGHT);
            }
        }
    }

    function drawDate(dc, today) {
        var info = Gregorian.info(today, Time.FORMAT_MEDIUM);

        var dateString;
        switch (dateFormat) {
            case 0: dateString = info.day;
                    break;
            case 1: dateString = Lang.format("$1$ $2$", [info.day_of_week.substring(0, 3), info.day]);
                    break;
            case 2: dateString = Lang.format("$1$ $2$", [info.day, info.day_of_week.substring(0, 3)]);
                    break;
            case 3: dateString = Lang.format("$1$ $2$", [info.day, info.month.substring(0, 3)]);
                    break;
            case 4: dateString = Lang.format("$1$ $2$", [info.month.substring(0, 3), info.day]);
                    break;
        }
        dc.setColor(dateColor, Graphics.COLOR_TRANSPARENT);
        switch (datePosition) {
            case 3: dc.drawText(screenWidth - 30, screenRadius, font, dateString, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
                    break;
            case 6: dc.drawText(screenRadius, dateAt6Y, font, dateString, Graphics.TEXT_JUSTIFY_CENTER);
                    break;
            case 9: dc.drawText(30, screenRadius, font, dateString, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
                    break;
        }
    }

    function drawHR(dc, refreshHR) {
        var hr = 0;
        var hrText;
        var activityInfo;
        var hrTextDimension = dc.getTextDimensions("888", font); //to compute correct clip boundaries

        if (refreshHR) {
            activityInfo = Activity.getActivityInfo();
            if (activityInfo != null) {
                hr = activityInfo.currentHeartRate;
                lastMeasuredHR = hr;
            }
        } else {
            hr = lastMeasuredHR;
        }

        if (hr == null || hr == 0) {
            hrText = "";
        } else {
            hrText = hr.format("%i");
        }

        if (showSecondHand != 2) {
            dc.setClip(30, screenRadius - (hrTextDimension[1] / 2), hrTextDimension[0], hrTextDimension[1]);
        }

        dc.setColor(hrColor, Graphics.COLOR_TRANSPARENT);
        //debug rectangle
        //dc.drawRectangle(30, screenRadius - (hrTextDimension[1] / 2), hrTextDimension[0], hrTextDimension[1]);
        dc.drawText(hrTextDimension[0] + 30, screenRadius, font, hrText, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function shouldPowerSave() {
        var refreshDisplay = true;
        var time = System.getClockTime();
        var timeMinOfDay = (time.hour * 60) + time.min;
        
        if (startPowerSaverMin <= endPowerSaverMin) {
        	if ((startPowerSaverMin <= timeMinOfDay) && (timeMinOfDay < endPowerSaverMin)) {
        		refreshDisplay = false;
        	}
        } else {
        	if ((startPowerSaverMin <= timeMinOfDay) || (timeMinOfDay < endPowerSaverMin)) {
        		refreshDisplay = false;
        	}        
        }

        return !refreshDisplay;
    }

    function drawPowerSaverIcon(dc) {
        dc.setColor(handsColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenRadius, screenRadius, 45 * powerSaverIconRatio);
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenRadius, screenRadius, 40 * powerSaverIconRatio);
        dc.setColor(handsColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(screenRadius - (13 * powerSaverIconRatio), screenRadius - (23 * powerSaverIconRatio), 26 * powerSaverIconRatio, 51 * powerSaverIconRatio);
        dc.fillRectangle(screenRadius - (4 * powerSaverIconRatio), screenRadius - (27 * powerSaverIconRatio), 8 * powerSaverIconRatio, 5 * powerSaverIconRatio);
        if (oneColor == offSettingFlag) {
            dc.setColor(powerSaverIconColor, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(oneColor, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(screenRadius - (10 * powerSaverIconRatio), screenRadius - (20 * powerSaverIconRatio), 20 * powerSaverIconRatio, 45 * powerSaverIconRatio);

        powerSaverDrawn = true;
    }
    
	function computeSunConstants() {
    	var posInfo = Toybox.Position.getInfo();
    	if (posInfo != null && posInfo.position != null) {
	    	var sc = new SunCalc();
	    	var time_now = Time.now();    	
	    	var loc = posInfo.position.toRadians();		
	        sunriseStartAngle = computeSunAngle(sc.calculate(time_now, loc, SunCalc.DAWN));	        
	        sunriseEndAngle = computeSunAngle(sc.calculate(time_now, loc, SunCalc.SUNRISE));
	        sunsetStartAngle = computeSunAngle(sc.calculate(time_now, loc, SunCalc.SUNSET));
	        sunsetEndAngle = computeSunAngle(sc.calculate(time_now, loc, SunCalc.DUSK));
        }
	}

	function computeSunAngle(time) {
        var timeInfo = Time.Gregorian.info(time, Time.FORMAT_SHORT);       
        var angle = ((timeInfo.hour % 12) * 60.0) + timeInfo.min;
        angle = angle / (12 * 60.0) * twoPI;
        return -(angle - Math.PI/2) * 180 / Math.PI;	
	}

	function drawSun(dc) {
        dc.setPenWidth(7);

        //draw sunrise
        if (sunriseColor != offSettingFlag) {
	        dc.setColor(sunriseColor, Graphics.COLOR_TRANSPARENT);
			dc.drawArc(screenRadius, screenRadius, screenRadius - 17, Graphics.ARC_CLOCKWISE, sunriseStartAngle, sunriseEndAngle);
		}

        //draw sunset
        if (sunsetColor != offSettingFlag) {
	        dc.setColor(sunsetColor, Graphics.COLOR_TRANSPARENT);
			dc.drawArc(screenRadius, screenRadius, screenRadius - 13, Graphics.ARC_CLOCKWISE, sunsetStartAngle, sunsetEndAngle);
		}
	}

}
