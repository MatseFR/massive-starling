# Massive
Massive is a high performance library for [Starling](https://github.com/openfl/starling) ), meant to render lots of quads (textured, animated) in a single `DisplayObject` very efficiently.

## Demos
[Benchmark](https://matse.skwatt.com/haxe/starling/massive/demo/) - compare Massive performance with classic Starling `Quad` and `MovieClip` (more info in the demo's [README](https://github.com/MatseFR/massive-starling/tree/main/samples/demo))

Hex Map - display only a part of a huge hexagon map and interact with it (link coming soon)

Particle Editor - editor for Massive's ParticleSystem (link coming soon)

## Getting started
Massive is not available on haxelib yet, you can either use haxelib to install it directly from GitHub :
```sh
haxelib git massive https://github.com/MatseFR/massive-starling
```
or download the Massive repo and then use haxelib to install it
```sh
haxelib dev massive path/to/massive
```
To include Massive in an OpenFL project, add this line to your [_project.xml_](https://lime.openfl.org/docs/project-files/xml-format/) file:
```xml
<haxelib name="massive" />
```

You can look at the benchmark demo's [MassiveImages](https://github.com/MatseFR/massive-starling/blob/main/samples/demo/src/scene/MassiveImages.hx) and [MassiveQuads](https://github.com/MatseFR/massive-starling/blob/main/samples/demo/src/scene/MassiveQuads.hx) for starters
