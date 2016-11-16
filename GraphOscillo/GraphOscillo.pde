  /*
 * Oscilloscope
 * Gives a visual rendering of analog pin 0 in realtime.
 * 
 * This project is part of Accrochages
 * See http://accrochages.drone.ws
 *
 * (c) 2015 David Trimoulet (dtrimoulet@cesi.fr)
 * Modified for Exia.Cesi school.
 * v1.2 Patch for Processing 3.xx
 *
 * (c) 2013 Vincent Levorato (vlevorato@cesi.fr)
 * Modified for Exia.Cesi school.
 * v1.1
 *
 * (c) 2008 Sofian Audry (info@sofianaudry.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
import processing.serial.*;

Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] values;
float zoom;

int refresh_mean=0;
float cur_mean=0.0;

void settings(){
    size(800, 600);
}

void setup() 
{
  // Open the port that the board is connected to and use the same speed
  port = new Serial(this, "COM5", 115200);
  values = new int[width];
  zoom = 1.0f;
  smooth();
  rectMode(CORNER); 
}

int getY(int val) {
  return (int)(height - val / 1023.0f * (height - 1));
}

int getValue() {
  int value = -1;
  while (port.available() >= 3) {
    if (port.read() == 0xff) {
      value = (port.read() << 8) | (port.read());
    }
  }
  return value;
}

void pushValue(int value) {
  for (int i=0; i<width-1; i++)
    values[i] = values[i+1];
  values[width-1] = value;
}

void drawLines() {
  stroke(255);
  
  int displayWidth = (int) (width / zoom);
  
  int k = values.length - displayWidth;
  int x0 = 0;
  int y0 = getY(values[k]);
  for (int i=1; i<displayWidth; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (displayWidth-1));
    int y1 = getY(values[k]);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
  }
}

void drawGrid() {
  
  stroke(255, 0, 0);
  line(30, height/2, width, height/2);
  line(30, 1, width, 1);
  line(30, height-1, width, height-1);
  float mid=2.5,b=0.0;
  fill(255,0,0);
  b=mid;
  text(str(b)+"V", 0, height/2 + 5);
  b=mid*2;
  text(str(b)+"V", 0, 10 );
  b=0;
  text(str(b)+"V", 0, height );
  
  stroke(0,255,0);
  line(40, height*1/4, width, height*1/4);
  line(40, height*3/4, width, height*3/4);
  
  stroke(0,128,0);
  line(50, height*1/8, width, height*1/8);
  line(50, height*3/8, width, height*3/8);
  line(50, height*5/8, width, height*5/8);
  line(50, height*7/8, width, height*7/8);
  
  fill(0,255,0);
  b=mid+mid/2;
  text(str(b)+"V", 0, height*1/4 + 5);
  b=mid/2;
  text(str(b)+"V", 0, height*3/4 + 5);
  
  fill(0,128,0);
  b=mid+mid/2+mid/4;
  text(str(b)+"V", 0, height*1/8 + 5);
  b=mid+mid/4;
  text(str(b)+"V", 0, height*3/8 + 5);
  b=mid-mid/2+mid/4;
  text(str(b)+"V", 0, height*5/8 + 5);
  b=mid-mid/2-mid/4;
  text(str(b)+"V", 0, height*7/8 + 5);
  
 
}

void drawValue(float v)
{
  //draw rectangle background for value
  fill(0);  
  rect(width-100, height-20,100, 20);
  
  //print volt value
  String s = str(v)+"V";
  fill(0,255,0);
  text(s, width-100, height); 
}

void drawMean(boolean r)
{
  
  if(r)
  {
    float mean=0;
    for (int i=0; i<width-1; i++)
      mean=mean+values[i];
    
    mean=mean/width;
    cur_mean=mean/1023.0f*5; //scale
    //2-digits precision
    cur_mean=cur_mean*100000;
    cur_mean=round(cur_mean);
    cur_mean=cur_mean/100000;
  }
  
  
  //draw rectangle background for mean value
  fill(0);  
  rect(width-100, height-40,100, 20);
  
  //print mean volt value
  String s = "Mean:"+str(cur_mean)+"V";
  fill(255,255,0);
  text(s, width-100, height-20); 
}


void keyReleased() {
  switch (key) {
    case '+':
      zoom *= 2.0f;
      println(zoom);
      if ( (int) (width / zoom) <= 1 )
        zoom /= 2.0f;
      break;
    case '-':
      zoom /= 2.0f;
      if (zoom < 1.0f)
        zoom *= 2.0f;
      break;
  }
}

void draw()
{
  background(0);
  drawLines();
  drawGrid();
  val = getValue();
  if (val != -1) {
    pushValue(val);
    drawValue(val/1023.0f*5);
    
    if(refresh_mean % 100 == 0)
    {
      refresh_mean=0;
      drawMean(true);
    }
    else
      drawMean(false);
    
  }
  
  refresh_mean++;
  
  
  
}