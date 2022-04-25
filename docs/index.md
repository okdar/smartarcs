<p align="center" width="100%">
    <img src="stand_with_ukraine.png">
</p>
<p align="center" width="100%">
    <img src="suite.png"> 
</p>

* [Description](#description)
  * [SmartArcs Origin](#smartarcs-origin)
  * [SmartArcs Active](#smartarcs-active)
  * [SmartArcs Trip](#smartarcs-trip)
  * [Civil Twilights](#civil-twilights)
  * [Power Saver](#power-saver)
    * [Power Saver Settings](#power-saver-settings)
* [Donation](#donation)
* [Feedback](#feedback)
* [Credits](#credits)

SmartArcs is a suite of Garmin watchfaces. They were designed to be clean, minimalist and highly configurable. The suite consists of three watchfaces:
* **SmartArcs Origin** - simply focuses on time, nothing else ([download](https://apps.garmin.com/en-US/apps/073e2cbc-f25e-44b9-ab59-4966fa5abbd6))
* **SmartArcs Active** - gives an overview of your daily activity (steps and floors) ([download](https://apps.garmin.com/en-US/apps/3f5e481a-5f9e-4764-b2d5-5e9b174e2a98))
* **SmartArcs Trip** - shows useful trip data in two configurable data fields and two graphs ([download](https://apps.garmin.com/en-US/apps/a1bfdf21-bde7-4d63-925f-a6a04cb84aff))

## Description
SmartArcs name comes from a common functionality to all three watchfaces - colored arc indicators around the screen to display:
* **battery status**
* **number of phone notifications**. First notification is displayed as five minutes arc, each other as one minute arc.
* **Bluetooth connection status**
* **do not disturb status**
* **number of alarms**. First alarm is displayed as five minutes arc, each other as one minute arc.
* **civil twilights**

Watchfaces are updated once each minute. Some watches support updating the screen every second. On those watches SmartArcs can display also:
* **'always on' second hand**
* **heart rate**

*Note: SmartArcs currently does not support every second screen update on watches with AMOLED screen (Venu® models and D2™ Air)*

### SmartArcs Origin
This watchface focuses on time. It can display:
* **number of days to an event**, e.g. number of remaining days to your vacation or next marathon
* **dual time** ('+' means there is already next day in the dual time location, '-' means previous day)
* **date**
<p align="center" width="100%">
    <img src="smartarcs_origin.png"> 
</p>

### SmartArcs Active
This watchface gives an overview of your daily activity:
* **steps/distance** on the left side. First line displays daily steps, second line walked distance (in kilometers or miles depending on systems settings). Arc shows how you fulfill daily steps goal.
* **floors** on the right side. First line displays climbed floors, second line descended floors. Arc shows how you fulfill daily climbed floors goal.
<p align="center" width="100%">
    <img src="smartarcs_active.png"> 
</p>

### SmartArcs Trip
This watchface shows useful trip data in two configurable data fields and two graphs.

#### Data fields options
* daily walked distance
* elevation
* pressure
* temperature

#### Graph options
* elevation
* pressure
* heart rate
* temperature
<p align="center" width="100%">
    <img src="smartarcs_trip.png"> 
</p>

### Civil Twilights
SmartArcs watchfaces display also morn
ing and evening [civil twilights](https://en.wikipedia.org/wiki/Twilight#Civil_twilight). The arcs represent the civil twilight periods with sunrise/sunset and civil dawn/dusk as beginnings or ends of the arcs.

*Note: Civil twilights indicators require access to GPS location. If GPS location is not available civil twilights indicators are not displayed.*

<p align="center" width="100%">
    <img src="sun.png"> 
</p>

### Power Saver
There is no need to update watch screen whole day, e.g. when you sleep. SmartArcs watchfaces come with a unique feature, you can set up a period of time when the watch screen is not updated. It can save up to 15% of battery life (depending on power saver confuguration, measured on *vívoactive 3*).

*Please note that this function saves battery life only when SmartArcs watchface is active (shown on the screen), it has no impact in any other application.*

Garmin does not allow any input method (screen touch, button press) in watchfaces. That's why you cannot invoke screen update by user input in the power saver mode. The only way to refresh the screen is to look at your watch. When you raise the watch to look at it, the watch exits sleep mode and the screen is updated. An attempt to workaround missing watchface input methods is to update the screen in user defined intervals when the watchface is in power saver mode - see next chapter for details.

#### Power Saver Settings
Power saver can be configured in a few ways. It can be enabled:
* **in defined time window** - only in specified time period
* **always** - whole 24 hours

When power saver is enabled the watch screen can be updated:
* **5, 10 or 15 minutes** - the screen is regularly updated in defined intervals. You can somehow rely on displayed time. It is indicated by *small* battery icon.
<p align="center" width="100%">
    <img src="power_saver_small.png"> 
</p>
* **never** - the screen is never updated, you cannot rely on what is displayed. It is indicated by *big* battery icon.
<p align="center" width="100%">
    <img src="power_saver_big.png"> 
</p>

### Colors

<table class="palette">
<tbody><tr>
 <td style="background-color: #000000; color:white">0x000000</td>
 <td style="background-color: #000055; color:white">0x000055</td>
 <td style="background-color: #0000aa; color:black">0x0000aa</td>
 <td style="background-color: #0000ff; color:black">0x0000ff</td>
 <td style="background-color: #005500; color:white">0x005500</td>
 <td style="background-color: #005555; color:white">0x005555</td>
 <td style="background-color: #0055aa; color:black">0x0055aa</td>
 <td style="background-color: #0055ff; color:black">0x0055ff</td>
</tr><tr>
 <td style="background-color: #00aa00; color:black">0x00aa00</td>
 <td style="background-color: #00aa55; color:black">0x00aa55</td>
 <td style="background-color: #00aaaa; color:black">0x00aaaa</td>
 <td style="background-color: #00aaff; color:black">0x00aaff</td>
 <td style="background-color: #00ff00; color:black">0x00ff00</td>
 <td style="background-color: #00ff55; color:black">0x00ff55</td>
 <td style="background-color: #00ffaa; color:black">0x00ffaa</td>
 <td style="background-color: #00ffff; color:black">0x00ffff</td>
</tr><tr>
 <td style="background-color: #550000; color:white">0x550000</td>
 <td style="background-color: #550055; color:white">0x550055</td>
 <td style="background-color: #5500aa; color:black">0x5500aa</td>
 <td style="background-color: #5500ff; color:black">0x5500ff</td>
 <td style="background-color: #555500; color:white">0x555500</td>
 <td style="background-color: #555555; color:white">0x555555</td>
 <td style="background-color: #5555aa; color:black">0x5555aa</td>
 <td style="background-color: #5555ff; color:black">0x5555ff</td>
</tr><tr>
 <td style="background-color: #55aa00; color:black">0x55aa00</td>
 <td style="background-color: #55aa55; color:black">0x55aa55</td>
 <td style="background-color: #55aaaa; color:black">0x55aaaa</td>
 <td style="background-color: #55aaff; color:black">0x55aaff</td>
 <td style="background-color: #55ff00; color:black">0x55ff00</td>
 <td style="background-color: #55ff55; color:black">0x55ff55</td>
 <td style="background-color: #55ffaa; color:black">0x55ffaa</td>
 <td style="background-color: #55ffff; color:black">0x55ffff</td>
</tr><tr>
 <td style="background-color: #aa0000; color:black">0xaa0000</td>
 <td style="background-color: #aa0055; color:black">0xaa0055</td>
 <td style="background-color: #aa00aa; color:black">0xaa00aa</td>
 <td style="background-color: #aa00ff; color:black">0xaa00ff</td>
 <td style="background-color: #aa5500; color:black">0xaa5500</td>
 <td style="background-color: #aa5555; color:black">0xaa5555</td>
 <td style="background-color: #aa55aa; color:black">0xaa55aa</td>
 <td style="background-color: #aa55ff; color:black">0xaa55ff</td>
</tr><tr>
 <td style="background-color: #aaaa00; color:black">0xaaaa00</td>
 <td style="background-color: #aaaa55; color:black">0xaaaa55</td>
 <td style="background-color: #aaaaaa; color:black">0xaaaaaa</td>
 <td style="background-color: #aaaaff; color:black">0xaaaaff</td>
 <td style="background-color: #aaff00; color:black">0xaaff00</td>
 <td style="background-color: #aaff55; color:black">0xaaff55</td>
 <td style="background-color: #aaffaa; color:black">0xaaffaa</td>
 <td style="background-color: #aaffff; color:black">0xaaffff</td>
</tr><tr>
 <td style="background-color: #ff0000; color:black">0xff0000</td>
 <td style="background-color: #ff0055; color:black">0xff0055</td>
 <td style="background-color: #ff00aa; color:black">0xff00aa</td>
 <td style="background-color: #ff00ff; color:black">0xff00ff</td>
 <td style="background-color: #ff5500; color:black">0xff5500</td>
 <td style="background-color: #ff5555; color:black">0xff5555</td>
 <td style="background-color: #ff55aa; color:black">0xff55aa</td>
 <td style="background-color: #ff55ff; color:black">0xff55ff</td>
</tr><tr>
 <td style="background-color: #ffaa00; color:black">0xffaa00</td>
 <td style="background-color: #ffaa55; color:black">0xffaa55</td>
 <td style="background-color: #ffaaaa; color:black">0xffaaaa</td>
 <td style="background-color: #ffaaff; color:black">0xffaaff</td>
 <td style="background-color: #ffff00; color:black">0xffff00</td>
 <td style="background-color: #ffff55; color:black">0xffff55</td>
 <td style="background-color: #ffffaa; color:black">0xffffaa</td>
 <td style="background-color: #ffffff; color:black">0xffffff</td>
</tr>
</tbody></table>

## Donation
SmartArcs watchfaces offer **premium features for free**, e.g. power saver or graphs. I don't plan to make paid or trial watchfaces. If you like SmartArcs watchfaces please consider a [donation](https://paypal.me/RadkoNajman). It is an appreciation of my work and all [donations](https://paypal.me/RadkoNajman) are for a good cause.

**Currently all donations go to support UKRAINE!**
<p align="center" width="100%">
    <img src="ukraine.png">
</p>

<!--I resend all [donations](https://paypal.me/RadkoNajman) to non-profit organizations, mainly:

<p align="center" width="100%">
    <a href="https://www.kiva.org/"><img src="/smartarcs/kiva_logo.png" alt="" /></a> <a href="https://sharethemeal.org/"><img src="/smartarcs/sharethemeal_logo.png" alt="" /></a> <a href="https://www.msf.org/"><img src="/smartarcs/msf_logo.png" alt="" /></a>
</p>
-->

**Thank you!**

## Feedback
If you have any comments to SmartArcs watchfaces feel free to [send me a message (okdar@centrum.cz)](mailto:okdar@centrum.cz). You can also write a review in Garmin ConnectIQ Store:
* **SmartArcs Origin** ([review](https://apps.garmin.com/en-US/apps/073e2cbc-f25e-44b9-ab59-4966fa5abbd6#reviews))
* **SmartArcs Active** - ([review](https://apps.garmin.com/en-US/apps/3f5e481a-5f9e-4764-b2d5-5e9b174e2a98#reviews))
* **SmartArcs Trip** - ([review](https://apps.garmin.com/en-US/apps/a1bfdf21-bde7-4d63-925f-a6a04cb84aff#reviews))


## Credits
The idea of arc indicators was inspired by **Activity Classic Watch Face** and **ManniAT Face**.

Twilights calculation is powered by **[SunCalc](https://github.com/haraldh/SunCalc)** library.
