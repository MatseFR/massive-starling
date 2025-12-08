# Benchmark demo
A few things to better understand what's going on in the demo
For context my PC is quite old : i5-6500 CPU and geforce GTX 1060 3GB, if you have a powerful machine I guess your numbers will be quite different.
## Options
Those apply to both Classic and Massive.
### atlas
One might think that this is just for looks, but it's not ! The bird atlas has much bigger textures than the zombi one, and bigger texture will make the GPU struggle with fillrate (how many texels it has to draw) faster.
On my machine I get the same framerate for 4000 classic and massive clips with the bird atlas. This is because for me, in this configuration, GPU is the bottleneck. Massive is still costing *a lot* less CPU though.

### randomize alpha
This one only works with Massive if the `use color` option is on, otherwise there is no ARGB color information in the vertex data. `use color` has a noticeable impact on Massive performance so consider turning it off when you don't need it.

### randomize color
Same as alpha : it only works with Massive if the `use color` option is on.

### randomize rotation
Massive will skip some calculations when rotation == 0.0, sin and cos values are cached at start in a lookup table but it still has a cost. That cost varies with the amount of objects to render.

### scale
It can affect the fillrate, if I set the scale low enough using the bird atlas Massive starts to shine again with steady 60fps while classic starling stutters.

### Sprite3D
This option exists only to show that Massive display works with the 3D stuff in Starling

### BlurFilter
This option exists only to show that filters work with Massive display.
By default a MassiveDisplay instance will use stage bounds, on classic starling this is very costy because the filter will request the Sprite's bounds, and it will calculate those with thousands of child objects.
I think we should add a `useStageBounds` to Starling's filters : they have an optimization for bounds but only when they are applied to the Stage.
Anyway, don't use that option to measure a performance difference between Classic and Massive !

## Massive options
Those only apply to Massive.
### use color
This controls whether the `MassiveDisplay` instance has color information in the vertex data or not, when you're using a texture and you turn it off it will display the texture without any tinting or alpha. Turning it off boosts performance noticeably.

### use ByteArray
This makes the `MassiveDisplay` instance use a `ByteArray` instead of the default `Vector<Float>` (flash target) / `Array<Float>` (other targets).
In my experience this seems to be less costy on the GPU side on flash/air target (I guess because of a faster upload ?) but always ends up being slower because it costs a lot more on the CPU side. If you get different results I'd love to hear !

### use Float32Array (non-flash targets)
This makes the `MasiveDisplay` instance use a `Float32Array` instead of the default `Vector<Float>` (flash target) / `Array<Float>` (other targets).
This is the fastest option and the default setting on non-flash targets : it has a pretty big impact on performance at no noticeable cost.

### buffers
This makes the `MassiveDisplay` instance use only one or more `VertexBuffer3D`, cycling to another one after a render, but it doesn't seem to have any effect : let me know if it has for you !