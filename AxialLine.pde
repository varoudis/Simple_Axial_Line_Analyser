// Copyright (C) 2013, Tasos Varoudis

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// 9th Space Syntax Symposium - Software Workshop
// Simple axial line analyser. Introduction to concepts like 'integration', 'total depth', 'node count', 'connectivity'....
// Not all classes are finished but it runs fine! Some missing protectors too (overflow.. etc)
// 
//  Books and references:
//  Hillier, Bill and Hanson, Julienne. The social logic of space.
//  Robert Sedgewick, Kevin Wayne, Algorithms (4th Edition).
//  Teklenburg (1993) Space syntax standardised integration measures and some simulations.
//  Processing Books: http://processing.org/books/
//  depthmapX source code: https://github.com/varoudis/depthmapX
//

class AxialLine {

  PVector m_p1, m_p2;
  float m_length;
  // in this somple example the Ref is also the graph's "V" id!
  int m_ref;
  ArrayList<String> m_measure_names;
  ArrayList<Float> m_measure_values;

  // no checks for common errors //
  AxialLine(PVector _p1, PVector _p2, int _ref) {
    m_p1 = _p1;
    m_p2 = _p2;
    m_ref = _ref;
    m_length = m_p1.dist(m_p2);
    m_measure_names = new ArrayList<String>();
    m_measure_values = new ArrayList<Float>();
  }

  void addMeasure(String _name, float _value) {
    // no checks for duplicates
    m_measure_names.add(_name);
    m_measure_values.add(_value);
  }
  
  float getMeasure(String s) {
    
    int hit = -1;
    for(int i=0;i<m_measure_names.size();++i) {
      if(m_measure_names.get(i) == s) {
        hit = i;
      }
    }
    
    if(hit != -1) {
      return m_measure_values.get(hit);
    }
    
    return -1.0;
  }

  void printAll() {
    for (int i=0;i<m_measure_names.size();++i) {
      println(m_measure_names.get(i) + " " + m_measure_values.get(i));
    }
  }
  
  void draw() {
    stroke(255 - (m_measure_values.get(currentMeasure) - measure_range.get(currentMeasure)[0])*255*measure_range.get(currentMeasure)[2], 255, 255);
    drawScaledLine(m_p1.x, m_p1.y, m_p2.x, m_p2.y);
  }
  
  float getCentreX() {
    return .5f*(m_p1.x+m_p2.x);
  }
  
  float getCentreY() {
    return .5f*(m_p1.y+m_p2.y);
  }
}


// Helpers
boolean linesIntersect(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
  // Return false if either of the lines have zero length
  if (x1 == x2 && y1 == y2 ||
    x3 == x4 && y3 == y4) {
    return false;
  }
  // Fastest method, based on Franklin Antonio's "Faster Line Segment Intersection" topic "in Graphics Gems III" book (http://www.graphicsgems.org/)
  double ax = x2-x1;
  double ay = y2-y1;
  double bx = x3-x4;
  double by = y3-y4;
  double cx = x1-x3;
  double cy = y1-y3;

  double alphaNumerator = by*cx - bx*cy;
  double commonDenominator = ay*bx - ax*by;
  if (commonDenominator > 0) {
    if (alphaNumerator < 0 || alphaNumerator > commonDenominator) {
      return false;
    }
  }
  else if (commonDenominator < 0) {
    if (alphaNumerator > 0 || alphaNumerator < commonDenominator) {
      return false;
    }
  }
  double betaNumerator = ax*cy - ay*cx;
  if (commonDenominator > 0) {
    if (betaNumerator < 0 || betaNumerator > commonDenominator) {
      return false;
    }
  }
  else if (commonDenominator < 0) {
    if (betaNumerator > 0 || betaNumerator < commonDenominator) {
      return false;
    }
  }
  if (commonDenominator == 0) {
    // This code wasn't in Franklin Antonio's method. It was added by Keith Woodward.
    // The lines are parallel.
    // Check if they're collinear.
    double y3LessY1 = y3-y1;
    double collinearityTestForP3 = x1*(y2-y3) + x2*(y3LessY1) + x3*(y1-y2);   // see http://mathworld.wolfram.com/Collinear.html
    // If p3 is collinear with p1 and p2 then p4 will also be collinear, since p1-p2 is parallel with p3-p4
    if (collinearityTestForP3 == 0) {
      // The lines are collinear. Now check if they overlap.
      if (x1 >= x3 && x1 <= x4 || x1 <= x3 && x1 >= x4 ||
        x2 >= x3 && x2 <= x4 || x2 <= x3 && x2 >= x4 ||
        x3 >= x1 && x3 <= x2 || x3 <= x1 && x3 >= x2) {
        if (y1 >= y3 && y1 <= y4 || y1 <= y3 && y1 >= y4 ||
          y2 >= y3 && y2 <= y4 || y2 <= y3 && y2 >= y4 ||
          y3 >= y1 && y3 <= y2 || y3 <= y1 && y3 >= y2) {
          return true;
        }
      }
    }
    return false;
  }
  return true;
}

