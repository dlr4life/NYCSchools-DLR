# NYCSchools-DLR

<div align="center">
    <img src="https://github.com/dlr4life/NYCSchools-DLR/blob/master/ListView.png" width="400px"</img> 
      <img src="https://github.com/dlr4life/NYCSchools-DLR/blob/master/DetailView.png" width="400px"</img> 
</div>

What I've learned from building this project:

Improved JSON Parsing skills with Swift 4. 
API integration and manipulation (merging sources for a merged dataset).
Show locations on a map and using annotations (outside of Realm, CloutKit, Plists).

Features:
- Displaying the NYC schools by name with Avg. Math, Reading, Writing scores w/ Total # of test takers
- Showing a collective map view of all listed NYC High Schools (not completed)
- Selecting a location in the MapView triggers a detailed look at the selected NYC High School w/ grade range, url & single annotation view (not completed)

Some challenges I encountered:

This project was definitely a challenging one to say the least. I was able to gain a greater understanding of json parsing and API handling when asynchronous activities are processing data, throughout an app. The updating of the UI with the assist of multithreading was particularly informative. 

Since the School and SAT scores start off are two separate classes. A relationship needed to be created between them, but there was no guarantee there would be match. In addition, there would be a performance cost to sort and match them using a dictionary upon loading the first time (which was not avoided), and some data was lost in the process. 

Another challenge faced was the inclusion of a “search & index” feature. This proved easy to setup, but difficult to execute, accurately with the given information. The results returned after reloading the filteredSchools by name did not accurately represent the search predicate specified.

The Map View, and displaying the NYC High School locations presented another hurdle during this quiz. In the order of planned actions:
- Add the Location and LatLong structs to place the Lat/Long struct nested inside our Location struct
- Create a protocol for your Client Request
- Create a Class that conforms to your ClientRequest protocol
- Add functions to access data through protocol
- Add object elements to ViewController for displaying NYC High School locations
- Add a print function for debugging
- Build & run application to test layout & location execution fro JSON response parsing activities.
