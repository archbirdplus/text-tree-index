
# Features:

* Ideally generates indexes for arbitrarily large text files using finite RAM.
* Finds locations of string matches in O(<tree-depth>) time.
* Technically matches utf8 bytes individually.
* 77kB/s initialization (very slow)

# Algorithm:

## Insertion

* Begin at the root node
* For each character until depth is reached
    * offset the cursor by the char value
    * read the value in the node at the cursor
    * if the value is 0, set it to the location of a new node
    * jump to value, to get to the next node
* Append a new item of (value, text_index) to the file
* Set the last node's element to point to the item added

## Search

* Begin at the root node
* For each character until depth is reached
    * offset the cursor by the char value
    * read the value in the node at the cursor
    * jump to value, to get to the next node
* While the value is non-zero, follow the linked list (value, text_index)

## Optimization (TODO?)
* Copy the nodes into another file
* Trace all linked lists and append them as compact arrays
* Include the length of the array at the beginning

# TODO:
* Allow it to index streams
* Pattern-matching
* Allow queries to be longer or shorter than the tree structure
* Allow customizable tree depths
* Allow the linked lists to be compacted
* More optimizations, because it's only at 77kB/s (maybe cache the tree in RAM?)
