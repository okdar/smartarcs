<p align="center" width="100%">
    <img src="suite.png"> 
</p>

- [Description](#description)
  - [SmartArcs Origin](#smartarcs-origin)
  - [SmartArcs Active](#smartarcs-active)
  - [SmartArcs Trip](#smartarcs-trip)
    - [Data fields options](#data-fields-options)
    - [Graph options](#graph-options)
  - [SmartArcs HR](#smartarcs-hr)
  - [Civil Twilights](#civil-twilights)
  - [Power Saver](#power-saver)
  - [Lost and Found](#lost-and-found)
  - [Colors](#colors)
- [Donation](#donation)
- [Feedback](#feedback)
- [Credits](#credits)

SmartArcs is a suite of Garmin watchfaces. They were designed to be clean, minimalist and highly configurable. The suite consists of four watchfaces:
* **SmartArcs Origin** - simply focuses on time, nothing else ([download](https://apps.garmin.com/en-US/apps/073e2cbc-f25e-44b9-ab59-4966fa5abbd6))
* **SmartArcs Active** - gives an overview of your daily activity (steps and floors) ([download](https://apps.garmin.com/en-US/apps/3f5e481a-5f9e-4764-b2d5-5e9b174e2a98))
* **SmartArcs Trip** - shows useful trip data in two configurable data fields and two graphs ([download](https://apps.garmin.com/en-US/apps/a1bfdf21-bde7-4d63-925f-a6a04cb84aff))
* **SmartArcs HR** - shows heart rate graph in a colorful manner, scaled in increments of 10 beats ([download](https://apps.garmin.com/en-US/apps/7fa66b8d-6b99-4eb6-a12f-f14c82215fa9))

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

*Note: SmartArcs currently does not support every second screen update on watches with AMOLED screen.*

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

### SmartArcs HR
This watchface is designed to display a heart rate graph in a colorful manner, scaled in increments of 10 beats.

*Note: More details will come shortly.*

<p align="center" width="100%">
    <img src="smartarcs_hr.png"> 
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

Garmin does not allow any input method (screen touch, button press) in watchfaces. That's why you cannot invoke screen update by user input in the power saver mode. The only way to refresh the screen is to look at your watch. When you raise the watch to look at it, the watch exits sleep mode and the screen is updated. An attempt to workaround missing watchface input methods is to update the screen in user defined intervals when the watchface is in power saver mode. When power saver is enabled the watch screen can be updated in **5, 10 or 15 minutes intervals** so you can somehow rely on displayed time.

<p align="center" width="100%">
    <img src="power_saver.png"> 
</p>


### Lost and Found
Have you misplaced or forgotten your Garmin watch? If so, don't worry - there is an opportunity to retrieve it. This helpful watchface feature provides your contact information, enabling the finder to connect with you and ensure the safe return of your watch. If your watch is not connected to your phone for a certain time, screen with your contact information is displayed.

<p align="center" width="100%">
    <img src="lostandfound.png"> 
</p>


### Colors
SmartArcs watchfaces use 64 colors palette on watches which support it. See [Reference Guide](https://developer.garmin.com/connect-iq/reference-guides/devices-reference) for details about your watch.

<table class="palette">
<tbody><tr>
 <td style="background-color: #000000; color:white">Black (Garmin)</td>
 <td style="background-color: #000055; color:white">Cetacean Blue</td>
 <td style="background-color: #0000aa; color:white">Duke Blue</td>
 <td style="background-color: #0000ff; color:white">Dark Blue (Garmin)</td>
 <td style="background-color: #005500; color:white">Dark Green (X11)</td>
 <td style="background-color: #005555; color:white">Midnight Green (Eagle Green)</td>
 <td style="background-color: #0055aa; color:white">Cobalt Blue</td>
 <td style="background-color: #0055ff; color:white">Blue (RYB)</td>
</tr><tr>
 <td style="background-color: #00aa00; color:black">Dark Green (Garmin)</td>
 <td style="background-color: #00aa55; color:black">Green (Pigment)</td>
 <td style="background-color: #00aaaa; color:black">Tiffany Blue</td>
 <td style="background-color: #00aaff; color:black">Blue (Garmin)</td>
 <td style="background-color: #00ff00; color:black">Green (Garmin)</td>
 <td style="background-color: #00ff55; color:black">Malachite</td>
 <td style="background-color: #00ffaa; color:black">Medium Spring Green</td>
 <td style="background-color: #00ffff; color:black">Aqua</td>
</tr><tr>
 <td style="background-color: #550000; color:white">Dark Chocolate</td>
 <td style="background-color: #550055; color:white">Imperial Purple</td>
 <td style="background-color: #5500aa; color:white">Metallic Violet</td>
 <td style="background-color: #5500ff; color:white">Electric Ultramarine</td>
 <td style="background-color: #555500; color:white">Dark Bronze (Coin)</td>
 <td style="background-color: #555555; color:white">Dark Gray (Garmin)</td>
 <td style="background-color: #5555aa; color:white">Liberty</td>
 <td style="background-color: #5555ff; color:white">Very Light Blue</td>
</tr><tr>
 <td style="background-color: #55aa00; color:black">Kelly Green</td>
 <td style="background-color: #55aa55; color:black">Apple</td>
 <td style="background-color: #55aaaa; color:black">Cadet Blue</td>
 <td style="background-color: #55aaff; color:black">Blue Jeans</td>
 <td style="background-color: #55ff00; color:black">Chlorophyll Green</td>
 <td style="background-color: #55ff55; color:black">Screamin' Green</td>
 <td style="background-color: #55ffaa; color:black">Medium Aquamarine</td>
 <td style="background-color: #55ffff; color:black">Electric Blue</td>
</tr><tr>
 <td style="background-color: #aa0000; color:white">Dark Red (Garmin)</td>
 <td style="background-color: #aa0055; color:white">Jazzberry Jam</td>
 <td style="background-color: #aa00aa; color:white">Heliotrope Magenta</td>
 <td style="background-color: #aa00ff; color:white">Purple (Garmin)</td>
 <td style="background-color: #aa5500; color:white">Windsor Tan</td>
 <td style="background-color: #aa5555; color:white">Middle Red Purple</td>
 <td style="background-color: #aa55aa; color:white">Purpureus</td>
 <td style="background-color: #aa55ff; color:white">Lavender Indigo</td>
</tr><tr>
 <td style="background-color: #aaaa00; color:black">Light Gold</td>
 <td style="background-color: #aaaa55; color:black">Olive Green</td>
 <td style="background-color: #aaaaaa; color:black">Light Gray (Garmin)</td>
 <td style="background-color: #aaaaff; color:black">Maximum Blue Purple</td>
 <td style="background-color: #aaff00; color:black">Spring Bud</td>
 <td style="background-color: #aaff55; color:black">Inchworm</td>
 <td style="background-color: #aaffaa; color:black">Menthol</td>
 <td style="background-color: #aaffff; color:black">Celeste</td>
</tr><tr>
 <td style="background-color: #ff0000; color:white">Red (Garmin)</td>
 <td style="background-color: #ff0055; color:white">Folly</td>
 <td style="background-color: #ff00aa; color:white">Fashion Fuchsia</td>
 <td style="background-color: #ff00ff; color:white">Pink (Garmin)</td>
 <td style="background-color: #ff5500; color:white">Orange (Garmin)</td>
 <td style="background-color: #ff5555; color:white">Sunset Orange</td>
 <td style="background-color: #ff55aa; color:white">Brilliant Rose</td>
 <td style="background-color: #ff55ff; color:white">Shocking Pink (Crayola)</td>
</tr><tr>
 <td style="background-color: #ffaa00; color:black">Yellow (Garmin)</td>
 <td style="background-color: #ffaa55; color:black">Rajah</td>
 <td style="background-color: #ffaaaa; color:black">Melon</td>
 <td style="background-color: #ffaaff; color:black">Rich Brilliant Lavender</td>
 <td style="background-color: #ffff00; color:black">True Yellow</td>
 <td style="background-color: #ffff55; color:black">Dodie Yellow</td>
 <td style="background-color: #ffffaa; color:black">Calamansi</td>
 <td style="background-color: #ffffff; color:black">White (Garmin)</td>
</tr>
</tbody></table>

Color names were taken from [color-name](https://www.color-name.com) webpage. Colors named  with (Garmin) suffix belongs to default Garmin 14 colors palette.

## Donation
SmartArcs watchfaces offer **premium features for free**, e.g. power saver or graphs. I don't plan to make paid or trial watchfaces. If you like SmartArcs watchfaces please consider a [donation](https://paypal.me/RadkoNajman). It is an appreciation of my work and all [donations](https://paypal.me/RadkoNajman) are for a good cause.

<!--
**Currently all donations go to support UKRAINE!**
<p align="center" width="100%">
    <img src="ukraine.png">
</p>
-->

I resend all [donations](https://paypal.me/RadkoNajman) to non-profit organizations, mainly:

<p align="center" width="100%">
    <a href="https://www.kiva.org/"><img src="/smartarcs/kiva_logo.png" alt="" /></a> <a href="https://sharethemeal.org/"><img src="/smartarcs/sharethemeal_logo.png" alt="" /></a> <a href="https://www.msf.org/"><img src="/smartarcs/msf_logo.png" alt="" /></a>
</p>

**Thank you!**

## Feedback
If you have any comments to SmartArcs watchfaces feel free to [send me a message (okdar@centrum.cz)](mailto:okdar@centrum.cz). You can also write a review in Garmin ConnectIQ Store:
* **SmartArcs Origin** ([review](https://apps.garmin.com/en-US/apps/073e2cbc-f25e-44b9-ab59-4966fa5abbd6#reviews))
* **SmartArcs Active** - ([review](https://apps.garmin.com/en-US/apps/3f5e481a-5f9e-4764-b2d5-5e9b174e2a98#reviews))
* **SmartArcs Trip** - ([review](https://apps.garmin.com/en-US/apps/a1bfdf21-bde7-4d63-925f-a6a04cb84aff#reviews))
* **SmartArcs HR** - ([review](https://apps.garmin.com/en-US/apps/7fa66b8d-6b99-4eb6-a12f-f14c82215fa9#reviews))


## Credits
The idea of arc indicators was inspired by **Activity Classic Watch Face** and **ManniAT Face**.

Twilights calculation is powered by **[SunCalc](https://github.com/haraldh/SunCalc)** library.
