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

//Global
Table imported_data;
Table export_data;
// The graph!
Graph graph;
ArrayList<AxialLine> axial_lines;

// drawing helpers //
float yAxis = -1f;
PVector min, max, centre;
float drawScale;
int currentMeasure = 0;
ArrayList<float []> measure_range = new ArrayList<float []>();
boolean displayGraph;
String overHeadText = "";
//  //

void setup() {
  // Init window
  size(1024, 768);
  smooth(); // antialiasing

  // Import data from CSV file. It must be in the project's "data" folder.
  imported_data = loadTable("axial_map01.csv", "header");
  println(imported_data.getRowCount() + " total rows in CSV file"); 
  println(imported_data.getColumnCount());

  axial_lines = new ArrayList<AxialLine>();

  // Init and build Graph from data
  int number_of_lines = imported_data.getRowCount();
  graph = new Graph(number_of_lines);

  for (int i=0;i<imported_data.getRowCount();++i) {
    TableRow row = imported_data.getRow(i);
    int id = row.getInt("Ref"); // keep the Ref so you can compare with depthmapX
    float x1 = row.getFloat("x1");
    float y1 = row.getFloat("y1");
    float x2 = row.getFloat("x2");
    float y2 = row.getFloat("y2");
    PVector p1 = new PVector(x1, y1);
    PVector p2 = new PVector(x2, y2); 

    AxialLine l = new AxialLine(p1, p2, id);
    axial_lines.add(l);
  }

  println("Line intersection!");
  // line intersection (basic!)
  // dummy all to all
  for (int i=0;i<axial_lines.size();++i) {
    double x1 = axial_lines.get(i).m_p1.x;
    double y1 = axial_lines.get(i).m_p1.y;
    double x2 = axial_lines.get(i).m_p2.x;
    double y2 = axial_lines.get(i).m_p2.y;

    // our graph class does not check for 'parallel edges'
    // but with this trick its ok, usually with the "addEdge" we check.
    for (int j=i+1;j<axial_lines.size();++j) {
      double x3 = axial_lines.get(j).m_p1.x;
      double y3 = axial_lines.get(j).m_p1.y;
      double x4 = axial_lines.get(j).m_p2.x;
      double y4 = axial_lines.get(j).m_p2.y;

      // add links/edges
      if (linesIntersect(x1, y1, x2, y2, x3, y3, x4, y4)) {
        // hit!! add an edge!
        // i/j and Ref are the same here ;)
        graph.addEdge(i, j);
      }
    }
  }
  // checks
  println("number of Vs: " + graph.V());
  println("number of Es: " + graph.E());

  // Run BFS search and analysis
  for (int source_id=0;source_id<graph.V();++source_id) {
    BreadthFirstPaths bfs = new BreadthFirstPaths(graph, source_id);
    int node_count = 1; // 1 because I have to count myself too
    int total_depth = 0;
    for (int dest_id=0;dest_id<graph.V();++dest_id) {
      if (source_id!=dest_id) {
        if (bfs.hasPathTo(dest_id)) { // we know its a fully connected graph...
          node_count++;
          total_depth = total_depth + bfs.distTo(dest_id);
        }
      }
    }
    // compute and add measures
    axial_lines.get(source_id).addMeasure("total_depth", total_depth);
    axial_lines.get(source_id).addMeasure("node_count", node_count);

    float d_value = 2.0 * ( (node_count * ( (log((node_count+2.0)/3.0)/log(2)) - 1.0) ) + 1.0 ) / ((node_count - 1.0) * (node_count - 2.0)); 
    float p_value = 2.0 * (node_count - (log(node_count)/log(2)) - 1.0) / ((node_count - 1.0) * (node_count - 2.0)); 
    float teklinteg = log(0.5 * (node_count - 2.0)) / log(total_depth - node_count + 1.0);

    float mean_depth = total_depth/(node_count - 1.0);
    float ra = 2.0 * ( mean_depth - 1.0)/( node_count-2.0 );
    float raa = ra / d_value;
    float intHH = 1.0 / raa;
    float intP = 1.0 / ( ra / p_value );

    axial_lines.get(source_id).addMeasure("mean_depth", mean_depth);
    axial_lines.get(source_id).addMeasure("ra", ra);
    axial_lines.get(source_id).addMeasure("raa", raa);
    axial_lines.get(source_id).addMeasure("intHH", intHH);
    axial_lines.get(source_id).addMeasure("intP", intP);
    axial_lines.get(source_id).addMeasure("teklinteg", teklinteg);
  }

  //test print
  axial_lines.get(0).printAll();


  // Export data // Write CSV
  export_data = new Table();

  export_data.addColumn("Ref");
  export_data.addColumn("x1");
  export_data.addColumn("y1");
  export_data.addColumn("x2");
  export_data.addColumn("y2");

  for (int j=0;j<axial_lines.get(0).m_measure_names.size();++j) {
    export_data.addColumn(axial_lines.get(0).m_measure_names.get(j));
  }

  for (int j=0;j<axial_lines.size();++j) {
    TableRow newRow = export_data.addRow();

    int ref = axial_lines.get(j).m_ref;
    float x1 = axial_lines.get(j).m_p1.x;
    float y1 = axial_lines.get(j).m_p1.y;
    float x2 = axial_lines.get(j).m_p2.x;
    float y2 = axial_lines.get(j).m_p2.y;

    // can be done in one go, without the lines above!
    newRow.setInt("Ref", ref);
    newRow.setFloat("x1", x1);
    newRow.setFloat("y1", y1);
    newRow.setFloat("x2", x2);
    newRow.setFloat("y2", y2);

    for (int k=0;k<axial_lines.get(j).m_measure_names.size();++k) {
      newRow.setFloat(axial_lines.get(j).m_measure_names.get(k), axial_lines.get(j).m_measure_values.get(k));
    }
  }
  // write the CSV file
  saveTable(export_data, "data/export_axial_map01.csv");
  
  // helpers for display
  findMap();
  findMeasuresRange();
  overHeadText = axial_lines.get(0).m_measure_names.get(0);
}

void draw() {
  // Simple map drawing
  background(255);
  
  // Axial map
  colorMode(HSB);
  for (AxialLine axl: axial_lines) 
    axl.draw();

  // Graph map
  colorMode(RGB);
  if (displayGraph) {
    stroke(120);
    fill(120);
    for (int i = 0; i < graph.adj.length; i++) {
      Iterator it = graph.adj[i].iterator();
      while (it.hasNext ()) {
        int j = (Integer) it.next();
        drawScaledCircle(axial_lines.get(i).getCentreX(), axial_lines.get(i).getCentreY(), 6);
        drawScaledLine(axial_lines.get(i).getCentreX(), axial_lines.get(i).getCentreY(), axial_lines.get(j).getCentreX(), axial_lines.get(j).getCentreY() );
      }
    }
  }
  
  fill(0);
  text(overHeadText, 10, 10, 200, 200);
}


// drawing helpers //
// Find extremes for scaling
void findMap() {
  min = new PVector(Float.MAX_VALUE, Float.MAX_VALUE);
  max = new PVector(-Float.MAX_VALUE, -Float.MAX_VALUE);
  for (AxialLine axl: axial_lines) {
    if (axl.m_p1.x < min.x) min.x = axl.m_p1.x;
    if (axl.m_p1.y < min.y) min.y = axl.m_p1.y;
    if (axl.m_p2.x < min.x) min.x = axl.m_p1.x;
    if (axl.m_p2.y < min.y) min.y = axl.m_p2.y;

    if (axl.m_p1.x > max.x) max.x = axl.m_p1.x;
    if (axl.m_p1.y > max.y) max.y = axl.m_p1.y;
    if (axl.m_p2.x > max.x) max.x = axl.m_p1.x;
    if (axl.m_p2.y > max.y) max.y = axl.m_p2.y;
  }  
  centre = new PVector(.5f*(max.x+min.x), .5f*(max.y+min.y));
  drawScale = .9f*height/(max.y-min.y);
}

// fins measure range for display
void findMeasuresRange() {
  for (int i = 0; i < axial_lines.get(0).m_measure_values.size(); i++) {
    measure_range.add(new float [3]);
    measure_range.get(i)[0] = Float.MAX_VALUE; //min
    measure_range.get(i)[1] = -Float.MAX_VALUE; //max
    measure_range.get(i)[2] = 0; // 1/range
  }
  for (AxialLine axl: axial_lines) 
    for (int i = 0; i < axl.m_measure_values.size(); i++) {
      if (axl.m_measure_values.get(i) < measure_range.get(i)[0]) measure_range.get(i)[0] = axl.m_measure_values.get(i);
      if (axl.m_measure_values.get(i) > measure_range.get(i)[1]) measure_range.get(i)[1] = axl.m_measure_values.get(i);
    }
  for (float [] value : measure_range) {
    value[2] = 1.0/(value[1]-value[0]);
  }
}

void drawScaledCircle(float px, float py, float sz) { // sz is screen size, not scaled
  ellipse(drawScale*(px-centre.x)+width*.5f, drawScale*(py-centre.y)*yAxis+height*.5f, sz, sz);
}
void drawScaledLine(float px, float py, float qx, float qy) {
  line(drawScale*(px-centre.x)+width*.5f, drawScale*(py-centre.y)*yAxis+height*.5f, drawScale*(qx-centre.x)+width*.5f, drawScale*(qy-centre.y)*yAxis+height*.5f);
}

// //
void keyPressed() {
  switch(key) {
  case 's':
  case 'S':
    saveFrame("####.png");
    break;
  case 'm':
  case 'M':
    if (axial_lines != null && axial_lines.get(0) != null && axial_lines.get(0).m_measure_names != null)
      currentMeasure = (currentMeasure + 1)%axial_lines.get(0).m_measure_names.size();
    overHeadText = axial_lines.get(0).m_measure_names.get(currentMeasure);
    break;
  case 'n':
  case 'N':
    if (axial_lines != null && axial_lines.get(0) != null && axial_lines.get(0).m_measure_names != null)
      currentMeasure = currentMeasure - 1;
       if(currentMeasure < 0) currentMeasure = axial_lines.get(0).m_measure_names.size()-1;
    overHeadText = axial_lines.get(0).m_measure_names.get(currentMeasure);
    break;
  case 'g':
  case 'G':
    displayGraph = !displayGraph;
    break;
  }
}

