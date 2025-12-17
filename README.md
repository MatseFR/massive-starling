# Massive
Massive is a high performance library for [Starling](https://github.com/openfl/starling), meant to render lots of quads (textured, animated) in a single `DisplayObject` very efficiently.

It's heavily inspired by the [FFParticleSystem](https://github.com/shin10/Starling-FFParticleSystem) lib by Michael Trenkler, which I [ported](https://github.com/MatseFR/starling-extension-FFParticleSystem) to haxe some years ago.

It's been tested on windows (haxelib version of hxcpp), html5 and air targets with the latest versions of OpenFL, Lime and Starling.

## Demos
[Benchmark](https://matse.skwatt.com/haxe/starling/massive/demo/) - compare Massive performance with classic Starling `Quad` and `MovieClip` (more info in the demo's [README](https://github.com/MatseFR/massive-starling/tree/main/samples/demo))

[Hex Grid](https://matse.skwatt.com/haxe/starling/massive/hexgrid/) - display only a part of an hexagon map, move around with infinite scroll and interact with it

[Particle Editor](https://matse.skwatt.com/haxe/starling/massive/particles/editor/) - editor for Massive's `ParticleSystem` (WIP)

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

## Quick setup
Massive is meant to be as easy as possible to work with, startup Starling like you would normally do
```haxe
var massive:MassiveDisplay = new MassiveDisplay();
// by default a MassiveDisplay instance will use the maximum buffer size, which is MassiveConstants.MAX_QUADS (16383)
// if you know you're gonna use less than that you can set the buffer size for better performance
massive.bufferSize = 5000; // display up to 5000 quads
massive.texture = assetManager.getTextureAtlas("my-atlas").texture;
addChild(massive);

// we need a layer in order to display something
var layer:MassiveImageLayer = new MassiveImageLayer();
massive.addLayer(layer);

// we need to create Frame instances to display Massive's equivalent of Image
var textures = assetManager.getTextures("my-atlas-animation");
var frames = Frame.fromTextureVectorWithAlign(textures, Align.CENTER, Align.CENTER); // the Frame class offers various helper functions
// we also need timings to associate with those frames
var timings = Animator.generateTimings(frames);

// we're ready to display our animated "image"
var img:ImageData = new ImageData();
img.setFrames(frames, timings);
img.x = 200;
img.y = 100;
layer.addImage(img);

```
You can also look at the [samples](https://github.com/MatseFR/massive-starling/tree/main/samples) source code for starters
