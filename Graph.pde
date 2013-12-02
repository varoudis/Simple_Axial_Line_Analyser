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

class Graph {
  int V;
  int E;
  Bag<Integer>[] adj;

  Graph(int V) {
    println("Init Graph! " + V);
    if (V < 0) throw new IllegalArgumentException("Number of vertices must be nonnegative");
    this.V = V;
    this.E = 0;
    adj = (Bag<Integer>[]) new Bag[V];
    for (int v = 0; v < V; v++) {
      adj[v] = new Bag<Integer>();
    }
    println("Init Graph! Done!");
  }

  int V() {
    return V;
  }

  int E() {
    return E;
  }

  void addEdge(int v, int w) {
    if (v < 0 || v >= V) throw new IndexOutOfBoundsException();
    if (w < 0 || w >= V) throw new IndexOutOfBoundsException();
    E++;
    adj[v].add(w);
    adj[w].add(v);
  }

  Iterable<Integer> adj(int v) {
    if (v < 0 || v >= V) throw new IndexOutOfBoundsException();
    return adj[v];
  }
}

