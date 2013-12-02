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

class BreadthFirstPaths {
  static final int INFINITY = Integer.MAX_VALUE;
  boolean[] marked;  // marked[v] = is there an s-v path
  int[] edgeTo;      // edgeTo[v] = previous edge on shortest s-v path
  int[] distTo;      // distTo[v] = number of edges shortest s-v path

  BreadthFirstPaths(Graph G, int s) {
    marked = new boolean[G.V()];
    distTo = new int[G.V()];
    edgeTo = new int[G.V()];
    bfs(G, s);
  }

  BreadthFirstPaths(Graph G, Iterable<Integer> sources) {
    marked = new boolean[G.V()];
    distTo = new int[G.V()];
    edgeTo = new int[G.V()];
    for (int v = 0; v < G.V(); v++) distTo[v] = INFINITY;
    bfs(G, sources);
  }

  void bfs(Graph G, int s) {
    Queue<Integer> q = new Queue<Integer>();
    for (int v = 0; v < G.V(); v++) distTo[v] = INFINITY;
    distTo[s] = 0;
    marked[s] = true;
    q.enqueue(s);

    while (!q.isEmpty ()) {
      int v = q.dequeue();
      for (int w : G.adj(v)) {
        if (!marked[w]) {
          edgeTo[w] = v;
          distTo[w] = distTo[v] + 1;
          marked[w] = true;
          q.enqueue(w);
        }
      }
    }
  }

  void bfs(Graph G, Iterable<Integer> sources) {
    Queue<Integer> q = new Queue<Integer>();
    for (int s : sources) {
      marked[s] = true;
      distTo[s] = 0;
      q.enqueue(s);
    }
    while (!q.isEmpty ()) {
      int v = q.dequeue();
      for (int w : G.adj(v)) {
        if (!marked[w]) {
          edgeTo[w] = v;
          distTo[w] = distTo[v] + 1;
          marked[w] = true;
          q.enqueue(w);
        }
      }
    }
  }

  boolean hasPathTo(int v) {
    return marked[v];
  }

  int distTo(int v) {
    return distTo[v];
  }

  Iterable<Integer> pathTo(int v) {
    if (!hasPathTo(v)) return null;
    Stack<Integer> path = new Stack<Integer>();
    int x;
    for (x = v; distTo[x] != 0; x = edgeTo[x])
      path.push(x);
    path.push(x);
    return path;
  }
}

