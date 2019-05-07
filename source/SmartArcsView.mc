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

    //variables for pre-computation
    var screenWidth;
    var screenRadius;
    var arcRadius;
    var twoPI = Math.PI * 2;
    var dualTimeLocationY;
    var dualTimeTimeY;
    var dualTimeAmPmY;
    var dualTimeOneLinerY;
    var eventNameY;
    var dateAt6Y;

    //user settings
    var bgColor;
    var handsColor;
    var secondHandColor;
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
    var dualTimeLocation;
    var showSecondHand;
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

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    function computeConstants(dc) {
        screenWidth = dc.getWidth();
        screenRadius = screenWidth / 2;

        var fontHeight = Graphics.getFontHeight(font);
        var fontAscent = Graphics.getFontAscent(font);
        dualTimeLocationY = screenWidth - (2 * fontHeight) - 32;
        dualTimeTimeY = screenWidth - (2 * fontHeight) - 30 + fontAscent;
        dualTimeAmPmY = screenWidth - fontHeight - 30 + fontAscent - Graphics.getFontHeight(Graphics.FONT_XTINY) - 1;
        dualTimeOneLinerY = screenWidth - fontHeight - 70;
        eventNameY = 35 + fontAscent;
        dateAt6Y = screenWidth - fontHeight - 30;

        if (arcsStyle == 1) {
            arcPenWidth = 10;
        } else {
            arcPenWidth = screenRadius;
        }
        arcRadius = screenRadius - (arcPenWidth / 2);

        precompute = false;
    }

    // Update the view
    function onUpdate(dc) {
        deviceSettings = System.getDeviceSettings();

        //compute what does not need to be computed on each update
        if (precompute) {
            computeConstants(dc);
        }

        today = Time.today();

        //clear the screen
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

        drawTicks(dc);

        if (!handsOnTop) {
            drawHands(dc, System.getClockTime());
        }

        if (eventColor != offSettingFlag) {
            //compute days to event
            var eventDateMoment = new Time.Moment(eventDate);
            var daysToEvent = (eventDateMoment.value() - today.value()) / Gregorian.SECONDS_PER_DAY;

            drawEvent(dc, eventName, daysToEvent);
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
        }
        bgColor = app.getProperty("bgColor");
        ticksColor = app.getProperty("ticksColor");
        ticks1MinWidth = app.getProperty("ticks1MinWidth");
        ticks5MinWidth = app.getProperty("ticks5MinWidth");
        ticks15MinWidth = app.getProperty("ticks15MinWidth");
        handsColor = app.getProperty("handsColor");
        secondHandColor = app.getProperty("secondHandColor");
        eventColor = app.getProperty("eventColor");
        dualTimeColor = app.getProperty("dualTimeColor");
        dateColor = app.getProperty("dateColor");
        arcsStyle = app.getProperty("arcsStyle");

        showSecondHand = app.getProperty("showSecondHand");
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

        if (ticks15MinWidth > 0) {
            dc.setPenWidth(ticks15MinWidth);
            //pre-computed 15-minute ticks coordinates, length 20
            dc.drawLine(220.000000, 120.000000, 240.000000, 120.000000); //15
            dc.drawLine(119.999992, 220.000000, 119.999992, 240.000000); //30
            dc.drawLine(20.000000, 119.999992, 0.000000, 119.999992); //45
            dc.drawLine(120.000000, 20.000000, 120.000000, 0.000000); //60
        }

        if (ticks5MinWidth > 0) {
            dc.setPenWidth(ticks5MinWidth);
            //pre-computed 5-minute ticks coordinates, length 20
            dc.drawLine(206.602539, 170.000000, 223.923050, 180.000000); //20
            dc.drawLine(170.000000, 206.602539, 180.000000, 223.923050); //25
            dc.drawLine(69.999992, 206.602539, 59.999992, 223.923050); //35
            dc.drawLine(33.397461, 170.000000, 16.076950, 180.000000); //40
            dc.drawLine(33.397476, 69.999985, 16.076965, 59.999977); //50
            dc.drawLine(70.000008, 33.397453, 60.000011, 16.076950); //55
            dc.drawLine(170.000000, 33.397453, 179.999985, 16.076950); //5
            dc.drawLine(206.602554, 70.000023, 223.923065, 60.000031); //10
        }

        if (ticks1MinWidth > 0) {
            dc.setPenWidth(ticks1MinWidth);
            //pre-computed minute ticks coordinates, length 10
            dc.drawLine(229.397400, 131.498138, 239.342621, 132.543411); //16
            dc.drawLine(227.596237, 142.870285, 237.377716, 144.949402); //17
            dc.drawLine(224.616211, 153.991867, 234.126785, 157.082031); //18
            dc.drawLine(220.489990, 164.741028, 229.625458, 168.808395); //19
            dc.drawLine(208.991867, 184.656372, 217.082031, 190.534225); //21
            dc.drawLine(201.745926, 193.604370, 209.177368, 200.295685); //22
            dc.drawLine(193.604370, 201.745941, 200.295670, 209.177383); //23
            dc.drawLine(184.656372, 208.991867, 190.534225, 217.082031); //24
            dc.drawLine(164.741028, 220.490005, 168.808395, 229.625458); //26
            dc.drawLine(153.991867, 224.616211, 157.082031, 234.126785); //27
            dc.drawLine(142.870285, 227.596237, 144.949402, 237.377716); //28
            dc.drawLine(131.498123, 229.397400, 132.543411, 239.342621); //29
            dc.drawLine(108.501862, 229.397400, 107.456581, 239.342621); //31
            dc.drawLine(97.129707, 227.596222, 95.050591, 237.377716); //32
            dc.drawLine(86.008125, 224.616211, 82.917953, 234.126770); //33
            dc.drawLine(75.258965, 220.489990, 71.191597, 229.625458); //34
            dc.drawLine(55.343605, 208.991852, 49.465752, 217.082031); //36
            dc.drawLine(46.395622, 201.745926, 39.704315, 209.177368); //37
            dc.drawLine(38.254074, 193.604370, 30.822624, 200.295685); //38
            dc.drawLine(31.008125, 184.656372, 22.917953, 190.534225); //39
            dc.drawLine(19.509995, 164.741028, 10.374542, 168.808395); //41
            dc.drawLine(15.383774, 153.991852, 5.873207, 157.082016); //42
            dc.drawLine(12.403763, 142.870270, 2.622284, 144.949402); //43
            dc.drawLine(10.602592, 131.498138, 0.657372, 132.543427); //44
            dc.drawLine(10.602592, 108.501869, 0.657372, 107.456589); //46
            dc.drawLine(12.403770, 97.129700, 2.622292, 95.050583); //47
            dc.drawLine(15.383797, 86.008102, 5.873230, 82.917938); //48
            dc.drawLine(19.510002, 75.258957, 10.374550, 71.191589); //49
            dc.drawLine(31.008133, 55.343613, 22.917969, 49.465759); //51
            dc.drawLine(38.254074, 46.395630, 30.822624, 39.704323); //52
            dc.drawLine(46.395645, 38.254066, 39.704338, 30.822617); //53
            dc.drawLine(55.343643, 31.008118, 49.465790, 22.917946); //54
            dc.drawLine(75.258972, 19.510002, 71.191605, 10.374550); //56
            dc.drawLine(86.008163, 15.383774, 82.917999, 5.873207); //57
            dc.drawLine(97.129745, 12.403763, 95.050629, 2.622284); //58
            dc.drawLine(108.501884, 10.602592, 107.456596, 0.657372); //59
            dc.drawLine(131.498123, 10.602592, 132.543396, 0.657372); //1
            dc.drawLine(142.870316, 12.403770, 144.949432, 2.622292); //2
            dc.drawLine(153.991882, 15.383789, 157.082062, 5.873222); //3
            dc.drawLine(164.741089, 19.510025, 168.808441, 10.374573); //4
            dc.drawLine(184.656403, 31.008148, 190.534256, 22.917984); //6
            dc.drawLine(193.604385, 38.254074, 200.295685, 30.822632); //7
            dc.drawLine(201.745941, 46.395638, 209.177383, 39.704330); //8
            dc.drawLine(208.991898, 55.343658, 217.082062, 49.465805); //9
            dc.drawLine(220.490021, 75.258987, 229.625458, 71.191620); //11
            dc.drawLine(224.616211, 86.008133, 234.126785, 82.917969); //12
            dc.drawLine(227.596222, 97.129707, 237.377716, 95.050591); //13
            dc.drawLine(229.397400, 108.501900, 239.342621, 107.456619); //14
        }

//        var x1, y1, x2, y2;
//        var outerR = screenRadius;
//        var innerR = outerR - 10;
//        var tick = 15;
//        for (var i = 0; i < 60; i++) {
//            var angle = i * twoPI / 60;
//            x1 = outerR + innerR * Math.cos(angle);
//            y1 = outerR + innerR * Math.sin(angle);
//            x2 = outerR + outerR * Math.cos(angle);
//            y2 = outerR + outerR * Math.sin(angle);
//            dc.drawLine(x1, y1, x2, y2);
//            System.println("dc.drawLine(" + x1 + ", " + y1 + ", " + x2 + ", " + y2 + "); //" + tick);
//            tick++;
//        }
//        System.println("=================");
    }

    function getColor(indicatorColor) {
        var color;
        if (oneColor != offSettingFlag) {
            color = oneColor;
        } else {
            color = indicatorColor;
        }

        return color;
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

    function drawBluetooth(dc) {
        if (deviceSettings.phoneConnected == true) {
            dc.setColor(getColor(bluetoothColor), Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(arcPenWidth);
            dc.drawArc(screenRadius, screenRadius, arcRadius, Graphics.ARC_CLOCKWISE, 0, -30);
        }
    }

    function drawDoNotDisturb(dc) {
        if (deviceSettings.doNotDisturb == true) {
            dc.setColor(getColor(dndColor), Graphics.COLOR_TRANSPARENT);
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
            drawItems(dc, alarms, 270, getColor(alarmColor));
        }
    }

    function drawNotifications(dc) {
        var notifications = deviceSettings.notificationCount;
        if (notifications > 0) {
            drawItems(dc, notifications, 90, getColor(notificationColor));
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
                //24-hour format -> 6 charactes for location
                location = location.substring(0, 6);
                dualTime = Lang.format("$1$$2$:$3$ $4$", [dayPrefix, dualHour, clockTime.min.format("%02d"), location]);
            } else {
                //12-hour format -> 3 charactes for location (because of AM/PM)
                location = location.substring(0, 3);
                dualTime = Lang.format("$1$$2$:$3$$4$ $5$", [dayPrefix, dualHour, clockTime.min.format("%02d"), suffix12Hour, location]);
            }
            dc.drawText(screenRadius, dualTimeOneLinerY, font, dualTime, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawDate(dc, today) {
        var info = Gregorian.info(today, Time.FORMAT_MEDIUM);

        var dateString;
        switch (dateFormat) {
            case 1: dateString = Lang.format("$1$ $2$", [info.day_of_week, info.day]);
                    break;
            case 2: dateString = Lang.format("$1$ $2$", [info.day, info.day_of_week]);
                    break;
            case 3: dateString = Lang.format("$1$ $2$", [info.day, info.month]);
                    break;
            case 4: dateString = Lang.format("$1$ $2$", [info.month, info.day]);
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
        if (daysToEvent > 0) {
            dc.setColor(eventColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenRadius, 35, font, daysToEvent, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(screenRadius, eventNameY, font, eventName, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawHand(dc, angle, length, width, tailHandLength) {
        dc.setPenWidth(width);

        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        var x1 = screenRadius - tailHandLength * sin;
        var y1 = screenRadius + tailHandLength * cos;
        var x2 = screenRadius + length * sin;
        var y2 = screenRadius - length * cos;
        dc.drawLine(x1, y1, x2, y2);
    }

    function drawHands(dc, clockTime) {
        var hour, min, sec;
        var tailHandLength = 15;

        //draw hour hand
        hour = (((clockTime.hour % 12) * 60.0) + clockTime.min);
        hour = hour / (12 * 60.0);
        hour = hour * twoPI;
        dc.setColor(handsColor, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, hour, screenRadius - 50, 5, tailHandLength);

        //draw minute hand
        min = (clockTime.min / 60.0) * twoPI;
        dc.setColor(handsColor, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, min, screenRadius - 30, 5, tailHandLength);

        //draw second hand
        var secondHandColor = -1;
        if (isAwake && showSecondHand) {
            secondHandColor = getSecondHandColor();

            sec = (clockTime.sec / 60.0) *  twoPI;
            dc.setColor(secondHandColor, Graphics.COLOR_TRANSPARENT);
            drawHand(dc, sec, screenRadius - 20, 3, tailHandLength);
        }

        //draq center bullet
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.fillCircle(screenRadius, screenRadius, 5);
        if (isAwake && showSecondHand) {
            dc.setColor(secondHandColor, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(handsColor,Graphics.COLOR_TRANSPARENT);
        }
        dc.drawCircle(screenRadius, screenRadius, 5);
    }
}
