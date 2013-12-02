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

import java.util.Iterator;
import java.util.NoSuchElementException;

class Stack<Item> implements Iterable<Item> {
  private int N;                // size of the stack
  private Node<Item> first;     // top of stack

  class Node<Item> {
    private Item item;
    private Node<Item> next;
  }

  Stack() {
    first = null;
    N = 0;
  }

  boolean isEmpty() {
    return first == null;
  }

  int size() {
    return N;
  }

  void push(Item item) {
    Node<Item> oldfirst = first;
    first = new Node<Item>();
    first.item = item;
    first.next = oldfirst;
    N++;
  }

  Item pop() {
    if (isEmpty()) throw new NoSuchElementException("Stack underflow");
    Item item = first.item;        // save item to return
    first = first.next;            // delete first node
    N--;
    return item;                   // return the saved item
  }

  Item peek() {
    if (isEmpty()) throw new NoSuchElementException("Stack underflow");
    return first.item;
  }

  String toString() {
    StringBuilder s = new StringBuilder();
    for (Item item : this)
      s.append(item + " ");
    return s.toString();
  }

  Iterator<Item> iterator() {
    return new ListIterator<Item>(first);
  }

  class ListIterator<Item> implements Iterator<Item> {
    Node<Item> current;

    ListIterator(Node<Item> first) {
      current = first;
    }
    boolean hasNext() { 
      return current != null;
    }
    void remove() { 
      throw new UnsupportedOperationException();
    }

    Item next() {
      if (!hasNext()) throw new NoSuchElementException();
      Item item = current.item;
      current = current.next; 
      return item;
    }
  }
}

