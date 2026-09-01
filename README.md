# Massive
Massive is a high performance library for [Starling](https://github.com/openfl/starling), meant to render lots of quads (textured, animated) in a single `DisplayObject` very efficiently.

It's heavily inspired by the [FFParticleSystem](https://github.com/shin10/Starling-FFParticleSystem) lib by Michael Trenkler, which I [ported](https://github.com/MatseFR/starling-extension-FFParticleSystem) to haxe some years ago.

It's been tested on windows (haxelib version of hxcpp), html5 and air targets with the latest versions of OpenFL, Lime and Starling.

## Demos
[Benchmark](https://matse.skwatt.com/haxe/starling/massive/demo/) - compare Massive performance with classic Starling `Quad` and `MovieClip` ([README](https://github.com/MatseFR/massive-starling/tree/main/samples/demo))

[Hex Grid](https://matse.skwatt.com/haxe/starling/massive/hexgrid/) - display only a part of an hexagon map, move around with infinite scroll and interact with it ([README](https://github.com/MatseFR/massive-starling/tree/main/samples/MassiveHexGrid))

[Particle Editor](https://matse.skwatt.com/haxe/starling/massive/particles/editor/) - editor for Massive's `ParticleSystem` (WIP) ([README](https://github.com/MatseFR/massive-starling/tree/main/samples/particles/editor))

## Getting started
Massive is available on haxelib
```sh
haxelib install massive-starling
```
you can also use haxelib to install it directly from GitHub :
```sh
haxelib git massive-starling https://github.com/MatseFR/massive-starling
```
or download the Massive repo and then use haxelib to install it
```sh
haxelib dev massive-starling path/to/massive
```
To include Massive in an OpenFL project, add this line to your [_project.xml_](https://lime.openfl.org/docs/project-files/xml-format/) file:
```xml
<haxelib name="massive-starling" />
```

## Quick setup
Massive is meant to be as easy as possible to work with, startup Starling like you would normally do
```haxe
// first init Massive
// you only have to do this once, and currently you don't need it if you don't use multitexturing
// but later updates might rely on this for non-multitexturing stuff so it's safer to do it anyway
MassiveDisplay.init();

// after calling init you can immediately check how many textures you can use simultaneously in a single MassiveDisplay instance
// Typically you should be able to use up to 16 textures
var maxTextures:Int = MassiveDisplay.maxNumTextures;

// create a Massive DisplayObject
var massive:MassiveDisplay = new MassiveDisplay();
// by default a MassiveDisplay instance will have maxQuads set to MassiveConstants.MAX_QUADS (16383)
// you can set maxQuads to any number, but there will be a draw call every 16383 quads
// if you have more quads than the maxQuads value it will still work but the MassiveDisplay will have
// to reuse a VertexBuffer that was already used on the current frame and it will reduce performance significantly
// Basically maxQuads lets the MassiveDisplay object create the required amount of VertexBuffer for best performance
massive.maxQuads = 50000; // display up to 50000 quads
// we set the default texture
massive.texture = assetManager.getTextureAtlas("my-atlas").texture;
addChild(massive);

// note that we could add more textures !

// we need a container in order to display something, here we use a MixedContainer which can have containers and quads
var container:MixedContainer = new MixedContainer();
massive.addLayer(container);

// let's also create an ImgContainer, which is a bit faster than MixedContainer at rendering quads
var imgContainer:ImgContainer = new ImgContainer();
// add it to the MixedContainer (we could also add it to the MassiveDisplay as a layer)
container.addChild(imgContainer);

// now let's add an Img object, which is simply a textured quad
// with Massive you don't set textures on quads, but Frame objects
// the Frame class offers several static functions to create frames easily
// here we just create a frame with a centered pivot point
var texture:Texture = assetManager.getTexture("my-atlas-texture");
var frame:Frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
// you can pass the Frame object in the constructor or set img.frame
var img:Img = new Img(frame);

// we add the textured quad to the ImgContainer
imgContainer.addChild(img);

// now let's add a few Clip objects to demonstrate texture animation in Massive
// first we need to create Frame objects from the textures
var textures = assetManager.getTextures("my-atlas-animation");
var frames = Frame.fromTextureVectorWithAlign(textures, Align.CENTER, Align.CENTER);
// now we can create an Animation object using AnimUtils
var animation = AnimUtils.createAnimation(frames);
// create Clip objects, the same Animation can be shared amongst as many Clips as you want
var clip:Clip;
for (i in 0...1000)
{
  clip = new Clip();
  clip.play(animation);
  imgContainer.addChild(clip);
}

// note that we don't use multitexturing here : MassiveDisplay only has one texture
// with multitexturing, unless we want our image to use the first texture we would
// have to set the Img and Clips textureIndex
```
You can also look at the [samples](https://github.com/MatseFR/massive-starling/tree/main/samples) source code for starters

## Frequently Asked Questions
### Why is Massive so fast ?
There are several reasons to this :
- every object in a MassiveDisplay is batchable with the others, no need to check anything
- Massive display objects are simple : they only have x y position, x y offset, x y scaling, x y skewing, rotation, red/green/blue/alpha color + color offsets and visible properties. Those are public and changing their values doesn't trigger any additionnal code like setting vertex data etc They also aren't touchable, can't have individual blend modes or filters
- ByteArray is slow + on non-flash targets it needs to be copied before being sent to OpenGL. In Massive the ByteArray renderMode is only there to show that you shouldn't use ByteArray for that kind of stuff :)
