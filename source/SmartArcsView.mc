using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

class SmartArcsView extends WatchUi.WatchFace {

    var screenWidth;
    var screenRadius;
    var twoPI = Math.PI * 2;
    var deviceSettings;
    var arcPenWidth = 10;
    var arcRadius;
    var today;
    var eventDay;
    var isAwake = false;
    var offSettingFlag = -999;
    var font = Graphics.FONT_TINY;

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

    // Update the view
    function onUpdate(dc) {
        deviceSettings = System.getDeviceSettings();

        screenWidth = dc.getWidth();
        screenRadius = screenWidth / 2;
        arcRadius = screenRadius - (arcPenWidth / 2);

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
        handsColor = app.getProperty("handsColor");
        secondHandColor = app.getProperty("secondHandColor");
        eventColor = app.getProperty("eventColor");
        dualTimeColor = app.getProperty("dualTimeColor");
        dateColor = app.getProperty("dateColor");

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
    }

    function drawTicks(dc) {
        dc.setColor(ticksColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);

        //pre-computed ticks coordinates for length 20
        dc.drawLine(220.000000, 120.000000, 240.000000, 120.000000); //3
        dc.drawLine(206.602539, 170.000000, 223.923050, 180.000000); //4
        dc.drawLine(170.000000, 206.602539, 180.000000, 223.923050); //5
        dc.drawLine(119.999992, 220.000000, 119.999992, 240.000000); //6
        dc.drawLine(69.999992, 206.602539, 59.999992, 223.923050); //7
        dc.drawLine(33.397446, 169.999985, 16.076942, 179.999969); //8
        dc.drawLine(20.000000, 119.999992, 0.000000, 119.999992); //9
        dc.drawLine(33.397476, 69.999985, 16.076965, 59.999977); //10
        dc.drawLine(70.000008, 33.397453, 60.000011, 16.076950); //11
        dc.drawLine(120.000000, 20.000000, 120.000000, 0.000000); //12
        dc.drawLine(170.000031, 33.397476, 180.000046, 16.076973); //1
        dc.drawLine(206.602554, 70.000023, 223.923065, 60.000031); //2

//        var x1, y1, x2, y2;
//        var outerR = halfWidth;
//        var innerR = outerR - 20;
//        for (var i = 0; i < 12; i++) {
//            var angle = i * twoPI / 12;
//            x1 = outerR + innerR * Math.cos(angle);
//            y1 = outerR + innerR * Math.sin(angle);
//            x2 = outerR + outerR * Math.cos(angle);
//            y2 = outerR + outerR * Math.sin(angle);
//            dc.drawLine(x1, y1, x2, y2);
//            System.println("dc.drawLine(" + x1 + ", " + y1 + ", " + x2 + ", " + y2 + ")");
//        }
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
            dc.drawText(screenRadius, screenWidth - (2 * Graphics.getFontHeight(font)) - 32, font, location, Graphics.TEXT_JUSTIFY_CENTER);
            dualTime = Lang.format("$1$$2$:$3$", [dayPrefix, dualHour, clockTime.min.format("%02d")]);
            if (deviceSettings.is24Hour) {
                dc.drawText(screenRadius, screenWidth - (2 * Graphics.getFontHeight(font)) - 30 + Graphics.getFontAscent(font), font, dualTime, Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                //X position fine tuning
                var xShift = 50;
                if (dualHour < 10 && dayPrefix.equals("")) {
                    xShift = 38;
                } else if ((dualHour >= 10 && dayPrefix.equals("")) || (dualHour < 10 && !dayPrefix.equals(""))) {
                    xShift = 44;
                }
                dc.drawText(screenRadius - xShift, screenWidth - (2 * Graphics.getFontHeight(font)) - 30 + Graphics.getFontAscent(font), font, dualTime, Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(screenRadius + xShift, screenWidth - Graphics.getFontHeight(font) - 30 + Graphics.getFontAscent(font) - Graphics.getFontHeight(Graphics.FONT_XTINY) - 1, Graphics.FONT_XTINY, suffix12Hour, Graphics.TEXT_JUSTIFY_RIGHT);
            }
        } else {
            if (deviceSettings.is24Hour) {
                location = location.substring(0, 6);
                dualTime = Lang.format("$1$$2$:$3$ $4$", [dayPrefix, dualHour, clockTime.min.format("%02d"), location]);
            } else {
                location = location.substring(0, 3);
                dualTime = Lang.format("$1$$2$:$3$$4$ $5$", [dayPrefix, dualHour, clockTime.min.format("%02d"), suffix12Hour, location]);
            }
            dc.drawText(screenRadius, screenWidth - Graphics.getFontHeight(font) - 70, font, dualTime, Graphics.TEXT_JUSTIFY_CENTER);
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
            case 6: dc.drawText(screenRadius, screenWidth - Graphics.getFontHeight(font) - 30, font, dateString, Graphics.TEXT_JUSTIFY_CENTER);
                    break;
            case 9: dc.drawText(30, screenRadius, font, dateString, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
                    break;
        }
    }

    function drawEvent(dc, eventName, daysToEvent) {
        if (daysToEvent > 0) {
            dc.setColor(eventColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(screenRadius, 35, font, daysToEvent, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(screenRadius, 35 + Graphics.getFontAscent(font), font, eventName, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawHand(dc, angle, length, width, overHandLine) {
        dc.setPenWidth(width);

        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        var x1 = screenRadius - overHandLine * sin;
        var y1 = screenRadius + overHandLine * cos;
        var x2 = screenRadius + length * sin;
        var y2 = screenRadius - length * cos;
        dc.drawLine(x1, y1, x2, y2);
    }

    function drawHands(dc, clockTime) {
        var hour, min, sec;
        var overHandLine = 15;

        //draw hour hand
        hour = (((clockTime.hour % 12) * 60.0) + clockTime.min);
        hour = hour / (12 * 60.0);
        hour = hour * twoPI;
        dc.setColor(handsColor, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, hour, screenRadius - 50, 5, overHandLine);

        //draw minute hand
        min = (clockTime.min / 60.0) * twoPI;
        dc.setColor(handsColor, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, min, screenRadius - 30, 5, overHandLine);

        //draw second hand
        var color = -1;
        if (isAwake && showSecondHand) {
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

            sec = (clockTime.sec / 60.0) *  twoPI;
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            drawHand(dc, sec, screenRadius - 20, 3, overHandLine);
        }

        //draq center bullet
        dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.fillCircle(screenRadius, screenRadius, 5);
        if (isAwake && showSecondHand) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(handsColor,Graphics.COLOR_TRANSPARENT);
        }
        dc.drawCircle(screenRadius, screenRadius, 5);
    }
}
