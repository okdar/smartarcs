using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

class SmartArcsView extends WatchUi.WatchFace {

    var deviceSettings;
    var arcPenWidth;
    var today;
    var eventDay;
    var isAwake = false;
    var offSettingFlag = -999;
    var font = Graphics.FONT_TINY;
    var precompute;

    // variables for pre-computation
    var screenWidth;
    var screenRadius;
    var arcRadius;
    var twoPI = Math.PI * 2;
    var dualTimeLocationY;
    var dualTimeTimeY;
    var dualTimeAmPmY;
    var dualTimeOneLinerY;
    var dualTimeOneLinerAmPmY;
    var eventNameY;
    var dateAt6Y;
    var ticks;
    var showTicks;

    // user settings
    var bgColor;
    var handsColor;
    var handsOutlineColor;
    var secondHandColor;
    var hourHandWidth;
    var minuteHandWidth;
    var secondHandWidth;
    var hourHandLength;
    var minuteHandLength;
    var secondHandLength;
    var handsTailLength;
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
    var ticks1MinLength;
    var ticks5MinLength;
    var ticks15MinLength;
    var eventName;
    var eventDate;
    var dualTimeOffset;
    var dualTimeLocation;
    var useBatterySecondHandColor;
    var oneColor;
    var handsOnTop;
    var showBatteryIndicator;
    var datePosition;
    var dateFormat;
    var arcsStyle;

    function initialize() {
        loadUserSettings();
        WatchFace.initialize();
    }

    // Load resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // pre-compute values which don't need to be computed on each update
    function computeConstants(dc) {
        screenWidth = dc.getWidth();
        screenRadius = screenWidth / 2;

        showTicks = ((ticksColor == offSettingFlag) ||
            (ticksColor != offSettingFlag && ticks1MinWidth == 0 && ticks5MinWidth == 0 && ticks15MinWidth == 0 &&
            ticks1MinLength == 0 && ticks5MinLength == 0 && ticks15MinLength == 0)) ? false : true;
        if (showTicks) {
            computeTicks(); // array of ticks coordinates
        }

        // Y coordinates of time infos
        var fontHeight = Graphics.getFontHeight(font);
        var fontAscent = Graphics.getFontAscent(font);
        dualTimeLocationY = screenWidth - (2 * fontHeight) - 32;
        dualTimeTimeY = screenWidth - (2 * fontHeight) - 30 + fontAscent;
        dualTimeAmPmY = screenWidth - fontHeight - 30 + fontAscent - Graphics.getFontHeight(Graphics.FONT_XTINY) - 1;
        dualTimeOneLinerY = screenWidth - fontHeight - 70;
        dualTimeOneLinerAmPmY = screenWidth - 70 - Graphics.getFontHeight(Graphics.FONT_XTINY) - 1;
        eventNameY = 35 + fontAscent;
        dateAt6Y = screenWidth - fontHeight - 30;

        if (arcsStyle == 2) {
            arcPenWidth = screenRadius;
        }
        arcRadius = screenRadius - (arcPenWidth / 2);

        precompute = false;
    }

    // Update the view
    function onUpdate(dc) {
        deviceSettings = System.getDeviceSettings();

        // compute what does not need to be computed on each update
        if (precompute) {
            computeConstants(dc);
        }

        today = Time.today();

        // clear the screen
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenRadius, screenRadius, screenRadius + 2);

        if (showBatteryIndicator) {
            drawBattery(dc);
        }
        if (notificationColor != offSettingFlag) {
            drawNotifications(dc);
        }
        if (bluetoothColor != offSettingFlag) {
            drawBluetooth(dc);
        }
        if (dndColor != offSettingFlag) {
            drawDoNotDisturb(dc);
        }
        if (alarmColor != offSettingFlag) {
            drawAlarms(dc);
        }

        if (showTicks) {
            drawTicks(dc);
        }

        if (!handsOnTop) {
            drawHands(dc, System.getClockTime());
        }

        if (eventColor != offSettingFlag) {
            // compute days to event
            var eventDateMoment = new Time.Moment(eventDate);
            var daysToEvent = (eventDateMoment.value() - today.value()) / Gregorian.SECONDS_PER_DAY.toFloat();

            if (daysToEvent < 0) {
                //hide event when it is over
                eventColor = offSettingFlag;
                Application.getApp().setProperty("eventColor", offSettingFlag);
            } else {
                drawEvent(dc, eventName, daysToEvent.toNumber());
            }
        }

        if (dualTimeColor != offSettingFlag) {
            drawDualTime(dc, System.getClockTime(), dualTimeOffset, dualTimeLocation);
        }

        if (dateColor != offSettingFlag) {
            drawDate(dc, today);
        }

        if (handsOnTop) {
            drawHands(dc, System.getClockTime());
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        isAwake = true;
    }

    // Terminate any active timers and prepare for slow updates.
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
        } else {
            notificationColor = oneColor;
            bluetoothColor = oneColor;
            dndColor = oneColor;
            alarmColor = oneColor;
            secondHandColor = oneColor;
        }
        bgColor = app.getProperty("bgColor");
        ticksColor = app.getProperty("ticksColor");
        if (ticksColor != offSettingFlag) {
            ticks1MinWidth = app.getProperty("ticks1MinWidth");
            ticks5MinWidth = app.getProperty("ticks5MinWidth");
            ticks15MinWidth = app.getProperty("ticks15MinWidth");
            ticks1MinLength = app.getProperty("ticks1MinLength");
            ticks5MinLength = app.getProperty("ticks5MinLength");
            ticks15MinLength = app.getProperty("ticks15MinLength");
        }
        handsColor = app.getProperty("handsColor");
        handsOutlineColor = app.getProperty("handsOutlineColor");
        hourHandWidth = app.getProperty("hourHandWidth");
        minuteHandWidth = app.getProperty("minuteHandWidth");
        secondHandWidth = app.getProperty("secondHandWidth");
        hourHandLength = app.getProperty("hourHandLength");
        minuteHandLength = app.getProperty("minuteHandLength");
        secondHandLength = app.getProperty("secondHandLength");
        handsTailLength = app.getProperty("handsTailLength");
        eventColor = app.getProperty("eventColor");
        dualTimeColor = app.getProperty("dualTimeColor");
        dateColor = app.getProperty("dateColor");
        arcsStyle = app.getProperty("arcsStyle");
        arcPenWidth = app.getProperty("indicatorWidth");

        useBatterySecondHandColor = app.getProperty("useBatterySecondHandColor");

        if (eventColor != offSettingFlag) {
            eventName = app.getProperty("eventName");
            eventDate = app.getProperty("eventDate");
        }

        if (dualTimeColor != offSettingFlag) {
            dualTimeOffset = app.getProperty("dualTimeOffset");
            dualTimeLocation = app.getProperty("dualTimeLocation");
        }

        if (dateColor != offSettingFlag) {
            datePosition = app.getProperty("datePosition");
            dateFormat = app.getProperty("dateFormat");
        }

        handsOnTop = app.getProperty("handsOnTop");

        showBatteryIndicator = app.getProperty("showBatteryIndicator");

        precompute = true;
    }

    function drawTicks(dc) {
        dc.setColor(ticksColor, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 60; i++) {
            if (ticks[i] != null) {
                dc.fillPolygon(ticks[i]);
            }
        }
    }

    function getSecondHandColor() {
        var color;
        if (useBatterySecondHandColor) {
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

    function drawBluetooth(dc) {
        if (deviceSettings.phoneConnected == true) {
            dc.setColor(bluetoothColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(arcPenWidth);
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 0, -30);
        }
    }

    function drawDoNotDisturb(dc) {
        if (deviceSettings.doNotDisturb == true) {
            dc.setColor(dndColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(arcPenWidth);
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_COUNTER_CLOCKWISE, 270, -60);
        }
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

    function drawAlarms(dc) {
        var alarms = deviceSettings.alarmCount;
        if (alarms > 0) {
            drawItems(dc, alarms, 270, alarmColor);
        }
    }

    function drawNotifications(dc) {
        var notifications = deviceSettings.notificationCount;
        if (notifications > 0) {
            drawItems(dc, notifications, 90, notificationColor);
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

    function drawDualTime(dc, clockTime, offset, location) {
        var dualTime;
        var suffix12Hour = "";
        var dayPrefix = "";
        var dualHour = clockTime.hour + offset;

        //compute dual hour
        if (dualHour > 23) {
            dualHour = dualHour - 24;
            dayPrefix = "+";
        } else if (dualHour < 0) {
            dualHour = dualHour + 24;
            dayPrefix = "-";
        }

        //12-hour format conversion
        if (!deviceSettings.is24Hour) {
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
            dc.drawText(screenRadius, dualTimeLocationY, font, location, Graphics.TEXT_JUSTIFY_CENTER);
            dualTime = Lang.format("$1$$2$:$3$", [dayPrefix, dualHour, clockTime.min.format("%02d")]);
            if (deviceSettings.is24Hour) {
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
            if (deviceSettings.is24Hour) {
                //24-hour format -> 6 characters for location
                location = location.substring(0, 6);
                dualTime = Lang.format("$1$$2$:$3$ $4$", [dayPrefix, dualHour, clockTime.min.format("%02d"), location]);
                dc.drawText(screenRadius, dualTimeOneLinerY, font, dualTime, Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                //12-hour format -> AM/PM position fine-tuning
                dualTime = Lang.format("$1$$2$:$3$", [dayPrefix, dualHour, clockTime.min.format("%02d")]);
                var loc = location.substring(0, 4);
                var xShift = 9;
                if (dualHour < 10 && dayPrefix.equals("")) {
                    xShift = 33;
                    loc = location.substring(0, 6);
                } else if ((dualHour >= 10 && dayPrefix.equals("")) || (dualHour < 10 && !dayPrefix.equals(""))) {
                    xShift = 21;
                    loc = location.substring(0, 5);
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

    function drawEvent(dc, eventName, daysToEvent) {
        dc.setColor(eventColor, Graphics.COLOR_TRANSPARENT);
        if (daysToEvent > 0) {
            dc.drawText(screenRadius, 35, font, daysToEvent, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(screenRadius, eventNameY, font, eventName, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(screenRadius, eventNameY, font, eventName, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawHands(dc, clockTime) {
        var hourAngle, minAngle, secAngle;

        //draw hour hand
        hourAngle = ((clockTime.hour % 12) * 60.0) + clockTime.min;
        hourAngle = hourAngle / (12 * 60.0) * twoPI;
        if (handsOutlineColor != offSettingFlag) {
            drawHand(dc, handsOutlineColor, computeHandRectangle(hourAngle, hourHandLength + 2, handsTailLength + 2, hourHandWidth + 4));
        }
        drawHand(dc, handsColor, computeHandRectangle(hourAngle, hourHandLength, handsTailLength, hourHandWidth));

        //draw minute hand
        minAngle = (clockTime.min / 60.0) * twoPI;
        if (handsOutlineColor != offSettingFlag) {
            drawHand(dc, handsOutlineColor, computeHandRectangle(minAngle, minuteHandLength + 2, handsTailLength + 2, minuteHandWidth + 4));
        }
        drawHand(dc, handsColor, computeHandRectangle(minAngle, minuteHandLength, handsTailLength, minuteHandWidth));

        //draw second hand
        var secondHandColor = -1;
        if (isAwake && secondHandWidth > 0 && secondHandLength > 0) {
            secondHandColor = getSecondHandColor();

            secAngle = (clockTime.sec / 60.0) *  twoPI;
            if (handsOutlineColor != offSettingFlag) {
                drawHand(dc, handsOutlineColor, computeHandRectangle(secAngle, secondHandLength + 2, handsTailLength + 2, secondHandWidth + 4));
            }
            drawHand(dc, secondHandColor, computeHandRectangle(secAngle, secondHandLength, handsTailLength, secondHandWidth));
        }

        //draw center bullet
        var bulletRadius = hourHandWidth > minuteHandWidth ? hourHandWidth / 2 : minuteHandWidth / 2;
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(screenRadius, screenRadius, bulletRadius + 1);
        if (isAwake && secondHandWidth > 0 && secondHandLength > 0) {
            dc.setPenWidth(secondHandWidth);
            dc.setColor(secondHandColor, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(screenRadius, screenRadius, bulletRadius + 2);
        } else {
            dc.setPenWidth(bulletRadius);
            dc.setColor(handsColor,Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(screenRadius, screenRadius, bulletRadius + 2);
        }
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

    function computeTicks() {
        var angle;
        ticks = new [60];
        for (var i = 0; i < 60; i++) {
            angle = i * twoPI / 60.0;
            if ((i % 15) == 0) { //quarter tick
                if (ticks15MinWidth > 0 && ticks15MinLength > 0) {
                    ticks[i] = computeTickRectangle(angle, ticks15MinLength, ticks15MinWidth);
                }
            } else if ((i % 5) == 0) { //5-minute tick
                if (ticks5MinWidth > 0 && ticks5MinLength > 0) {
                    ticks[i] = computeTickRectangle(angle, ticks5MinLength, ticks5MinWidth);
                }
            } else if (ticks1MinWidth > 0 && ticks1MinLength > 0) { //1-minute tick
                ticks[i] = computeTickRectangle(angle, ticks1MinLength, ticks1MinWidth);
            }
        }
    }

}
