# Main Reference

https://github.com/onmyway133/awesome-ios-architecture

Subreferences are omitted as they are present at the main reference (`README.md`)

# MVC

As per [Apple docs](https://developer.apple.com/library/archive/documentation/General/Conceptual/CocoaEncyclopedia/Model-View-Controller/Model-View-Controller.html) this guy is very old. This pattern is associated with the global app arch. Cocoa and lots of stuff is based on MVC.

## Roles and Relationships

Model, view and controller are three roles of objects in this pattern, separated from each other by abstract boundaries. These roles perform communications via the boundaries. The main point is that all models / views / controllers are reusable and explicitly separated from one another.

**Model**

They hild app's data and define the logic that manipulates the data. All persistent data should reside in model too. Model object has no explicit connection to the UI. But if the model objects represent the graphics displayed – we can say this is an exclusion.

**View**

They know how to display UI and allow user to access the data from the model on screen. View is disconnected from the data, but it can cache some (well, reasonably, for some performance tricks for one). View should know about the changes of the model's data to present the content correctly.

**Controller**

They tie model to the view