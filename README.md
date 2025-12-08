Massive
=======
Massive is a high performance DisplayObject for Starling ( [https://github.com/openfl/starling](https://github.com/openfl/starling) ), meant to render lots of quads (textured, animated) very efficiently.

Demos
-----
Benchmark - compare Massive performance with classic Starling Quad and MovieClip https://matse.skwatt.com/haxe/starling/massive/demo/

Hex Map - display only a part of a huge hexagon map and interact with it (link coming soon)

Particle Editor - editor for Massive's ParticleSystem (link coming soon)

Getting started
---------------
Massive is not available on haxelib yet, you can either use haxelib to install it directly from GitHub :
```sh
haxelib git massive https://github.com/MatseFR/massive-starling
```
or fork the Massive repo and then use haxelib to install it
```sh
haxelib dev massive path/to/massive
```
To include Massive in an OpenFL project, add this line to your [_project.xml_](https://lime.openfl.org/docs/project-files/xml-format/) file:
```xml
<haxelib name="massive" />
```
